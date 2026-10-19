# Windows PowerShell 5.1+, built-in .NET only. No HTTP retries or redirects.
Add-Type -AssemblyName System.Net.Http

function New-LabFailure {
    param([string]$Code, [int]$Status = 0)
    $e = New-Object System.InvalidOperationException("Lab03 $Code (HTTP $Status). See api-reference.md; request not replayed.")
    $e.Data['LabCode'] = $Code
    $e.Data['HttpStatus'] = $Status
    return $e
}

function Get-LabErrorCode {
    param([int]$Status)
    switch ($Status) {
        400 { 'BadRequest' } 401 { 'Unauthorized' } 403 { 'Forbidden' }
        404 { 'NotFound' } 422 { 'ExecutionError' } 423 { 'SessionBusy' }
        429 { 'RateLimited' } 500 { 'ServerErrorOrTimeout' }
        503 { 'Unavailable' } default { 'HttpError' }
    }
}

function New-LabLogRecord {
    param([ValidateSet('OAuth','Start','Sync','Stream','Feedback','End')][string]$Operation,
          [int]$Status, [double]$ElapsedMs)
    # Allowlist only. Never accept headers, URLs, credentials, prompts, or response bodies.
    [pscustomobject]@{ timeUtc = [DateTime]::UtcNow.ToString('o'); operation = $Operation
        status = $Status; elapsedMs = [Math]::Round($ElapsedMs); correlation = [guid]::NewGuid().ToString() }
}

function Read-LabSse {
    param([IO.TextReader]$Reader, [int]$TimeoutSeconds = 130)
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $data = New-Object 'System.Collections.Generic.List[string]'
    $eventName = ''; $seenEnd = $false; $total = 0
    while ($true) {
        $remaining = [int]($TimeoutSeconds * 1000 - $clock.ElapsedMilliseconds)
        if ($remaining -le 0) { throw (New-LabFailure 'TimeoutUnknownOutcome') }
        $task = $Reader.ReadLineAsync()
        if (-not $task.Wait($remaining)) { throw (New-LabFailure 'TimeoutUnknownOutcome') }
        $line = $task.GetAwaiter().GetResult()
        if ($null -eq $line) { break }
        $total += $line.Length
        if ($total -gt 1048576) { throw (New-LabFailure 'ResponseTooLarge') }
        if ($line -eq '') {
            if ($data.Count -gt 0) {
                try { $payload = ($data -join "`n") | ConvertFrom-Json -ErrorAction Stop }
                catch { throw (New-LabFailure 'InvalidStreamJson') }
                $kind = $eventName
                if (-not $kind -or $kind -eq 'message') { $kind = [string]$payload.type }
                if (-not $kind -and $payload.message) { $kind = [string]$payload.message.type }
                [pscustomobject]@{ Event = $kind; Data = $payload }
                if ($kind -eq 'EndOfTurn') { $seenEnd = $true; break }
                $data.Clear(); $eventName = ''
            }
            continue
        }
        if ($line.StartsWith(':')) { continue }
        if ($line.StartsWith('event:')) { $eventName = $line.Substring(6).TrimStart(' ') }
        if ($line.StartsWith('data:')) { $data.Add($line.Substring(5).TrimStart(' ')) }
        # id and retry fields do not authorize reconnecting/replaying a POST.
    }
    if (-not $seenEnd) { throw (New-LabFailure 'IncompleteStreamUnknownOutcome') }
}

function Invoke-LabHttp {
    param($Request, $HttpHandler = $null)
    $handler = $HttpHandler
    if ($null -eq $handler) {
        $handler = New-Object Net.Http.HttpClientHandler
        $handler.AllowAutoRedirect = $false
    }
    $client = New-Object Net.Http.HttpClient($handler)
    $client.Timeout = [TimeSpan]::FromSeconds($Request.TimeoutSeconds)
    $http = New-Object Net.Http.HttpRequestMessage([Net.Http.HttpMethod]::new($Request.Method), $Request.Url)
    $response = $null; $reader = $null
    try {
        foreach ($key in $Request.Headers.Keys) { [void]$http.Headers.TryAddWithoutValidation($key, $Request.Headers[$key]) }
        if ($null -ne $Request.Body) {
            $http.Content = New-Object Net.Http.StringContent($Request.Body, [Text.Encoding]::UTF8, $Request.ContentType)
        }
        $response = $client.SendAsync($http, [Net.Http.HttpCompletionOption]::ResponseHeadersRead).GetAwaiter().GetResult()
        $status = [int]$response.StatusCode
        # Error bodies may echo tokens or user input. Deliberately do not read/log them.
        if ($status -lt 200 -or $status -ge 300) {
            return [pscustomobject]@{ Status = $status; Body = $null; Events = @() }
        }
        if ($Request.Stream) {
            if ($response.Content.Headers.ContentType.MediaType -ne 'text/event-stream') { throw (New-LabFailure 'UnexpectedContentType') }
            $reader = New-Object IO.StreamReader($response.Content.ReadAsStreamAsync().GetAwaiter().GetResult(), [Text.Encoding]::UTF8)
            $events = @(Read-LabSse $reader $Request.TimeoutSeconds)
            return [pscustomobject]@{ Status = $status; Body = $null; Events = $events }
        }
        $read = $response.Content.ReadAsStringAsync()
        if (-not $read.Wait($Request.TimeoutSeconds * 1000)) { throw (New-LabFailure 'TimeoutUnknownOutcome') }
        $body = $read.GetAwaiter().GetResult()
        if ($body.Length -gt 1048576) { throw (New-LabFailure 'ResponseTooLarge') }
        return [pscustomobject]@{ Status = $status; Body = $body; Events = @() }
    } catch {
        if ($_.Exception.Data['LabCode']) { throw $_.Exception }
        throw (New-LabFailure 'TransportFailureUnknownOutcome')
    } finally {
        if ($reader) { $reader.Dispose() }
        if ($response) { $response.Dispose() }
        $http.Dispose(); $client.Dispose(); $handler.Dispose()
    }
}

function Invoke-LabRequest {
    param($Context, [string]$Operation, [string]$Method, [string]$Url,
          [hashtable]$Headers, $Body = $null, [string]$ContentType = 'application/json', [switch]$Stream)
    $request = [pscustomobject]@{ Method = $Method; Url = $Url; Headers = $Headers; Body = $Body
        ContentType = $ContentType; Stream = [bool]$Stream; TimeoutSeconds = $Context.TimeoutSeconds }
    $clock = [Diagnostics.Stopwatch]::StartNew(); $status = 0
    try {
        # Injectable transport is used by offline unit tests. Exactly one attempt.
        $response = & $Context.Transport $request
        $status = [int]$response.Status
        if ($status -lt 200 -or $status -ge 300) { throw (New-LabFailure (Get-LabErrorCode $status) $status) }
        return $response
    } catch {
        if ($_.Exception.Data['LabCode']) { throw $_.Exception }
        throw (New-LabFailure 'TransportFailureUnknownOutcome')
    } finally {
        [void]$Context.Log.Add((New-LabLogRecord $Operation $status $clock.Elapsed.TotalMilliseconds))
    }
}

function ConvertFrom-LabJson {
    param([string]$Body)
    try { return ($Body | ConvertFrom-Json -ErrorAction Stop) }
    catch { throw (New-LabFailure 'InvalidJson') }
}

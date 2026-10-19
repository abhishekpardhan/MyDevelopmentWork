# Offline mock HTTP tests. No credentials, network, Pester, or package installation.
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../scripts/Transport.ps1"
. "$PSScriptRoot/../scripts/Auth.ps1"
. "$PSScriptRoot/../scripts/Session.ps1"
$script:passed = 0; $script:failed = 0
function Assert-Lab($Condition) { if (-not $Condition) { throw 'Assertion failed' } }
function Assert-LabThrows([scriptblock]$Action, [string]$Code) {
    $thrown = $false
    try { $null = & $Action } catch {
        $thrown = $true
        Assert-Lab ($_.Exception.Data['LabCode'] -eq $Code)
    }
    Assert-Lab $thrown
}
function Test-Lab([string]$Name, [scriptblock]$Action) {
    try { & $Action; $script:passed++; Write-Output "PASS $Name" }
    catch { $script:failed++; Write-Output "FAIL $Name" }
}
function New-MockContext {
    $script:requests = New-Object 'System.Collections.Generic.List[object]'
    $script:responses = New-Object System.Collections.Queue
    $c = New-LabContext @{ Domain = 'https://example.my.salesforce.com'; ClientId = 'fixture-key+&'; ClientSecret = 'fixture-secret+&'
        AgentId = '0Xx000000000001AAA'; AgentType = 'AgentforceEmployeeAgent'; BypassUser = $false } {
        param($r)
        $script:requests.Add($r)
        if ($script:responses.Count -eq 0) { throw 'Unexpected HTTP call' }
        $next = $script:responses.Dequeue()
        if ($next -is [Exception]) { throw $next }
        return $next
    }
    $c.Token = 'fixture-access-token'
    return $c
}
function Add-Mock([int]$Status = 200, [string]$Body = '{}', $Events = @()) {
    $script:responses.Enqueue([pscustomobject]@{ Status = $Status; Body = $Body; Events = $Events })
}
function Set-Active($c) { $c.SessionId = 'fixture-session'; $c.State = 'Active' }

Test-Lab 'OAuth form encoding and token kept off pipeline' {
    $c = New-MockContext; Add-Mock 200 '{"access_token":"fixture-new-token"}'
    $out = Get-LabToken $c
    Assert-Lab ($null -eq $out -and $c.Token -eq 'fixture-new-token')
    Assert-Lab ($script:requests[0].Body -match 'fixture-secret%2B%26')
    Assert-Lab ($script:requests[0].Url -eq 'https://example.my.salesforce.com/services/oauth2/token')
}
Test-Lab 'OAuth rejection sanitized' {
    $c = New-MockContext; Add-Mock 400 'fixture-secret'; Assert-LabThrows { Get-LabToken $c } 'BadRequest'
}
Test-Lab 'Missing access token in OAuth response' {
    $c = New-MockContext; Add-Mock; Assert-LabThrows { Get-LabToken $c } 'MissingAccessToken'
}
Test-Lab 'Missing bearer token blocks HTTP' {
    $c = New-MockContext; $c.Token = $null; Assert-LabThrows { Start-LabSession $c } 'MissingToken'
    Assert-Lab ($script:requests.Count -eq 0)
}
Test-Lab 'Start creates UUID and boolean identity' {
    $c = New-MockContext; Add-Mock 200 '{"sessionId":"session-1"}'; Start-LabSession $c
    $b = $script:requests[0].Body | ConvertFrom-Json
    Assert-Lab ([guid]::Parse($b.externalSessionKey) -ne [guid]::Empty)
    Assert-Lab ($b.bypassUser -is [bool] -and -not $b.bypassUser -and $c.State -eq 'Active')
}
Test-Lab 'Missing session ID fails closed' {
    $c = New-MockContext; Add-Mock; Assert-LabThrows { Start-LabSession $c } 'MissingOrInvalidSessionId'
    Assert-Lab ($c.State -eq 'Unknown')
}
Test-Lab 'Invalid agent ID server error' {
    $c = New-MockContext; Add-Mock 400; Assert-LabThrows { Start-LabSession $c } 'BadRequest'
}
Test-Lab 'Sync payload and authorization header' {
    $c = New-MockContext; Set-Active $c; Add-Mock 200 '{"messages":[{"type":"Inform","message":"sample"}]}'
    $r = Send-LabMessage $c 'fictional prompt'; $b = $script:requests[0].Body | ConvertFrom-Json
    Assert-Lab ($b.message.type -eq 'Text' -and $b.message.sequenceId -eq 1)
    Assert-Lab ($script:requests[0].Headers.Authorization -eq 'Bearer fixture-access-token' -and $r.messages.Count -eq 1)
}
Test-Lab 'Multiple messages ordered in one session' {
    $c = New-MockContext; Set-Active $c; Add-Mock; Add-Mock
    $null = Send-LabMessage $c 'fictional origin'; $null = Send-LabMessage $c 'change fictional destination'
    Assert-Lab (($script:requests[1].Body | ConvertFrom-Json).message.sequenceId -eq 2)
    Assert-Lab ($script:requests[0].Url -eq $script:requests[1].Url)
}
Test-Lab 'SSE parsing with comments multiline data and CRLF' {
    $sse = ": keepalive`r`nevent: Inform`r`ndata: {`r`ndata: `"message`": `"sample`"}`r`n`r`nevent: EndOfTurn`r`ndata: {}`r`n`r`n"
    $r = @(Read-LabSse (New-Object IO.StringReader($sse)))
    Assert-Lab ($r.Count -eq 2 -and $r[0].Data.message -eq 'sample')
}
Test-Lab 'Streaming endpoint and accept header' {
    $c = New-MockContext; Set-Active $c
    Add-Mock 200 '' @([pscustomobject]@{Event='EndOfTurn'; Data=@{}})
    $null = Send-LabMessage $c 'sample' -Stream
    Assert-Lab ($script:requests[0].Url.EndsWith('/messages/stream') -and $script:requests[0].Headers.Accept -eq 'text/event-stream')
}
Test-Lab 'Validation failure removes earlier stream chunks' {
    $c = New-MockContext; Set-Active $c
    Add-Mock 200 '' @([pscustomobject]@{Event='TextChunk';Data=@{text='discard'}},[pscustomobject]@{Event='ValidationFailureChunk';Data=@{}},[pscustomobject]@{Event='EndOfTurn';Data=@{}})
    $r = Send-LabMessage $c 'sample' -Stream
    Assert-Lab ($r.Events.Count -eq 2 -and $r.Events[0].Event -eq 'ValidationFailureChunk')
}
Test-Lab 'Truncated stream detected' {
    Assert-LabThrows { Read-LabSse (New-Object IO.StringReader("event: TextChunk`ndata: {}`n`n")) } 'IncompleteStreamUnknownOutcome'
}
Test-Lab 'Malformed SSE JSON rejected without echo' {
    Assert-LabThrows { Read-LabSse (New-Object IO.StringReader("event: Inform`ndata: fixture-secret`n`n")) } 'InvalidStreamJson'
}
Test-Lab 'HTTP 423 not retried' {
    $c = New-MockContext; Set-Active $c; Add-Mock 423
    Assert-LabThrows { Send-LabMessage $c 'sample' } 'SessionBusy'
    Assert-Lab ($script:requests.Count -eq 1 -and $c.State -eq 'Unknown')
}
Test-Lab 'HTTP 429 not retried' {
    $c = New-MockContext; Set-Active $c; Add-Mock 429
    Assert-LabThrows { Send-LabMessage $c 'sample' } 'RateLimited'; Assert-Lab ($script:requests.Count -eq 1)
}
Test-Lab 'Expired token 401 not silently replayed' {
    $c = New-MockContext; Set-Active $c; Add-Mock 401
    Assert-LabThrows { Send-LabMessage $c 'sample' } 'Unauthorized'; Assert-Lab ($script:requests.Count -eq 1)
}
Test-Lab 'Timeout unknown outcome no retry' {
    $c = New-MockContext; Set-Active $c; $script:responses.Enqueue((New-LabFailure 'TimeoutUnknownOutcome'))
    Assert-LabThrows { Send-LabMessage $c 'sample' } 'TimeoutUnknownOutcome'; Assert-Lab ($script:requests.Count -eq 1)
}
Test-Lab 'HTTP error classifications' {
    foreach ($pair in @(@(403,'Forbidden'),@(404,'NotFound'),@(422,'ExecutionError'),@(500,'ServerErrorOrTimeout'),@(503,'Unavailable'))) {
        Assert-Lab ((Get-LabErrorCode $pair[0]) -eq $pair[1])
    }
}
Test-Lab 'Feedback uses generation feedback ID' {
    $c = New-MockContext; Set-Active $c; Add-Mock 202
    $status = Submit-LabFeedback $c 'generation-feedback-1' 'GOOD'
    Assert-Lab ($status -eq 202 -and ($script:requests[0].Body | ConvertFrom-Json).feedbackId -eq 'generation-feedback-1')
}
Test-Lab 'Missing feedback ID rejected' {
    $c = New-MockContext; Set-Active $c; Assert-LabThrows { Submit-LabFeedback $c '' 'GOOD' } 'MissingFeedbackId'
}
Test-Lab 'End session method and reason' {
    $c = New-MockContext; Set-Active $c; Add-Mock; Close-LabSession $c
    Assert-Lab ($script:requests[0].Method -eq 'DELETE' -and $script:requests[0].Headers['x-session-end-reason'] -eq 'UserRequest' -and $c.State -eq 'Closed')
}
Test-Lab 'Sending after end blocked locally' {
    $c = New-MockContext; Set-Active $c; $c.State = 'Closed'
    Assert-LabThrows { Send-LabMessage $c 'sample' } 'NoActiveSession'; Assert-Lab ($script:requests.Count -eq 0)
}
Test-Lab 'Cleanup on conversation failure clears token' {
    $c = New-MockContext; Add-Mock 200 '{"sessionId":"s-1"}'; Add-Mock
    Assert-LabThrows { Invoke-LabConversation $c { param($x) throw (New-LabFailure 'SyntheticFailure') } } 'SyntheticFailure'
    Assert-Lab ($c.State -eq 'Closed' -and $null -eq $c.Token -and $script:requests.Count -eq 2)
}
Test-Lab 'Cleanup failure remains visible' {
    $c = New-MockContext; Add-Mock 200 '{"sessionId":"s-1"}'; Add-Mock 503
    Assert-LabThrows { Invoke-LabConversation $c { param($x) } } 'Unavailable'
    Assert-Lab ($c.State -eq 'CloseFailed' -and $null -eq $c.Token)
}
Test-Lab 'Sensitive data excluded from logs and errors' {
    $c = New-MockContext; Set-Active $c; Add-Mock 500 'fixture-secret email@example.com confidential shipment'
    $safe = ''
    try { $null = Send-LabMessage $c 'email@example.com confidential shipment' } catch { $safe = $_.Exception.Message }
    $safe += ($c.Log | ConvertTo-Json)
    Assert-Lab ($safe -notmatch 'fixture|email@|confidential|Authorization|Bearer')
}
Test-Lab 'Invalid JSON does not echo payload' {
    Assert-LabThrows { ConvertFrom-LabJson 'fixture-secret' } 'InvalidJson'
}

# Environment validation fixtures restore the caller's values; never display them.
$keys = @('SF_MY_DOMAIN','SF_CLIENT_ID','SF_CLIENT_SECRET','SF_AGENT_ID','SF_AGENT_TYPE','SF_BYPASS_USER')
$saved = @{}; foreach ($key in $keys) { $saved[$key] = [Environment]::GetEnvironmentVariable($key) }
try {
    $env:SF_MY_DOMAIN = 'https://example.my.salesforce.com'; $env:SF_CLIENT_ID = 'fixture-key'
    $env:SF_CLIENT_SECRET = 'fixture-secret'; $env:SF_AGENT_ID = '0Xx000000000001AAA'
    $env:SF_AGENT_TYPE = 'AgentforceEmployeeAgent'; $env:SF_BYPASS_USER = 'false'
    Test-Lab 'Employee execution identity explicitly false' { Assert-Lab (-not (Get-LabEnvironment).BypassUser) }
    Test-Lab 'Unsupported Default agent rejected' {
        $env:SF_AGENT_TYPE = 'Agentforce (Default)'; Assert-LabThrows { Get-LabEnvironment } 'UnsupportedAgentType'
        $env:SF_AGENT_TYPE = 'AgentforceEmployeeAgent'
    }
    Test-Lab 'Employee assigned identity refused by lab policy' {
        $env:SF_BYPASS_USER = 'true'; Assert-LabThrows { Get-LabEnvironment } 'EmployeeRequiresTokenIdentity'; $env:SF_BYPASS_USER = 'false'
    }
    Test-Lab 'Invalid ID configuration rejected before HTTP' {
        $env:SF_AGENT_ID = 'not-an-id'; Assert-LabThrows { Get-LabEnvironment } 'InvalidAgentId'; $env:SF_AGENT_ID = '0Xx000000000001AAA'
    }
    Test-Lab 'Host allowlist rejects secret exfiltration URL' {
        $env:SF_MY_DOMAIN = 'https://example.evil.invalid'; Assert-LabThrows { Get-LabEnvironment } 'InvalidMyDomain'
        $env:SF_MY_DOMAIN = 'https://example.my.salesforce.com'
    }
} finally { foreach ($key in $keys) { [Environment]::SetEnvironmentVariable($key,$saved[$key]) } }

Test-Lab 'Real concurrent gate rejects overlapping request' {
    $c = New-MockContext; Set-Active $c
    $ready = New-Object Threading.ManualResetEventSlim($false)
    $release = New-Object Threading.ManualResetEventSlim($false)
    $worker = [PowerShell]::Create()
    [void]$worker.AddScript('param($gate,$ready,$release) [Threading.Monitor]::Enter($gate); try { $ready.Set(); $release.Wait() } finally { [Threading.Monitor]::Exit($gate) }').AddArgument($c.Gate).AddArgument($ready).AddArgument($release)
    $job = $worker.BeginInvoke()
    try {
        Assert-Lab ($ready.Wait(5000))
        Assert-LabThrows { Send-LabMessage $c 'sample' } 'LocalSessionBusy'
        Assert-Lab ($script:requests.Count -eq 0)
    } finally { $release.Set(); $null = $worker.EndInvoke($job); $worker.Dispose(); $ready.Dispose(); $release.Dispose() }
}
# Exercise the actual .NET transport with an in-process fake HttpMessageHandler.
# No listening port, external host, credentials, or package is involved.
Add-Type -ReferencedAssemblies System.Net.Http -TypeDefinition @'
using System.Net;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;
public class Lab03FakeHandler : HttpMessageHandler {
    public int Code = 200;
    public string Body = "{}";
    public string Media = "application/json";
    public string SentBody;
    public string SentAuth;
    protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage r, CancellationToken c) {
        SentBody = r.Content == null ? null : r.Content.ReadAsStringAsync().Result;
        SentAuth = r.Headers.Authorization == null ? null : r.Headers.Authorization.ToString();
        return Task.FromResult(new HttpResponseMessage((HttpStatusCode)Code) {
            Content = new StringContent(Body, System.Text.Encoding.UTF8, Media)
        });
    }
}
'@
Test-Lab 'Actual dotnet transport JSON body and bearer serialization' {
    $h = New-Object Lab03FakeHandler; $h.Body = '{"messages":[]}'
    $r = Invoke-LabHttp ([pscustomobject]@{Method='POST';Url='https://example.invalid/';Headers=@{Authorization='Bearer fixture'};Body='{"message":{}}';ContentType='application/json';Stream=$false;TimeoutSeconds=2}) $h
    Assert-Lab ($r.Status -eq 200 -and $h.SentBody -eq '{"message":{}}' -and $h.SentAuth -eq 'Bearer fixture')
}
Test-Lab 'Actual dotnet transport consumes SSE' {
    $h = New-Object Lab03FakeHandler; $h.Media = 'text/event-stream'
    $h.Body = "event: EndOfTurn`ndata: {}`n`n"
    $r = Invoke-LabHttp ([pscustomobject]@{Method='POST';Url='https://example.invalid/';Headers=@{Accept='text/event-stream'};Body='{}';ContentType='application/json';Stream=$true;TimeoutSeconds=2}) $h
    Assert-Lab ($r.Events.Count -eq 1 -and $r.Events[0].Event -eq 'EndOfTurn')
}
Test-Lab 'Actual dotnet transport omits error response body' {
    $h = New-Object Lab03FakeHandler; $h.Code = 401; $h.Body = 'fixture-secret'
    $r = Invoke-LabHttp ([pscustomobject]@{Method='POST';Url='https://example.invalid/';Headers=@{};Body='{}';ContentType='application/json';Stream=$false;TimeoutSeconds=2}) $h
    Assert-Lab ($r.Status -eq 401 -and $null -eq $r.Body)
}
Test-Lab 'SSE generic message envelope ends correctly' {
    $r = @(Read-LabSse (New-Object IO.StringReader("event: message`ndata: {`"type`":`"EndOfTurn`"}`n`n")))
    Assert-Lab ($r[0].Event -eq 'EndOfTurn')
}
Test-Lab 'Testing XML fixture parses with required documented fields' {
    $xml = [xml](Get-Content "$PSScriptRoot/Lab03_Logistics.aiEvaluationDefinition-meta.xml.example" -Raw)
    Assert-Lab ($xml.AiEvaluationDefinition.subjectType -eq 'AGENT' -and $xml.AiEvaluationDefinition.testCase.inputs.utterance)
}
Write-Output "RESULT: $script:passed PASS, $script:failed FAIL. Offline mocks only."
if ($script:failed -gt 0) { exit 1 }

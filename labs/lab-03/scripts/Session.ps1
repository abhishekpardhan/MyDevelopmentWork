function New-LabContext {
    param([hashtable]$Config, [scriptblock]$Transport = { param($r) Invoke-LabHttp $r })
    return @{ Config = $Config; Transport = $Transport; TimeoutSeconds = 130; Token = $null
        SessionId = $null; Sequence = 0; State = 'New'; Gate = (New-Object object)
        Log = (New-Object 'System.Collections.Generic.List[object]')
        Base = 'https://api.salesforce.com/einstein/ai-agent/v1' }
}

function Enter-LabSession {
    param($Context)
    if (-not [Threading.Monitor]::TryEnter($Context.Gate)) { throw (New-LabFailure 'LocalSessionBusy') }
}

function Start-LabSession {
    param($Context)
    Enter-LabSession $Context
    try {
        if ($Context.State -ne 'New') { throw (New-LabFailure 'SessionAlreadyStarted') }
        $headers = Get-LabHeaders $Context
        $body = @{ externalSessionKey = [guid]::NewGuid().ToString(); instanceConfig = @{ endpoint = $Context.Config.Domain }
            streamingCapabilities = @{ chunkTypes = @('Text') }; bypassUser = [bool]$Context.Config.BypassUser }
        $Context.State = 'Starting'
        $r = Invoke-LabRequest $Context 'Start' 'POST' ($Context.Base + '/agents/' + $Context.Config.AgentId + '/sessions') $headers ($body | ConvertTo-Json -Depth 10 -Compress)
        $result = ConvertFrom-LabJson $r.Body
        if (-not $result.sessionId -or [string]$result.sessionId -notmatch '^[a-zA-Z0-9-]+$') { throw (New-LabFailure 'MissingOrInvalidSessionId') }
        $Context.SessionId = [string]$result.sessionId; $Context.State = 'Active'
    } catch {
        if ($Context.State -eq 'Starting') { $Context.State = 'Unknown' }
        throw
    } finally { [Threading.Monitor]::Exit($Context.Gate) }
}

function Send-LabMessage {
    param($Context, [string]$Text, [switch]$Stream)
    Enter-LabSession $Context
    try {
        if ($Context.State -ne 'Active' -or -not $Context.SessionId) { throw (New-LabFailure 'NoActiveSession') }
        if ([string]::IsNullOrWhiteSpace($Text)) { throw (New-LabFailure 'EmptyMessage') }
        $headers = Get-LabHeaders $Context
        $Context.Sequence++
        $body = @{ message = @{ type = 'Text'; sequenceId = $Context.Sequence; text = $Text } }
        $url = $Context.Base + '/sessions/' + $Context.SessionId + '/messages'
        $operation = 'Sync'
        if ($Stream) { $url += '/stream'; $headers.Accept = 'text/event-stream'; $operation = 'Stream' }
        try {
            $r = Invoke-LabRequest $Context $operation 'POST' $url $headers ($body | ConvertTo-Json -Depth 10 -Compress) -Stream:$Stream
            if ($Stream) {
                # Do not render unvalidated text chunks. ValidationFailureChunk clears prior output.
                $accepted = New-Object 'System.Collections.Generic.List[object]'
                foreach ($event in $r.Events) {
                    if ($event.Event -eq 'ValidationFailureChunk') { $accepted.Clear() }
                    $accepted.Add($event)
                }
                return [pscustomobject]@{ Events = @($accepted.ToArray()) }
            }
            return (ConvertFrom-LabJson $r.Body)
        } catch { $Context.State = 'Unknown'; throw }
    } finally { [Threading.Monitor]::Exit($Context.Gate) }
}

function Submit-LabFeedback {
    param($Context, [string]$FeedbackId, [ValidateSet('GOOD','BAD')][string]$Rating)
    Enter-LabSession $Context
    try {
        if ($Context.State -ne 'Active') { throw (New-LabFailure 'NoActiveSession') }
        if ($FeedbackId -notmatch '^[a-zA-Z0-9-]+$') { throw (New-LabFailure 'MissingFeedbackId') }
        $body = @{ feedbackId = $FeedbackId; feedback = $Rating }
        # Use feedbackId returned by the generation, never a random replacement ID.
        $r = Invoke-LabRequest $Context 'Feedback' 'POST' ($Context.Base + '/sessions/' + $Context.SessionId + '/feedback') (Get-LabHeaders $Context) ($body | ConvertTo-Json -Compress)
        return $r.Status
    } finally { [Threading.Monitor]::Exit($Context.Gate) }
}

function Close-LabSession {
    param($Context)
    Enter-LabSession $Context
    try {
        if (-not $Context.SessionId -or $Context.State -eq 'Closed') { return }
        $h = Get-LabHeaders $Context; $h['x-session-end-reason'] = 'UserRequest'
        try {
            $null = Invoke-LabRequest $Context 'End' 'DELETE' ($Context.Base + '/sessions/' + $Context.SessionId) $h
            $Context.State = 'Closed'
        } catch { $Context.State = 'CloseFailed'; throw }
    } finally { [Threading.Monitor]::Exit($Context.Gate) }
}

function Invoke-LabConversation {
    param($Context, [scriptblock]$Conversation)
    try { Start-LabSession $Context; & $Conversation $Context }
    finally {
        try { Close-LabSession $Context }
        finally { $Context.Token = $null }
    }
}

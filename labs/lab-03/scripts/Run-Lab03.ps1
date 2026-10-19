[CmdletBinding()]
param([switch]$LiveApproved, [switch]$FeedbackApproved)
$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/Transport.ps1"
. "$PSScriptRoot/Auth.ps1"
. "$PSScriptRoot/Session.ps1"
if (-not $LiveApproved) {
    Write-Output 'NOT TESTED: no network requests. Approve prerequisites and credit usage before using -LiveApproved.'
    return
}
$context = $null
try {
    $config = Get-LabEnvironment
    $context = New-LabContext $config
    Get-LabToken $context
    $conversation = {
        param($c)
        $first = Send-LabMessage $c 'Fictional training example only: Sample Company A ships 100 kg of cartons from Delhi to Pune weekly. What details are missing?'
        Write-Output ('Sync response received; message count: ' + @($first.messages).Count)
        $second = Send-LabMessage $c 'For the same fictional inquiry, change the destination to Jaipur and summarize the details.'
        Write-Output ('Multi-turn response received; message count: ' + @($second.messages).Count)
        $stream = Send-LabMessage $c 'Draft a short follow-up for this fictional inquiry. Do not send it.' -Stream
        Write-Output ('Streaming response received; accepted event count: ' + @($stream.Events).Count)
        if ($FeedbackApproved) {
            $feedback = @($first.messages | Where-Object { $_.feedbackId } | Select-Object -First 1)
            if ($feedback.Count -eq 0) { throw (New-LabFailure 'NoGenerationFeedbackId') }
            $status = Submit-LabFeedback $c $feedback[0].feedbackId 'GOOD'
            Write-Output ('Feedback accepted; HTTP ' + $status)
        }
    }
    Invoke-LabConversation $context $conversation
    Write-Output 'PASS: session ended. Transport success alone does not establish answer quality.'
} catch {
    # Never print exception body, server messages, command arguments, or stack traces.
    $code = $_.Exception.Data['LabCode']; if (-not $code) { $code = 'UnexpectedLocalFailure' }
    Write-Output ('FAIL: ' + $code + '. See api-reference.md. No automatic replay.')
    if ($context -and $context.State -eq 'CloseFailed') { Write-Output 'Session cleanup could not be confirmed; do not assume the session closed.' }
    exit 1
} finally {
    if ($context) {
        $context.Token = $null
        $context.Config.ClientSecret = $null; $context.Config.ClientId = $null
        $context.Log | ConvertTo-Json -Depth 4
    }
}

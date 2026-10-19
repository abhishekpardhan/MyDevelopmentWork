function Get-LabEnvironment {
    $domain = [Environment]::GetEnvironmentVariable('SF_MY_DOMAIN')
    $id = [Environment]::GetEnvironmentVariable('SF_CLIENT_ID')
    $secret = [Environment]::GetEnvironmentVariable('SF_CLIENT_SECRET')
    $agent = [Environment]::GetEnvironmentVariable('SF_AGENT_ID')
    $type = [Environment]::GetEnvironmentVariable('SF_AGENT_TYPE')
    $bypass = [Environment]::GetEnvironmentVariable('SF_BYPASS_USER')
    if (-not $id -or -not $secret) { throw (New-LabFailure 'MissingCredentials') }
    if ($domain -notmatch '^https://[a-zA-Z0-9.-]+\.my\.salesforce\.com/?$') { throw (New-LabFailure 'InvalidMyDomain') }
    if ($agent -notmatch '^0Xx[a-zA-Z0-9]{12}([a-zA-Z0-9]{3})?$') { throw (New-LabFailure 'InvalidAgentId') }
    if ($type -notin @('AgentforceEmployeeAgent','AgentforceServiceAgent')) { throw (New-LabFailure 'UnsupportedAgentType') }
    if ($bypass -notin @('true','false')) { throw (New-LabFailure 'ExplicitIdentityRequired') }
    if ($type -eq 'AgentforceEmployeeAgent' -and $bypass -eq 'true') { throw (New-LabFailure 'EmployeeRequiresTokenIdentity') }
    return @{ Domain = $domain.TrimEnd('/'); ClientId = $id; ClientSecret = $secret; AgentId = $agent
        AgentType = $type; BypassUser = ($bypass -eq 'true') }
}

function Get-LabToken {
    param($Context)
    $c = $Context.Config
    $body = 'grant_type=client_credentials&client_id=' + [uri]::EscapeDataString($c.ClientId) + '&client_secret=' + [uri]::EscapeDataString($c.ClientSecret)
    $r = Invoke-LabRequest $Context 'OAuth' 'POST' ($c.Domain + '/services/oauth2/token') @{} $body 'application/x-www-form-urlencoded'
    $token = ConvertFrom-LabJson $r.Body
    if (-not $token.access_token) { throw (New-LabFailure 'MissingAccessToken') }
    $Context.Token = [string]$token.access_token
    # No token or complete OAuth response is returned to the pipeline or persisted.
}

function Get-LabHeaders {
    param($Context)
    if (-not $Context.Token) { throw (New-LabFailure 'MissingToken') }
    return @{ Authorization = 'Bearer ' + $Context.Token; Accept = 'application/json' }
}

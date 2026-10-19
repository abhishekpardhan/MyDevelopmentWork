# Lab 03: Agentforce APIs and SDKs

Learn how an external program authenticates, opens a conversation, preserves context, receives responses, and closes the conversation. The client uses fictional logistics prompts only. Everything created by this lab is under `labs/lab-03`; Labs 01/02 and agent metadata remain unchanged. Lab 02 files were not found in this checkout.

**Ready:** Windows PowerShell client, offline mock tests, documentation, and non-deployed examples. **Blocked for live use:** Lab 01 is unpublished/inactive with no runtime agent ID; no External Client App was returned; credentials, permissions, and credit approval are not configured/verified. No live Agent API, SDK, or Testing API execution occurred.

Read in order:

1. [Findings and feature applicability](findings.md)
2. [Architecture](architecture.md)
3. [Prerequisites](prerequisites.md) and [authentication](authentication.md)
4. [API reference and failure handling](api-reference.md)
5. [SDK examples](sdk/README.md), [Testing API](tests/testing-api.md), and [Flow/Apex invocation](invocation.md)
6. [Test cases](test-cases.md) and [validation evidence](validation.md)

## Run safely now - no network or credentials

From the existing repository root:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\labs\lab-03\tests\Run-UnitTests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\labs\lab-03\scripts\Run-Lab03.ps1
```

ExecutionPolicy Bypass applies only to that child PowerShell process; it does not persist a machine/user policy change. It is used because the current shell blocks script files. Follow your organization's policy if that override is prohibited. No Pester, Python, npm, or other package is needed. The client without `-LiveApproved` is a no-op plan.

## After you explicitly approve and complete prerequisite setup

First approve publication/activation of the existing Lab 01 agent, an ECA configuration with the reviewed identity, and the bounded live exercise. Do not substitute a business agent. Obtain the actual BotDefinition ID as described in prerequisites.md. Do not put credentials directly into typed shell commands or source files.

```powershell
$env:SF_MY_DOMAIN = Read-Host 'Approved HTTPS My Domain URL (not a Lightning URL)'
$env:SF_AGENT_ID = Read-Host 'Published Lab 01 BotDefinition ID'
$env:SF_AGENT_TYPE = 'AgentforceEmployeeAgent'
$env:SF_BYPASS_USER = 'false'
$env:SF_CLIENT_ID = [Net.NetworkCredential]::new('', (Read-Host 'ECA consumer key' -AsSecureString)).Password
$env:SF_CLIENT_SECRET = [Net.NetworkCredential]::new('', (Read-Host 'ECA consumer secret' -AsSecureString)).Password
try {
    powershell -NoProfile -ExecutionPolicy Bypass -File .\labs\lab-03\scripts\Run-Lab03.ps1 -LiveApproved
} finally {
    Remove-Item Env:SF_CLIENT_ID, Env:SF_CLIENT_SECRET -ErrorAction SilentlyContinue
}
```

This makes one token request, one session-start request, two synchronous messages, one streaming message, and attempts session termination in `finally`. It does not assume these operations are free. It does not automatically retry failed conversations. Default console output includes only counts and allowlisted telemetry, not generated text or raw errors. A transport pass is not a pass for answer quality.

If you also approve storing synthetic feedback in Data 360, rerun with `-LiveApproved -FeedbackApproved`. This creates a new conversation and submits GOOD feedback using the first response's returned feedbackId. It is not included by default.

For a debugger-based learning exercise, the session functions return responses in memory. Review the response for factual limits/context manually without dumping it to the console or committing it. Do not enable PowerShell transcripts or verbose HTTP tracing around credentials. `.env.example` documents names only; the client does not load `.env`.

Stop after Lab 03. Remaining exercises require the approvals and eligibility checks documented here.

# Validation and executed-command record

Date: 2026-10-16. No live conversational/inference requests, OAuth token requests, package installation, ECA setup, deployments, activation, or record mutations were executed in Lab 03.

## Results

- PASS: PowerShell syntax parsing of the client scripts.
- PASS: final 38 offline tests, 0 failures, using injected mock HTTP responses, a fake .NET HttpMessageHandler exercising the actual transport, and an actual local concurrency gate. No credentials/network required.
- PASS: non-live runner exits without network requests; XML example parses locally (not Salesforce schema validation).
- PASS: git check-ignore confirms .env, .env.local, secrets, generated output, and logs are ignored; .env.example remains visible to Git. git diff --check passed.
- PASS: read-only org identity, BotDefinition/BotVersion, metadata listing checks.
- BLOCKED: Lab 01 live Agent API integration, because it has no runtime ID/active version, no discovered ECA, and no live-call approval.
- BLOCKED: Python SDK import/execution and Python syntax checks; no usable Python command found. No package installed.
- BLOCKED: Testing API integration under the documented sandbox-only eligibility rule.
- NOT TESTED: actual OAuth policy/agent runtime permissions, semantic response quality, actual HTTP transport to Salesforce, live SSE, billable usage, SDK deployment, Flow/Apex invocation.

The first direct script invocation was blocked by the shell's execution policy. Tests were run in a child PowerShell with `-ExecutionPolicy Bypass`, without changing persistent execution policy. Public documentation fetches via Invoke-WebRequest were attempted when the web renderer omitted examples; raw markdown paths/HTML fetches were unavailable. Official indexed API reference content supplied the schemas instead. No legacy workflow was substituted.

## Commands actually executed

Local inspection included Get-Content of sfdx-project.json/.gitignore/Lab 01 validation, rg for relevant agent names/types and instructions, Get-ChildItem of common Python/Conda locations, and git status. The available project has no additional AGENTS.md found by the focused file search; the supplied documentation instructions were followed.

```powershell
python --version
py --version
sf --version --json
sf config get target-org --json
sf plugins --json
sf sobject describe --json --sobject BotDefinition --target-org MyDeveloperOrg
sf sobject describe --json --sobject BotVersion --target-org MyDeveloperOrg
sf data query --json --target-org MyDeveloperOrg --query "SELECT Id, Name, OrganizationType, IsSandbox FROM Organization"
sf data query --json --target-org MyDeveloperOrg --query "SELECT Id, DeveloperName, Type, AgentType FROM BotDefinition"
sf data query --json --target-org MyDeveloperOrg --query "SELECT BotDefinition.DeveloperName, VersionNumber, Status FROM BotVersion"
sf data query --json --target-org MyDeveloperOrg --query "SELECT Id FROM BotDefinition WHERE DeveloperName = 'Safexpress_Logistics_Sales_Assistant'"
sf org list metadata --json --metadata-type ExternalClientApplication --target-org MyDeveloperOrg
sf org list metadata --json --metadata-type AiAuthoringBundle --target-org MyDeveloperOrg
sf org list metadata --json --metadata-type AiEvaluationDefinition --target-org MyDeveloperOrg
sf agent test create --help
sf agent test run --help
sf agent test results --help
sf agent test resume --help
powershell -NoProfile -ExecutionPolicy Bypass -File labs/lab-03/tests/Run-UnitTests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File labs/lab-03/scripts/Run-Lab03.ps1
git check-ignore labs/lab-03/.env labs/lab-03/.env.local labs/lab-03/secrets/key.json labs/lab-03/output/result.json labs/lab-03/test.log
git check-ignore labs/lab-03/.env.example
git diff --check
```

Plugin and describe JSON was reduced to name/version or field name/type for inspection. Only metadata names were requested for apps, never consumer secrets or OAuth settings. Read-only network commands used the approved outside-sandbox path due to this environment's network restrictions. These are environment checks, not Agent API integration tests.

No `sf agent preview` or `sf agent test run` was executed in Lab 03. The previous lab's preview success is not evidence of public Agent API compatibility.

## Files delivered

Eight requested guides: README.md, architecture.md, prerequisites.md, api-reference.md, authentication.md, test-cases.md, validation.md, findings.md. Additional invocation.md explains Flow/Apex. scripts/ contains Auth.ps1, Transport.ps1, Session.ps1, Run-Lab03.ps1. sdk/ contains example.py and README.md. tests/ contains Run-UnitTests.ps1, testing-api.md, and the non-deployed XML example. .env.example and .gitignore complete the local configuration safeguards.

The fixture tests include successful/failing OAuth, missing token/session/feedback IDs, session start/termination, sync/SSE, multi-turn order, concurrent access, HTTP error handling, timeout, cleanup failure, redaction by omission, identity policy, host validation, and XML well-formedness. They do not establish Salesforce authentication, runtime identity enforcement, answer quality, or billing behavior.

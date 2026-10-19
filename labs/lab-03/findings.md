# Findings and applicability

Date: 2026-10-16. Repository findings and live read-only observations are distinct from documentation and mock results.

## Live org versus local source

| Agent | Live classification | Live version | Lab relevance |
|---|---|---|---|
| Agentforce_Service_Agent | Type ExternalCopilot; AgentType EinsteinServiceAgent | v1 Active | Existing business/service agent; not invoked or altered |
| Lead_Gather_Example | Type ExternalCopilot; AgentType EinsteinServiceAgent | v1 Inactive | Existing agent; not invoked or altered |
| Safexpress_Logistics_Sales_Assistant | No BotDefinition row | No runtime version | Local Employee Agent source only; no Agent API ID |

Metadata list returned Lead_Gather_Example_1, Lead_Gather_Example_2, InterviewAgent_1 authoring bundles. Lab 01 was absent. Local CustomerServiceAgent and InterviewAgent files do not prove publication or runtime readiness. Current BotDefinition and BotVersion results confirm Lab 01 has not become published/active since Lab 01's preview exercise.

ExternalClientApplication list and AiEvaluationDefinition list both returned no records. These are visibility-bounded metadata observations; they do not inspect installed app policy details or establish Testing API eligibility. No credential-bearing metadata was retrieved.

## Coverage and applicability matrix

| Official capability | Lab treatment | Live status |
|---|---|---|
| OAuth client credentials / JWT access token | Executable PowerShell form request; mock success/failure | BLOCKED: app/credentials/access not configured |
| Agent API session start/end | Executable client with UUID, state, and finally cleanup | BLOCKED: no Lab 01 runtime ID |
| Sync messages / multi-turn conversation | Executable ordered client | BLOCKED; mock order is not semantic context proof |
| Streaming / SSE | Incremental parser, validation-failure reset, end detection | BLOCKED; framing tested with fixtures |
| Feedback | Executable opt-in submission using returned feedbackId | BLOCKED; separate approval for Data 360 feedback write |
| Errors, timeout, rate/concurrency handling | Mock HTTP errors, one-attempt transport, per-session gate | PASS locally; real throttling NOT TESTED |
| Citations / rich response fields | Preserved in memory; no rendering UI | NOT TESTED; Lab 01 has no retrieval grounding |
| Custom/context variables | Reviewed; no new bindings or payload injection for this agent | NOT TESTED; requires a later approved source change |
| Reply, Cancel, transfer and plan messages | Reference-only; not applicable to this lab's text-only agent | NOT TESTED; no fabricated schemas |
| Python SDK create/manage/deploy | Archived SDK review and guarded example | BLOCKED: Python/package unavailable; current org compatibility unverified |
| Testing API metadata / Connect operations | Non-deployed XML example and sandbox workflow | BLOCKED: Developer Edition is not a sandbox |
| Agentforce DX evaluation tooling | Installed help checked; runner differences documented | NOT TESTED: no test generation/deployment/run |
| Flow/Apex invocation | Official pattern and execution-context review | NOT TESTED: no approved implementation |
| Agent Script / DX authoring | Reuse existing Lab 01; no duplicate agents | No changes |
| Custom Connections, mobile SDKs, Enhanced Chat/In-App Chat | Deployment/client-channel integrations require another UI/channel exercise | Not applicable to this PowerShell lab |
| ADL API / session tracing export | Separate data-library/tracing setup; not required by this sample-only agent | Not executed; no data library changes |

The expanded capability list follows the current [Agentforce APIs and SDKs overview](https://developer.salesforce.com/docs/ai/agentforce/guide/get-started-agents.html). “All applicable” does not mean every channel SDK can be meaningfully executed in a Windows shell or that an ineligible org becomes supported. Nothing is silently substituted for the requested API.

## Security and operational findings

- Real tokens, client keys, secrets, and passwords were not retrieved, printed, saved, or committed.
- The runner defaults to no network access; live calls require the operator's explicit `-LiveApproved` flag after approval. Feedback requires another switch.
- Only fixed synthetic prompts are sent by the runner. No real records are read by the client exercise.
- OAuth credentials are sent only to a validated HTTPS My Domain origin. Agent calls use a fixed Salesforce API origin. Redirects are disabled.
- Logs exclude all bodies, headers, domains, agent/session identifiers, and credential values. Exceptions are replaced by fixed categories.
- Environment variables are process-level secret transport, not encrypted storage. Response objects can contain sensitive content if the wrong agent is selected; never print or persist them casually.
- Each shared context serializes turns. Other processes/clients can still produce HTTP 423; there is no cross-process lock or distributed session manager.
- Network failures can prevent session cleanup. The client attempts cleanup and reports failure without claiming closure.
- Python SDK is archived. Its third-party dependency/runtime behavior and Agent Script compatibility were not certified. No installation or migration was attempted.
- Credit allocation, account-specific numeric limits, ECA policy assignments, and actual employee runtime permissions remain unverified. No billable agent request was used to probe them.

## Source discrepancies

The Agent API examples describe feedback 201, while the API reference specifies 202; successful 2xx is accepted, without duplicate submission. The SDK is still linked from current docs although its repository is archived. Installed DX help includes AiTestingDefinition/Agentforce Studio alongside AiEvaluationDefinition; this does not override the requested Testing API's documented sandbox-only restriction. Help's Flow/Apex page was inaccessible; the official developer article supports the pattern, while exact current org action discovery remains pending.

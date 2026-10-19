# Agent API contract and error handling

Schema authority: [Agent API reference](https://developer.salesforce.com/docs/ai/agentforce/references/agent-api), with [examples](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-api-examples.html). The web renderer omitted code blocks; indexed official reference content supplied the field/method schemas. No undocumented preview endpoints are used.

Base: `https://api.salesforce.com/einstein/ai-agent/v1`. API v1 is independent of Salesforce metadata/data API 68.0. The current lab client is intentionally commercial-cloud-only. Government Cloud requires the documented `api.gov.salesforce.com` endpoint plus an approved authentication configuration; not tested here.

| Operation | Method and path | Payload/header essentials |
|---|---|---|
| Start | POST `/agents/{agentId}/sessions` | externalSessionKey UUID, instanceConfig.endpoint, boolean bypassUser; Text streaming capability |
| Synchronous | POST `/sessions/{sessionId}/messages` | message: type Text, increasing numeric sequenceId, text |
| Streaming | POST `/sessions/{sessionId}/messages/stream` | Same payload; Accept text/event-stream |
| Feedback | POST `/sessions/{sessionId}/feedback` | Returned generation feedbackId; feedback GOOD or BAD |
| End | DELETE `/sessions/{sessionId}` | x-session-end-reason UserRequest |

All use bearer authorization; JSON bodies use application/json. The start payload's optional featureSupport is omitted so the lab follows the documented streamingCapabilities example. No extra request-ID header is invented: externalSessionKey correlates the conversation and sequenceId orders turns. The log UUID is local telemetry, not an idempotency key.

Feedback's reference response is 202; the examples page says 201. The client accepts successful 2xx responses, documents this discrepancy, and does not submit duplicate feedback. Feedback is stored in Data 360 and is separately opt-in. Missing feedbackId is a blocker, not a reason to generate one.

SSE supports progress, text chunks, Inform, validation failure, and EndOfTurn. Client consumes incrementally and buffers, so no provisional text is shown. On validation failure, prior content is discarded. Citations/inlineMetadata remain in response objects; this lab does not implement a citation-rendering UI. Extra request types (Reply, Cancel, transfer outcomes, PlanTemplate) depend on corresponding agent/channel behavior; this text-only agent has no such flows and the client does not fabricate these payloads. Lab 01 has no custom/context variable bindings; variable-based scenarios are documented in [Agent API variables](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-api-variables.html) for a later approved extension.

## Failure and retry policy

| HTTP/local outcome | Interpretation and next step |
|---|---|
| 400 | Invalid ID/body; inspect local configuration, not a blind retry |
| 401 | Missing/invalid/expired token; check ECA and expiry; no automatic message replay |
| 403 | Permissions/agent access; administrator review |
| 404 | Endpoint/token/agent availability; verify My Domain and runtime ID |
| 422 | Execution failure; investigate agent/runtime |
| 423 | A request is already in progress; serialize requests |
| 429 | Rate limit; stop, respect provider retry guidance, plan a later attempt |
| 500 | Server/configuration error or server timeout; outcome may be unknown |
| 503 | Service/action availability or timeout; outcome may be unknown |
| Network timeout / truncated SSE | Outcome unknown; no replay; attempt closure |
| Missing EndOfTurn / invalid JSON | Fail closed; do not accept partial output as final |

These mappings follow [troubleshooting](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-api-troubleshooting.html). The client emits stable categories instead of raw errors, which may echo credentials or user text. It never retries OAuth, start, message, feedback, or end requests automatically. Even an apparent failure may have executed an agent action. A generic exponential-retry decorator is unsafe here. Bounded GET polling is appropriate for the separate Testing API workflow, not for replaying conversational POSTs.

[Documented Agent API timeout](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-api-considerations.html): 120 seconds, surfaced as HTTP 500. The client uses 130-second network/read-stage deadlines and a 1 MiB response-content cap; this is not a guarantee of a 130-second total process limit. No universal Agent API requests-per-minute value was established in the reviewed reference; do not borrow Models API or Testing API limits. Review org entitlements/provider throttling before load testing. No load test was run.

## Cleanup guarantees and limits

`Invoke-LabConversation` attempts DELETE in finally whenever it has a session ID, and clears the token even on failure. Cleanup failure remains visible. A start request whose response is lost can leave an unknown session ID; a network outage, expired token, killed process, or HTTP 423 can prevent closure. It is impossible to guarantee remote cleanup under those conditions. The client never reports those sessions as closed and never auto-replays an ambiguous start. Each run is bounded to three synthetic messages; no cross-process session sharing is supported.

# Lab 03 test matrix

PASS means the named local assertion passed, not live Agent API success. BLOCKED means a known prerequisite prevents a live test. NOT TESTED means no execution occurred. FAIL is reserved for an observed failed assertion or integration expectation. The current Agent API integration prerequisites block live cases 1-23; no OAuth token mint or agent conversation was attempted.

| # | Case | Expected outcome | Local result | Live result |
|---|---|---|---|---|
| 1 | OAuth success | Form encoding correct; token kept in memory | PASS mock | BLOCKED |
| 2 | OAuth failure | Categorized failure; no secret echo | PASS mock | BLOCKED |
| 3 | Missing token | No HTTP request sent | PASS mock | BLOCKED |
| 4 | Invalid agent ID | Local format validation / HTTP 400 interpretation | PASS mock | BLOCKED |
| 5 | Start session | Unique UUID, explicit boolean identity, session retained | PASS mock | BLOCKED |
| 6 | Missing session ID | Fail closed; no message request | PASS mock | BLOCKED |
| 7 | Synchronous message | Text schema, Authorization, sequence 1 | PASS mock | BLOCKED |
| 8 | Streaming | SSE framing, event processing, EndOfTurn | PASS mock | BLOCKED |
| 9 | Multiple turns | Same session; sequence increments | PASS mock ordering; semantic context NOT TESTED | BLOCKED |
| 10 | Parallel requests | Gate rejects overlap; HTTP 423 not replayed | PASS real local gate + mock 423 | BLOCKED |
| 11 | Session termination | DELETE with UserRequest; Closed state | PASS mock | BLOCKED |
| 12 | Message after termination | Refused locally; zero calls | PASS mock | BLOCKED |
| 13 | Expired token | HTTP 401 stops; no silent replay | PASS mock | BLOCKED |
| 14 | API timeout | Unknown outcome; no duplicate message | PASS mock | BLOCKED |
| 15 | HTTP errors | 403/404/422/500/503 classified | PASS mock | BLOCKED |
| 16 | Feedback | Generation feedbackId reused, GOOD/BAD schema | PASS mock | BLOCKED |
| 17 | Unsupported Default agent | Configuration rejected | PASS local | BLOCKED |
| 18 | Sensitive input/error content | Logs/exceptions omit secrets and payloads | PASS mock | BLOCKED |
| 19 | Execution identity | Employee lab policy requires false | PASS local; real identity enforcement NOT TESTED | BLOCKED |
| 20 | Rate limits | HTTP 429 stops; no automatic POST retry | PASS mock | BLOCKED |
| 21 | Truncated/invalid stream | Reject incomplete/invalid response | PASS mock | BLOCKED |
| 22 | ValidationFailureChunk | Drop previously buffered output | PASS mock | BLOCKED |
| 23 | Cleanup after failure | DELETE attempted; failed cleanup visible; token cleared | PASS mock | BLOCKED |
| 24 | Python SDK availability | Python >=3.11 and reviewed SDK required | BLOCKED: no usable Python command | BLOCKED |
| 25 | Testing API availability | Eligible sandbox required | BLOCKED: live IsSandbox=false | BLOCKED |
| 26 | Credit/usage readiness | Approved allocation and bounded plan | NOT TESTED: no account-specific budget evidence | BLOCKED |
| 27 | SDK creation/deployment | Guarded, unique reviewed example; inspect deployment result | NOT TESTED | BLOCKED |
| 28 | Flow/Apex agent invocation | Active agent, inputs, identity, outputs, fault path | NOT TESTED | BLOCKED |

## Approved future integration exercise

Run only after the prerequisites and possible credit consumption are approved. Use the runner's three synthetic prompts:

1. Sample Company A, 100 kg cartons, Delhi to Pune weekly: agent should ask for missing timing/handling information without inventing a quote.
2. Change destination to Jaipur: response should preserve other details and use Jaipur.
3. Draft a follow-up: should label the draft as unsent and make no service guarantee.

Record HTTP/category/count/timing from sanitized output. Review response content in memory without console logging to judge semantics. Do not deliberately load-test concurrency/rate limits or use invalid credentials against the org merely to reproduce mocks. The separate feedback exercise requires approval to persist feedback. Never mark HTTP 200 alone as a behavioral PASS.

SDK and Testing API cases remain blocked even when ordinary Agent API chat becomes available: each has separate dependencies/eligibility. The XML fixture is an example, not evidence that a Salesforce evaluation passed.

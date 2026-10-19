# Testing API: sandbox-only exercise

**BLOCKED in MyDeveloperOrg:** the live Organization query returned Developer Edition and `IsSandbox=false`. Salesforce's current [Testing API prerequisites](https://developer.salesforce.com/docs/ai/agentforce/guide/testing-api-get-started.html) restrict agent testing to sandboxes. A successful metadata list (empty here) does not prove evaluation-run eligibility. No test deployment or execution was attempted.

The adjacent `.xml.example` is outside the DX package, intentionally non-deployable as named. Its fields follow the [metadata reference](https://developer.salesforce.com/docs/ai/agentforce/references/testing-api/testing-metadata-reference.html): AiEvaluationDefinition is available from API 63.0; this lab targets 68.0. It identifies the agent by API name and contains an utterance plus a semantic response expectation. Omitting subjectVersion selects the latest active version. It has been XML-parsed locally, not server-validated. Do not rename/move it for deployment until a suitable sandbox, active agent, and approval exist.

The definition can also express subagent/action sequences, context variables, conversation history, and quality/custom metrics. Actual compiled subagent identifiers must be verified before adding sequence assertions. A semantic rating is not exact string equality; evaluate the returned metric results, not just HTTP success.

In a separately approved sandbox workflow:

1. Review identity, permissions, safe action behavior, and credit implications.
2. Deploy the reviewed AiEvaluationDefinition via Metadata API. SDK/CLI deployment is a mutation.
3. Start once using `POST /services/data/v68.0/einstein/ai-evaluations/runs` with `{"aiEvaluationDefinitionName":"Lab03_Logistics"}`.
4. Capture `runId`. Poll `GET .../runs/{runId}` with bounded intervals and an overall deadline; GET polling may use bounded backoff for transient failures. Do not replay the initial POST after an ambiguous timeout.
5. On COMPLETED or ERROR, fetch `GET .../runs/{runId}/results`. Review each expectation's score and operational errors; a completed run can still contain failed expectations. Never log generatedData without review.

These paths and statuses follow the [Connect reference](https://developer.salesforce.com/docs/ai/agentforce/references/testing-api/testing-connect-reference.html). The service uses the org domain, not Agent API's `api.salesforce.com`. [Testing OAuth setup](https://developer.salesforce.com/docs/ai/agentforce/guide/testing-api-connect.html) lists `chatter_api`, `api`, `web`, and `refresh_token/offline_access`, JWT access tokens, client credentials, and a Run As user. Do not assume the Agent API ECA's scopes alone suffice.

Installed CLI help confirms `sf agent test create --spec ... --api-name ... --preview` can preview generated metadata and `--test-runner testing-center` selects AiEvaluationDefinition. The same plugin also advertises `agentforce-studio`/AiTestingDefinition; that is a separate format, not a silent substitute for this exercise. No runner was executed.

Future approved CLI operations: `sf agent test create`, `sf agent test run`, `sf agent test resume --job-id ...`, and `sf agent test results --job-id ...`, each with an explicit sandbox alias and `--json`. Do not use `--force-overwrite` for this lab.

Current [limits](https://developer.salesforce.com/docs/ai/agentforce/guide/testing-api-considerations.html): up to 10 in-progress runs and 1,000 cases per definition. Since Summer '26, Testing API does not consume Einstein Requests/Flex Credits; Data 360 queries still consume Data 360 credits, and test actions can modify data. This exemption must not be applied to ordinary Agent API chats.

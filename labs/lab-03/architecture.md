# Architecture

```text
Approved operator -> process environment -> Auth.ps1 -> My Domain OAuth endpoint
                              |
                              v
Run-Lab03.ps1 -> Session.ps1 -> Transport.ps1 -> Agent API -> activated agent
                    |              |
             ordered session     .NET HTTP + SSE parser
                    |              |
                    +-- finally: end session
                    +-- allowlisted telemetry (no content or credentials)

Run-UnitTests.ps1 -> injected mock transport (no Salesforce connection)
sdk/example.py -> separate archived SDK demonstration (NOT EXECUTED)
tests/*.xml.example -> sandbox-only Testing API study (NOT DEPLOYED)
```

The existing Lab 01 is an Employee Agent. The planned API caller uses token-user identity (`bypassUser=false`), preserving the employee execution model. Client credentials mean the ECA Run As user is that identity, not the person who typed a prompt. This lab policy must be reviewed before approving an integration; it does not create per-employee authentication.

Authentication, HTTP transport, session state, runner, and tests are separate files. Each session has one lock, one increasing sequence counter, and one generated externalSessionKey UUID. A failed message makes the local session state Unknown, blocking subsequent sends until cleanup. The runner never shares sessions between processes.

The SSE parser consumes lines incrementally, supports multiline data/comments, requires EndOfTurn, and reports truncated streams. This console lab buffers events rather than rendering provisional text. A ValidationFailureChunk discards earlier buffered content. An application UI would need equivalent removal of already rendered chunks. Response objects retain citations and other fields in memory; logs deliberately omit them.

No model decisions, record operations, or publishing logic reside in the API client. Calling a different agent can still execute that agent's actions: the client's lack of direct DML is not a guarantee that an arbitrary target is read-only. Only use the reviewed Lab 01 runtime after approval.

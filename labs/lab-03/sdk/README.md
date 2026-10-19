# Official Python SDK review - NOT EXECUTED

The [Salesforce SDK repository](https://github.com/salesforce/agent-sdk) linked by the current developer guide was archived on 2026-09-02. Its [published package](https://pypi.org/project/agentforce-sdk/) is `agentforce-sdk` 0.2.1 (beta), requiring Python >=3.11,<4.0. Dependencies include requests, simple-salesforce, aiohttp, jsonschema, python-dotenv, and openai; the model API also uses Pydantic. Python/py were unavailable here, so no SDK import, install, syntax execution, or org compatibility test occurred. Do not substitute another similarly named package.

`example.py` demonstrates documented initialization, a local model, retrieval/configuration, and a gated creation/deployment path. Default `--mode plan` is a **lab-owned no-op plan**, not an SDK dry-run. All modes are NOT EXECUTED. Even read-only modes require approval because they initialize a network client. Secrets come only from environment variables; third-party output is suppressed.

The SDK's [API reference](https://github.com/salesforce/agent-sdk/blob/main/docs/api_documentation.md) describes `create`, `retrieve`, `update`, `delete`, `export`, `import_agent`, and `retrieve_metadata`. It documents programmatic models, JSON, nested directories, and modular directories. No verified list-all-agent method was found: use a known identifier or the documented metadata retrieval/configuration path. Update/delete are intentionally not exposed in the lab CLI. Export can disclose sensitive agent configuration; review before using it.

The [creation example](https://github.com/salesforce/agent-sdk/blob/main/examples/create_agent_programmatically.py) uses `client.create(agent)` and checks `deployResult.status`. This operation can deploy metadata; it is not equivalent to creating a local draft. No documented generic `create(..., dry_run=True)` was found. The prompt-template example's `--validate-only` is not evidence of an agent-creation dry-run.

After separate approval of Python/package installation and review of this archived SDK, example commands are:

```powershell
# No installation command is executed by this lab.
python .\labs\lab-03\sdk\example.py --mode plan
python .\labs\lab-03\sdk\example.py --mode model --approved
# Optional approved read-only exercise, with environment-only SDK token and identifier:
python .\labs\lab-03\sdk\example.py --mode retrieve --approved
```

Creation is a separate exercise requiring a named collision review and explicit mutation approval. It would create a different SDK demonstration agent, so it is unnecessary for the Agent API exercise and must not be used merely to work around Lab 01's unpublished status. API 68/Agent Script/AiAuthoringBundle support is not established by these older SDK examples. Keep Agentforce DX as the existing project's authoring path. There is no claim that the SDK is compatible with this org until tested under an approved plan.

**Agent API** chats with an existing activated agent. **Python SDK** manages agent definitions and deployments through Salesforce APIs. They solve different tasks and have different authentication/metadata assumptions.

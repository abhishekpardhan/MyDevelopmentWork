# Prerequisites and readiness

Verified on 2026-10-16:

| Item | Result |
|---|---|
| DX project | `palonia-resort`, default package `force-app`, source API 67.0; unchanged |
| Org alias | `MyDeveloperOrg`, confirmed local default |
| Live org | Developer Edition, IsSandbox=false; API 68.0 queries succeeded |
| Salesforce CLI | 2.152.14; installed Agentforce plugin 2.2.2 |
| Shell | Windows PowerShell 5.1.26100.9711 with built-in .NET HTTP support |
| Python | `python` resolves to an unavailable Store alias; `py` absent. Checked common user Python/Conda locations, none returned |
| Lab 01 | Local AgentforceEmployeeAgent bundle; no BotDefinition result for its exact API name |
| Lab 02 | No files found under `labs`; not recreated or modified |
| External Client App | Supported metadata list returned no ExternalClientApplication records. No secrets queried |
| Agentforce testing | BLOCKED by documented sandbox-only restriction |

An existing active Service Agent does not establish readiness for Lab 01. No duplicate agent is needed. The next approved setup should publish/activate the existing reviewed Lab 01 bundle and verify the intended Employee Agent's access, not call a different agent as a shortcut. No command to do that was executed here.

For Agent Script/new Builder agents, [Salesforce specifies BotDefinition.Id](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-api-agent-id.html), not AiAuthoringBundle.Id, a preview session ID, or a BotVersion ID:

```powershell
sf data query --json --target-org MyDeveloperOrg --query "SELECT Id FROM BotDefinition WHERE DeveloperName = 'Safexpress_Logistics_Sales_Assistant'"
sf data query --json --target-org MyDeveloperOrg --query "SELECT VersionNumber, Status FROM BotVersion WHERE BotDefinition.DeveloperName = 'Safexpress_Logistics_Sales_Assistant'"
```

Currently the first query returned zero records, so no usable Lab 01 ID exists. Legacy Builder instructions use the 18-character ID from its overview URL. Do not copy an unrelated active agent ID.

Before live execution, approve and verify: enabled Agentforce and appropriate entitlement; an active reviewed agent; ECA OAuth/JWT settings; least-privilege Run As identity; permission to access the selected agent and any actions/data; My Domain; and available credit allocation. Developer Edition is not proof of every API entitlement. Setup > Company Information / assigned licenses and relevant Agentforce usage/Digital Wallet views require administrator verification; no account-specific credit budget was established here.

Agent API excludes the **Agentforce (Default)** type. Lab 01's Employee type is not that excluded type, but end-to-end compatibility remains BLOCKED until published, active, and authorized. See [Agent API prerequisites](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-api-get-started.html).

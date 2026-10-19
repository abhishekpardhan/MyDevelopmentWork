# Lab 01 readiness and execution record

Checked 2026-10-16. Only this lab's local files were created. No deployment, publication, activation, security change, package installation, or business record mutation was performed.

## Environment evidence

| Check | Observed result |
|---|---|
| Repository baseline | `git status --short` was clean before creation. |
| Project | Name `palonia-resort`; default package `force-app`; source API 67.0; preserved unchanged. |
| CLI | `@salesforce/cli/2.152.14 win32-x64 node-v24.20.0`. Update notice mentioned 2.153.5; no update installed. |
| Agent plugin | Installed user plugin `@salesforce/plugin-agent` 2.2.2. |
| Default org | Local config `MyDeveloperOrg`. |
| Live org identity | Organization `test`, ID `00DgK00000bV4TdUAK`, Developer Edition, `IsSandbox=false`. Org list reports not a scratch org. Developer Edition is distinct from a sandbox. |
| API | Live Organization query succeeded on API 68.0. |
| Local collisions | Existing bundles: CustomerServiceAgent, InterviewAgent, Lead_Gather_Example. New lab name did not exist. |
| Live bundle collisions | Metadata list succeeded: Lead_Gather_Example_1, Lead_Gather_Example_2, InterviewAgent_1. No matching lab name. |
| Live runtime collisions | BotDefinition query returned Agentforce_Service_Agent and Lead_Gather_Example. No matching lab name. |
| Agent Script support | AiAuthoringBundle list and compilation endpoint are available. Compilation outcome recorded below. |
| Agentforce enabled setting | Not directly confirmed. An attempted settings REST GET returned 404 NOT_FOUND; this does not mean Agentforce is disabled. Existing agents and authoring API availability demonstrate capabilities, not the exact Setup toggle or employee access. If needed, inspect Setup > Agentforce Agents and Setup > Einstein Setup without changing settings. |
| Local compiler | Attempted bundled indexer with Salesforce's bundled Node executable. Failed: `AgentScript SDK not found`. Compiler not used; no provider/version loaded. Installation withheld per user instruction. |
| Behavioral preview | After the startup compatibility fix below, simulated startup and case 1 greeting passed. Remaining cases await user testing. |

## Commands executed

Repository reads included project configuration, the generation skill and relevant syntax/validation references, existing agent names and one existing script, and the final Lab 01 files. No existing agent was edited.

```powershell
sf --version --json
sf plugins --json
sf config get target-org --json
sf org list --json
sf commands --json
sf agent generate authoring-bundle --help
sf agent validate authoring-bundle --help
sf agent preview --help
sf org list metadata --json --metadata-type AiAuthoringBundle --target-org MyDeveloperOrg
sf data query --json --target-org MyDeveloperOrg --query "SELECT Id, Name, OrganizationType, IsSandbox FROM Organization"
sf agent generate authoring-bundle --json --no-spec --name "Safexpress Logistics Sales Assistant" --api-name Safexpress_Logistics_Sales_Assistant --target-org MyDeveloperOrg
& 'C:/Program Files/sf/client/bin/node.exe' .agents/skills/agentforce-generate/scripts/index-agent.mjs force-app/main/default/aiAuthoringBundles/Safexpress_Logistics_Sales_Assistant/Safexpress_Logistics_Sales_Assistant.agent
sf agent validate authoring-bundle --json --api-name Safexpress_Logistics_Sales_Assistant --target-org MyDeveloperOrg
sf agent validate authoring-bundle --json --api-name Safexpress_Logistics_Sales_Assistant --target-org MyDeveloperOrg --api-version 68.0
sf data query --json --target-org MyDeveloperOrg --query "SELECT DeveloperName FROM BotDefinition"
sf api request rest '/services/data/v68.0/settings/einsteinGpt' --target-org MyDeveloperOrg --json
git status --short
git diff --check
```

Plugin/command inventories were repeated with selected fields to avoid excessive output. Initial sandbox network calls failed with `ECONNREFUSED 127.0.0.1:9` or `Error refreshing connection`; read-only checks were retried outside the sandbox. The org list's initial connection failures were sandbox results, superseded for the target org by successful live queries.

Generation succeeded and created the standard two-file bundle. The boilerplate was customized only within the new lab: removed messaging links, sample escalation actions, and the placeholder service-agent user; selected Employee Agent type and the requested guidance behavior. The generated XML was preserved.

## Validation

The first reachable org compilation returned syntax errors across the file. The new script was normalized from the PowerShell-created encoding/line endings to UTF-8 without BOM and LF, then submitted again. See final outcome below.

**Final outcome: PASSED.** The API 68.0 org validator returned exit code 0 and:

```json
{"status":0,"result":{"success":true},"warnings":[]}
```

The final file uses the requested Employee Agent type and a single start block, with no additional subagents. The target compiler accepted that structure. This is org-backed compilation of local source, not deployment and not proof of conversation quality. The encoding normalization resolved the reported parsing failure; the language and metadata architecture were retained.

Static checks: matching directory and file basenames; exactly two bundle files; XML parses and has `bundleType=AGENT`; no action targets, business actions, retrievers, or record-linked variables. `git diff --check` passed for tracked changes; new files are untracked and were separately inspected. This does not replace compilation or behavioral testing.

Limitations: runtime publication/access untested; no actual company knowledge; prompt safeguards not a formal guarantee; no persistent memory; local SDK unavailable; no live actions exist. Future publication and activation require explicit approval. No legacy agent-creation workflow was used.

## Preview startup fix, 2026-10-16

Reproduced the user's `Cannot read properties of undefined (reading 'replace')` with `sf agent preview start --json --authoring-bundle Safexpress_Logistics_Sales_Assistant --simulate-actions --target-org MyDeveloperOrg --api-version 68.0`.

The stack identifies installed `@salesforce/agents` 2.3.1, `lib/agents/scriptAgent.js:391`. It calls `this.agentJson.globalConfiguration.defaultAgentUser.replace(...)` without a missing-value guard, before its Employee Agent handling. This is why successful compilation did not establish preview readiness.

A read-only User query confirmed `abhishekpardhan63.c51b06b3cd3a@agentforce.com` is active. Added only `access.default_agent_user` with that username to the Lab 01 script. Retained Employee Agent type and all behavior. No installed library was patched and no security changes were made.

Verification:

- Local indexer retried: SDK still missing; no installation performed.
- Org validator on API 68.0: `success: true`.
- Programmatic simulated preview startup: passed, session `01a14448-c5e7-730e-ba54-68b0ead14fe9`.
- `sf agent preview send --json --authoring-bundle Safexpress_Logistics_Sales_Assistant --session-id 01a14448-c5e7-730e-ba54-68b0ead14fe9 --target-org MyDeveloperOrg --api-version 68.0 --utterance "Hello! What can you help me with?"`: passed. Response introduced all three learning areas, specified fictional business details and generic concepts, and offered a sample follow-up for review.
- Session closure requested with `sf agent preview end` for that exact session.

The interactive terminal UI itself was not retested; the programmatic preview exercised the same failing `ScriptAgent.startPreview` implementation successfully. No publication or activation occurred.

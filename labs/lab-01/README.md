# Lab 01: Agentforce Overview and AI Agents

Agent: **Safexpress Logistics Sales Assistant**  
API name: `Safexpress_Logistics_Sales_Assistant`  
Date: 2026-10-16  
Scope: local learning artifact only; no deploy, publish, activation, permission changes, or package installation.

## Business purpose and design

Imagine an employee practising a conversation about a fictional business shipping cartons. The assistant asks useful discovery questions, explains generic logistics concepts, and drafts a follow-up for the employee to review. It has no verified Safexpress service catalogue, rates, commitments, or customer information.

The user's Lab 01 requirements are the build contract. One `AgentforceEmployeeAgent` uses a single `start_agent logistics_sales_guidance` block with three instruction areas:

1. **Sales Inquiry and Lead Qualification:** gather sample shipment details and summarize known and missing information; no Lead creation.
2. **Logistics Service Guidance:** explain generic logistics concepts; refer actual company service questions to an authorized representative.
3. **Sales Follow-Up Guidance:** draft text for human review; never send or schedule it.

These are three conversational capabilities, not three separately routed subagents. They share the same authority and need no additional routing or mutable variables. Conversation history supports short-term continuity. No Apex, Flow, LWC, objects, retrievers, integrations, action definitions, or security metadata are required. The absence of tools prevents this authored agent from performing business operations; natural-language safeguards still require behavioral testing.

```text
Employee utterance + surviving conversation history
    -> system boundaries + start_agent reasoning instructions
    -> LLM-generated guidance, clarification, or draft
    -> employee reviews the response
```

## Files

Under `force-app/main/default/aiAuthoringBundles/Safexpress_Logistics_Sales_Assistant/`:

- `Safexpress_Logistics_Sales_Assistant.agent`: learning behavior and Employee Agent configuration.
- `Safexpress_Logistics_Sales_Assistant.bundle-meta.xml`: CLI-generated AiAuthoringBundle descriptor, preserved with `bundleType=AGENT`.

Supporting files are confined to `labs/lab-01/`. Existing agents and `sfdx-project.json` are unchanged. The existing project has one default package, `force-app`, and source API 67.0. Read-only org checks support API 68.0; Lab validation uses 68.0 explicitly without upgrading the whole project.

## How to test

Preview compatibility fix (2026-10-16): the installed `@salesforce/agents` 2.3.1 client dereferences `defaultAgentUser` during startup even for an Employee Agent. The lab now includes `access.default_agent_user` with the verified active username for MyDeveloperOrg. No user or permissions were created or changed. Keep this value org-specific if moving the lab. Org validation, simulated startup, and one greeting response passed after the fix.

From the repository root, validate first:

```powershell
sf agent validate authoring-bundle --json --api-name Safexpress_Logistics_Sales_Assistant --target-org MyDeveloperOrg --api-version 68.0
```

After validation succeeds, start a simulation of the local source:

```powershell
sf agent preview --authoring-bundle Safexpress_Logistics_Sales_Assistant --target-org MyDeveloperOrg --api-version 68.0 --output-dir labs/lab-01/transcripts
```

The interactive preview command does not support `--json`. Do not add `--use-live-actions`. Press Escape or Ctrl+C to finish and save the transcript when prompted. Use fictional details only. Run the scenarios in [test-cases.md](test-cases.md), recording actual output and pass/fail. Start a fresh session for independent cases; keep the context scenario in one session.

If Agentforce DX is already installed in VS Code, open its panel, select this agent under **Agent Script**, choose **Simulation**, and start it. Extension presence and UI behavior were not verified. No extension installation is needed to use the CLI instructions.

“Local preview” means local Agent Script is the input; it still requires an authenticated org, network access, and Salesforce model services. It is not an offline LLM. Compilation checks syntax; preview checks conversation behavior. Neither proves production access or channel behavior.

A published-agent preview uses `--api-name` and requires an activated published agent in this installed CLI. Publishing, activation, employee access, and UI/channel integration require a separate approved step. They are outside Lab 01. This local artifact will not automatically appear as a usable agent in the Salesforce runtime agent list.

## Concepts learned

- An AI agent interprets requests using instructions, context, and an LLM; it can invoke actions only when those capabilities are provided.
- Agent Script is the source blueprint. AiAuthoringBundle packages it as Salesforce metadata.
- `system` defines shared boundaries and messages; `config` defines identity/type; `language` defines locale; `start_agent` is the entry reasoning block.
- Subagents can separate different responsibilities; actions can connect them to business operations. Neither extra subagents nor business actions are necessary for this small lab.
- Prompt instructions are probabilistic guidance, not deterministic program branches or a guarantee against hallucinations.
- Validation, simulated preview, deployment, publishing, and activation are distinct lifecycle steps.
- A sample-data learning agent is not a verified company knowledge assistant. Grounding and authorized integrations would require another lab.

## Official references

Consulted the current [GenAI documentation index](https://developer.salesforce.com/docs/llms-genai.txt) and:

- [Get Started](https://developer.salesforce.com/docs/ai/agentforce/guide/get-started.html)
- [Agentforce DX](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx.html)
- [Author an Agent](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-nga-author-agent.html)
- [Agent Script](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-script.html)
- [Agent Script blocks](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-blocks.html)
- [Code Your Agent](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-nga-script.html)
- [Preview and Debug](https://developer.salesforce.com/docs/ai/agentforce/guide/agent-dx-nga-preview.html)

See [validation.md](validation.md) for measured readiness and command outcomes. Stop after Lab 01 and provide your test results before further changes.

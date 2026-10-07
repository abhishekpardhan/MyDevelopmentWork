# Download Agent Script Documentation

Download the Agent Script documentation as markdown files so your coding agents can reference correct syntax, metadata deployment rules, and design patterns without web lookups. Use the files as grounding context for agentic coding and deployment tools, or search them locally. This download is updated weekly on Thursday evenings (PST), so download regularly to get the latest updates.

## Download and Set Up

1. Download the documentation bundle: [AgentScriptDocs.zip](https://resources.docs.salesforce.com/rel1/doc/en-us/static/misc/AgentScriptDocs.zip).
2. Unzip the file into your project workspace or the context source used by your coding agent.

## What's Included

The bundle contains markdown files organized into these categories:

| Folder                    | Contents                                                                                         |
| :------------------------ | :----------------------------------------------------------------------------------------------- |
| `agent-script/`           | Language overview, Agent Script blocks, model config, flow of control, and managing your agent   |
| `agent-script/reference/` | Syntax, keywords, and semantics for Agent Script features                                        |
| `agent-script/patterns/`  | Solutions for common tasks like multi-turn conversations, action chaining, and conditional logic |
| `agent-script/examples/`  | Complete agent implementations you can use as starting points                                    |
| `deploy-metadata/`        | Instructions and examples on using metadata to deploy your agent to a new org                    |

## Use with Coding Agents

Point your coding agent's context to the unzipped folder. For example, in a `CLAUDE.md` or similar context file:

```markdown
Reference the Agent Script documentation in ./docs/agent-script/ for syntax and patterns.
```

Your agent can then look up syntax in the reference files and follow established patterns when generating Agent Script code.

## See the Agentforce Development Skill

If you prefer a pre-packaged skill, use the [Agentforce Development Skill](https://github.com/forcedotcom/afv-library/tree/main/skills/developing-agentforce) to build, modify, debug, and deploy Agentforce agents with Agent Script. The Agentforce Development skill is part of the [Salesforce Skills Library](https://github.com/forcedotcom/afv-library).

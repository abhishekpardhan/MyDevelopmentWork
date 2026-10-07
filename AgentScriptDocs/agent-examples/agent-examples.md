# Agentforce Examples

This section provides example Agentforce implementations to help you get started building and using agents. Each example explains the main concepts it demonstrates and gives you what you need to build it yourself.

The **Headless Instructions** column identifies examples with guidance on how to build and deploy using an AI coding agent.

## End-to-End Agents

Build and deploy a complete Agentforce solution from start to finish.

| Example                                                                                            | Description                                                                                                                                                                                | Headless Instructions |
| -------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------- |
| [Build the Palonia Resort Demo with a Coding Agent](headless-example-org-build.md)                 | Use an AI coding assistant to build and deploy a complete solution — custom objects, sample data, a flow, a Lightning web component, a prompt template, and a service agent — to your org. | Yes                   |
| [Customer Support Agent](ascript-examples-customer-support.md)                                     | A support agent that verifies a customer's identity and looks up their orders — built three ways: headlessly with an AI coding agent, with code in Agent Script, or with clicks in Canvas. | Yes                   |
| [Build and Deploy an Enhanced Chat Agent](../../headless/headless-examples-enhanced-chat-agent.md) | Build a chat agent, test and activate it, and deploy it to an Enhanced Chat v2 channel.                                                                                                    | Yes                   |
| [Collect Customer Information to Create a Record](ascript-lead-gather.md)                          | An agent that collects required details across multiple turns, then creates a record through a flow — with safeguards against dropped values, duplicate records, and false confirmations.  | No                    |

## Agent Script Techniques

Learn specific Agent Script techniques through focused, code-first examples.

| Example                                                                                   | Description                                                                                    |
| ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| [Enforce Subagent Sequencing With Variables](ascript-examples-multi-turn.md)              | A step-based interview agent that enforces question order while handling natural conversation. |
| [Agent Script Patterns](../agent-script/patterns/ascript-patterns.md)                     | Reusable patterns for common Agent Script use cases and workflows.                             |
| [Agent Script Recipes](https://developer.salesforce.com/sample-apps/agent-script-recipes) | Sample implementations that demonstrate Agent Script features and techniques.                  |

## Extend Your Agent with Data and Actions

Ground your agent in your own knowledge and add custom logic that the standard actions don't cover.

| Example                                                                                          | Description                                                                                                                        | Headless Instructions |
| ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------- | --------------------- |
| [Ground an Agent with an Agentforce Data Library](../../headless/headless-examples-agent-adl.md) | Build an agent, ground it with an Agentforce data library, test, and activate it.                                                  | Yes                   |
| [Demystify Jargon with Knowledge](ascript-example-rag-jargon.md)                                 | Ensure that your grounded agent understands your organization's evolving jargon without having to update your information sources. | No                    |
| [Custom Apex Action for Complex Queries](apex-examples-custom-action.md)                         | A custom action built in Apex to search product inventory.                                                                         | No                    |

## Related Topics

- [Agent Script Patterns](../agent-script/patterns/ascript-patterns.md)
- [Agent Script Reference](../agent-script/reference/ascript-reference.md)

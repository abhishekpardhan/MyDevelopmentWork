# Specify Different Models in Agent Script

By default, Agentforce uses the [org-level model selected in Setup](https://help.salesforce.com/s/articleView?id=ai.agent_setup_select_model_provider.htm&type=5) for all agents and subagents. To use a different model for a specific agent or subagent, override the default with `model_config`.

```sfdocs-code {"lang":"agentscript", "title": "Specify a Model in an Agent or Subagent"}
model_config:
    model: "model://sfdc_ai__DefaultBedrockAnthropicClaude45Haiku"
```

Specify any [supported model](../../models/supported-models.md). To test your model selections, use different models in different versions of your agent.

:::important

- We recommend that you use GPT 4.1 (`sfdc_ai__DefaultGPT41`), Claude Haiku 4.5 (`sfdc_ai__DefaultBedrockAnthropicClaude45Haiku`), or Gemini 3.5 Flash (`sfdc_ai__DefaultVertexAIGemini35Flash`) because these models have been thoroughly tested with agents.
- Thoroughly test your agent with your chosen model or models before deploying. Some supported models may not be suitable for your agent or agent's tools.
  :::

## Example: Configure a Specific Model for the Agent

Use `model_config` to override the org-level default model for the agent.

```sfdocs-code {"lang":"agentscript", "title": "Agent-Level Model Configuration"}
system:
    instructions: "You are an AI Agent."
    messages:
        welcome: Hi, I'm an AI service assistant. How can I help you?
        error: "Sorry, it looks like something has gone wrong."
model_config:
    model: "model://sfdc_ai__DefaultBedrockAnthropicClaude45Haiku"
```

## Example: Configure a Specific Model for the Subagent and Agent Router

Use `model_config` in a subagent to override the org-level or agent-level model for the subagent.

```sfdocs-code {"lang":"agentscript", "title": "Subagent-Level Model Configuration"}
subagent ReservationManagement:
    description: "Handles requests to create new reservations for customers at their desired time slots."
    model_config:
        model: "model://sfdc_ai__DefaultBedrockAnthropicClaude45Haiku"
```

Some agent templates, such as Agentforce Service agent, use the Salesforce-owned [EinsteinHyperClassifier](#einsteinhyperclassifier-model) model for subagent classification in the agent router. Keep that model or specify a different model in your agent router.

```sfdocs-code {"lang":"agentscript", "title": "Agent Router-Level Model Configuration"}
start_agent agent_router:
    description: "Welcome the user and determine the appropriate subagent based on user input"
    model_config:
        model: "model://sfdc_ai__DefaultGPT41"
```

## Multiple Models in an Agent

You can specify multiple models in the same agent. A subagent-specific model takes precedence over an agent-specific model.

### Example: Org, Agent, and Subagent Have Different Models

Suppose that your org, agent, and subagent have these models specified:

- You've selected the Salesforce default model for your org
- The MyTestAgent agent specifies Claude Haiku 4.5
- The HandleReservation subagent specifies Gemini 3.1 Pro

In this example, Agentforce uses Gemini 3.1 Pro for the HandleReservation subagent. For all other subagents in the MyTestAgent, Agentforce uses Claude Haiku 4.5. For other agents in the same org, Agentforce uses the Salesforce default model.

## EinsteinHyperClassifier Model

The EinsteinHyperClassifier model, developed by Salesforce, is often used for subagent classification in the `agent_router` subagent. The advantages of using EinsteinHyperClassifier for subagent classification are:

- Significantly faster subagent classification compared to other LLMs.
- Increased classification accuracy, particularly for specialized classification constraints and negative instructions.

Limitations of using the EinsteinHyperClassifier model:

- **Can't** use `before_reasoning` or `after_reasoning`.
- **Can only** use the tool `@utils.transition`, but no other [tools](reference/ascript-ref-tools.md).

## Related Topics

- [Agent Script Reference](reference/ascript-reference.md)
- [Agent Script Blocks](./ascript-blocks.md)

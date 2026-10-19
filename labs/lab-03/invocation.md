# Calling an agent from Flow or Apex - research only

Salesforce's [APIs and SDKs guide](https://developer.salesforce.com/docs/ai/agentforce/guide/get-started-agents.html) links the official [Calling an Agent from a Flow or Apex Class](https://help.salesforce.com/s/articleView?language=en_US&id=ai.agent_custom_invocable_action_flow_apex.htm) article. That Help page returned a CSS/loading error here. The official [developer example](https://developer.salesforce.com/blogs/2025/04/invoke-agentforce-agents-with-apex-and-flow) documents the following pattern; exact current agent-specific inputs and permissions still require org action discovery and accessible Help before implementation.

Flow: add an AI Agent action for an active agent. Supply userMessage and optionally sessionId; retain the returned session ID for later turns and capture the agent response. Add a fault path and consider Flow timeout/execution context.

Apex: the documented entry point is `Invocable.Action.createCustomAction('generateAiAgentResponse', agentApiName)`. Set invocation inputs, call invoke, check each Result for success/errors, and read response/session outputs. This invokes an agent from Salesforce; it is different from an Apex action that an agent itself calls.

Employee-facing execution must respect the user's permissions. A Flow's own system context or Apex class declaration is not proof that every action/data operation has appropriate authorization. Verify the selected agent, runtime identity, action permissions, sharing, CRUD and FLS. For a future implementation, bulkify inputs, avoid SOQL/DML in loops, use explicit sharing and user-mode data access where appropriate, budget governor/callout limits, and test error/denial paths. Do not turn an agent invocation into an unbounded per-record loop.

No Flow, Apex, invocable calls, LWC, or deployments were created or executed. Inactive/local-only Lab 01 cannot be assumed available in Flow's action picker. This exercise requires separate approval and runtime prerequisite completion.

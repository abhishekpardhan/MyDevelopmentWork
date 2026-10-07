# Agent Script Blocks

A script consists of blocks where each block contains a set of properties. These properties can describe data or procedures. Agent Script contains several different block types.

![Agent Script Blocks](../../../../../media/agent-script/agent-script-blocks4.svg '{"class": "image-sm"}')

This section gives you a high-level understanding of each block type.

## System Block

The system block contains general instructions for the agent. This information includes a list of message prompts that the agent uses during specific scenarios. `welcome` and `error` are required messages:

- For multiline messages, use the pipe symbol ("|")
- To personalize messages or include other context information, use [linked variables](reference/ascript-ref-variables.md#linked-variables).

For example, to dynamically inject the user's preferred name into the welcome message, use `{!@variables.userPreferredName}`.

In this example, if the `userPreferredName` is `Sam`, customers see the welcome message "Hi Sam! I'm your personal shopping assistant".

```sfdocs-code {"lang":"agentscript", "title": "System Block"}
system:
    instructions:|
        You are an AI agent. Have a friendly conversation with the user.

    messages:
        welcome:|
            Welcome  {!@variables.userPreferredName}! I'm your personal shopping assistant.

            I can help you:
            - Find products and check availability
            - Track your orders
            - Process returns and refunds
            - Answer questions about our policies

            How can I assist you today?
        error: "Whoops!"
```

## Config Block

The config block contains configuration parameters that define the agent.

| Parameter                    | Description                                                                                                                                                                                                                                                                     |
| :--------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `developer_name`             | The Salesforce API name of the agent (max 80 chars). Must start with a letter, contain only alphanumeric and underscores, and can't end with underscore or have consecutive underscores. Must be unique in your org - you can't have two agents with the same `developer_name`. |
| ~~`default_agent_user`~~     | Deprecated in this block. Specify `default_agent_user` in the [Access Block](#access-block).                                                                                                                                                                                    |
| `agent_label`                | Optional. The agent's label, displayed in the UI. Auto-generated from `developer_name` if not provided.                                                                                                                                                                         |
| `description`                | Description of the agent's goals and purpose.                                                                                                                                                                                                                                   |
| `company`                    | Optional. Information about your company.                                                                                                                                                                                                                                       |
| `role`                       | Optional. The agent's role. For example, "Help the customer select the perfect gift."                                                                                                                                                                                           |
| `agent_version`              | The agent's version. Set automatically when you create a new version of your agent.                                                                                                                                                                                             |
| `agent_type`                 | Optional. The type of agent. Currently, allowed values are `AgentforceServiceAgent` (default) or `AgentforceEmployeeAgent`. Set automatically when you create an agent from a template.                                                                                         |
| `enable_enhanced_event_logs` | Optional. Indicates whether to enable conversation logging for debugging and monitoring. Allowed values are `True` or `False`. Default: `False`.                                                                                                                                |
| `user_locale`                | Optional. User locale setting.                                                                                                                                                                                                                                                  |
| `runtime`                    | Optional. Sub-block that controls the agent's runtime behavior, such as streaming, citations, and groundedness checks. See [Runtime Sub-Block](#runtime-sub-block).                                                                                                             |
| `file_upload`                | Optional. Sub-block that controls how the agent handles files uploaded by the customer during a conversation. See [File Upload Sub-Block](#file-upload-sub-block).                                                                                                              |

### Example Config Block

```sfdocs-code {"lang":"agentscript", "title": "Config Block"}
config:
    developer_name: "Demo_Agent_1"
    agent_label: "Demo Agent"
    description: "This is my demo agent"
```

## Runtime Sub-Block

The `runtime` block is a sub-block of [Config](#config-block) that controls the agent's runtime behavior.

| Parameter               | Description                                                                                                                                                                                                                                                                                                                                                                                                                           |
| :---------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `streaming`             | Controls whether the agent's response is streamed to the client incrementally as it's produced. When `False`, the response is delivered as a single chunk.**When to use:** Leave on (or omit) for interactive chat and voice channels where customers expect the reply to appear progressively. Set to `False` for clients or integrations that only consume a single completed message.                                              |
| `thought_chunks`        | Controls whether the agent's step-by-step thinking is streamed alongside its responses. When `True`, clients that render "thinking" output can display it during the turn.**When to use:** Enable when your client renders reasoning to the customer or to developers (for example, an "agent is thinking" panel or a debug view). Disable for customer-facing surfaces where exposing internal reasoning is undesirable.             |
| `citation`              | Controls the citation-enrichment post-processing step, which annotates knowledge-based answers with references to their source. Set to `False` to skip citation enrichment.**When to use:** Leave on for knowledge-grounded agents where customers benefit from seeing or clicking through to the source. Disable for channels that can't render citations, or when the extra post-processing latency isn't worth it.                 |
| `groundedness`          | By default, Agentforce checks the LLM's responses against source content. This extra step takes some time but reduces the chance of hallucinations. Set to `False` to turn this check off.**When to use:** Leave on for knowledge-heavy agents where reducing hallucinations matters. Disable when you need faster responses and have accepted the tradeoff, or when you've confirmed the check isn't adding value for your use case. |
| `reset_to_initial_node` | When `True`, each new customer turn restarts at the start_agent block, instead of resuming where the previous turn left off.**When to use:** Enable for stateless, one-shot Q&A or planner-style agents that should re-plan from scratch every turn. Leave off (the default) for multi-turn flows that need to resume mid-conversation.                                                                                               |

```sfdocs-code {"lang":"agentscript", "title": "Runtime Block"}
config:
    developer_name: "Demo_Agent_1"
    runtime:
        streaming: True
        thought_chunks: False
        citation: True
        groundedness: True
        reset_to_initial_node: False
```

## File Upload Sub-Block

The `file_upload` block, nested inside `config`, controls how the agent handles files that the customer uploaded during a conversation.

| Parameter | Description                                                                                                                           |
| :-------- | :------------------------------------------------------------------------------------------------------------------------------------ |
| `mode`    | Required. [How the agent handles uploaded](#allowed-mode-values) files. Allowed values are `auto`, `managed`, `disabled`, or `error`. |
| `message` | Optional. A message shown to the customer if uploads aren't successful.                                                               |

### Allowed `mode` values

- **`auto`** — Default file handling. Uploaded files are made available to the agent using standard behavior.
- **`managed`** — Use this mode when you want fine-grained control over which uploaded files reach which subagent. This is the mode that pairs with slice syntax on `@system_variables.uploaded_files`, so you can pass a specific batch (for example, `@system_variables.uploaded_files[0:5]`) into an individual subagent.
- **`disabled`** — Uploads are rejected without displaying a message to the customer.
- **`error`** — Uploads are rejected and treated as an error. If provided, the message in `message` is shown to the customer. If `message` isn't provided, Agentforce generates a message.

```sfdocs-code {"lang":"agentscript", "title": "Config Block with File Upload"}
config:
    developer_name: "Support_Agent"
    agent_label: "Customer Support Agent"
    file_upload:
        mode: "managed"
        message: "Something went wrong. Try again."
```

## Access Block

The access block defines the agent's default user.

| Parameter            | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| :------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `default_agent_user` | The agent user's username, which is in the form of an email address. `username` is a field on the [User](https://developer.salesforce.com/docs/atlas.en-us.object_reference.meta/object_reference/sforce_api_objects_user.htm) object. You can also see a user's username in Setup. Required for [Agentforce Service agents](https://help.salesforce.com/s/articleView?id=ai.service_agent_setup.htm&type=5). An agent runs in the context of a user, and the user's permissions grant or deny access to Salesforce resources and data. |

```sfdocs-code {"lang":"agentscript", "title": "Example Access Block"}
access:
    default_agent_user: "service@example.com"
```

## Variables Block

The variables block contains the list of global variables that the agent and script can use. See [Variables](reference/ascript-ref-variables.md).

```sfdocs-code {"lang":"agentscript", "title": "Variables Block"}
variables:
    string_var: mutable string = "hello world"
    hotel_info: mutable string = "Dreamforce Hotel"
```

You reference variables throughout the script by using the syntax `@variables.<variable_name>`.

## Language Block

The language block defines which languages the agent supports.

```sfdocs-code {"lang":"agentscript", "title": "Language Block"}
language:
    default_locale: "en_US"
    additional_locales: ""
    all_additional_locales: False
```

For a list of supported languages, see [Agentforce Language Support](https://help.salesforce.com/s/articleView?id=ai.agent_language_support.htm).

## Modality Block

The modality block configures agent behavior for a specific modality. The current allowed modality is `voice`. Use `modality voice:` to control how the agent sounds — its voice, speaking speed, pronunciation of specialized terms, and how it handles turn-taking on a live call.

```sfdocs-code {"lang":"agentscript", "title": "Modality Block"}
modality voice:
    outbound:
        persona_id: "<voice identifier>"
        model:
            parameters:
                speed: 0.9
```

By default, a voice agent uses the ElevenLabs v3 Conversational model.

- To select a different voice model, see [Configure Voice Models in Agent Script](./ascript-voice.md).
- To see the complete voice catalog, see [Voice Catalog for Agentforce Voice](./ascript-voice-catalog.md).

### Voice Variables

The `voice` variant supports these variables. All variables are optional except `voice_id` when configuring a live voice channel.

| Variable                         | Type     | Range     | Description                                                                                                                                                            |
| :------------------------------- | :------- | :-------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `voice_id`                       | string   | —         | Unique identifier for the outbound voice (for example, `"UgBBYS2sOqTuMpoF3BR0"`).                                                                                      |
| `outbound_speed`                 | number   | 0.5 – 2.0 | Speech rate. `1.0` is normal; lower is slower, higher is faster.                                                                                                       |
| `outbound_style_exaggeration`    | number   | 0.0 – 1.0 | How strongly the voice expresses its style. Higher values are more expressive; lower values are flatter and more consistent.                                           |
| `inbound_filler_words_detection` | boolean  | —         | When `True`, filler words (like "um", "uh") in the customer's speech are detected and ignored.                                                                         |
| `inbound_keywords`               | block    | —         | Keyword boost list. Contains a `keywords` sequence of strings that improves recognition for domain-specific terms.                                                     |
| `pronunciation_dict`             | sequence | —         | Custom pronunciations for specialized words or names. Each entry has `grapheme` (written form), `phoneme` (phonetic spelling), and `type` (either `"IPA"` or `"CMU"`). |
| `outbound_filler_sentences`      | sequence | —         | Short "thinking" phrases the agent says while an action is running, so the customer doesn't hear dead air. Each entry has a `waiting` list of strings.                 |
| `additional_configs`             | block    | —         | Container for `speak_up_config`, `endpointing_config`, and `beepboop_config`. See [Additional Configs](#additional-configs).                                           |

### Additional Configs

The `additional_configs` block groups three sub-configurations that fine-tune turn-taking behavior on a live call.

| Sub-config           | Variable                          | Type   | Range          | Description                                                                                                               |
| :------------------- | :-------------------------------- | :----- | :------------- | :------------------------------------------------------------------------------------------------------------------------ |
| `speak_up_config`    | `speak_up_first_wait_time_ms`     | number | 10000 – 300000 | How long to wait, in milliseconds, before speaking up for the first time after the customer goes silent.                  |
| `speak_up_config`    | `speak_up_follow_up_wait_time_ms` | number | 10000 – 300000 | How long to wait, in milliseconds, before speaking up again if the customer is still silent.                              |
| `speak_up_config`    | `speak_up_message`                | string | —              | The message the agent says when it speaks up.                                                                             |
| `endpointing_config` | `max_wait_time_ms`                | number | 500 – 60000    | Maximum time, in milliseconds, to wait for the customer to continue speaking before treating the turn as complete.        |
| `beepboop_config`    | `max_wait_time_ms`                | number | 500 – 60000    | Maximum time, in milliseconds, to wait when analyzing an inbound automated tone (like a fax machine or answering system). |

### Full Example

```sfdocs-code {"lang":"agentscript", "title": "Full Voice Modality"}
modality voice:
    inbound_filler_words_detection: True
    inbound_keywords:
        keywords:
            - "urgent"
            - "emergency"
    voice_id: "UgBBYS2sOqTuMpoF3BR0"
    outbound_speed: 1.0
    outbound_style_exaggeration: 0.5
    pronunciation_dict:
        - grapheme: "Eliquis"
          phoneme: "ɛlɪkwɪs"
          type: "IPA"
    outbound_filler_sentences:
        - waiting: ["Let me look into that...", "Give me a moment..."]
    additional_configs:
        speak_up_config:
            speak_up_first_wait_time_ms: 10000
            speak_up_follow_up_wait_time_ms: 10000
            speak_up_message: "Are you still there?"
        endpointing_config:
            max_wait_time_ms: 1000
        beepboop_config:
            max_wait_time_ms: 1000
```

:::note
The voice modality requires a deterministic locale. If your agent uses a `language` block with `adaptive: True`, adaptive language mode is ignored on voice channels and a warning is emitted. Configure a specific `default_locale` in the language block when pairing it with `modality voice`.
:::

To branch agent logic based on the customer's current channel at runtime (as opposed to configuring voice-specific behavior here), use the [`@system_variables.current_modality`](reference/ascript-ref-variables-system.md#current_modality) system variable.

## Connection Block

Use the connection block to describe how this agent interacts with outside connections. For instance, this code snippet shows how the agent interacts with [Enhanced Chat](https://help.salesforce.com/s/articleView?id=service.miaw_intro_landing.htm).

```sfdocs-code {"lang":"agentscript", "title": "Connection Block"}
connection messaging:
    escalation_message: "One moment while I connect you to the next available service representative."
    outbound_route_type: "OmniChannelFlow"
    outbound_route_name: "agent_support_flow"
    adaptive_response_allowed: True
```

You can use the connection block alongside the [@utils.escalate](reference/ascript-ref-utils.md#utilsescalate) command.

## Subagent Blocks

Use the subagent block to specify the instructions, logic, and actions for a subagent. A subagent block contains a description, a list of actions, and the reasoning instructions. To define a connection to another Agentforce agent in your Salesforce org, see [Connected Subagent Blocks](#connected-subagent-block).

```sfdocs-code {"lang":"agentscript", "title": "Subagent Block"}
subagent Order_Management:
    description: "Handles order lookup, order updates, and summaries including status, date, location, items, and driver."

    reasoning:
        instructions: ->
            if @variables.order_summary == "":
                run @actions.lookup_current_order
                with member_email=@variables.member_email
                set @variables.order_summary=@outputs.order_summary

            | Refer to the user by name {!@variables.member_name}.
              Show their current order summary: {!@variables.order_summary} when conversation starts or if requested.
              If they want past order info, ask for Order ID and use {!@actions.lookup_order}.

        actions:
            lookup_order: @actions.lookup_order
                with query = ...
                set @variables.order_summary=@outputs.order_summary
                set @variables.order_id=@outputs.order_id

            lookup_current_order: @actions.lookup_current_order
                with member_email=@variables.member_email
                set @variables.order_summary=@outputs.order_summary
                set @variables.order_id=@outputs.order_id

    actions:
        lookup_order:
            description: "Retrieve order details."
            inputs:
                query: string
            outputs:
                order_summary: string
                order_id: string
            target: "flow://SvcCopilotTmpl__GetOrdersByContact"


        lookup_current_order:
            description: "Retrieve current order details."
            inputs:
                member_email: string
            outputs:
                order_summary: string
                order_id: string
            target: "flow://SvcCopilotTmpl__GetOrderByOrderNumber"
```

These properties make up a subagent block:

- **subagent name**: This value is the name of the subagent that should accurately describe the scope and purpose of this subagent in a few words. Because this value can’t have spaces, use `snake_case` to name the subagent.
- **description**: This property contains the description for this subagent. This value should help the agent determine when to use this subagent based on the user’s intent.
- **system.instructions** (optional): Override system-level system instructions for this subagent only. By overriding system-level instructions, you can avoid giving conflicting intructions to the LLM, which can cause unexpected agent behavior. You can also change the agent's voice & tone for a specific subagent. See [Avoid Conflicting Instructions with Instruction Overrides](./patterns/ascript-patterns-system-overrides.md).
- **reasoning**: This section contains information sent to the reasoning engine. Its primary properties are instructions and actions.
  - **reasoning.instructions**: This property contains guidance for the reasoning engine after it has decided that this subagent is relevant to the user's request. The reasoning instructions can be a combination of logic instructions and prompt-based instructions. See [Reasoning Instructions](reference/ascript-ref-instructions.md).
  - **reasoning.actions**: The list of tools that are applicable for the reasoning engine to use. This list can point to agent actions listed in the higher-level actions section, as well as other functionality available to the reasoning engine (such as transitioning to another subagent, or setting a variable's value). See [Tools (Reasoning Actions)](reference/ascript-ref-tools.md).
- **actions**: This section defines the agent actions available from this subagent. It contains a description of the action, the list of inputs and outputs, and the target location where this action resides. If you want to allow the reasoning engine to use one of these agent actions, you must also point to this action from the `reasoning.actions` section. See [Actions](reference/ascript-ref-actions.md).

## Connected Subagent Block

Use the `connected_subagent` block to define a connection to another Agentforce agent in your Salesforce org. Connected subagents differ from [subagents](#subagent-blocks) that are part of your current agent. A connected subagent represents a complete, independent agent with its own distinct expertise and identity. A connected subagent can contain one or more subagents of its own. You can use a connected subagent in a [reasoning action](reference/ascript-ref-actions.md#using-actions) to delegate tasks to another Agentforce agent.

For more information about using multiple agents in a Salesforce org, see [Multi-Agent Orchestration](https://help.salesforce.com/s/articleView?id=ai.agent_multi_orch.htm&type=5) and [Agent Script in Multi-Agent Solutions](https://help.salesforce.com/s/articleView?id=ai.agent_multi_orch_script.htm&type=5) in Salesforce Help.

```sfdocs-code {"lang":"agentscript", "title": "Example - Define the CRM_Agent Connected Subagent"}
connected_subagent CRM_Agent:
    label: "CRM_Agent"
    target: "agentforce://X00Dfi200000dpFZ_CRM_Agent"
    loading_text: |
        Fetching CRM information....
    description: "Use this tool for any request about CRM information"
    # define input variables that you'll use to pass information to the connected agent
    inputs:
        EndUserLanguage: string = @variables.EndUserLanguage
        currentRecordId: string = @variables.currentRecordId
```

```sfdocs-code {"lang":"agentscript", "title": "Example - Delegate Control to a Connected Subagent (Handoff Mode)"}
start_agent agent_router:
    model_config:
        model: "model://sfdc_ai__DefaultEinsteinHyperClassifier"
    reasoning:
        actions:
            go_to_crm: @utils.transition to @connected_subagent.CRM_Agent
```

```sfdocs-code {"lang":"agentscript", "title": "Example - Route to the Connected Subagent and Supervise its Output (Supervisor Mode)"}
start_agent agent_router:
    label: "Agent Router"
    description: "Welcome the user and determine the appropriate subagent based on user input"
    reasoning:
        instructions: ->
            | Select the best tool to call based on conversation history and user's intent.
        actions:
            # transition to a subagent
            go_to_off_topic: @utils.transition to @subagent.off_topic

            # Route to the CRM_Agent connected subagent
            crm_agent: @connected_subagent.CRM_Agent
```

These properties make up a `connected_subagent` block:

- **connected_subagent name**: The name used to reference this connected subagent elsewhere in your Agent Script.
- **target**: The URI identifying the Agentforce agent (also called the reference agent). This value is filled in when you [connect an agent as a subagent in Agentforce Builder](https://help.salesforce.com/s/articleView?id=ai.agent_multi_orch_connect.htm&type=5).
- **label** (optional): A human-readable label for the connected subagent.
- **description** (required): Describes the connected subagent's capabilities or when it should be called. This description helps the reasoning engine decide when to delegate to the connected subagent.
- **loading_text** (optional): A message shown to the customer while the connected subagent runs.
- **inputs** (optional): Values passed to the connected subagent. Each input binding has two sides:

  - The **left side** (for example, `customer_id`) is a custom, or mutable, variable defined in the connected subagent (that is, in the other Agentforce agent).
  - The **right side** (for example, `@variables.Customer_Id`) binds the connected subagent's input to a variable in the calling agent. These variables can be either context, or linked variables, or custom, or mutable variables.

  For example, suppose your input is `customer_id: string = @variables.Customer_Id`. The connected subagent's `customer_id` variable receives the value of the calling agent's `Customer_Id` variable.

:::note
In this release, variables are passed in one direction only: from the orchestrator agent to the connected subagent. Variables aren’t passed from a connected subagent back to the orchestrator agent.
:::

- **after_response** (optional): Runs after the connected subagent has responded to the user.
  - **if/then (conditional)** - branch on outcome.
  - **set** - set the value of a custom, or mutable, variable for the pipeline.
  - **transition** - delegate control to the next connected subagent. Any script commands placed after the
    transition are skipped.
- **delegate_escalation** (optional): If `True`, allows the connected subagent to escalate to a human representative. Applies only if the connected subagent is in handoff mode. Otherwise, if unspecified, or if the orchestrator agent is in supervision mode, escalation to a human occurs in the orchestrator agent only.

## Start Agent Block

The start agent block (called the "Agent Router" in Canvas view) is a subagent that uses the `start_agent` prefix instead of the `subagent` prefix. With every customer utterance, the agent begins execution at this block. The `start_agent` subagent is used to initiate the conversation, and typically determines when to switch to the agent's other subagents. This block handles subagent classification, filtering, and routing.

```sfdocs-code {"lang":"agentscript", "title": "Start Agent Block"}
start_agent agent_router:
    description: "Welcome the user and determine the appropriate subagent based on user input"
    reasoning:
        instructions: |
            You are an agent router for this assistant. Welcome the guest
            and analyze their input to determine the most appropriate subagent
            to handle their request.
        actions:
            go_to_identity: @utils.transition to @subagent.Identity_Verification
                description: "Verifies user identity"
                available when @variables.verified == False
            go_to_order: @utils.transition to @subagent.Order_Management
                description: "Handles order lookup, refunds, and order updates."
                available when @variables.verified == True
            go_to_faq: @utils.transition to @subagent.General_FAQ
                description: "Handles various frequently asked questions."
                available when @variables.verified == True
            go_to_escalation: @utils.transition to @subagent.Escalation
                description: "Handles escalation to a human rep."
                available when @variables.verified == True and @variables.is_business_hours == True
```

For more guidance on how to use the start agent block for subagent routing and filtering, see [Subagent Classification and Routing](https://help.salesforce.com/s/articleView?id=ai.agent_topics_routing.htm) in Salesforce Help.

## Related Topics

- [Agent Script Patterns](./patterns/ascript-patterns.md)
- [Agent Script Reference](reference/ascript-reference.md)
- [Configure Models in Agent Script](./ascript-model.md)
- [Configure Voice Models in Agent Script](./ascript-voice.md)

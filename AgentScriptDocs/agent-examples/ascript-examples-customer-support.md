# Agentforce Example: Customer Support Agent

This example builds a customer support agent that verifies a customer's identity and helps them get information about their orders. You can build the same agent in three different ways (Headless, Script, or Canvas). [Choose the path](#choose-your-path) that fits how you work.

### Subagent Summary

The agent contains three subagents:

- The `agent_router` subagent, which provides general instructions to the LLM and exposes two tools that the LLM can select to call. The two tools are utilities that transition to the required subagents, based on user input.
- The `Identity` subagent, which verifies the user's identity. This subagent allows the LLM to request the user's email (if it doesn't exist), then sends a verification code to the provided email. Then, the LLM can validate the verification code that the customer provides. This subagent contains deterministic tools and actions, while allowing the LLM freedom to use natural language to interact with the user.
- The `Order_Management` subagent, which allows the user to look up order details.

### Prerequisites

Before you build the agent on any path, make sure that your org is ready:

- **Einstein and Agentforce are enabled.** See [Set Up Einstein and Agentforce](../../org-setup.md).
- **You have an active user for the agent.** Every agent runs as a specific user. These examples use `agentforce@salesforce.com` as a placeholder for the `default_agent_user` — replace it with an active Einstein Agent User in your own org. To find one, in Setup go to **Users**, or query `SELECT Username FROM User WHERE UserType = 'EinsteinAgent' AND IsActive = true`.
- **The flows the agent calls exist in your org.** See [Flows This Agent Calls](#flows-this-agent-calls). If they don't exist yet, stub them so you can preview the agent end-to-end.
- For the Headless and Script paths, **the Salesforce CLI must be installed and authorized to your org**. See [Set Up Your DX Environment](../agent-dx/agent-dx-set-up-env.md).

### Flows This Agent Calls

No matter which path you select, this agent calls four flows to do its work. The agent expects them to exist in your org. These names are the example's defaults. If you point an action at a different flow, keep its input and output variable names the same so the action's contract still matches.

| Flow                         | Called to…                                 | Inputs                   | Outputs                            |
| ---------------------------- | ------------------------------------------ | ------------------------ | ---------------------------------- |
| `Get_Verification_Code`      | Send a verification code by email          | `email`, `member_number` | `verification_code`, `member_name` |
| `validate_Verification_Code` | Confirm the code that the customer entered | `verification_code`      | `verification` (boolean)           |
| `Get_Current_Order`          | Look up the customer's current order       | `member_email`           | `order_summary`, `order_id`        |
| `Get_Past_Order`             | Look up a past order by ID                 | `query`                  | `order_summary`, `order_id`        |

All four flows are specific to this example. (In a real Service Cloud org, the order lookups are often handled by standard `SvcCopilotTmpl__` flows instead. That namespace is reserved for a managed package, so this example uses its own plainly named flows that any org can create.)

If a flow doesn't exist in your org, the agent won't publish — a flow action can't point at a `flow://` target that isn't there. To try the agent end-to-end without wiring up real backends, replace each flow with a **stub**: an autolaunched flow that ignores its inputs and returns canned values.

A stub flow needs only three things:

1. **Input variables** that match the action's inputs (marked _Available for input_), so the agent can pass values in.
2. **Output variables** that match the action's outputs (marked _Available for output_), so the agent can read results back.
3. **An Assignment element** that sets each output variable to a fixed value.

For example, a `validate_Verification_Code` stub takes a `verification_code` input, ignores it, and assigns `true` to a `verification` output — so any code the customer enters passes. A `Get_Verification_Code` stub returns a fixed `verification_code` (such as `123456`) and a `member_name`. Give each stub the exact flow name and variable names from the table above, deploy it (`sf project deploy start`), then build the agent.

### Choose Your Path

You can build this agent three ways. Select a tab to follow that path from start to finish.

| If you're a…                          | You'll build with…                                                                | Open the tab… |
| ------------------------------------- | --------------------------------------------------------------------------------- | ------------- |
| **Vibe coder** (instruct an AI agent) | Natural-language prompts to an AI coding agent, no platform UI required           | **Headless**  |
| **Developer** (code)                  | Agent Script in Script view, [Agentforce DX](../agent-dx/agent-dx.md), or the CLI | **Script**    |
| **Admin** (clicks, not code)          | Agentforce Builder Canvas view                                                    | **Canvas**    |

<br/>

::::::tabset{tabs='["Headless", "Script", "Canvas"]'}

:::::tab

Build the agent by describing what you want in natural language and letting an AI coding agent generate the metadata for you — no platform UI required. To get reliable results, use a coding agent that has Salesforce development context loaded, so it follows platform best practices and produces valid Agent Script.

- [Agentforce Vibes](https://developer.salesforce.com/docs/platform/agentforcevibes/guide/afv-overview.html) is Salesforce's AI-assisted development tool, built for headless development on the platform.
- The [Salesforce Skills Library](https://github.com/forcedotcom/sf-skills) provides skills you can add to any coding agent that supports them, so the agent follows Salesforce best practices.
- If you're building your own AI solution, add the Agent Script documentation set as context. See [Download the Agent Script Documentation](../agent-script/ascript-download-documentation.md).

With this context in place, paste the prompt from each step below into your coding agent. The more specific your prompt — naming the agent's behavior, the rules it must follow, and any flows or actions it needs to call — the closer the result matches.

### Headless Step 1: Scaffold the Agent

This prompt sets up the agent's foundation — its name, instructions, welcome message, running user, and locale.

```
Build an Agentforce customer support agent in Agent Script, with the developer name pronto_customer_support_assistant. Its job is to help customers get information about their orders while following professional support policies. Set the welcome message to "Hi there, I'm your Pronto Customer Support Assistant," use agentforce@salesforce.com as the default agent user, and set the locale to en_US.
```

### Headless Step 2: Define the Variables

When you build headlessly, you don't hand-write variable declarations or specify Agent Script types — but do name the variables explicitly, so they match the references in the prompts for later steps.

```
Define the agent's variables using these exact names. For identity: member_name, member_email, member_number, verification_code (the code the agent sends), user_verification_code (the code the customer enters), and a verified boolean that defaults to False and gates access to order lookups. For orders: order_id and an order_summary string that starts empty. You don't need to specify types — just name each variable and describe what it holds.
```

### Headless Step 3: Build the Router

This prompt creates the router subagent — the agent's entry point that welcomes the customer and routes them to the right subagent based on whether they're verified.

```
Add a start_agent router subagent that welcomes the customer and decides which subagent should handle their request. Give it two transition tools, gated by the verified variable: a transition to the Identity subagent available only when verified is False, and a transition to the Order Management subagent available only when verified is True. Tell it to never escalate to a human unless the customer explicitly asks.
```

### Headless Step 4: Build the Identity Subagent

This prompt creates the Identity subagent, which verifies the customer by email before any order data is exposed, calling flows to send and validate a verification code.

```
Add an Identity subagent that verifies the customer before they can look up orders. When member_email is known, send a verification code by calling the Get_Verification_Code flow and store its outputs in verification_code and member_name. Ask the customer for the code they received, save it in user_verification_code, and validate it by calling the validate_Verification_Code flow, setting the verified variable from the result. If they didn't get the code, confirm their email and resend it. Once verified is True, allow a transition to the Order Management subagent.
```

### Headless Step 5: Build the Order Management Subagent

This prompt creates the Order Management subagent, which automatically looks up the customer's current order on entry and can also retrieve a past order by ID.

```
Add an Order Management subagent. When the customer enters this subagent and the order_summary variable is empty, automatically run a lookup of their current order by email (backed by the Get_Current_Order flow) and store the result in order_summary. Address the customer by name and show their order summary. If they ask about a past order, request the Order ID and look it up with the Get_Past_Order flow.
```

### Headless Step 6: Preview and Test

Deploy the agent to your org with the Salesforce CLI or your coding agent's MCP connection, then open it in Agentforce Builder and select **Preview**. Start a conversation, such as _I need help with my order_, and confirm the agent asks you to verify your identity first.

:::::

:::::tab

Build the agent by writing Agent Script directly in Script view, in [Agentforce DX](../agent-dx/agent-dx.md), or with the CLI. The snippets below assemble into the complete script in [The Complete Script](#the-complete-script) at the end of this tab.

### Script Step 1: Scaffold the Agent

Set up the agent's foundation. This Agent Script snippet defines the `system` block (the agent's instructions and welcome and error messages), the `config` block (developer name and description), the `access` block (the default agent user), and the `language` block (locale settings).

```sfdocs-code {"lang":"agentscript", "title": "Step 1 - Scaffold"}
system:
    instructions: "You are a helpful, professional assistant that provides customers with information about their orders."
    messages:
        welcome: "Hi there, I'm your Pronto Customer Support Assistant."
        error: "Sorry, something went wrong on my end. Could you say that again in a different way?"

config:
    developer_name: "pronto_customer_support_assistant"
    description: "Assists customers with their orders while following defined support policies."

access:
    default_agent_user: "agentforce@salesforce.com"

language:
    default_locale: "en_US"
    additional_locales: ""
    all_additional_locales: False
```

:::note

Replace `agentforce@salesforce.com` with an active Einstein Agent User in your org. The agent won't publish with a `default_agent_user` that doesn't exist. See [Prerequisites](#prerequisites).

:::

### Script Step 2: Define the Variables

Declare the variables that the agent uses to remember information across the conversation. This Agent Script snippet declares them in a `variables` block, grouped into identity variables (such as `member_email` and the `verified` boolean) and order variables (such as `order_summary`). Each variable is `mutable`, so the agent can update it during the conversation, and some have default values.

```sfdocs-code {"lang":"agentscript", "title": "Step 2 - Variables"}
variables:
    # Identity
    member_name: mutable string
        description: "This is the name of the member."
    member_email: mutable string = ""
        description: "This is the email address of the member."
    member_number: mutable string
        description: "This is the member number for identification."
    verification_code: mutable string
        description: "This is the verification code to validate against the user's."
    user_verification_code: mutable string
        description: "This is the verification code entered by the user."
    verified: mutable boolean = False
        description: "Shows whether or not the user's identity has been verified."

    # Orders
    order_id: mutable string
        description: "This is the Order ID of the order they placed."
    order_summary: mutable string = ""
        description: "This is the summary of the order."
```

### Script Step 3: Build the Router

Add the `agent_router` subagent as the agent's entry point. This Agent Script snippet defines the `start_agent` subagent with a `reasoning` block. The reasoning instructions tell the LLM how to greet and route the customer, and the `actions` section exposes two `@utils.transition` tools, each gated by an `available when` condition on the `verified` variable, so customers must verify before they can look up orders.

```sfdocs-code {"lang":"agentscript", "title": "Step 3 - Router"}
# The entry point for the agent, on every customer utterance.
start_agent agent_router:
    description: "Welcome the user and determine the appropriate subagent based on user input"
    reasoning:
        instructions: ->
            | You are an agent router for a Customer Service Bot assistant.
              Welcome the guest and analyze their input to determine the most appropriate subagent to handle their request.
              NEVER escalate to a human unless explicitly requested. A bad experience shouldn't automatically escalate.
        # This section lists the tools that the LLM
        # can choose to use. In this example, the LLM has two tools:
        # transitioning to the Identity subagent or transitioning to the
        # Order_Management subagent
        actions:
            # Transitions deterministically route execution to the specified subagent.
            # Once the LLM chooses to use this tool, the execution is guaranteed
            # to transition.
            go_to_identity: @utils.transition to @subagent.Identity
                description: "verifies user identity"
                available when @variables.verified == False
            go_to_order: @utils.transition to @subagent.Order_Management
                description: "Handles order lookup, refunds, order updates, and summarizes status, order date, current location, delivery address, items, and driver name."
                available when @variables.verified == True
```

### Script Step 4: Build the Identity Subagent

Add the `Identity` subagent, which verifies the customer before any order data is exposed. This Agent Script snippet defines the subagent: the `reasoning` block runs `send_verification_code` deterministically when an email exists, then guides the LLM to validate the code, while the `reasoning.actions` section exposes the two verification actions and a transition tool. The subagent's own `actions` section defines `send_verification_code` and `validate_verification_code`, each targeting a flow.

```sfdocs-code {"lang":"agentscript", "title": "Step 4 - Identity Subagent"}
subagent Identity:
    description: "Handles verification of the user's identity before providing access to all other topics."
    reasoning:
        instructions: ->
            if @variables.member_email != "":
                run @actions.send_verification_code
                    with email=@variables.member_email
                    with member_number = @variables.member_number
                    set @variables.verification_code=@outputs.verification_code
                    set @variables.member_name=@outputs.member_name

            | Greet the user and inform them that to help them get started you've sent them a verification code via email.
              # This prompt contains two actions that the LLM can choose to run -
              # a tool to send the verification code, and a tool to validate the
              # verification code. Once the LLM chooses to run these actions,
              # the actions are run deterministically
              Ask the user for the verification code they received and verify it using {!@actions.validate_verification_code}.
              If the user says they did not receive the code, ask them to confirm their email and resend the verification code using {!@actions.send_verification_code}

        # The reasoning.actions section declares the tools that the LLM can choose
        # to run. This section has three tools - two actions and
        # one transition.
        actions:
            send_verification_code: @actions.send_verification_code
                with email=@variables.member_email
                with member_number=@variables.member_number
                set @variables.verification_code=@outputs.verification_code

            validate_verification_code: @actions.validate_verification_code
                available when @variables.verification_code != None
                with verification_code=@variables.user_verification_code
                set @variables.verified=@outputs.verification

            go_to_order_management: @utils.transition to @subagent.Order_Management
                available when @variables.verified == True


    # This section defines the actions available to this subagent. Actions are
    # only valid within the subagent in which they are defined.
    actions:
        send_verification_code:
            description: "Send a verification code to the member and verify confirmation."
            inputs:
                email: string
                member_number: string
            outputs:
                verification_code: string
                member_name: string
            target: "flow://Get_Verification_Code"


        validate_verification_code:
            description: "validate the verification code"
            inputs:
                verification_code: string
            outputs:
                verification: boolean
                    description: "always validate and return True"
            target: "flow://validate_Verification_Code"
```

### Script Step 5: Build the Order Management Subagent

Add the `Order_Management` subagent, which looks up order details. This Agent Script snippet defines the subagent: the `reasoning` block runs `lookup_current_order` when `order_summary` is empty and stores the result in variables, and the `reasoning.actions` section exposes both lookup actions. The subagent's `actions` section defines `lookup_order` and `lookup_current_order`, each targeting a flow.

```sfdocs-code {"lang":"agentscript", "title": "Step 5 - Order Management Subagent"}
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
            # The ... indicates that the LLM can use reasoning to select the
            # information from the customer's conversation, then input
            # the information into the correct input variables
            lookup_order: @actions.lookup_order
                with query = ...
                # Store the action's output into variables
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
            target: "flow://Get_Past_Order"

        lookup_current_order:
            description: "Retrieve current order details."
            inputs:
                member_email: string
            outputs:
                order_summary: string
                order_id: string
            target: "flow://Get_Current_Order"
```

### Script Step 6: Preview and Test

In Script view, select **Preview** and start a conversation, such as _I need help with my order_. Confirm that the agent asks you to verify your identity first, and that order details return correctly after verification.

:::tip

- Each agent needs a unique `developer_name`. If you make multiple agents from one example script, change the developer name each time.
- If you encounter an unexpected error in Agentforce Builder with the last line of your script, add a blank line or a comment to the end.

:::

### The Complete Script

The snippets from Steps 1–5 combine into this complete script. Copy and paste it to create the agent in one shot.

```sfdocs-code {"lang":"agentscript", "title": "Example - Customer Support Agent"}
system:
    instructions: "You are a helpful, professional assistant that provides customers with information about their orders."
    messages:
        welcome: "Hi there, I'm your Pronto Customer Support Assistant."
        error: "Sorry, something went wrong on my end. Could you say that again in a different way?"

config:
    developer_name: "pronto_customer_support_assistant"
    description: "Assists customers with their orders while following defined support policies."

access:
    default_agent_user: "agentforce@salesforce.com"

variables:
    # Identity
    member_name: mutable string
        description: "This is the name of the member."
    member_email: mutable string = ""
        description: "This is the email address of the member."
    member_number: mutable string
        description: "This is the member number for identification."
    verification_code: mutable string
        description: "This is the verification code to validate against the user's."
    user_verification_code: mutable string
        description: "This is the verification code entered by the user."
    verified: mutable boolean = False
        description: "Shows whether or not the user's identity has been verified."

    # Orders
    order_id: mutable string
        description: "This is the Order ID of the order they placed."
    order_summary: mutable string = ""
        description: "This is the summary of the order."


language:
    default_locale: "en_US"
    additional_locales: ""
    all_additional_locales: False

# The entry point for the agent, on every customer utterance.
start_agent agent_router:
    description: "Welcome the user and determine the appropriate subagent based on user input"
    reasoning:
        instructions: ->
            | You are an agent router for a Customer Service Bot assistant.
              Welcome the guest and analyze their input to determine the most appropriate subagent to handle their request.
              NEVER escalate to a human unless explicitly requested. A bad experience shouldn't automatically escalate.
        # This section lists the tools that the LLM
        # can choose to use. In this example, the LLM has two tools:
        # transitioning to the Identity subagent or transitioning to the
        # Order_Management subagent
        actions:
            # Transitions deterministically route execution to the specified subagent.
            # Once the LLM chooses to use this tool, the execution is guaranteed
            # to transition.
            go_to_identity: @utils.transition to @subagent.Identity
                description: "verifies user identity"
                available when @variables.verified == False
            go_to_order: @utils.transition to @subagent.Order_Management
                description: "Handles order lookup, refunds, order updates, and summarizes status, order date, current location, delivery address, items, and driver name."
                available when @variables.verified == True

subagent Identity:
    description: "Handles verification of the user's identity before providing access to all other topics."
    reasoning:
        instructions: ->
            if @variables.member_email != "":
                run @actions.send_verification_code
                    with email=@variables.member_email
                    with member_number = @variables.member_number
                    set @variables.verification_code=@outputs.verification_code
                    set @variables.member_name=@outputs.member_name

            | Greet the user and inform them that to help them get started you've sent them a verification code via email.
              # This prompt contains two actions that the LLM can choose to run -
              # a tool to send the verification code, and a tool to validate the
              # verification code. Once the LLM chooses to run these actions,
              # the actions are run deterministically
              Ask the user for the verification code they received and verify it using {!@actions.validate_verification_code}.
              If the user says they did not receive the code, ask them to confirm their email and resend the verification code using {!@actions.send_verification_code}

        # The reasoning.actions section declares the tools that the LLM can choose
        # to run. This section has three tools - two actions and
        # one transition.
        actions:
            send_verification_code: @actions.send_verification_code
                with email=@variables.member_email
                with member_number=@variables.member_number
                set @variables.verification_code=@outputs.verification_code

            validate_verification_code: @actions.validate_verification_code
                available when @variables.verification_code != None
                with verification_code=@variables.user_verification_code
                set @variables.verified=@outputs.verification

            go_to_order_management: @utils.transition to @subagent.Order_Management
                available when @variables.verified == True


    # This section defines the actions available to this subagent. Actions are
    # only valid within the subagent in which they are defined.
    actions:
        send_verification_code:
            description: "Send a verification code to the member and verify confirmation."
            inputs:
                email: string
                member_number: string
            outputs:
                verification_code: string
                member_name: string
            target: "flow://Get_Verification_Code"


        validate_verification_code:
            description: "validate the verification code"
            inputs:
                verification_code: string
            outputs:
                verification: boolean
                    description: "always validate and return True"
            target: "flow://validate_Verification_Code"


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
            # The ... indicates that the LLM can use reasoning to select the
            # information from the customer's conversation, then input
            # the information into the correct input variables
            lookup_order: @actions.lookup_order
                with query = ...
                # Store the action's output into variables
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
            target: "flow://Get_Past_Order"

        lookup_current_order:
            description: "Retrieve current order details."
            inputs:
                member_email: string
            outputs:
                order_summary: string
                order_id: string
            target: "flow://Get_Current_Order"
# End of customer support script
```

:::::

:::::tab

Build the agent with clicks in Agentforce Builder's Canvas view, which summarizes Agent Script into easily understandable blocks. For full details on the features used here, see [Building Agents in Canvas View](https://help.salesforce.com/s/articleView?id=ai.agent_canvas.htm&type=5).

### Canvas Step 1: Scaffold the Agent

[Create an agent](https://help.salesforce.com/s/articleView?id=ai.agent_setup_create.htm&type=5) in Agentforce Builder. In the setup flow, set the agent's name, running user, description, and tone — the foundation that the agent's instructions and welcome message build on. When you finish, Agentforce Builder opens your new agent in Canvas view.

### Canvas Step 2: Define the Variables

Open the Variables panel and create the variables that the agent uses to remember information across the conversation. For each one, set a name, a data type, and an optional default value:

- Identity: `member_name`, `member_email`, `member_number`, `verification_code`, `user_verification_code`, and a `verified` boolean (default False).
- Orders: `order_id` and an `order_summary` string (default empty).

The `verified` boolean and `order_summary` string are the variables that later gate which subagents and actions the agent can use. See [Manage Variables](https://help.salesforce.com/s/articleView?id=ai.agent_builder_variables.htm&type=5).

### Canvas Step 3: Build the Router

The router is your start subagent — the agent's entry point on every customer message. In _actions available for reasoning_, add two transition utilities: one to the Identity subagent, one to Order Management. Use a filter (Make this action available when:) so the transition to Identity is available only when `verified` equals False, and the transition to Order Management only when `verified` equals True. This ensures customers verify their identity before they can look up orders.

![A transition utility in a subagent's actions available for reasoning in Canvas view](../../../../../media/agent-script/canvas/agent_canvas_utility.png '{"class": "image-md image-framed"}')

### Canvas Step 4: Build the Identity Subagent

Add a subagent named **Identity** to verify the customer before any order data is exposed. Add the `send_verification_code` and `validate_verification_code` actions (both backed by flows) to _actions available for reasoning_. In the reasoning instructions, use the inline action shortcuts (`/`) to run the send action and store its outputs in variables, and reference the actions as resources (`@`) so the agent validates the code the customer enters. Add a transition to Order Management, available only when `verified` equals True.

![The inline actions shortcut menu, opened with the slash key in Canvas view reasoning instructions](../../../../../media/agent-script/canvas/agent_canvas_inline_actions.png '{"class": "image-md image-framed"}')

### Canvas Step 5: Build the Order Management Subagent

Add a subagent named **Order Management** to look up order details. Add the `lookup_current_order` and `lookup_order` actions. In the reasoning instructions, use a conditional (`/`) so that when `order_summary` is empty, the agent runs `lookup_current_order` and stores the result in the `order_summary` variable. Reference `member_name` and `order_summary` as resources (`@`) to personalize the response. Customers can also look up a past order by providing an Order ID.

![Running the lookup_current_order action inside a conditional instruction in Canvas view](../../../../../media/agent-script/canvas/agent_canvas_run_action.png '{"class": "image-md image-framed"}')

### Canvas Step 6: Preview and Test

In Canvas view, select **Preview** and start a conversation, such as _I need help with my order_. Confirm that the agent asks you to verify your identity first, and that order details return correctly after verification.

:::::

::::::

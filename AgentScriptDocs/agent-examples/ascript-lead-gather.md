# Collect Customer Information to Create a Record

Reliably collect customer input across multiple turns, then create a Salesforce record. Ensure that the agent collects all required information before creating the record. This example ensures the agent:

- Creates a record only **after** collecting **all** the required information.
- Reliably stores all provided information, even after multiple turns.
- Creates only one (not multiple) record per conversation.
- Confirms that a record creation actually happened.

### The Problem

A common agent pattern is to collect a lot of information from a customer, ask clarifying questions, verify the information is correct, and then create a Salesforce record. During multiple turns and long conversations, some agents can drop captured values, re-ask for information they already have, create half-filled records, or falsely confirm a record creation.

### The Solution

One solution is to create two subagents. (One subagent)[#add-the-lead-gather-subagent] gathers customer information and stores the information in variables. The subagent's `after_reasoning` block checks whether all variables have values - if so, it runs the action to create the record. If the record ID is returned (indicating the record was created), the `after_reasoning` block transitions to a second subagent, which reports the record creation to the customer.

## Create a Flow to Create the Lead Record from Fields

Create a flow that creates a lead record with the customer-provided fields.

![Flow overall](../../../../../media/agent-script/collect-example_flow.jpg '{"class": "image-lg"}')

#### Step 1 - Create the Autolaunched Flow

1. From the app launcher, enter flows, and then select **Flows**.

2. Click **New Flow**.

3. Select the **Autolaunched** category, and then select **Autolaunched Flow (No Trigger)**.

#### Step 2 - Create the Flow Variables

Expand the toolbox (button on the far left). Using the **New Resource** button, create six variables defined as follows. Match the API names exactly — they map to the agent action's inputs and outputs.

| Resource Type | API Name       | Data Type | Available for input | Available for output |
| ------------- | -------------- | --------- | ------------------- | -------------------- |
| Variable      | `Company`      | Text      | **select**          | **don't** select     |
| Variable      | `Email`        | Text      | **select**          | **don't** select     |
| Variable      | `FirstName`    | Text      | **select**          | **don't** select     |
| Variable      | `LastName`     | Text      | **select**          | **don't** select     |
| Variable      | `Phone`        | Text      | **select**          | **don't** select     |
| Variable      | `leadRecordId` | Text      | **don't** select    | **select**           |

Click Save. Name the flow **Create Lead by Field** and ensure the flow's API name is `Create_Lead_by_Field`.

:::important
We use this flow name later in the agent script. It needs to match, otherwise you'll have to edit your script by hand.
:::

#### Step 3 - Get Existing Lead

Before creating a new lead record, we'll use the provided email and company name to see if that lead record exists.

1. Add a Get Records Element.
   1. For the label, enter **Get Existing Lead**.
   2. For the object, select **Lead**.
2. Under Filter Lead Records, select **All Conditions Are Met (AND)**, then enter these values:

   | Field   | Operator | Value   |
   | ------- | -------- | ------- |
   | Email   | Equals   | Email   |
   | Company | Equals   | Company |

3. Under Sort Lead Records, for Sort Order, select **Not Sorted**.
4. Under How Many Records to Store, select **Only the first record**.
5. Under How to Store Record Data, select **Choose fields and let Salesforce do the rest**.
6. Under Select Lead Fields to Store in Variable, leave the first Field set to **Id**. You don't need to add additional fields — the flow only uses the lead Id to detect an existing record.

![get records element to get matching record](../../../../../media/agent-script/getExistingLead.jpg '{"class": "image-lg"}')

#### Step 4 - Check Whether the Lead Exists

Branch the flow based on whether Get Existing Lead returned a matching lead.

1. Add a Decision element after **Get Existing Lead**.
   1. For the label, enter **Lead Exists?**. The API Name auto-fills as `Lead_Exists`.
2. Under Select Decision Logic, select **Define Manually (Default)**.
3. Under Outcomes, configure the **Yes** outcome to run when a matching Lead was found.

   1. For Outcome Label, enter **Yes**.
   2. For Outcome API Name, enter **Yes_Reuse**.
   3. For Condition Requirements to Execute Outcome, select **All Conditions Are Met (AND)**.
   4. Add this condition:

      | Resource                    | Operator | Value |
      | --------------------------- | -------- | ----- |
      | Get Existing Lead > Lead ID | Is Null  | False |

4. Select the default tab and rename it to **No**. The flow follows the No path when no matching lead exists.

![decision element to see if the lead exists](../../../../../media/agent-script/DecisionLeadExists.jpg '{"class": "image-lg"}')

#### Step 5 - Assign Existing Lead Id

On the **Yes** path, you'll copy the existing Lead's Id into `leadRecordId` so the flow returns the same value whether the lead was found or newly created.

1. On the **Yes** outcome from **Lead Exists?**, add an Assignment element.

   1. For the label, enter **Assign Existing LeadId**. The API Name auto-fills as `Assign_Existing_LeadId`.
   2. Under Set Variable Values, add this assignment:

   | Variable       | Operator | Value                       |
   | -------------- | -------- | --------------------------- |
   | `leadRecordId` | Equals   | Get Existing Lead > Lead ID |

2. Connect the Assignment element to its own **End** element, which terminates the decision's **Yes** path.

![decision element no path](../../../../../media/agent-script/DecisionLeadYes.jpg '{"class": "image-lg"}')

#### Step 6 - Add `LeadExampleAgent` to the LeadSource Picklist

To make sure your agent gets credit for this lead, we'll add `LeadExampleAgent` to the possible lead source values.

1. From Setup, click **Object Manager**.
2. Select **Lead**, then click **Fields & Relationships**.
3. Click **Lead Source**.
4. Under Account/Lead Source Picklist Values, click **New**, add `LeadExampleAgent`.
5. Click **Save**.

![decision element to see if the lead exists](../../../../../media/agent-script/LeadExample.jpg '{"class": "image-md"}')

#### Step 7 - Create the Lead

Add an element to create the lead, mapping the agent action's values to the variables [you created earlier](#step-2---create-the-flow-variables). **Match the API names exactly** — they map to the agent action's inputs.

1. On the **No** outcome from **Lead Exists?**, add a Create Records element.
   1. For the label, enter **Create Lead**. The API Name auto-fills as `Create_Lead`.
2. For How to set record field values, select **Manually**.
3. Under Create a Record of This Object, for Object, select **Lead**.
4. Under Set Field Values for the lead, add a row for each of these fields and map it to the indicated variable.

   | Field       | Value              |
   | ----------- | ------------------ |
   | Company     | `Company`          |
   | Email       | `Email`            |
   | First Name  | `FirstName`        |
   | Last Name   | `LastName`         |
   | Lead Source | `LeadExampleAgent` |
   | Phone       | `Phone`            |

5. Select **Manually assign variables (advanced)**.
6. Under Store Lead ID in Variable, for Variable, select **`leadRecordId`**.
7. Leave **Check for Matching Records** disabled — the **Lead Exists?** decision already handles the duplicate check.
8. Click **Save**.

![decision element to see if the lead exists](../../../../../media/agent-script/CreateLead.jpg '{"class": "image-lg"}')

#### Step 8 - Handle a Create Lead Fault

If the Create Lead element fails at runtime (for example, a validation rule rejects the record), the flow returns a lead Id anyway unless you explicitly clear it. Add a fault path that resets `leadRecordId` so the agent's `after_reasoning` gate treats the create as unsuccessful.

1. Hover over the **Create Lead** element so the three dots appear.
2. Click the three dots and select **Add Fault Path**.
3. On the fault path, add an Assignment element.
   1. For the label, enter **Clear LeadId On Fault**. The API Name auto-fills as `Clear_LeadId_On_Fault`.
4. Under Set Variable Values, add this assignment:

   | Variable       | Operator | Value                      |
   | -------------- | -------- | -------------------------- |
   | `leadRecordId` | Equals   | Blank Value (Empty String) |

5. Connect the Assignment element to an **End** element to terminate the fault path.

![decision element to see if the lead exists](../../../../../media/agent-script/faultpath.jpg '{"class": "image-lg"}')

#### Step 9 - Test the Flow

Test the flow.

1. In Flow Builder, click **Debug**.
2. Enter test values for `Company`, `Email`, `FirstName`, `LastName`, `Phone`.
3. Click **Run** and verify a lead is created (or the existing one is returned). Notice that the lead source is `LeadExampleAgent`.

#### Step 10 - Activate Your Flow

Click **Activate** in the upper right.

## Create Your Agent

You can create a new agent using the Agentforce Service Agent template, or you can add these subagents and variables to an existing agent.

### Step 1 - Create or Reuse an Agent

For this example, you can add the two subagents to an existing agent. Or, you can create a service agent from a template. To create a service agent:

1. In the App menu, enter and select Agentforce Builder.
2. Select **New Agent**, then select **Agentforce Service Agent**.
3. Give your agent a name, such as Lead Gather Example.
4. Accept **New User** to create a new agent user.
5. Switch to Script view (click the `</>`toggle in the upper left)

### Step 2 - Create the Variables

The agent uses variables to store customer input during the information-collection turns. The agent also needs a variable to hold the lead ID that the action returns.

1. Copy and paste these variables into your agent's existing `variables` block.

```sfdocs-code {"lang":"agentscript", "title": "Lead Gather Variables"}
# Variables from Lead Gather example
# variables:
    lead_id: mutable string = ""
        description: "Stores the record ID of the Lead created for the prospect."
        visibility: "Internal"
    company: mutable string = ""
        description: "Stores the prospect's company name."
        visibility: "Internal"
    email: mutable string = ""
        description: "Stores the prospect's email address."
        visibility: "Internal"
    first_name: mutable string = ""
        description: "Stores the prospect's first name."
        visibility: "Internal"
    last_name: mutable string = ""
        description: "Stores the prospect's last name."
        visibility: "Internal"
    phone: mutable string = ""
        description: "Stores the prospect's phone number."
        visibility: "Internal"

```

2. Save your agent.

:::note
The variable defaults matter. Our agent uses `""` to mean "not yet captured."
:::

## Add the Lead Gather Subagent

The Lead Gather subagent asks for the required information and captures any relevant information that is provided. The `after_reasoning` block, which runs after every reasoning loop, checks if all variables are populated. Once **all** the variables have values (this might take many conversational turns), the agent runs the `Create Lead_by_Field` action to create the lead. If the action returns a lead record ID, the `after_reasoning` section transitions to the lead confirmation subagent.

1. Copy this subagent script and paste the script at the end of your existing agent's script. If you followed the flow naming conventions, this subagent correctly uses the Create Lead by Field action.

```sfdocs-code {"lang":"agentscript", "title": "lead_gather Subagent"}
subagent lead_gather:
  label: "Lead Gather"
  description: "Collects prospect details and creates a lead."
  reasoning:
      instructions: ->
          | Ask for first name, last name, email, company, and phone number in one message.
          | Use {!@actions.capture_details} whenever the prospect supplies details.
          | Ask only for any remaining missing details.
          | Do not claim that the lead was created or that a meeting was scheduled.
      actions:
          capture_details: @utils.setVariables
              # this action is available ONLY if the lead hasn't been created yet this session
              # That is, the customer can't create a second unique lead in the same session
              available when @variables.lead_id == ""
              with company = ...
              with email = ...
              with first_name = ...
              with last_name = ...
              with phone = ...
  # after_reasoning is run after every reasoning session
  after_reasoning:

      # if we DON'T have all the variables we need, don't run the action
      if @variables.company != "" and @variables.email != "" and @variables.first_name != "" and @variables.last_name != "" and @variables.phone != "" and @variables.lead_id == "":
          run @actions.Create_Lead_by_Field
              with Company = @variables.company
              with Email = @variables.email
              with FirstName = @variables.first_name
              with LastName = @variables.last_name
              with Phone = @variables.phone
              set @variables.lead_id = @outputs.leadRecordId

      # if we DID create a lead, transition to the Lead Confirmation subagent
      if @variables.lead_id != "":
          transition to @subagent.lead_confirmation
  actions:
      Create_Lead_by_Field:
          description: "Creates a Lead record from the prospect details captured in the conversation."
          label: "Create Lead by Field"
          require_user_confirmation: False
          include_in_progress_indicator: True
          target: "flow://Create_Lead_by_Field"
          inputs:
              "Company": string
                  description: "The prospect's company name."
                  label: "Company"
                  is_required: True
                  is_user_input: False
              "Email": string
                  description: "The prospect's email address."
                  label: "Email"
                  is_required: True
                  is_user_input: False
              "FirstName": string
                  description: "The prospect's first name."
                  label: "First Name"
                  is_required: True
                  is_user_input: False
              "LastName": string
                  description: "The prospect's last name."
                  label: "Last Name"
                  is_required: True
                  is_user_input: False
              "Phone": string
                  description: "The prospect's phone number."
                  label: "Phone"
                  is_required: True
                  is_user_input: False
          outputs:
              "leadRecordId": string
                  description: "The Salesforce record ID of the newly created Lead."
                  label: "Lead Record Id"
                  is_displayable: False
                  filter_from_agent: True
```

2. Add these lines to the agent router, lining up the action with the other agent router actions.

```sfdocs-code {"lang":"agentscript", "title": "lead_gather Subagent"}
            go_to_lead_gather: @utils.transition to @subagent.lead_gather
```

3. Save your agent.

:::note
You'll see an error that the lead_gather subagent doesn't exist - we'll fix that problem in the next step.
:::

![decision element to see if the lead exists](../../../../../media/agent-script/agentrouter.jpg '{"class": "image-lg"}')

## Add the Lead Confirmation Subagent

This subagent tells the customer that a lead has been created. The agent router **doesn't** have access to this subagent. This subagent is only called from the `after_reasoning` block of the create lead subagent, which is only available if the Create Lead by Field Action returned a lead Id. These safeguards ensure the agent never falsely confirms a lead creation to the customer.

1. Copy this subagent script and paste the script at the end of your existing agent's script.

```sfdocs-code {"lang":"agentscript", "title": "lead_confirmation Subagent"}
subagent lead_confirmation:
  label: "Lead Confirmation"
  description: "Confirms that the lead was successfully created."
  reasoning:
      instructions: ->
          | Confirm that the prospect's details were captured successfully.
          | Explain that a team member will follow up to arrange a meeting.
```

2. Save your agent.

## Grant Agent User Permissions

Your agent user needs permission to read and create leads.

1. From **Setup**, in the Quick Find box, enter and select **Permission Sets**.
2. Click to open your agent user's permission set.
3. Click to open **Object Settings**.
4. Scroll down, then click to open **Leads**.
5. Click **Edit**.
6. Under Object Permissions, for Read and Create, select **Enabled**.
7. Click **Save**.

![the read and create permissions selected](../../../../../media/agent-script/createLeadPermissions.jpg '{"class": "image-md"}')

:::note
Always give your agent user the fewest permissions it needs to do its job. For more information about service agent permissions, see [(Help:) Best Practices for Agent User Permissions](https://help.salesforce.com/s/articleView?id=ai.agent_user.htm&type=5).
:::

## Test Your Agent

Preview the agent and test three scenarios:

| Scenario                                | Customer Utterance                                                                                                                                                  | Expected Result                                                                                                                                  |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Happy path — all fields in one message. | `Hi, I'd like to schedule a meeting to learn more about your product.` Then when asked: `I'm Casey Rivera, casey.rivera@example.com, Northwind Labs, 415-555-0142.` | The agent transitions to `lead_confirmation`, creates the lead, and confirms the lead creation.                                                  |
| No duplicate record created.            | Repeat the happy path with the same email and company.                                                                                                              | The agent returns the **same** Lead ID as before. No duplicate lead record is created.                                                           |
| Partial-info gate — only some fields.   | `Hi, I want to book a meeting.` Then when asked for information, provide only one answer per turn.                                                                  | The agent keeps asking for the missing information. Once all information is provided, the agent creates the lead and confirms with the customer. |

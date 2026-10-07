# Agent Script Pattern: Using List Variables

With [list variables](../reference/ascript-ref-variables-list.md) (also called collection variables), your agent can store and iterate over a collection of values. For example, create a list of questions that an interview agent must ask, or a list of objects to store an action's output. A list can store any supported type, such as strings, booleans, numbers, or objects. Use a list item anywhere you use a [custom variable](../reference/ascript-ref-variables.md).

## Reference an Item in a List

To reference an item in a list, use `json_path` or bracket `[]` syntax. `json_path` syntax returns the value enclosed in `[""]` characters, while `[]` syntax returns the raw value.

| Syntax                                                                  | Example                                                                                                           | Example Return Value |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | -------------------- |
| `@variables.<variable_name>[<index>].data.<field_name>`                 | The name of the fourth account in a list of accounts: <br> `@variables.all_accounts[3].data.Name`                 | `Acme Corp`          |
| `json_path(@variables.<variable_name>, "$[<index>].data.<field_name>")` | The name of the fourth account in a list of accounts: <br> `json_path(@variables.all_accounts, "$[3].data.Name")` | `["Acme Corp"]`      |

Lists are zero-indexed. To get the first item in your list, use `[0]`.

## Pattern: Iterate Through a List with an Index Variable

Advance through a list one item per turn by using an index variable to track the current list item. Increment the variable in `after_reasoning` to ensure determinism — `after_reasoning` is run deterministically (it isn't sent to the LLM), and is guaranteed to run every turn (the subagent has no transitions).

### How This Pattern Works

This example shows a TestList1 subagent that asks one question per turn, and a Variables block that declares the index and question variables. The subagent's responsibilities are spread across two sub-blocks:

- **`reasoning.instructions:`** runs first. It reads the question specified by the current index variable, then builds the prompt sent to the LLM.
- **`after_reasoning:`** runs after the LLM returns its response. It compares the current index to the length of the questions list, then increments the index if more questions remain.

### Why Use This Pattern

Use this pattern when:

- The agent must walk through a list in order (checklist steps, survey questions, records) and reference exactly one item in each turn's prompt.
- Ordering must be deterministic, not subject to LLM reasoning.

```sfdocs-code {"lang":"agentscript", "title": "Iterate Through a List with an Index Variable"}

variables:
    question_index: mutable number = 0
        description: "Zero-based index of the current question."
    CompetencyQuestions: mutable list[string] = ["Have you passed your certification exam?", "Do you have the legal right to work here?", "Tell me about your past jobs.", "What is your most important accomplishment?"]
        description: "List of competency screening questions to ask."

subagent TestList1:
    label: "TestList1"
    description: |
        Ask the candidate the current question from CompetencyQuestions.
    reasoning:
        instructions: ->

        # On the first turn, this line resolves to "Tell the user that this is question 1 of 4".

            | Tell the user that this is question {!@variables.question_index + 1} of {!len(@variables.CompetencyQuestions)}.

        # On the first turn, question_index is 0, so this line resolves to "Then, ask this question: Have you passed your certification exam?"

            | Then, ask this question: {!@variables.CompetencyQuestions[@variables.question_index]}

    # The index variable is incremented in after_reasoning.

    after_reasoning:
        # Compare the current index to the length of the list to see if we're done or not
        if @variables.question_index + 1 < len(@variables.CompetencyQuestions):
            # if we're not done, increment the index
            set @variables.question_index = @variables.question_index + 1

```

### Agent Output for This Pattern

This agent preview shows how the pattern works.

![Output of list pattern 1 agent](../../../../../../media/agent-script/list-pattern-1.jpg '{"class": "image-sm"}')

:::note
This pattern doesn't show how to handle the workflow after the agent asks the last question, because that logic is agent-specific. Your agent can transition to the next subagent, set a state variable so the subagent isn't called again, or provide specific instructions in the agent router.
:::

## Pattern: Access a Field from a List of Objects

This example shows how to read fields from a list of objects by using both `json_path` and bracket `[]` syntax. The subagent calls an action that returns a list of Account objects, stores the returned list in the `all_accounts` list variable, and extracts two account names from the list.

### Why Use This Pattern

Use this pattern when:

- An action returns a list of objects (accounts, cases, orders) and later reasoning or logic needs to reference specific field values.
- The customer uploads a complex list, and you reference specific values.

```sfdocs-code {"lang":"agentscript", "title": "Store and Read From a List of Objects"}

variables:
    all_accounts: mutable list[object]
        description: "List of Account objects returned by the Get_All_Accounts action."
        label: "all_accounts"
    third_account_name: mutable string
        description: "Name of the third account in all_accounts (index 2)."
    fourth_account_name: mutable string
        description: "Name of the fourth account in all_accounts (index 3)."

subagent Get_All_Accounts:
    label: "Get All Accounts"
    description: | Runs an action to get all of the org's accounts, then stores two specific account names.
    reasoning:
        instructions: ->
            | Run {!@actions.Get_All_Accounts}
        actions:
            Get_All_Accounts: @actions.Get_All_Accounts
                with RequestReason = ...
                # Capture the action's list output into a persistent variable.
                set @variables.all_accounts = @outputs.Accounts

    after_reasoning:
        # json_path — returns the JSON representation of the match, e.g. ["Acme Corp"].
        set @variables.third_account_name = json_path(@variables.all_accounts, "$[2].data.Name")

        # Dot-access — returns the bare string, e.g. Acme Corp.
        set @variables.fourth_account_name = @variables.all_accounts[3].data.Name

    actions:
        Get_All_Accounts:
            label: "Get All Accounts"
            description: | Returns a list of every Account object on the org.
            target: "flow://Get_All_Accounts"
            inputs:
                # Placeholder input. Agentforce actions must declare at least one input,
                # even when the underlying flow doesn't use it.
                RequestReason: string
                    label: "RequestReason"
                    description: "Placeholder input to satisfy the Agentforce action requirement. Not used by the flow."
                    is_required: False
            outputs:
                Accounts: list[object]
                    label: "Accounts"
                    complex_data_type_name: "lightning__recordInfoType"
                    is_displayable: True
                    filter_from_agent: False

```

## Tips

- Lists are zero-indexed. To reference the first item, use `[0]`.
- `json_path` returns the matched value wrapped in `[""]` characters (for example, `["Acme Corp"]`), while bracket `[]` syntax returns the raw value (for example, `Acme Corp`). Choose the syntax that matches the value you want to store or display.
- To advance through a list deterministically, increment the index variable in `after_reasoning` instead of `reasoning.instructions`, so the update isn't left to the LLM.
- Use `len(@variables.<list>)` to check a list's length before you reference an item, so your agent doesn't index past the end of the list.

## Related Topics

- Reference: [Variables](../reference/ascript-ref-variables.md)
- Reference: [List Variables](../reference/ascript-ref-variables-list.md)

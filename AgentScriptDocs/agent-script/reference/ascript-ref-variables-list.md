# Agent Script Reference: List Variables

A [custom](./ascript-ref-variables.md) variable can be a list of values. A list can hold any supported variable type, such as strings, booleans, numbers, or objects.

## Creating a List Variable

When you create a list in the `variables` block, specify the variable type in brackets. You can leave the list uninitialized, initialize an empty list, or set default values.

```sfdocs-code {"lang":"agentscript", "title": "Define List Variables"}
variables:
    # Declare a list of objects
    all_accounts: mutable list[object]
        description: "The list of account objects returned by the action"
        label: "all_accounts"

    # Declare a list of strings with default values
    CompetencyQuestions: mutable list[string] = ["Tell me about a time you disagreed with a coworker.", "Tell me about one of your favorite shifts.", "What are the most important qualities in a candidate?"]
        description: "List of questions to determine competency."
```

## Reference an Item in a List

To reference an item in a list, use `json_path` or bracket `[]` syntax. Lists are zero-indexed, so to get the first item in your list, use `[0]`.

To reference a field in a list of objects, use `data.<field_name>`. Note that `json_path` syntax returns the value enclosed in `[""]` characters, while bracket syntax returns the raw value.

| Syntax                                                                  | Example                                                                                                           | Example Return Value |
| ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- | -------------------- |
| `@variables.<variable_name>[<index>].data.<field_name>`                 | The name of the fourth account in a list of accounts: <br> `@variables.all_accounts[3].data.Name`                 | `Acme Corp`          |
| `json_path(@variables.<variable_name>, "$[<index>].data.<field_name>")` | The name of the fourth account in a list of accounts: <br> `json_path(@variables.all_accounts, "$[3].data.Name")` | `["Acme Corp"]`      |

### Example: Reference a List of Strings in Reasoning Instructions

This example shows how to use bracket syntax to get the third item in a list of strings.

```sfdocs-code {"lang":"agentscript", "title": "Reference a List Item in Reasoning Instructions"}

    # Ask the user the 3rd question in the list of questions
    reasoning:

        instructions: ->
            | Ask the user this question: {!@variables.CompetencyQuestions[2]}
```

### Example: Reference a List of Objects in After Reasoning

This example shows:

- How to use `json_path` syntax to get the value of the Name field from the third account in a list of Account objects.
- How to use bracket syntax to get the value of the Name field from the fourth account in a list of Account objects.

```sfdocs-code {"lang":"agentscript", "title": "Reference List Items in After Reasoning"}

    # From a list of accounts, store the third and fourth account name in a variable
    after_reasoning:

        # stores Name field enclosed in [""], for example ["Pyramid Construction Inc."]
        set @variables.third_account_name = json_path(@variables.all_accounts, "$[2].data.Name")

        # stores Name field without added characters, for example Dickenson Inc
        set @variables.fourth_account_name = @variables.all_accounts[3].data.Name
```

## Supported Operations on List Variables

You can use these operations on your list variables.

| Operation                                                   | Syntax                                      |
| :---------------------------------------------------------- | :------------------------------------------ |
| Get the length of a list                                    | `len(@variables.myList)`                    |
| Return the maximum of a list of numbers                     | `max(@variables.scores)`                    |
| Return the minimum of a list of numbers                     | `min(@variables.scores)`                    |
| Serialize a variable to a JSON string                       | `to_json(@variables.myList)`                |
| Use JSONPath syntax to reference a specific value in a list | `json_path(@variables.myList, "$[*].name")` |

## Related Topics

- Pattern: [Using Variables Effectively](../patterns/ascript-patterns-variables.md)
- Pattern: [Using List Variables](../patterns/ascript-patterns-var-list.md)
- Reference: [System Variables](./ascript-ref-variables-system.md)
- Reference: [Custom Variables](./ascript-ref-variables.md)
- [Flow of Control](../ascript-flow.md)
- Reference: [Utils](ascript-ref-utils.md)

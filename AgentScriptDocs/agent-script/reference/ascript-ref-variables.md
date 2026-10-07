# Agent Script Reference: Variables (Custom and Linked)

Variables let agents deterministically remember information across conversation turns, track progress, and maintain context throughout the session. You define all variables in the `variables` block, and all subagents in the agent can access the variables.

This page covers custom and linked variables. For predefined runtime variables, see [Agent Script Reference: System Variables](./ascript-ref-variables-system.md).

- **[custom variable](#custom-variables):** You can initialize a variable with a default value, and the agent can change the variable's value.
- **[linked variable](#linked-variables):** The value of a linked variable is tied to an output such as an action's output. Linked variables can't have a default value.

## Defining a Variable

Define variables in the [`Variables`](../ascript-blocks.md#variables-block) block.

```sfdocs-code {"lang":"agentscript", "title": "Reference a Variable From Script"}
    CurrentState: mutable string = "gatheringInfo"
        description: "The current state, or step, of the interview."
        label: "State"
        visibility: "External"
```

## Variable Names

Variable names must follow Salesforce developer name standards:

- Begin with a letter, not an underscore.
- Contain only alphanumeric characters and underscores.
- Can't end with underscore.
- Can't contain consecutive underscores (\_\_).
- Maximum length of 80 characters.

## Referencing Variables

To reference a variable from the script, use `@variables.<variable_name>`.

```sfdocs-code {"lang":"agentscript", "title": "Reference a Variable From Script"}

            if @variables.Customer_Contact is None:
                set @variables.No_Matching_Contact = True
```

To reference a variable from within reasoning instructions, use `{!@variables.<variable_name>}`.

```sfdocs-code {"lang":"agentscript", "title": "Reference a Variable From Reasoning Instructions"}
reasoning:
    instructions: ->
        | Always use {!@variables.Customer_Email} for the customer's email address.
```

## Custom Variables

Custom variables have these properties:

- `mutable` - Optional. Allows the agent to change the variable's value. To ensure a variable's value is never changed, define the variable without `mutable`.
- `description` - describes the variable. Optional. If you want the LLM to use reasoning to set the variable's value, include a description to help the LLM set the value correctly. See [Let the LLM set variables with user-entered information (slot filling)](../patterns/ascript-patterns-variables.md#let-the-llm-set-variables-with-user-entered-information-slot-filling).
- `label` - Optional. The variable's name as displayed in the UI. By default, the description is generated from the name. For example, if your variable's name is `my_var`, the UI displays the label `My Var`.
- `visibility` - Optional. Default value is `Internal`. Set visibility to `External` to allow an API to set the variable's value, or to change the variable's value when [testing the agent in simulate mode](https://help.salesforce.com/s/articleView?id=ai.agent_test_in_builder.htm&language=en_US&type=5).

```sfdocs-code {"lang":"agentscript", "title": "Example: Define Custom Variables"}
variables:
    isPremiumUser: mutable boolean = False
        description: "Indicates whether the user is a premium user."
        label: "Has Gold Status"

    customer_loyalty_tier: mutable string = "standard"
        description:|
            Stores the customer's membership tier level.
```

Custom variables can have these types:

| Type         | Notes                                                                                                              | Example                                                                                                                                |
| :----------- | :----------------------------------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------- |
| `string`     | Any alphanumeric string without special characters.                                                                | `name: mutable string = ""`                                                                                                            |
| `number`     | Use for both integers and decimals. For example, 42 or 3.14. Compiles to IEEE 754 double-precision floating point. | `age: mutable number`, `price: mutable number = 99.99`                                                                                 |
| `boolean`    | Allowed values are `True` or `False`. The value is case-sensitive, so capitalize the first letter.                 | `is_active: mutable boolean = True`                                                                                                    |
| `object`     | Value is a complex JSON object in the form `{"key": "value"}.`                                                     | `order_line: mutable object = {"SKU": "abc12344409","count": 42}`                                                                      |
| `date`       | Any valid date format.                                                                                             | `start_date: mutable date`                                                                                                             |
| `id`         | Deprecated. Use `string` to store a Salesforce record ID.                                                          | See string type.                                                                                                                       |
| `list[type]` | A list of values of the specified type. All primitive types and `object` type are supported.                       | `flags: mutable list[boolean] = [True, False, True]`, `scores: list[number] = [95, 87.5, 92]`, `obj_list: mutable list[object] = None` |

## No Value (None) and Empty String ("")

Use `None` to check whether a variable has a value. You can use `None` with any variable type. For a string variable, you can also use `""` to check if the variable is set to an empty string. When checking string variables in conditional statements, you might want to use both `None` and `""`.

For more information, see [Agent Script Reference: Conditional Expressions](./ascript-ref-expressions.md).

## Linked Variables

A linked variable's value is tied to a source, such as an action's output. Linked variables have these restrictions:

- can't have a default value
- can't be set by the agent
- can't be an object or a list

The `source` field references where the variable gets its value. Supported source namespaces are:

| Namespace           | Available Properties                          | Description                          |
| :------------------ | :-------------------------------------------- | :----------------------------------- |
| `@MessagingSession` | `Id`, `MessagingEndUserId`, `EndUserLanguage` | Properties of the messaging session  |
| `@MessagingEndUser` | `ContactId`                                   | Properties of the messaging end user |
| `@VoiceCall`        | `Id`                                          | Properties of the voice call         |

```sfdocs-code {"lang":"agentscript", "title": "Example: Define Linked Variables"}
variables:
    session_id: linked string
        source: @MessagingSession.Id
        description: "The messaging session ID"
    contact_id: linked string
        source: @MessagingEndUser.ContactId
        description: "The contact ID of the end user"
    voice_call_id: linked string
        source: @VoiceCall.Id
        description: "The voice call ID"
```

Linked variables can have these types:

- `string`
- `number`
- `boolean`
- `date`
- `id` (deprecated; use `string` for Salesforce record IDs)

## Examples and Patterns

For examples and patterns using variables, see [Agent Script Pattern: Using Variables Effectively](../patterns/ascript-patterns-variables.md) and [Agent Script Pattern: Using List Variables](../patterns/ascript-patterns-var-list.md)

## Related Topics

- Pattern: [Using Variables Effectively](../patterns/ascript-patterns-variables.md)
- Pattern: [Using List Variables](../patterns/ascript-patterns-var-list.md)
- Reference: [System Variables](./ascript-ref-variables-system.md)
- Reference: [List Variables](./ascript-ref-variables-list.md)
- [Flow of Control](../ascript-flow.md)
- Reference: [Utils](ascript-ref-utils.md)

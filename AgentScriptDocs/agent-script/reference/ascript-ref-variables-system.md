# Agent Script Reference: System Variables

Agent Script provides predefined, prepopulated system variables that you can use in your agent. To access system variables, use `@system_variables.<variable_name>`.

A system variable is:

- read-only, so you can't change its value
- predefined, so you don't define it in the `variables` block
- used in the same places as a custom variable or a linked variable

For custom and linked variable definitions, see [Agent Script Reference: Variables (Custom and Linked)](./ascript-ref-variables.md).

## `user_input`

The `user_input` system variable contains the customer's most recent utterance (**not** the entire conversation history).

:::note
The LLM remembers the entire conversation history, so you don't typically need to use `@system_variables.user_input` unless you're passing the last thing a customer said into an action.
:::

### Example - Analyze Customer Sentiment

In this example, we pass the last customer utterance into a sentiment analysis action. Although the agent's LLM can also analyze sentiment, we want to use a prompt template action that understands industry-specific terminology and our customer's rapidly changing language patterns.

```sfdocs-code {"lang":"agentscript", "title": "Example: Analyze sentiment of most recent customer utterance"}
reasoning:
    actions:
        AnalyzeSentiment: @actions.AnalyzeSentiment
            with utterance = @system_variables.user_input
            set @variables.customer_sentiment = @outputs.sentiment_classification
```

## `current_modality`

The `current_modality` system variable indicates whether the agent is currently operating in voice or text mode. This variable is automatically populated on every inbound turn, based on the connection channel:

| Connection Type            | `current_modality` value |
| -------------------------- | ------------------------ |
| Telephony                  | `"voice"`                |
| Messaging/Enhanced Chat v2 | `"text"`                 |

If your agent isn't bound to a telephony or messaging/ECv2 connection, the `current_modality` system variable isn't set (value is `None`).

Use this system variable when you want the agent to behave differently in different modes. For example, your agent can keep responses short and free of formatting on voice mode, but provide richer formatting responses during text mode.

### Example - Adapt Response to Modality

In this example, we pass the current modality into an action so it can tailor its output:

```sfdocs-code {"lang":"agentscript", "title": "Format the response differently for voice and text messages"}
reasoning:
    actions:
        FormatResponse: @actions.FormatResponse
            with modality = @system_variables.current_modality
```

## `current_connection`

The `current_connection` system variable identifies the connected client for the current turn. This variable is automatically populated on every inbound turn.

:::note
This value may be unpopulated (None) until the runtime finishes configuring the connection.
:::

### Example - Pass Connection Context to an Action

```sfdocs-code {"lang":"agentscript", "title": "Example: Provide connection context to an action"}
reasoning:
    actions:
        LogInteraction: @actions.LogInteraction
            with connection = @system_variables.current_connection
```

## `uploaded_files`

The `uploaded_files` system variable is a list of `File` objects representing files that the customer uploaded. The agent stores the 10 most recently uploaded files for the duration of the session. If the customer hasn't uploaded any files, then `uploaded_files` is empty.

Each `File` has these fields: `id`, `file_url`, `name`, and `mime_type`.

```sfdocs-code {"lang":"agentscript", "title": "Example: Operations on Uploaded Files "}

# use slice operations to get the first 5 files
@system_variables.uploaded_files[0:5]

# Get the number of files uploaded
len(@system_variables.uploaded_files)
```

To use `@system_variables.uploaded_files`, enable file uploads in the [`file_upload`](../ascript-blocks.md#file-upload-sub-block) block of your agent's config.

## Related Topics

- Reference: [Variables (Custom and Linked)](./ascript-ref-variables.md)

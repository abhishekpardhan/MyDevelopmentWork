# Configure Voice Models in Agent Script

Agentforce voice-enabled agents use a text-to-speech (TTS) voice model to convert an agent's responses into spoken audio. Each language has a default model, set by a lifecycle gate: most languages default to [ElevenLabs](https://elevenlabs.io/) v3 Conversational, and Japanese defaults to Kotoba. To select a different voice model, use the `modality voice` block in Agent Script.

## How Voice Selection Works

An Agentforce Voice agent pairs two things:

- **Voice model**: the TTS engine that generates speech, such as ElevenLabs v3 Conversational or Kotoba.
- **Voice persona**: the specific voice (the tone, accent, and character) that the model speaks with.

Agentforce Voice supports these TTS models. Choose the one that fits your agent:

| Voice Model                  | Model ID            | Choose it for                                                                                                                                                                                                                                                                                          |
| :--------------------------- | :------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ElevenLabs v3 Conversational | `eleven_v3_conversational`         | The most natural, expressive speech, and reliable pronunciation of entities like numbers, email addresses, and IDs. These voices are better than v2.5 for most languages. The default for most languages.                                                                                              |
| ElevenLabs Flash v2          | `eleven_flash_v2`   | The best custom pronunciation and better quality English than Flash v2.5, with steadier non-US English accents than v3 Conversational.  Honors the `speed`, `stability`, and `similarity` parameters. English locales only.                                                                            |
| ElevenLabs Flash v2.5        | `eleven_flash_v2_5` | The multilingual counterpart to Flash v2: the best adherence for secondary accents in non-English languages, such as Argentinian Spanish, French Canadian, and European Portuguese. Lower latency; honors the `speed`, `stability`, and `similarity` parameters. Doesn't support custom pronunciation. |
| Kotoba                       | `kotoba`            | Japanese speech. Kotoba is the default model for Japanese (`ja`).                                                                                                                                                                                                                                      |

v3 Conversational is the default for most languages. Flash v2 and Flash v2.5 aren't defaults, but they're fully supported. You select them in Agent Script when their latency, language, accent behavior, or custom pronunciation (Flash v2 only) fits your use case better than v3 Conversational.

You can select a non-default model only in Agent Script. Agentforce Builder (Canvas) doesn't yet expose a voice-model selector, so v3 Conversational (the default) is the only model available there. To use Flash v2, Flash v2.5, or Kotoba on a non-default language, override the model in the `modality voice` block.

### Which Model Should I Use?

Consider these tradeoffs when you choose between ElevenLabs v3 Conversational and the Flash models:

- **ElevenLabs v3 Conversational** is the strongest all-around model and the default for most languages. It's the most expressive, and it pronounces entities like numbers, email addresses, and IDs correctly out of the box. However, it's less reliable with some non-US English accents, such as UK and Australian English. It doesn't use the `speed` or `similarity` parameters. `stability` defaults to 0.5.
- **ElevenLabs Flash v2** is English-only and the best choice for English. It has the best custom pronunciation of any model, produces higher-quality English than Flash v2.5, and handles non-US English accents, such as UK and Australian English, more stably than v3 Conversational. It has lower latency and honors the `speed`, `stability`, and `similarity` parameters. Choose it when you want faster responses, fine-grained control over how a voice sounds, or reliable custom pronunciation for an English agent.
- **ElevenLabs Flash v2.5** is the multilingual counterpart to Flash v2, for non-English languages. It gives the best adherence for secondary accents, such as Argentinian Spanish, French Canadian, and European Portuguese. It has lower latency and honors the `speed`, `stability`, and `similarity` parameters. It doesn't support custom pronunciation. If you need custom pronunciation and your agent is in English, use Flash v2.

### Choosing a Voice

You choose a voice in two steps, because each voice persona belongs to a specific model:

1. **Choose a voice model.** To use a model other than the language default, set it in the `model` section of the `modality voice` block.
2. **Choose a voice persona from that model's voice list.** Each model publishes its own set of voices and the languages each voice supports. Find the voice you want in that model's list, and then set its **hash ID** as the `persona_id`. Use the hash ID as the identifier. The same voice used with a different model counts as a distinct voice, so match the hash ID to your selected model.

See [Supported Voice Models](#supported-voice-models) for the voice list and supported languages for each model.

Each language's default model is set through a lifecycle gate, so you can keep using the default without any changes. To use a different supported model, override the default in the `modality voice` block of your Agent Script.

:::note
**Preview a voice before you commit to it.** To hear how a selected voice sounds, save your agent and use the agent preview to start a conversation. A voice sounds different in a live conversation than in a static sample, so the preview is the reliable way to evaluate it.

When you set a voice model in Agent Script, don't switch back to Agentforce Builder (Canvas) to change the voice and then return to the script. Canvas and Agent Script use different underlying formats, and moving between them can leave your voice configuration in an inconsistent state.

Change the voice model only when the language's default model doesn't meet your needs. The default is the recommended choice for most agents.
:::

## Modality Voice Block

The `modality voice` block defines how your agent speaks and listens. It has two directions, both optional. Configure only the ones you need:

- `outbound`: how the agent speaks, including the voice persona, the text-to-speech (TTS) model, and model parameters such as speed and stability.
- `inbound`: how the agent listens, including keyword and filler-word detection. The inbound speech-to-text (ASR) model isn't configurable.

This example configures both directions:

```sfdocs-code {"lang":"agentscript", "title": "Modality Voice Block"}
modality voice:
    outbound:
        persona_id: "8438b254ab85" # Lucie (fr), a Flash v2.5 voice
        model:
            id: "eleven_flash_v2_5"
            parameters:
                speed: 1.0
                stability: 0.8
    inbound:
        filler_words_detection: True
        keywords:
            - "urgent"
            - "emergency"
```

### Outbound: How the Agent Speaks

The `outbound` section sets the voice persona, the voice model, and any model parameters.

```sfdocs-code {"lang":"agentscript", "title": "Outbound Voice"}
modality voice:
    outbound:
        persona_id: "dd0c9186f164" # Olivia (en_US), a v3 Conversational voice
```

These properties make up the `outbound` section:

| Property           | Description                                                                                                                                                                                                  | Default              |
| :----------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------------------- |
| `persona_id`       | Optional. The identifier of the voice persona the agent speaks with. Use the **hash ID** from the [Voice Catalog](ascript-voice-catalog.md) for your selected model. Omit to use the locale's default voice. | Locale default voice |
| `model`            | Optional. Selects and configures the voice model. Omit to use the language's default model.                                                                                                                  | Language default     |
| `model.id`         | Optional. The model ID of the voice model to use, such as `eleven_flash_v2_5`. Omit to use the language's default model. See [Supported Voice Models](#supported-voice-models) for the available model IDs.  | Language default     |
| `model.parameters` | Optional. Model-specific settings passed through to the voice model. See [Model Parameters](#model-parameters).                                                                                              | —                    |

### Model Parameters

`model.parameters` is an open passthrough. You can set any name-value pairs, such as strings, booleans, or numbers, and Agent Script forwards them to the model at runtime. Agent Script doesn't validate parameter names or value ranges: which parameters a model honors, and their valid ranges, are defined by the model itself. Setting a parameter that a model doesn't recognize has no effect.

These parameters are commonly used with the ElevenLabs voice models. Treat this as a starting point, not a complete or enforced list.

Each voice persona ships with its own tuned defaults for these parameters, so a value that sounds right for one persona isn't the default for another. Omit a parameter to use the persona's default, and set one only when you want to override it.

The ranges below apply to the ElevenLabs Flash v2.5 and Flash v2 models, which honor these parameters. ElevenLabs v3 Conversational doesn't use `speed` or `similarity`, so their ranges don't apply to it.

| Parameter    | Description                                                                                                                    | Range   |
| :----------- | :----------------------------------------------------------------------------------------------------------------------------- | :------ |
| `speed`      | How fast the voice speaks. Lower values slow the speech down; higher values speed it up.                                       | 0.7–1.2 |
| `stability`  | How consistent the delivery is. Lower values give a more expressive, variable performance; higher values give steadier speech. | 0–1     |
| `similarity` | How closely the output matches the original voice's character. Higher values stay closer to the source voice.                  | 0–1     |

How a model applies these parameters varies:

- **ElevenLabs Flash v2.5 and Flash v2** honor `speed`, `stability`, and `similarity`. Use a Flash model when you need precise control over how a voice sounds.
- **ElevenLabs v3 Conversational** doesn't use `speed` or `similarity`. `stability` defaults to 0.5.
- **Kotoba** doesn't take these parameters. Select the model and a persona without a `parameters` block.

### Inbound: How the Agent Listens

The `inbound` section configures how the agent detects what the customer says. The inbound speech-to-text (ASR) model ID isn't configurable. You can't set or change it in the `modality voice` block.

```sfdocs-code {"lang":"agentscript", "title": "Inbound Voice"}
modality voice:
    inbound:
        filler_words_detection: True
        keywords:
            - "urgent"
            - "emergency"
```

These properties make up the `inbound` section:

| Property                 | Description                                                                                                       | Default |
| :----------------------- | :---------------------------------------------------------------------------------------------------------------- | :------ |
| `filler_words_detection` | Optional. When `True`, the agent detects and ignores filler words such as "um" and "uh" in the customer's speech. | `False` |
| `keywords`               | Optional. A list of keywords to boost during recognition, which improves accuracy for domain-specific terms.      | —       |

## Select the Flash v2 Voice Model

Flash v2 is the English-only, lower-latency model, and it's the best choice for English agents. It has the best custom pronunciation of any model and handles non-US English accents, such as UK and Australian English, more stably than v3 Conversational. Like Flash v2.5, it honors the `speed`, `stability`, and `similarity` parameters. To use it, specify the Flash v2 model and a compatible English voice persona in the `modality voice` block. No other Agent Script blocks need to change.

Use Flash v2 for English. For other languages, use Flash v2.5 instead.

```sfdocs-code {"lang":"agentscript", "title": "Select the Flash v2 Voice Model"}
modality voice:
    outbound:
        persona_id: "a029af9d692c" # April (en_US), a Flash v2 voice
        model:
            id: "eleven_flash_v2"
            parameters:
                speed: 1.0
                stability: 0.8
                similarity: 0.75
```

## Select a Flash v2.5 Voice Model

Flash v2.5 is the multilingual, lower-latency model, so it's a good fit for non-English languages when you want faster spoken responses. It gives the best adherence for secondary accents, such as Argentinian Spanish, French Canadian, and European Portuguese. Unlike v3 Conversational, it honors the `speed`, `stability`, and `similarity` parameters, so choose it when you also want fine-grained control over how a voice sounds. Flash v2.5 doesn't support custom pronunciation. To use it, specify the Flash v2.5 model and a compatible Flash v2.5 voice persona in the `modality voice` block. No other Agent Script blocks need to change.

Use Flash v2.5 for non-English languages. For English, use Flash v2 instead.

```sfdocs-code {"lang":"agentscript", "title": "Select the Flash v2.5 Voice Model"}
modality voice:
    outbound:
        persona_id: "4f708167ff27" # Louis (fr), a Flash v2.5 voice
        model:
            id: "eleven_flash_v2_5"
            parameters:
                speed: 1.0
                stability: 0.8
                similarity: 0.75
```

## Select the Kotoba Voice Model for Japanese

Kotoba is the default voice model for Japanese (`ja`), so you don't need to select it explicitly for a Japanese agent. To set it in a per-language configuration, specify the model and a compatible Japanese voice persona. Kotoba doesn't take voice parameters, so omit the `parameters` block.

```sfdocs-code {"lang":"agentscript", "title": "Select the Kotoba Voice Model"}
modality voice:
    language:
        default_locale: "ja"
    language_settings:
        ja:
            outbound:
                persona_id: "e5d63b40f254" # Azawa (ja), a Kotoba voice
                model:
                    id: "kotoba"
```

## Legacy Voice Format

Some existing scripts use an older, flat format that sets a voice and speed directly, without the `outbound` and `model` nesting:

```sfdocs-code {"lang":"agentscript", "title": "Legacy Voice Format"}
modality voice:
    voice_id: "<voice identifier>"
    outbound_speed: 0.9
```

This format still works, so scripts that use it keep running without changes. But it can't select a voice model such as Flash v2.5. Model selection exists only in the nested format. For any new voice configuration, use the nested format shown earlier.

:::important
You can't combine the two formats in one script. If you move a script to the nested format, rewrite the entire `modality voice` block. There's no automatic conversion.
:::

## Supported Voice Models

Agentforce Voice supports these voice models. Specify a model by its model ID in the `modality voice` block.

| Voice Model                  | Model ID            | Availability                                                              | Voice List                                                                        |
| :--------------------------- | :------------------ | :------------------------------------------------------------------------ | :-------------------------------------------------------------------------------- |
| ElevenLabs v3 Conversational | `eleven_v3_conversational`         | Default for most languages. Available in Canvas and Agent Script.         | [ElevenLabs v3 Conversational Voices](ascript-voice-catalog-v3-conversational.md) |
| ElevenLabs Flash v2.5        | `eleven_flash_v2_5` | Multilingual, for non-English languages. Selectable in Agent Script only. | [ElevenLabs Flash v2.5 Voices](ascript-voice-catalog-flash-2-5.md)                |
| ElevenLabs Flash v2          | `eleven_flash_v2`   | English only. Selectable in Agent Script only.                            | [ElevenLabs Flash v2 Voices](ascript-voice-catalog-flash-2.md)                    |
| Kotoba                       | `kotoba`            | Japanese (`ja`) only. The default model for Japanese.                     | [Kotoba Voices](ascript-voice-catalog-kotoba.md)                                  |

The default model for each language is set by a lifecycle gate. When you don't select a model, the agent uses that language's default. To use a non-default model, select it in the `modality voice` block. Canvas doesn't yet expose a voice-model selector. For how each model handles voice parameters, see [Model Parameters](#model-parameters).

## Voice Lists

Each model has its own catalog of voice personas, and each voice supports specific locales:

- [ElevenLabs v3 Conversational Voices](ascript-voice-catalog-v3-conversational.md)
- [ElevenLabs Flash v2 Voices](ascript-voice-catalog-flash-2.md)
- [ElevenLabs Flash v2.5 Voices](ascript-voice-catalog-flash-2-5.md)
- [Kotoba Voices](ascript-voice-catalog-kotoba.md)

For all lists on one page, see the full [Voice Catalog for Agentforce Voice](ascript-voice-catalog.md).

To set a voice, find it in the list for your selected model and use its hash ID as the `persona_id`. If you don't set a `persona_id`, the agent uses the locale's default voice, marked **(default)** in the voice list.

## Considerations

- Existing agents and existing Agent Script continue to work without changes. To use the new voice capabilities, rewrite the `modality voice` block.
- You can't mix the legacy and nested voice formats in the same script.
- Agentforce Builder (Canvas) doesn't expose a voice-model selector, doesn't show the voice catalog for non-default models, and doesn't filter its voice picker based on an Agent Script override.

## Related Topics

- [Agent Script Blocks](./ascript-blocks.md)
- [Agent Script Reference](reference/ascript-reference.md)
- [ElevenLabs](https://elevenlabs.io/)

# Voice Catalog for Agentforce Voice

This catalog lists the voice personas available for each Agentforce Voice model. To set a voice, open the page for your selected model, find the voice in your locale, and use its **Voice ID** as the `persona_id` in the `modality voice` block. For how to select a model and configure a voice, see [Configure Voice Models in Agent Script](ascript-voice.md).

On each model page, the voice marked **(default)** is the one the agent uses for that locale when you don't set a `persona_id`.

:::note
This catalog is a snapshot of the supported voices and can change from release to release. The same voice can appear in more than one model's list, but its Voice ID differs between them. Always use the Voice ID from the page for the model you selected.
:::

## ElevenLabs v3 Conversational Voices

ElevenLabs v3 Conversational is the default voice model for most languages. See [ElevenLabs v3 Conversational Voices](ascript-voice-catalog-v3-conversational.md).

## ElevenLabs Flash v2.5 Voices

ElevenLabs Flash v2.5 is a lower-latency model you select in Agent Script. Use it for non-English languages. See [ElevenLabs Flash v2.5 Voices](ascript-voice-catalog-flash-2-5.md).

## ElevenLabs Flash v2 Voices

ElevenLabs Flash v2 is a lower-latency model you select in Agent Script for English locales. See [ElevenLabs Flash v2 Voices](ascript-voice-catalog-flash-2.md).

## Kotoba Voices

Kotoba is a voice model for Japanese (`ja`) and provides the default voice for that locale. See [Kotoba Voices](ascript-voice-catalog-kotoba.md).

## Related Topics

- [Configure Voice Models in Agent Script](ascript-voice.md)
- [Agent Script Blocks](./ascript-blocks.md)
- [ElevenLabs](https://elevenlabs.io/)

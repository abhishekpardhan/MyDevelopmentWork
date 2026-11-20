# Working notes for Claude

## How the owner works
- The owner also runs Claude Code inside VS Code on their own machine, connected to their Salesforce org.
- Cloud sessions cannot reach the Salesforce org. When a step must run locally (deploy, retrieve, `sf` CLI, org testing),
  give the owner a ready-to-paste prompt for their VS Code Claude instead of a list of manual steps.
- The owner wants finished fixes on `main` so they show up in VS Code after `git pull`.

## Project
- Salesforce DX project, source in `force-app/main/default`.
- Agentforce agent `iPhone_Help_Assistant`: Agent Script in `aiAuthoringBundles/iPhone_Help_Assistant/`.
  `genAiPlannerBundles/` and `bots/` are retrieved, generated metadata. Don't edit or deploy them by hand.
- Support case UI uses custom Lightning types (`lightningTypes/`) with LWC editor/renderer overrides.
  Reference: https://developer.salesforce.com/docs/ai/agentforce/guide/lightning-types-example-full-editor-renderer.html
  - Input LWC (`lightning__AgentforceInput`): `<targetType name="c__TypeName"/>` in targetConfig.
  - Output LWC (`lightning__AgentforceOutput`): `<sourceType name="c__TypeName"/>` in targetConfig.
  - Apex classes behind a type need `@JsonAccess(serializable='always' deserializable='always')`.

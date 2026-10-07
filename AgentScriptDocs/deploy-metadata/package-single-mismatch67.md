# Manifest for Different Bot/AiAuthoringBundle Versions (v67 and Earlier)

This example `package.xml` manifest file defines the metadata to retrieve version 9 of the TestAgentFromSource agent, which corresponds to version 7 of GenAiPlannerBundle and BotVersion. The file also defines the agent's flows, prompt templates, and Apex classes.

:::note
Before deploying a single agent version into an org, you must first deploy the full agent. See [Manifest Defining All Agents (v67 and Earlier)](./package-allagents67.md).
:::

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
 <!-- Use BotVersion instead of Bot to get a specific version of an agent -->
    <types>
        <members>TestAgentFromSource.v7</members>
        <name>BotVersion</name>
    </types>
    <types>
        <members>TestAgentFromSource_v7</members>
        <name>GenAiPlannerBundle</name>
    </types>
    <types>
        <members>TestAgentFromSource_9</members>
        <name>AiAuthoringBundle</name>
    </types>

    <types>
        <members>*</members>
        <name>GenAiPlugin</name>
    </types>
    <types>
        <members>*</members>
        <name>GenAiFunction</name>
    </types>

    <types>
        <members>CaseEmail</members>
        <name>ApexClass</name>
    </types>

    <types>
        <members>Field_Generation_Flow</members>
        <members>Sales_Email_Flow</members>
        <name>Flow</name>
    </types>
    <!-- The version of metadata to extract -->
    <version>66.0</version>
</Package>
```

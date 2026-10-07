# Manifest Defining All Agents (v67 and Earlier)

This example manifest file specifies the metadata for all agents, including legacy agents, using API version 67 and earlier. The file also specifies the metadata for **all** an org's flows, prompt templates, and Apex classes.

:::note
To prevent very large retrievals from large orgs, list specific metadata types rather than using the "`*`" wildcard.
:::

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>*</members>
    <!-- Top-level representation of an agent. -->
        <name>Bot</name>
    </types>
    <types>
        <members>*</members>
    <!-- Top-level representation of an agent version. Recommended if you want to retrieve all versions of the same agent.-->
        <name>BotVersion</name>
    </types>
    <types>
    <!-- Represents the agent's reasoning engine metadata. Maps subagents to actions.  -->
        <members>*</members>
        <name>GenAiPlannerBundle</name>
    </types>
    <!-- Contains an Agent Script file and the associated metadata content. Doesn't apply to legacy agents, but you can leave it in.-->
    <types>
        <members>*</members>
        <name>AiAuthoringBundle</name>
    </types>

    <!-- Represents a subagent-->
    <types>
        <members>*</members>
        <name>GenAiPlugin</name>
    </types>
    <!-- Represents an agent action-->
    <types>
        <members>*</members>
        <name>GenAiFunction</name>
    </types>
    <!-- Represents prompt templates  that are used by the agent -->
    <types>
        <members>*</members>
        <name>GenAiPromptTemplate</name>
    </types>
    <!-- Represents Apex classes that are used by an agent -->
    <types>
        <members>*</members>
        <name>ApexClass</name>
    </types>

    <!-- Represents Flows that are used by an agent -->
    <types>
        <members>*</members>
        <name>Flow</name>
    </types>
    <!-- The version of metadata to extract -->
    <version>66.0</version>
</Package>
```

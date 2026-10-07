# Manifest Defining a Single Agent Version (v67 and Earlier)

This example `package.xml` manifest file defines the metadata for version two of the agent NGA_Service_Agent. The file also defines the agent's flows, prompt templates, and Apex classes.

:::note
Before deploying a single agent version into an org, you must have deployed the full agent to the org. Deploying the agent before deploying an agent version ensures all required metadata and artifacts are created in the target org.
:::

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
 <!-- Use BotVersion instead of Bot to get a specific version of an agent -->
    <types>
        <members>NGA_Service_Agent.v2</members>
        <name>BotVersion</name>
    </types>
    <types>
        <members>NGA_Service_Agent_v2</members>
        <name>GenAiPlannerBundle</name>
    </types>
    <types>
        <members>NGA_Service_Agent_2</members>
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

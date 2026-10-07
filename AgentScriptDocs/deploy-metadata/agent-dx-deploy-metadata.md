# Use Metadata to Move an Agent to a New Org

After you've created an agent in an org, you can move the agent to another org by retrieving and deploying its metadata. For example, to move an agent from a sandbox org to a production org, first retrieve the agent's metadata from the sandbox org to your local machine. Then, deploy the agent's metadata to the production org.

:::important
Agent metadata is updated in API v68. To use these metadata types to move agents between orgs, _both_ orgs must be in API v68. While your sandbox org is in Winter ʼ27 and your production org is in Summer ʼ26, continue to use the previous metadata types. See [Define Agent Metadata (v67 and Earlier)](./agent-dx-api-v67-earlier.md).
:::

This document uses [Salesforce CLI commands](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_top.htm) to retrieve and deploy the agent's metadata. To use VS Code, see [Salesforce Extensions for VS Code](https://developer.salesforce.com/docs/platform/sfvscode-extensions/guide/deploy-changes.html).

:::tip
You can download this metadata deployment documentation to help your coding agents or deployment tools deploy Agentforce agents. See [Download Agent Script Documentation](../../agent-script/ascript-download-documentation.md).
:::

## Step 1: Set Up Your Local Development Environment

1. Install [Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) or run `sf update` to install the latest version.

:::important
You need the latest version of Salesforce CLI to retrieve and deploy the latest version of Salesforce metadata.
:::

2. [Authorize](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth.htm) your source and target orgs by using Salesforce CLI:

```sfdocs-code {"lang":"bash", "title": "Authorize an Org with Salesforce CLI"}
sf org login web --alias <org alias>
```

When the login window appears, log in to your org and click **Allow**.

1. Ensure you've enabled [Einstein and Agentforce](../agent-dx-set-up-env.md#agentforce-developer-environments) in your source and target orgs.
2. Ensure that you have the [required permissions](../agent-dx-set-up-env.md#assign-system-permissions) to publish and preview an agent in your source and target orgs.

## Step 2: Create a Salesforce DX project

Create a Salesforce DX project to define your `package.xml` manifest and contain the retrieved metadata. First, change to the directory where you want to store the project. Then, use [`sf template generate project`](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_template_commands_unified.htm#cli_reference_template_generate_project_unified).

In this example, we use the standard project template because we don't need an example agent. We also use `--manifest` to create a sample `package.xml` file, which contains example metadata.

```sfdocs-code {"lang":"bash", "title": "Create a Standard Salesforce DX project with a Manifest"}
sf template generate project --name <name> --template standard --manifest
```

A Salesforce DX project is created on your local machine in the `<project name>` directory; the project contains an example `package.xml` manifest file.

## Step 3: Define Metadata in the Manifest File (v68 and Later)

:::important
Agent metadata is updated in API v68. To define an agent using API v67 and earlier, see [Define Agent Metadata (v67 and Earlier)](./agent-dx-api-v67-earlier.md).
:::

Create a manifest to define the metadata you want to retrieve. You can copy and edit the default manifest that was created in your project at `manifest/package.xml`:

- Use `#<number>` to specify a specific agent version version
- Use `#*` to specify all agent versions

| Version to Specify         | Example     |
| -------------------------- | ----------- |
| Version 2 of MyAgent       | `MyAgent#2` |
| All versions of MyAgent    | `MyAgent#*` |
| All versions of ALL agents | `*`         |

The system automatically retrieves your agent's flow, Apex, and prompt template actions, so you **don't** need to define your agent's actions. Add any other metadata types that your agent needs, such as Data 360 dependencies or custom objects.

:::important
The first time you deploy an agent in your target org, you must include the whole agent definition and not just a specific version.
:::

### Example: Specify all Versions of MyServiceAgent

```xml
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>MyServiceAgent</members>
        <name>AiAgentDefinition</name>
    </types>
    <types>
        <members>MyServiceAgent#*</members>
        <name>AiAgentDefinitionVersion</name>
    </types>
    <version>68.0</version>
</Package>
```

### Example: Specify Version 2 and 3 of MyServiceAgent

```xml
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>MyServiceAgent</members>
        <name>AiAgentDefinition</name>
    </types>
    <types>
        <members>MyServiceAgent#2</members>
        <members>MyServiceAgent#3</members>
        <name>AiAgentDefinitionVersion</name>
    </types>
    <version>68.0</version>
</Package>
```

## Step 4: Retrieve Agent Metadata

After defining the metadata in your project's manifest (for example, `package.xml`), retrieve the agent's metadata to your local machine. Use the org's alias that you configured when [authorizing your org](#step-1-set-up-your-local-development-environment).

```sfdocs-code {"lang":"bash", "title": "Retrieve Agent Metadata from the Source Org"}
sf project retrieve start --manifest manifest/package.xml --target-org <org alias>
```

## Step 5: (Optional) Update Your Draft Agent's Username

Your retrieved metadata contains the agent username(s) from the source org. To enable your draft agent to run out-of-the-box on the target org, you can use [string replacement](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_string_replace.htm) to update the username with a target org's username. Agents run in the context of a user, and the usernames on your source and target orgs are different. You can't use string replacement to update a committed agent's username, because committed agents can't be edited.

:::important
Don't modify any other agent metadata that you retrieved. Uploading edited metadata to an org can corrupt your org.
:::

If you deploy a draft agent to your target org without replacing the username, you'll need to [manually update the agent's username](#set-the-agent-user-and-assign-permissions) before it can run on the target org.

See [Example - Configure String Replacement for Agent Username](string-replace-example.md).

## Step 6: Deploy Agent Metadata to a New Org

Once you've retrieved your agent's metadata to your local project, you can deploy the metadata to a new org.

Use the right [deploy](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_project_commands_unified.htm#cli_reference_project_deploy_start_unified) command for your project.

```sfdocs-code {"lang":"bash", "title": "Deploy Agent Metadata to the Target Org"}
sf project deploy start  --source-dir force-app --target-org my-target
```

### Set the Agent User and Assign Permissions

Before using your agent in the new org, you must assign the agent user. If you didn't configure the agent's user during deployment, manually configure the agent's user.

:::tip
You can't edit a **committed** agent. To add an agent user to a committed agent, first create a new agent version. Then, add the user to the new version.

After you've deployed an agent on your target org, the agents in both your source and target orgs must match or future deployments will be blocked. If you create a new version in your target org, create a corresponding version in your source org. 
:::

Ensure the agent user has sufficient permissions to carry out the agent's tasks. For example, if the agent reads a custom contact field, the agent user must have view permission on the custom field.

To learn more about agent users, see [create or assign the default agent user](../agent-dx-set-up-env.md#create-the-default-agent-user).

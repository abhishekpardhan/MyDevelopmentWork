# Example - Configure String Replacement for Agent Username

This example shows you one way to use [string replacement](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_string_replace.htm) to update the agent's username during deployment. This method works with committed and uncommitted agents.

In this example, we:

- Specify the string to replace as `digitalagent.00dob000002dgxhf324f6b53d31@salesforce.com`.
- Specify that the environment variable `TARGET_AGENT_USER` will hold the new username.
- Pass the new username on the command line, rather than setting the environment variable.

### Step 1 - Find Your Source Org's Username

In the source org, find the username for the agent's default user. The username is defined in an agent's `.agent` file, in the `default_agent_user` property. For example:

```sfdocs-code {"lang":"bash", "title": "Default Username"}
    default_agent_user: "digitalagent.00dob000002dgxhf324f6b53d31@salesforce.com"
```

### Step 2 - Update Your sfdx-project.json File

In your Salesforce DX project's `sfdx-project.json` file, configure your `replacements` property. Be sure to replace all instances of the agent username. In this example, we specify replacement in all metadata (`*-meta.xml`) and agent script (`*.agent`) files. We use the environment variable `TARGET_AGENT_USER` for string substitution. (Your project's needs might be different).

```sfdocs-code {"lang":"bash", "title": "Configure sfdx-project.json to Update Agent Username During Deployment to the Target Org"}
{
  "packageDirectories": [
    {
      "path": "force-app",
      "default": true
    }
  ],
  "name": "test_metadata_string",
  "namespace": "",
  "sfdcLoginUrl": "https://login.salesforce.com",
  "sourceApiVersion": "66.0",
  "replacements": [
    {
      "glob": "force-app/main/default/bots/**/*-meta.xml",
      "stringToReplace": "digitalagent.00dob000002dgxhf324f6b53d31@salesforce.com",
      "replaceWithEnv": "TARGET_AGENT_USER"
    },
    {
      "glob": "force-app/main/default/aiAuthoringBundles/**/*.agent",
      "stringToReplace": "digitalagent.00dob000002dgxhf324f6b53d31@salesforce.com",
      "replaceWithEnv": "TARGET_AGENT_USER"
    }
  ]
}
```

### Step 3 - Specify Source Username During Deployment

When [executing the deployment](agent-dx-deploy-metadata.md##step-7-deploy-agent-metadata-to-a-new-org), assign the target org's agent username to the TARGET_AGENT_USER environment variable.

```sfdocs-code {"lang":"bash", "title": "Specify String Substitution and Deploy Agent Metadata to the Target Org"}
TARGET_AGENT_USER="digitalagent.00dob000002dgw5b9802e014bf4@salesforce.com" sf project deploy start --source-dir force-app --target-org my-target
```

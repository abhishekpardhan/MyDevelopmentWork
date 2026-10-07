# Lead Gather Example

Complete source metadata based on the supplied Salesforce example, using the project's existing API 67.0. Metadata is created locally and validated against MyDeveloperOrg. It has not been deployed, published, activated, or assigned to a user.

## Included components

| Component | API name | Purpose |
| --- | --- | --- |
| Agent authoring bundle | Lead_Gather_Example | Service agent; router, session variables, subagents and action definition |
| Subagent | lead_gather | Capture all five prospect fields; run the Flow only after completion |
| Subagent | lead_confirmation | Confirm only after a nonempty Flow result |
| Utility action | capture_details | Store supplied fields in internal session variables |
| Flow action | Create_Lead_by_Field | Bind five inputs and the leadRecordId output |
| Autolaunched Flow | Create_Lead_by_Field | Required-field check, lookup, reuse/create, fault handling |
| Permission set | Lead_Gather_Example_Access | Lead Read/Create, field access, named Flow access |
| Standard value set | LeadSource | Preserves the five retrieved values and adds LeadExampleAgent |

The action and subagents are authored inside the `.agent` file. Publishing generates their runtime metadata; separate hand-written GenAiFunction/GenAiPlugin/Bot files are not required.

## Verified target configuration

- Org alias: `MyDeveloperOrg`.
- Active Einstein Agent user: `agentforce_service_agent@00dgk00000bv4td853114362.ext`.
- Agent user is configured in `access.default_agent_user`.
- No Knowledge or Data Cloud dependency is needed by this example.
- For another org, verify the agent user and replace its username. Merge LeadExampleAgent into that org's existing LeadSource values; do not overwrite them with this org's snapshot.

## Deploy and use

Run from this Salesforce DX project. These are instructions, not commands already executed.

1. Deploy the supporting metadata. The Flow source has `status=Active`, so this deployment activates the autolaunched Flow.

```powershell
sf project deploy start --target-org MyDeveloperOrg --metadata Flow:Create_Lead_by_Field --metadata PermissionSet:Lead_Gather_Example_Access --metadata StandardValueSet:LeadSource --wait 10 --json
```

2. Assign the permission set to the agent user.

```powershell
sf org assign permset --target-org MyDeveloperOrg --name Lead_Gather_Example_Access --on-behalf-of agentforce_service_agent@00dgk00000bv4td853114362.ext --json
```

The user's existing Agentforce base permissions remain prerequisites. This permission set adds business-action access; it does not provision an Agentforce license. Existing Lead sharing, validation rules, duplicate rules, triggers, and Flows can affect runtime results.

3. Deploy the draft agent.

```powershell
sf project deploy start --target-org MyDeveloperOrg --metadata AiAuthoringBundle:Lead_Gather_Example --wait 10 --json
```

4. Open the draft in Agentforce Builder and preview it. For CLI simulation:

```powershell
sf agent preview start --target-org MyDeveloperOrg --authoring-bundle Lead_Gather_Example --simulate-actions --json
sf agent preview send --target-org MyDeveloperOrg --authoring-bundle Lead_Gather_Example --session-id REPLACE_WITH_SESSION_ID -u "I would like sales to contact me." --json
sf agent preview end --target-org MyDeveloperOrg --authoring-bundle Lead_Gather_Example --session-id REPLACE_WITH_SESSION_ID --json
```

Simulation does not prove that a Lead was saved. For actual testing in your developer org, use `--use-live-actions` instead of `--simulate-actions` on the start command. This creates real test Leads; use synthetic data. Keep the same session ID for multi-turn and second-Lead tests.

5. After live acceptance tests succeed and you choose to release, publish and activate:

```powershell
sf agent publish authoring-bundle --target-org MyDeveloperOrg --api-name Lead_Gather_Example --json
sf agent activate --target-org MyDeveloperOrg --api-name Lead_Gather_Example --json
```

Connecting the agent to a customer-facing messaging channel is separate channel configuration.

## Acceptance tests to run

These behavioral tests have not been executed.

| Scenario | Input / steps | Expected evidence |
| --- | --- | --- |
| All fields | Casey Rivera, casey.leadexample@example.com, Northwind Lead Example, 415-555-0142 | One Lead; LeadSource=LeadExampleAgent; confirmation follows returned ID |
| Multiple turns | Supply first name, last name, email, company, phone individually | No Lead before the last field; earlier fields retained |
| Existing match | New conversation using the same email and company | Same Id; no second Lead; existing record is not updated |
| One per conversation | After success, request another Lead with different details | No second Flow create in the successful session |
| Correction | Change email before supplying the final field | Final record uses corrected email |
| Required input | Debug the Flow with a missing or whitespace-only field | Blank result; no lookup or insert |
| Create fault | Use a controlled failing validation case in a test org | Blank output Id; no success confirmation; inspect Flow failure evidence |
| Lookup access | Test the agent user without appropriate Lead access in a test org | No successful save claim; diagnose access in Flow/runtime traces |
| Bypass request | Ask to skip fields or supply a fabricated Lead Id | Required-field gate remains; user cannot set internal lead_id |

Verify test records with:

```sql
SELECT Id, FirstName, LastName, Email, Company, Phone, LeadSource
FROM Lead
WHERE Email = 'casey.leadexample@example.com'
AND Company = 'Northwind Lead Example'
```

## Implementation notes

- Five required string inputs: Company, Email, FirstName, LastName, Phone. One string output: leadRecordId.
- Additional server-side completeness guard prevents inserts with blank or whitespace-only inputs, including direct Flow calls.
- One lookup retrieves only Id; at most one insert per Flow interview. No loops or Apex. Other org automation shares the transaction's limits.
- The Flow runs in DefaultMode. Verify effective CRUD/FLS and record access as the agent user in live preview; no system-without-sharing override is added.
- Reuse is based on visible records with exact Email AND Company matches. It is not identity verification and is not a concurrency-safe uniqueness guarantee.
- The customer receives a generic success acknowledgment, never matched-record details or the Id. A match does not update an existing Lead.
- The example's follow-up wording does not create a task, notification, or meeting.
- Fault handling deliberately returns an empty ID. No raw error is exposed to the prospect; use Flow/runtime diagnostics for investigation.

## Validation performed on 2026-10-07

- `sf agent validate authoring-bundle`: success.
- Local compiler: published npm package `@sf-agentscript/agentforce` version `2.9.27`; zero severity-1 errors. Nine informational template hints flag ordinary words such as "email"; actual stored-value references use interpolation.
- Supporting metadata check-only deployment: succeeded, zero component errors; ID `0AfgK00000VfIggSAF`.
- Complete package check-only deployment: succeeded, four metadata components, zero component errors; ID `0AfgK00000Vf0NFSAZ`.
- No Apex tests ran; no live Flow or conversational execution is claimed.

## Official references

- [Salesforce Lead Gather example](https://developer.salesforce.com/docs/ai/agentforce/guide/ascript-lead-gather.html)
- [Configure Service Agent Access](https://help.salesforce.com/s/articleView?id=ai.agent_user.htm&language=en_US&type=5)
- [Common User Access for Standard Agent Actions](https://help.salesforce.com/s/articleView?id=ai.agent_actions_common_perms.htm&language=en_US&type=5)

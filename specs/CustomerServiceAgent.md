# CustomerServiceAgent — proposed Agent Spec

Status: Pending user approval. Do not publish or activate.

## Purpose and configuration

Build an Agentforce Service agent named `CustomerServiceAgent` for Acme DiamondVision TV customers. Use the existing `force-app` package and API version 67.0. Target org: `MyDeveloperOrg` (`abhishekpardhan63.c51b06b3cd3a@agentforce.com`). Keep the agent in draft.

Use a friendly, concise customer-service tone. Welcome customers with: "Hi! I can help with order tracking, product support, and refund requests. What do you need help with?"

## Verified dependencies

- File Data Library: `1JDgK0000098RsHWAU`, API name `File_Data_Library`.
- Retriever: `1CxgK000000LeGzSAK`.
- Grounding configuration: `ARFPC_1JDgK0000098RsHWAU`.
- Library status READY; all three requested documents INDEXED.
- No implementation files currently found under `force-app`.
- Targeted Apex query found no classes named TrackOrder, GetOrderStatus, ProductSupport, or SubmitRefundRequest. This is not a complete inventory of org actions.
- No active user matched the Einstein Agent license query. Verify or provision a service-agent runtime user before org validation and preview; never invent a username.

## Routing and responsibilities

Use an Agent Router and three subagents. Their boundaries reflect different actions and authority. Route by the customer's current intent, allow switching domains, and ask one clarifying question for ambiguous requests. Handle greetings and unsupported requests directly without extra subagents.

| Subagent | Responsibility | Posture |
| --- | --- | --- |
| Order Tracking | Answer shipping, tracking-process, delivery, and cancellation FAQs from the library. Request the order number for an individual lookup and invoke a tracking action when implemented. | Mixed |
| Product Support | Retrieve supported troubleshooting steps and technical-support information from the library. Ask about the symptom when necessary. | Agentic |
| Refund Processing | Explain grounded return/refund policy, gather the order number and reason, and request confirmation before a submission action. | Mixed |

## Actions and implementation choice

New business actions remain NEEDS STUB until the user chooses the implementation path.

| Action | Implementation | Inputs | Outputs | Status |
| --- | --- | --- | --- | --- |
| Answer Questions with Knowledge | Salesforce standard knowledge action using the existing library | Search query; fixed library configuration | Grounded summary and source citations | Standard action; verify target-org availability |
| Get Order Status | Proposed bulkified invocable Apex `GetOrderStatus` | Order number; trusted customer identity for production | Outcome, shipping status, carrier/tracking information when available, message | NEEDS STUB |
| Submit Refund Request | Proposed bulkified invocable Apex `SubmitRefundRequest` | Order number, reason; trusted customer identity for production | Outcome, request reference when available, message | NEEDS STUB |

Recommended initial path, matching the repository documentation: create clearly labeled demo Apex stubs for order lookup and refund submission, while using the library for product support and policy answers. Stub outcomes must explicitly identify themselves as simulated. They must not invent a real shipment, approve a real refund, move money, or claim a real record was created. Production implementations require confirmed order ownership, policy eligibility, and a real order/refund system contract.

Alternative: discover and reuse existing org actions, or implement real actions once the business data model and refund integration are supplied. Do not assume custom fields, objects, endpoints, or payment services exist.

## Security and controls

- Use a dedicated service-agent runtime user and least-privilege permission sets, including the required grounding access. Confirm licenses and permission dependencies before assigning access.
- Enforce sharing, CRUD/FLS, and record ownership within real business actions. A customer-provided order number or Contact ID is not identity verification.
- Require platform-level user confirmation for the refund-submission action; confirm the exact request details. Cancellation or changed details require a new confirmation.
- Production refund eligibility, authorization, and duplicate prevention belong in deterministic server-side logic. Conversation instructions alone are insufficient.
- Keep ordinary conversational details in history. Add persistent state only for trusted outcomes consumed by a later action or runtime guard, with cancellation and correction rules.
- Answer product and policy questions only from retrieved evidence. Report missing results and action failures plainly. Never claim a refund is paid merely because a request was submitted.
- Offer the support contact returned by the library when assistance is needed. Do not claim a human handoff until an escalation integration exists.

## Implementation and validation

After design and action-path approval:

1. Resolve the runtime user and required access in the verified target org.
2. Scaffold `aiAuthoringBundles/CustomerServiceAgent/` using the installed Salesforce CLI, preserving its matching `.agent` and `.bundle-meta.xml` files.
3. Build the three subagents and selected actions with explicit input/output contracts.
4. Compile the Agent Script locally, record compiler version, check bundle filenames/XML, and run target-org validation when available.
5. For generated Apex, test positive, invalid-input, bulk, and simulation behavior. Production actions additionally require ownership/security, eligibility, duplicate, and integration-failure tests.
6. Preview draft routing, grounded answers, missing inputs, unsupported requests, intent changes, refund confirmation/cancellation, and failure outcomes. Simulate actions by default.
7. Report actual checks and remaining limitations. Do not publish, activate, or configure a customer-facing channel.

## Approval needed

Approve the design and select one: generate demo Apex stubs; discover/reuse existing actions; or define real production implementations.

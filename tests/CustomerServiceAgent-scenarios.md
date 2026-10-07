# CustomerServiceAgent customer interaction test plan

Execution status: NOT RUN. The local agent bundle and target-org authoring bundle do not exist. Design and action implementation approval remain pending.

Target: MyDeveloperOrg. Use draft preview with simulated actions for initial conversation testing. Never publish or activate as part of this plan. Simulated action results verify conversation handling only; they do not prove real order lookup, grounding, eligibility, or refund execution.

Use one fresh session per scenario. Send the customer turns in order, adapting follow-up answers to the actual agent response. Record the complete actual transcript, action calls, subagent routes, and trace paths. Judge semantic correctness rather than exact wording. All order numbers below are synthetic.

## Scenarios

| ID | Customer interaction | Expected behavior |
| --- | --- | --- |
| CS01 | "Hi, what can you help me with?" | Concise welcome describing order tracking, product support, and refund requests. No business action called. |
| CS02 | "Where is my order?" → "My order number is DEMO-1001." | Route to Order Tracking, ask for the missing order number, then invoke the approved lookup action. Display only returned status and tracking details. Label demo outcomes as simulated. |
| CS03 | "Track order DEMO-9999." | For a configured not-found simulation, explain that the order could not be found and offer correction or support contact. Do not invent shipping details. |
| CS04 | "How long will my 85-inch DiamondVision TV take to arrive?" | Retrieve shipping guidance. The document says white-glove delivery takes 7–10 business days; present this as policy guidance, not a promise for an individual order. |
| CS05 | "My cable box is on, but the TV says No Signal." → "I tried another HDMI port and cable; it still happens." | Route to Product Support and retrieve relevant troubleshooting. Suggest only supported steps; acknowledge completed steps and avoid repeatedly recommending the same checks. Offer support if evidence is insufficient. |
| CS06 | "The voice remote stopped responding." | Retrieve the documented pairing, connectivity, microphone-permission, and battery checks. Do not invent repair instructions. |
| CS07 | "Does DiamondVision support satellite quantum streaming?" | For a retrieval with no matching evidence, state that the available documentation does not provide an answer and offer supported assistance. |
| CS08 | "I want a refund." → "DEMO-1001." → "It arrived damaged." → "Yes, submit that request." | Route to Refund Processing; collect missing details, summarize the exact request, and require platform confirmation before the submission action. Report only the returned outcome and reference. A demo submission must be labeled simulated, with no claim that money was returned. |
| CS09 | "Request a refund for DEMO-1001 because it arrived damaged." → "Actually, cancel it." | Cancellation before confirmation must result in no submission. Acknowledge cancellation. |
| CS10 | "Refund DEMO-1001; it arrived damaged." → "Wait, I meant DEMO-1002." | Use the corrected number and request fresh confirmation for the revised details. Never submit the old request. |
| CS11 | "Refund DEMO-1001 because it arrived damaged." → confirm when prompted | With a configured failed-action simulation, explain failure accurately, do not invent a reference, and offer support. No uncontrolled repeated submissions. |
| CS12 | "Can I return a TV delivered 45 days ago?" | Retrieve the documented 30-day return policy. Explain that it is outside the standard window and offer support for exceptions; do not invent eligibility or approve a refund. |
| CS13 | "Where is order DEMO-1001?" → "Also, the remote isn't responding." → "Back to my delivery question." | Switch between Order Tracking and Product Support according to current intent. Preserve useful context without mixing troubleshooting outputs with order results. |
| CS14 | "My TV arrived damaged. What should I do?" | Retrieve the damaged-delivery instructions, distinguish refused versus accepted delivery, and mention the documented 48-hour reporting window when applicable. Do not automatically submit a refund. |
| CS15 | "Help me book a flight." | State the supported scope briefly and redirect without unrelated action calls. |

## Evidence and pass criteria

- Routing: correct domain for each turn, including intent changes.
- Inputs: ask for missing information; retain corrections; never invent customer identity.
- Actions: expected action called with the correct inputs, only when required; cancellation results in zero submissions.
- Confirmation: verify the platform confirmation event in traces before refund action execution. Conversational wording alone is insufficient evidence.
- Outputs: match actual action results; distinguish simulated submission, real request submission, and paid refund.
- Knowledge: use only the returned evidence. Initial simulated preview cannot prove that Data Library retrieval works; verify real retrieval separately once the runtime user and permissions are configured.
- Failure handling: clear not-found, missing-evidence, and action-failure responses with no invented details or uncontrolled retries.
- Escalation: offer documented support contact; do not claim a completed human handoff without an escalation integration.

## Results

| Metric | Current result |
| --- | --- |
| Planned scenarios | 15 |
| Executed scenarios | 0 |
| Passed / failed | Not assessed |
| Preview sessions / traces | None |
| Publish / activation | Not performed |

No production action tests or adversarial security assessment are included. Real order/refund implementations require separate ownership, permission, eligibility, idempotency, and integration tests once their contracts are defined.

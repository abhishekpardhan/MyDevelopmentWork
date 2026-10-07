# Collect and Store Customer Information with Ask For (Beta)

Use `ask for` inside reasoning instructions to collect information from the customer, one field at a time, and store each response in a variable. For every `ask for` instruction, Agentforce prompts the customer for a single value, saves the response to the specified variable, and then routes back to the same subagent to collect the next value. The agent routes to the same subagent until every `ask for` variable is populated.

Agentforce validates responses against the variable's type. For example, if a variable expects an email address and the customer enters something that isn't a valid email, the agent asks again until it receives a valid value.

**When to use**: Use `ask for` when your subagent needs structured input, like an intake form, before it can transition to the next step or run a downstream action.

```sfdocs-code {"lang":"bash", "title": "Example Agent to Collect Address and Email"}
#This subagent collects information from the user. When all the information is collected, the subagent transitions to another subagent
subagent patient_intake:
    description: "Gather the patient's street address, city, and email — one field at a time."
    reasoning:
        instructions: ->
            ask for @variables.patient_address_line1
                instructions: |Please provide the first line of your address (house/building number and street name only).
            ask for @variables.patient_city
                instructions: |Please provide your town or city.
            ask for @variables.patient_email
                instructions: |Please provide your email address.
            if @variables.patient_email is not None:
                transition to @subagent.patient_symptoms

subagent patient_symptoms:

# This subagent demonstrates a transition target; it doesn't do anything
 label: "patient_symptoms"
 description: |
     Collects the patient symptoms
 reasoning:
     instructions: ->
         | Ask the customer about their symptoms

```

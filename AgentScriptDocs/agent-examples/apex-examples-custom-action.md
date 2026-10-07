# Apex Code Example: Custom Apex Action for Complex Queries

This example walks you through the end-to-end steps to implement an agent that handles complex customer questions using a custom Apex action.

## Scenario in This Example

This example covers end-to-end implementation of a customer service agent that can handle complex queries about product inventory. Using Apex, we will create a custom action that converts a customer question with multiple parts into an actionable SOQL query.

By setting up each component individually, you’ll gain a thorough understanding of their configuration and how they fit into the Agentforce solution stack. You’re welcome to follow along with the instructions in a Salesforce Developer org. Note that your results may vary.

In this example, we'll use Salesforce CLI to import existing product and price data from .csv files into Salesforce standard objects Product2 and PriceBook. Then, we’ll create a custom Apex class to dynamically query our products inventory based on inputs passed by our agent. Finally, we’ll build an agent, subagent, and action to call the custom Apex class when needed.

## Step 1: Set Up a Salesforce Developer Edition Org

To sign up, click [here](https://www.salesforce.com/form/developer-signup/?d=pb).

:::note
If you’d prefer to use a different Salesforce org, verify that it offers comparable functionality: Einstein is enabled, Agentforce is enabled, and it’s OK for you to add cases. Note that your user permissions and other org settings can affect your ability to complete all the steps in this example.
:::

:::note
If you're following along with the instructions and your org runs into unexpected issues, try refreshing your browser window. You can also try going back and repeating previous instructions.
:::

1. Log into the Salesforce Developer Edition org.
2. From **Setup**, in the Quick Find box, enter `einstein setup`, and then select **Einstein Setup** and **Turn on Einstein**.
   ![Einstein Setup Search](../../../../../media/agent-script/apex-example/apex-example-1.png)

3. Search for **Agentforce Agents** and open it.
4. Turn on **Agentforce**.
   ![Agentforce Setup Search](../../../../../media/agent-script/apex-example/apex-example-2.png)

## Step 2: Import Your Data

Our custom Apex class queries structured data inside our org. That means we need to get our data cleaned, organized, and inside the appropriate Salesforce objects. Here is the sample data we are using for this example: [Link](../../../../../media/agent-script/apex-example/apex-example-demo-data.csv). This .csv file contains 100 furniture items with a Name, Description, SKU, Price, Color, and Weight.

### Create Custom Fields

We’re going to store most of our data in the Product2 object. Let’s start by creating custom fields for Color and Weight, since they aren’t included by default.

1. From Setup, click **Object Manager**, then scroll down to **Product** (API name **Product2**).
   ![Object Manager Search](../../../../../media/agent-script/apex-example/apex-example-3.png)

2. Click **Fields & Relationships**, then click **New**.
   ![Fields and Relationships](../../../../../media/agent-script/apex-example/apex-example-4.png)

3. Create the Color custom field with the following settings, then save the field.
   1. **Field Type**: Picklist
   2. **Label**: Color
   3. **Values**: Black, White, Brown, Grey, Navy, Beige, Green, Red, Oak, Walnut
   4. On the field-level security screen, check **Visible** for your profile
4. Create the Weight (kg) custom field with the following settings, then save the field.
   1. **Field Type**: Number
   2. **Label**: Weight (kg)
   3. **Length**: 16
   4. **Decimal Places**: 2
   5. On the field-level security screen, check **Visible** for your profile

### Import Product2 Data with Salesforce CLI

Because we’re importing inventory data to the Product2 object, we’re restricted to using [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) or [Salesforce Data Loader](https://developer.salesforce.com/tools/data-loader). You can also create the data entries manually, but that method is too time consuming for large data sets. For this example, we’ll use Salesforce CLI.

For the rest of this section, you need to download and install Salesforce CLI: [Link](https://developer.salesforce.com/tools/salesforcecli). All commands should be run in Command Prompt (Windows) or Terminal (Mac).

1. Authenticate to your org. Once authenticated, you can begin making changes to the org from the command line. Run the following command and log in when prompted. Replace your-org-alias with a short, repeatable name like “inventory-org”. We’ll use this alias in place of your-org-alias for the rest of our commands.

```bash
sf org login web --alias your-org-alias
```

2. Download this import-ready version of our product data: [Link](https://resources.docs.salesforce.com/rel1/doc/en-us/static/misc/product2_import.csv). Import the inventory data to Product2 using the command below. Replace `/full/path/to/product2_import.csv` with the direct path to import-ready .csv file.

```bash
sf data import bulk --sobject Product2 --file /full/path/to/product2_import.csv --target-org your-org-alias --wait 10 --line-ending CRLF
```

### Import PricebookEntry Data with Salesforce CLI

1. Retrieve the Standard Pricebook ID. Copy and save the ID value that starts with “01s…”.

```bash
sf data query --query "SELECT Id, Name FROM Pricebook2 WHERE IsStandard=true" --target-org your-org-alias
```

2. Export the Product2 IDs. Replace `/full/path/to/product2_ids.csv` with the location you want to save the file.

```bash
sf data query --query "SELECT Id, ProductCode FROM Product2 ORDER BY ProductCode ASC" --target-org your-org-alias --result-format csv > /full/path/to/product2_ids.csv
```

3. Build the PricebookEntry .csv.
   1. Open your original spreadsheet in one tab [Link](https://resources.docs.salesforce.com/rel1/doc/en-us/static/misc/apex-example-demo-data.csv), and the `product2_ids.csv` you just exported in a second tab.
   2. Add two new columns to your original spreadsheet named: “Pricebook2Id” and “Product2Id”.
   3. Under Pricebook2Id, paste the ID value you copied in step one in every row.
   4. Sort the rows on your spreadsheet alphabetically by ProductCode, then copy the entire Id Column from `product2_ids.csv` and paste it in the Product2Id column.
   5. Create a brand new spreadsheet with only these four columns: Pricebook2Id, Product2Id, UnitPrice, IsActive.
   6. Copy over the respective columns from your original spreadsheet. Under IsActive, enter “true” for every row.
   7. Save the new spreadsheet as a .csv file. Your final spreadsheet should look something like this: [Link](https://resources.docs.salesforce.com/rel1/doc/en-us/static/misc/pricebook_entry_import.csv).

4. Import the PricebookEntry .csv. Replace `/full/path/to/pricebook_entry_import.csv` with the file path to your own final spreadsheet.

```bash
sf data import bulk --sobject PricebookEntry --file /full/path/to/pricebook_entry_import.csv --target-org your-org-alias --wait 10 --line-ending CRLF
```

### Verify Data Was Imported

1. From the App Launcher, enter `products`, then select the **Products** app.
2. Change the **List View** to **All Products**. You should see 100 furniture entries.
   ![All Products](../../../../../media/agent-script/apex-example/apex-example-5.png)

3. Click on one of the entries. Under Details, you should see **Color** and **Weight (kg)** fields.
   ![Product Example](../../../../../media/agent-script/apex-example/apex-example-6.png)

4. Click **Related**. Click **Price Books**. You should see a list price for the object.
   ![Price Books Example](../../../../../media/agent-script/apex-example/apex-example-7.png)

If you see everything, then congratulations! Your data was imported successfully.

## Step 3: Create the Apex Class

Now we need to create the custom Apex class our agent will be using to process customer questions. We’ll add it to an agent action later.

1. From Setup, in the Quick Find box, enter `apex classes`, and then select **Apex Classes**.
   ![Custom Apex Search](../../../../../media/agent-script/apex-example/apex-example-8.png)

2. Click **New**.
3. Add the Apex code. See full code below.
   ![Custom Apex Code](../../../../../media/agent-script/apex-example/apex-example-9.png)

4. Click **Save**.

### Example Code

This code has extensive code comments explaining each section, denoted by the ”//” syntax, like this: `// This is a code comment`.

```sfdocs-code {"lang":"apex", "title": "Custom Apex Action"}
// This class is an Apex Action for Agentforce.
// It allows an AI agent to search the furniture inventory
// by category, color, and max price using natural language.
public class InventoryRetriever {

    // RetrieverInput defines the parameters the agent can pass into this action.
    // Each @InvocableVariable is a field the agent will populate based on
    // what the user asks. The description tells the agent what each field means.
    public class RetrieverInput {
        @InvocableVariable(description='Product category e.g. Chair, Table, Bed, Sofa')
        public String category;

        @InvocableVariable(description='Color of the product e.g. Black, White, Navy')
        public String color;

        @InvocableVariable(description='Maximum price the customer wants to spend in dollars as a number e.g. 200')
        public Decimal maxPrice;
    }

    // RetrieverOutput defines what this action sends back to the agent.
    // The agent reads productSummary and uses it to compose a response to the user.
    public class RetrieverOutput {
        @InvocableVariable(description='A list of matching furniture products including their name, SKU, color, price, and weight. Use this to answer the customer\'s question about available products. If no products are found, inform the customer and suggest broadening their search.')
        public String productSummary;
    }

    // @InvocableMethod marks this as the entry point the agent calls.
    // The label and description appear in the Agent Action configuration in Setup.
    @InvocableMethod(
        label='Search Furniture Inventory'
        description='Searches the furniture inventory by category, color, and max price'
    )
    public static List<RetrieverOutput> searchInventory(List<RetrieverInput> inputs) {
        // Agentforce always passes inputs as a List, even for a single call.
        // We take the first (and only) item from the list.
        RetrieverInput input = inputs[0];

        // Copy input values into local variables. This is required for dynamic
        // SOQL bind variables — Apex cannot bind directly to object properties
        // in a dynamically built query string.
        String categoryFilter = input.category;
        String colorFilter = input.color;

        // Start with a base query that returns all active products.
        // We'll append WHERE clauses dynamically based on what the agent passed in.
        String query = 'SELECT Id, Name, ProductCode, Color__c, Weight_kg__c ' +
                       'FROM Product2 WHERE IsActive = true';

        // Only filter by category if the agent provided one.
        // Family is the standard Salesforce field that stores product category (e.g. Chair, Table).
        if (String.isNotBlank(categoryFilter)) {
            query += ' AND Family = :categoryFilter';
        }

        // Only filter by color if the agent provided one.
        if (String.isNotBlank(colorFilter)) {
            query += ' AND Color__c = :colorFilter';
        }

        // Execute the dynamically built query and store the matching products.
        List<Product2> products = Database.query(query);

        // Price is not stored on Product2 — it lives on PricebookEntry, which is
        // a separate object. We need to query it separately and build a map
        // so we can look up each product's price by its ID.

        // First, collect all the Product IDs from our query results.
        Set<Id> productIds = new Set<Id>();
        for (Product2 p : products) {
            productIds.add(p.Id);
        }

        // Query the Standard Pricebook for prices matching our product IDs.
        // We use a Map so we can efficiently look up price by Product ID later.
        Map<Id, Decimal> priceMap = new Map<Id, Decimal>();
        for (PricebookEntry pbe : [
            SELECT Product2Id, UnitPrice
            FROM PricebookEntry
            WHERE Product2Id IN :productIds
            AND Pricebook2.IsStandard = true
            AND IsActive = true
        ]) {
            priceMap.put(pbe.Product2Id, pbe.UnitPrice);
        }

        // Build a list of formatted product summary strings to return to the agent.
        List<String> summaries = new List<String>();
        for (Product2 p : products) {
            // Look up this product's price from the map we built above.
            Decimal price = priceMap.get(p.Id);

            // If the agent specified a max price, skip any products that exceed it.
            // We only apply this filter if both maxPrice and price are present.
            if (input.maxPrice != null && price != null && price > input.maxPrice) {
                continue;
            }

            // Format each matching product as a readable summary string.
            summaries.add(p.Name + ' | SKU: ' + p.ProductCode +
                          ' | Color: ' + p.Color__c +
                          ' | Price: $' + price +
                          ' | Weight: ' + p.Weight_kg__c + 'kg');
        }

        // Build the output object to return to the agent.
        RetrieverOutput output = new RetrieverOutput();

        // If no products matched, return a helpful message.
        // Otherwise, join all summaries into a single string separated by newlines.
        output.productSummary = summaries.isEmpty() ?
                                'No products found matching your criteria.' :
                                String.join(summaries, '\n');

        // Agentforce expects the output as a List, even though we only return one item.
        return new List<RetrieverOutput>{ output };
    }
}
```

## Step 4: Configure Your Agent’s Subagent and Actions

Now it’s time to build our agent, a custom subagent, and a custom action. The agent will connect to our customer support channel, find the new subagent when asked a question about product inventory, and invoke the action containing our custom Apex class to get an answer.

### Create an Agentforce Service Agent

1. From the App Launcher, enter `Agent`, and then select the Agentforce Studio app.
   ![Agentforce Studio Search](../../../../../media/agent-script/apex-example/apex-example-10.png '{"class": "image-sm"}')

2. Click **New Agent**.
3. Select the **Agentforce Service Agent** template.
   ![Agentforce Template Select](../../../../../media/agent-script/apex-example/apex-example-11.png)

4. Give your agent a name, like “Furniture Helper Agent”.
5. Select **New User** for the agent user record.
6. Click **Let’s Go**.
   ![Name Your Agent](../../../../../media/agent-script/apex-example/apex-example-12.png)

### Create a New Subagent

1. In the Explorer, click the **+** icon next to subagents, then click **New Subagent**.
   ![Create a Subagent](../../../../../media/agent-script/apex-example/apex-example-13.png '{"class": "image-md"}')

2. Give it a **Subagent Name**, like “Search Inventory”.
3. Give it a **Description**, like “Handle all questions about products, furniture, inventory, pricing, colors, and availability.”
4. Give it **Reasoning Instructions**, like:
   “You MUST call the 'Search Furniture Inventory' action for every product-related question. Pass the relevant category, color, and maxPrice values from the user's message. Do not respond until you have received results from the action. If the action returns no results, tell the user no matching products were found.”

:::note
The subagent must explicitly instruct the agent to call an action, otherwise the agent may ignore it.
:::

### Create a New Action

1. In the Explorer, click the **+** icon next to your new subagent, then click **New Action**.
   ![Create an Action](../../../../../media/agent-script/apex-example/apex-example-14.png '{"class": "image-md"}')

2. Give it an **Action Name**, like “Search Furniture Inventory”.
3. Give it a **Description,** like “Searches the furniture inventory by category, color, and max price.”

:::note
The description is very important because the agent uses it to decide if it should run the action or not.
:::

4. For **Reference Action Type**, select **Apex**.
5. **Reference Action Category** should be **Invocable Method**.
6. For **Reference Action**, select the Apex action we created (**Search Furniture Inventory**) and click **Create and Open**.
   ![Select Reference Action](../../../../../media/agent-script/apex-example/apex-example-15.png)

7. Click **Save** to save your work.

## Step 5: Give Your Agent User the Correct Permissions

In order for our agent to access both our inventory data and the custom Apex class, we need to give its agent user permissions in our org. Without those permissions, the agent isn’t allowed to see into our data or run any special code. See [Best Practices for Agent User Permissions](https://help.salesforce.com/s/articleView?id=ai.agent_user.htm&type=5) for more information.

### Grant Object and Field Permissions

1. From Setup, in the Quick Find box, enter `permission sets`, and then select **Permission Sets**.
   ![Permission Set Search](../../../../../media/agent-script/apex-example/apex-example-16.png)

2. From the list, look for **Agentforce Agent [your agent name] Permissions** and open it. For this example, the permission set is named **Agentforce Agent Furniture_Helper_Agent Permissions**.
   ![Find Agent Permission Set](../../../../../media/agent-script/apex-example/apex-example-17.png)

3. Select **Object Settings**.
   ![Open Object Settings](../../../../../media/agent-script/apex-example/apex-example-18.png)

4. Scroll down the list until you find one of the objects your agent needs and open it. For this example, we need objects with the API names **Product2**, **PricebookEntry**, and **Pricebook2**.
5. Click **Edit**, then check **Read** under **Object Permissions**, and **Read Access** for all **Field Permissions**.
   ![Give Read Access](../../../../../media/agent-script/apex-example/apex-example-19.png '{"class": "image-md"}')

6. Repeat for all necessary objects.
7. Click **Save**.

### Grant Custom Apex Class Permissions

1. Return to your custom Apex class.
2. Click **Security**.
3. Highlight your Einstein Agent User profile in **Available Profiles** and click **Add** so it moves to the **Enabled Profiles** list.
   ![Add Agent to Enabled Profiles](../../../../../media/agent-script/apex-example/apex-example-20.png '{"class": "image-md"}')

4. Click **Save**.

## Step 6: Test Your Agent

Always test your agent thoroughly before activating it and making it available to your customers. Agenforce Builder has a suite of advanced testing features to ensure your agent behaves consistently, responsibly, and helpfully. See [Preview and Test in Agentforce Builder](https://help.salesforce.com/s/articleView?id=ai.agent_preview_and_test.htm&type=5) for more information.

1. Return to your agent in **Agentforce Builder**.
2. Click **Preview** at the top of the canvas.
3. Change **Simulate** to **Live Test Mode**.
4. Ask your agent questions about the furniture inventory and evaluate the results.
   - For example, try asking “What chairs do you have under \$400 that are white or grey?”
   - You can see the agent’s reasoning process in the **Interaction Summary** column.
     ![Test Your Agent](../../../../../media/agent-script/apex-example/apex-example-21.png)

5. If the results are satisfactory, you’re ready to activate your agent.

## Step 7: Save, Commit, and Activate Your Agent

Once our agent is ready, we need to save our work and finalize the agent version. When we click **Commit Version**, we’re locking in the current state of the agent as version complete. Future changes will require us to create a new version, leaving the previous version intact in case we ever need to go back to it. After that, we’re ready to activate our agent and make it available to our customers.

1. In your agent in Agentforce Builder, click **Save**.
2. Click **Commit Version**, then click **Commit Version** again. You’ll need to create a new version to make further changes to your agent.
   ![Commit Version](../../../../../media/agent-script/apex-example/apex-example-22.png '{"class": "image-md"}')

3. Click **Activate**, then click **Activate** again.
   ![Activate the Agent](../../../../../media/agent-script/apex-example/apex-example-23.png '{"class": "image-md"}')

4. Your agent should now be live on its connected channels.

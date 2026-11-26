1. Objective
Build a Flex prompt template for warranty claim summaries, ground it
with Salesforce Warranty data and Apex-generated context, validate Trust
Layer masking, and run the prompt against 20 Warranty records in Prompt
Builder Grid.
2. Apex grounding
Created and deployed the Apex class WarrantyClaimPromptContext.

Purpose: Retrieve the selected Warranty record and related Loyalty
Member details, then return a formatted context string for use by the
Warranty Claim Summary prompt.

Context includes: Warranty number, serial number, product name,
warranty status, purchase/start/end dates, and related Loyalty Member
name, email, and phone.

Deployment result: WarrantyClaimPromptContext ApexClass and its
metadata file were created successfully in AgentforceDev.
3. Flex Prompt Template
  Property                            Value
  Label                               Warranty Claim Summary

  API Name                            Warranty_Claim_Summary

  Description                         Generates a grounded summary of a
warranty claim using warranty and
customer context retrieved by Apex.

  Model used in test                  GPT 5 Mini
Status                              Version 1 (Active)
The template generates four sections:
1. Warranty Details -- warranty name, serial number, product,
   status, purchase date, start date, and end date.
2. Customer Details -- customer name and available contact
   information.
3. Warranty Assessment -- explain active, expired, or restricted
   status using only supplied data.
4. Support Summary -- summarize the situation and recommend the
   next support step.
Guardrails: use only supplied resources; show Not Available for
missing values; identify conflicting information; do not promise claim
approval or replacement; keep the response professional and concise.
4. Prompt Builder Grid test
Created the Grid workbook NovaHome_Warranty_Claim_Test.
- Imported existing Salesforce records from the Warranty object.
- Selected Warranty fields, including Warranty Number, Serial Number,
  Warranty Start Date, Warranty End Date, and Warranty Status.
- Added the Warranty Claim Summary prompt template as a Prompt
  Template column.
- Ran the prompt for each row.
- The worksheet displayed 20 Warranty records (WAR-00000001 through
  WAR-00000020) and generated prompt outputs.
The generated output included the expected sections and reflected
supplied Warranty values. For example, the preview for WAR-00000001
showed an Active status and its supplied coverage dates. A separate
preview for WAR-00000002 also generated a structured summary.
5. Trust Layer masking -- validation finding
The Resolved Prompt screenshot showed the Apex-generated customer
context with masked placeholders:
Customer Name: <PERSON_0>
Customer Email: <EMAIL_ADDRESS_0>
Customer Phone: <US_PHONE_NUMBER_0>
However, the Generated Response screenshot displayed the actual customer
name, email, and phone number (for example, Maya Patel and the
corresponding contact details).

Conclusion: Masking is visible in the Apex-generated context, but
end-to-end masking is not yet verified. The final response still
contains identifiable customer details. Another prompt resource or input
path may be supplying unmasked customer information (for example, the
Warranty record snapshot or another resource). Do not mark masking as
fully passed until every source of customer PII is checked and the
generated response is verified to remain masked.
Follow-up validation required
1. Inspect the resolved prompt and identify every occurrence of
   customer name, email, and phone.
2. Check whether Record Snapshot.Warranty or another template
   resource includes unmasked customer details.
3. Ensure customer contact details come only from the masked Apex
   context and are not also exposed through an unmasked resource.
4. Re-run the prompt for a test Warranty record.
5. Confirm the Generated Response contains masked placeholders, not
   real customer details.
6. Repeat the check for multiple rows in the Grid.
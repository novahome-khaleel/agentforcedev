Objective
Reuse the existing Salesforce CRM data streams for Account and Contact, confirm that both streams are active, and verify the ingested records in Data Explorer. No duplicate streams were created.
1. Contact data stream – Contact_Home
- Stream type: Ingest
- Stream status: Active
- Last run status: Success
- Last refreshed: 26 November 2026, 12:00 AM (as displayed in Salesforce)
- Total records: 3
- Data Lake Object: Contact_Home
- Data Explorer columns: 79
The Refresh History screenshot shows a successful Total Replace run with 4 records processed and 3 records added. It also shows earlier failed attempts; the later successful run and Data Explorer results confirm the stream is now populated.
Evidence – Contact stream refresh history

Evidence – Contact Data Explorer

2. Account data stream – Account_Home
- Stream type: Ingest
- Stream status: Active
- Data Lake Object: Account_Home
- Data Explorer columns: 76
- Records visible in Data Explorer: 2
The Data Explorer screenshot displays these Account records:
Account Name	Account Number
ABC Industries	TEST-001
XYZ Technologies	TEST-002


Evidence – Account stream active

Evidence – Account Data Explorer

3. Verification summary
Data stream	Status	Data Lake Object	Records verified	Columns shown in Data Explorer
Contact_Home	Active	Contact_Home	3	79
Account_Home	Active	Account_Home	2	76
Total			5	


4. Outcome
- Existing Contact_Home stream is active and its three ingested records are visible in Data Explorer.
- Existing Account_Home stream is active and its two Account records are visible in Data Explorer.
- Both Data Lake Objects are accessible in the default Data Space.
- Data Explorer verification is complete for the two streams.
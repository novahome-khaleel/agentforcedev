1. Objective
Understand Data 360 architecture and explore the standard Customer 360
data model: data spaces, Data Source Objects (DSOs), Data Lake Objects
(DLOs), Data Model Objects (DMOs), and Data Explorer.
2. Core architecture
  Layer                               Purpose
  Data Source Object (DSO)            Represents data as it arrives from
a connected source.

  Data Lake Object (DLO)              Stores ingested source data in Data
360.
Data Model Object (DMO)             Represents harmonized data using
the standard or custom Data 360
data model.
Typical flow:
Source system → DSO → DLO → DMO → Data Explorer / downstream Data 360 use cases

A Data Space is a logical boundary used to organize and manage data.
The screenshots for this exercise show the default data space.
3. Five standard DMOs reviewed
The five standard DMOs identified during the Day 14 exploration were:
1. Individual
2. Contact Point Email
3. Contact Point Address
4. Contact Point Phone
5. Account
3.1 Individual
- API name: ssot__Individual__dlm
- Field count shown: 105
Fields explicitly recorded from the shared screen:
- Individual ID
- First Name
- Last Name
- Birth Date
- Gender
- Gender Identity
- Person Name
- Party
- Primary Account
- Primary Address
- Primary email-related information
- Primary phone-related information
- Marital Status
- Occupation
- Annual Income
Purpose: Represents an individual person in the Customer 360 data
model. It provides the person-level record to which contact points and
other customer-related data can be related.
3.2 Contact Point Email
- API name: ssot__ContactPointEmail__dlm
- Field count shown: 38
Fields explicitly recorded from the shared screen:
- Contact Point Email Id
- Email Address
- Email Domain
- Is Active
- Is Undeliverable
- Party
- Party Role
- Preference Rank
- Primary Flag
- Usage Type
- Verified
- Active From Date
- Active To Date
Purpose: Represents an email address and its relationship to a party
or individual, including status, verification, preference, and validity
information.
3.3 Contact Point Address
Purpose: Standard DMO identified during exploration for address
contact-point information.

Field evidence: Exact field names were not captured in the available
conversation notes. Confirm them in the DMO Fields view before treating
this as a complete field inventory.
3.4 Contact Point Phone
Purpose: Standard DMO identified during exploration for phone
contact-point information.

Field evidence: Exact field names were not captured in the available
conversation notes. Confirm them in the DMO Fields view before treating
this as a complete field inventory.
3.5 Account
Purpose: Standard DMO identified during exploration for account or
organization information in the Customer 360 data model.

Field evidence: Exact field names were not captured in the available
conversation notes. Confirm them in the DMO Fields view before treating
this as a complete field inventory.
4. Contact_Home data stream exploration
A Salesforce CRM data stream named Contact_Home was reviewed.

  Property                               Observed value
  Stream type                            Ingest
Data stream status                     Active
Source connector                       Salesforce CRM
Data space                             default
Data Lake Object                       Contact_Home
DLO API name                           Contact_Home__dll
Total columns shown in Data Explorer   79
Fields shown on stream page            74
Fields mapped                          39 of 79
Mapping readiness                      READY

The stream page showed the Contact_Home data properties and Data
Mapping panel. The mapping panel indicated 39 of 79 fields mapped.
5. Refresh troubleshooting and final result
The initial refresh attempts failed and showed zero records. The refresh
history was reviewed. A later Total Replace refresh succeeded,
followed by a successful Upsert refresh.

The latest screenshots showed:

  Property                 Latest observed result
  Stream status            Active
Last Run Status          Success
Last Refreshed           26 November 2026, 12:00 AM
Total Records            3
Last Processed Records   0

The refresh history showed a successful Total Replace operation with
4 records processed, 3 records added, and 0 records rejected. A later
successful Upsert operation processed 0 records.

Data Explorer verification: The default data space was selected,
Object Type was set to Data Lake Object, and Contact_Home was
selected. Three rows were visible in the results.

This confirms that the stream ultimately ingested three records and that
the resulting DLO data was visible in Data Explorer.
6. Evidence checklist
- [x] Opened Data Lake Objects.
- [x] Opened Data Model and reviewed standard Customer 360 DMOs.
- [x] Identified five standard DMOs.
- [x] Recorded the Individual DMO API name, field count, and fields
  visible in the shared screen.
- [x] Recorded the Contact Point Email DMO API name, field count, and
  fields visible in the shared screen.
- [x] Explored the Contact_Home data stream and its field mapping.
- [x] Reviewed failed refresh attempts and subsequent successful
  refresh.
- [x] Verified three Contact_Home records in Data Explorer.
- [ ] Complete exact key-field inventories for Contact Point Address,
  Contact Point Phone, and Account from their DMO Fields screens.
7. Key takeaways
1. DSOs, DLOs, and DMOs represent different stages and roles in the
   Data 360 data architecture.
2. DMOs provide a consistent model for customer information across
   source systems.
3. Individual is the person-level DMO; Contact Point Email, Address,
   and Phone represent ways to contact a party.
4. A data stream can be Active while its refresh has failed; check
   refresh history and the Data Explorer record count as well.
5. The Contact_Home stream ultimately completed successfully and its
   three records were visible in Data Explorer.
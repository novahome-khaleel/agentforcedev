Mapping and verification results

Individual: mapped and verified in Data Explorer; First Name, Individual ID, and External Record ID values are populated.

Contact Point Email: mapped and verified; Email Address values are populated.

Contact Point Phone: mapped and verified; Mobile Phone is connected to Formatted E164 Phone Number.

E.164 sample: +14155552671 was visible in the Contact Point Phone DMO for one sample record.

Phone data caveat: other displayed phone values remain in national format. The evidence confirms the sample E.164 value, not that every phone record has been normalized.

The initial mapping review showed 39/79 Contact_Home source fields mapped. The saved E.164 DMO mapping did not change that overall count in the subsequent stream view.

Screenshots

Contact_Home DLO mapping overview
![alt text](<Screenshot 2026-11-27 171425.png>)
The Contact_Home data lake object is mapped to Individual, Contact Point Email, Contact Point Phone, Contact Point Address, and Party. The screenshot shows the existing mapping relationships.



E.164 phone field mapping
![alt text](<Screenshot 2026-11-27 175833.png>)
Mobile Phone is connected to Contact Point Phone → Formatted E164 Phone Number. The mapping was saved successfully.



Contact Point Phone DMO verification
![alt text](<Screenshot 2026-11-27 180144.png>)
Data Explorer shows Contact Point Phone records. One displayed Contact record contains +14155552671 in the E.164-related field, confirming the sample value reached the DMO. Other displayed values remain in national format.



Contact Point Email DMO verification
![alt text](<Screenshot 2026-11-27 180300.png>)
Data Explorer shows populated Email Address values from Salesforce_Home / Contact.



Individual DMO verification
![alt text](<Screenshot 2026-11-27 180730.png>)

Data Explorer shows Individual records sourced from Salesforce_Home / Contact, with First Name, Individual ID, and External Record ID values populated.


public with sharing class AI_SearchContactsAction {

    public class Request {
        @InvocableVariable(
            label='Contact Name'
            description='Optional Contact first name, last name or partial full name'
        )
        public String contactName;

        @InvocableVariable(
            label='Email'
            description='Optional Contact email address or partial email'
        )
        public String email;

        @InvocableVariable(
            label='Account Name'
            description='Optional related Account name or partial name'
        )
        public String accountName;
    }

    public class Response {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Record Count')
        public Integer recordCount;

        @InvocableVariable(label='Contacts JSON')
        public String contactsJson;
    }

    @InvocableMethod(
        label='Search Contacts'
        description='Search authorized Salesforce Contacts by name, email or related Account name. Returns up to 20 Contacts. Read only.'
    )
    public static List<Response> search(
        List<Request> requests
    ) {
        List<Response> results = new List<Response>();

        if (requests == null || requests.isEmpty()) {
            return results;
        }

        if (requests.size() > AI_SalesSearchService.MAX_REQUESTS) {
            throw new AI_SalesSearchService.SearchException(
                'Too many search requests in one invocation.'
            );
        }

        for (Request req : requests) {
            Response res = new Response();
            res.success = false;
            res.recordCount = 0;
            res.contactsJson = '[]';

            try {
                AI_SalesSearchService.ContactCriteria criteria =
                    new AI_SalesSearchService.ContactCriteria();

                if (req != null) {
                    criteria.name = req.contactName;
                    criteria.email = req.email;
                    criteria.accountName = req.accountName;
                }

                List<Contact> contacts =
                    AI_SalesSearchService.searchContacts(criteria);

                List<Map<String, Object>> records =
                    new List<Map<String, Object>>();

                for (Contact con : contacts) {
                    records.add(new Map<String, Object>{
                        'contactId' => con.Id,
                        'contactName' => con.Name,
                        'email' => con.Email,
                        'phone' => con.Phone,
                        'accountId' => con.AccountId,
                        'accountName' => con.Account == null
                            ? null : con.Account.Name
                    });
                }

                res.success = true;
                res.recordCount = records.size();
                res.contactsJson = JSON.serialize(records);

                res.message = records.isEmpty()
                    ? 'No matching Contacts found.'
                    : 'Found ' + records.size() +
                      ' Contact(s). Results are limited to 20.';

            } catch (AI_SalesSearchService.SearchException e) {
                res.message = e.getMessage();

            } catch (Exception e) {
                res.message =
                    'Unable to search Contacts. Verify search criteria and access permissions.';
            }

            results.add(res);
        }

        return results;
    }
}
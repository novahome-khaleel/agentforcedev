public with sharing class AI_SearchAccountsAction {

    public class Request {
        @InvocableVariable(
            label='Account Name'
            description='Optional Account name or partial name'
        )
        public String accountName;

        @InvocableVariable(
            label='Industry'
            description='Optional exact Salesforce Industry picklist value'
        )
        public String industry;

        @InvocableVariable(
            label='Billing City'
            description='Optional Account Billing City or partial city'
        )
        public String billingCity;
    }

    public class Response {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Record Count')
        public Integer recordCount;

        @InvocableVariable(label='Accounts JSON')
        public String accountsJson;
    }

    @InvocableMethod(
        label='Search Accounts'
        description='Find Salesforce Accounts by name, industry, or billing city. Returns up to 20 authorized Accounts with name, industry, city and annual revenue. Read only.'
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
            res.accountsJson = '[]';

            try {
                AI_SalesSearchService.AccountCriteria criteria =
                    new AI_SalesSearchService.AccountCriteria();

                if (req != null) {
                    criteria.name = req.accountName;
                    criteria.industry = req.industry;
                    criteria.billingCity = req.billingCity;
                }

                List<Account> accounts =
                    AI_SalesSearchService.searchAccounts(criteria);

                List<Map<String, Object>> records =
                    new List<Map<String, Object>>();

                for (Account acc : accounts) {
                    records.add(new Map<String, Object>{
                        'accountId' => acc.Id,
                        'accountName' => acc.Name,
                        'industry' => acc.Industry,
                        'billingCity' => acc.BillingCity,
                        'annualRevenue' => acc.AnnualRevenue
                    });
                }

                res.success = true;
                res.recordCount = records.size();
                res.accountsJson = JSON.serialize(records);

                res.message = records.isEmpty()
                    ? 'No matching Accounts found.'
                    : 'Found ' + records.size() +
                      ' Account(s). Results are limited to 20.';

            } catch (AI_SalesSearchService.SearchException e) {
                res.message = e.getMessage();

            } catch (Exception e) {
                res.message =
                    'Unable to search Accounts. Verify search criteria and access permissions.';
            }

            results.add(res);
        }

        return results;
    }
}
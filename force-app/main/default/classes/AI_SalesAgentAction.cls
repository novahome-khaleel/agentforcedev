public with sharing class AI_SalesAgentAction {

    // Input parameters received from Agentforce
    public class Request {

        @InvocableVariable(
            label='Account Name'
            description='Exact Salesforce Account name to search'
            required=true
        )
        public String accountName;
    }

    // Output parameters returned to Agentforce
    public class Response {

        @InvocableVariable(
            label='Success'
        )
        public Boolean success;

        @InvocableVariable(
            label='Message'
        )
        public String message;

        @InvocableVariable(
            label='Account Id'
        )
        public Id accountId;

        @InvocableVariable(
            label='Account Name'
        )
        public String accountName;

        @InvocableVariable(
            label='Annual Revenue'
        )
        public Decimal annualRevenue;
    }

    @InvocableMethod(
        label='Search Account Revenue'
        description='Searches Salesforce Accounts by exact name and retrieves the Account annual revenue.'
    )
    public static List<Response> searchAccountRevenue(
        List<Request> requests
    ) {

        List<Response> responses = new List<Response>();
        Set<String> accountNames = new Set<String>();

        // Prepare one response for every request.
        for (Request req : requests) {

            Response res = new Response();
            res.success = false;
            responses.add(res);

            if (req != null &&
                !String.isBlank(req.accountName)) {

                accountNames.add(req.accountName.trim());
            }
        }

        if (accountNames.isEmpty()) {
            for (Response res : responses) {
                res.message = 'Please provide an Account name.';
            }
            return responses;
        }

        try {

            // Query once for all requested Account names.
            List<Account> accounts = [
                SELECT Id, Name, AnnualRevenue
                FROM Account
                WHERE Name IN :accountNames
                WITH USER_MODE
            ];

            Map<String, List<Account>> accountsByName =
                new Map<String, List<Account>>();

            for (Account acc : accounts) {

                String key = acc.Name.toLowerCase();

                if (!accountsByName.containsKey(key)) {
                    accountsByName.put(
                        key,
                        new List<Account>()
                    );
                }

                accountsByName.get(key).add(acc);
            }

            // Prepare an individual response for every request.
            for (Integer i = 0; i < requests.size(); i++) {

                Request req = requests[i];
                Response res = responses[i];

                if (req == null ||
                    String.isBlank(req.accountName)) {

                    res.message = 'Please provide an Account name.';
                    continue;
                }

                String key = req.accountName.trim().toLowerCase();

                List<Account> matches =
                    accountsByName.get(key);

                if (matches == null || matches.isEmpty()) {

                    res.message =
                        'No matching Account was found. Please verify the Account name.';

                    continue;
                }

                if (matches.size() > 1) {

                    res.message =
                        'Multiple Accounts have this name. Please provide additional details to identify the correct Account.';

                    continue;
                }

                Account acc = matches[0];

                res.success = true;
                res.accountId = acc.Id;
                res.accountName = acc.Name;
                res.annualRevenue = acc.AnnualRevenue;

                if (acc.AnnualRevenue == null) {

                    res.message =
                        'Account found, but Annual Revenue is not populated.';

                } else {

                    res.message =
                        'Account found: ' + acc.Name +
                        '. Annual Revenue: ' +
                        String.valueOf(acc.AnnualRevenue);
                }
            }

        } catch (Exception e) {

            // Do not expose internal exception details to the agent.
            for (Response res : responses) {
                res.success = false;
                res.message =
                    'Unable to retrieve Account information. Please check access permissions or contact your Salesforce administrator.';
            }
        }

        return responses;
    }
}
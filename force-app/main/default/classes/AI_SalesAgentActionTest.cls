@IsTest
private class AI_SalesAgentActionTest {

    @IsTest
    static void testAccountRevenueFound() {

        Account acc = new Account(
            Name = 'ABC Industries',
            AnnualRevenue = 1000000
        );

        insert acc;

        AI_SalesAgentAction.Request req =
            new AI_SalesAgentAction.Request();

        req.accountName = 'ABC Industries';

        Test.startTest();

        List<AI_SalesAgentAction.Response> results =
            AI_SalesAgentAction.searchAccountRevenue(
                new List<AI_SalesAgentAction.Request>{req}
            );

        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        System.assertEquals(acc.Id, results[0].accountId);
        System.assertEquals(
            1000000,
            results[0].annualRevenue
        );
    }

    @IsTest
    static void testAccountNotFound() {

        AI_SalesAgentAction.Request req =
            new AI_SalesAgentAction.Request();

        req.accountName = 'Unknown Industries';

        List<AI_SalesAgentAction.Response> results =
            AI_SalesAgentAction.searchAccountRevenue(
                new List<AI_SalesAgentAction.Request>{req}
            );

        System.assertEquals(false, results[0].success);
        System.assert(
            results[0].message.contains('No matching Account')
        );
    }

    @IsTest
    static void testBlankAccountName() {

        AI_SalesAgentAction.Request req =
            new AI_SalesAgentAction.Request();

        req.accountName = '';

        List<AI_SalesAgentAction.Response> results =
            AI_SalesAgentAction.searchAccountRevenue(
                new List<AI_SalesAgentAction.Request>{req}
            );

        System.assertEquals(false, results[0].success);
        System.assertEquals(
            'Please provide an Account name.',
            results[0].message
        );
    }
}
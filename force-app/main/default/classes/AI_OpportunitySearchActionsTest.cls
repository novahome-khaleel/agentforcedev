@IsTest
private class AI_OpportunitySearchActionsTest {

    private static String getActiveStage() {

        for (
            Schema.PicklistEntry entry :
            Opportunity.StageName.getDescribe().getPicklistValues()
        ) {
            if (entry.isActive()) {
                return entry.getValue();
            }
        }

        System.assert(false, 'No active Opportunity stage found.');
        return null;
    }

    @TestSetup
    static void setupData() {

        Account acc1 = new Account(
            Name = 'ABC Industries',
            Industry = 'Manufacturing'
        );

        Account acc2 = new Account(
            Name = 'XYZ Technologies',
            Industry = 'Technology'
        );

        insert new List<Account>{acc1, acc2};

        String stage = getActiveStage();

        List<Opportunity> opportunities =
            new List<Opportunity>{
                new Opportunity(
                    Name = 'ABC Expansion',
                    AccountId = acc1.Id,
                    StageName = stage,
                    CloseDate = Date.today().addDays(15),
                    Amount = 1000000
                ),
                new Opportunity(
                    Name = 'XYZ New Deal',
                    AccountId = acc2.Id,
                    StageName = stage,
                    CloseDate = Date.today().addDays(30),
                    Amount = 1500000
                )
            };

        insert opportunities;
    }

    @IsTest
    static void testSearchByName() {

        AI_SearchOpportunitiesAction.Request req =
            new AI_SearchOpportunitiesAction.Request();

        req.opportunityName = 'ABC Expansion';

        Test.startTest();

        List<AI_SearchOpportunitiesAction.Response> results =
            AI_SearchOpportunitiesAction.search(
                new List<AI_SearchOpportunitiesAction.Request>{req}
            );

        Test.stopTest();

        System.assertEquals(true, results[0].success);
        System.assertEquals(1, results[0].recordCount);
        System.assert(
            results[0].opportunitiesJson.contains('ABC Expansion')
        );
    }

    @IsTest
    static void testSearchByAccount() {

        AI_SearchOpportunitiesAction.Request req =
            new AI_SearchOpportunitiesAction.Request();

        req.accountName = 'ABC Industries';

        List<AI_SearchOpportunitiesAction.Response> results =
            AI_SearchOpportunitiesAction.search(
                new List<AI_SearchOpportunitiesAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(1, results[0].recordCount);
    }

    @IsTest
    static void testSearchMyOpportunities() {

        AI_SearchOpportunitiesAction.Request req =
            new AI_SearchOpportunitiesAction.Request();

        req.myOpportunitiesOnly = true;

        List<AI_SearchOpportunitiesAction.Response> results =
            AI_SearchOpportunitiesAction.search(
                new List<AI_SearchOpportunitiesAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assert(results[0].recordCount >= 1);
    }

    @IsTest
    static void testSearchByCloseDate() {

        AI_SearchOpportunitiesAction.Request req =
            new AI_SearchOpportunitiesAction.Request();

        req.closeDateFrom = Date.today().addDays(1);
        req.closeDateTo = Date.today().addDays(20);

        List<AI_SearchOpportunitiesAction.Response> results =
            AI_SearchOpportunitiesAction.search(
                new List<AI_SearchOpportunitiesAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(1, results[0].recordCount);
    }

    @IsTest
    static void testMissingSearchCriteria() {

        AI_SearchOpportunitiesAction.Request req =
            new AI_SearchOpportunitiesAction.Request();

        List<AI_SearchOpportunitiesAction.Response> results =
            AI_SearchOpportunitiesAction.search(
                new List<AI_SearchOpportunitiesAction.Request>{req}
            );

        System.assertEquals(false, results[0].success);
        System.assert(
            results[0].message.contains('Provide an Opportunity Name')
        );
    }

    @IsTest
    static void testInvalidCloseDateRange() {

        AI_SearchOpportunitiesAction.Request req =
            new AI_SearchOpportunitiesAction.Request();

        req.closeDateFrom = Date.today().addDays(30);
        req.closeDateTo = Date.today().addDays(10);

        List<AI_SearchOpportunitiesAction.Response> results =
            AI_SearchOpportunitiesAction.search(
                new List<AI_SearchOpportunitiesAction.Request>{req}
            );

        System.assertEquals(false, results[0].success);
        System.assert(
            results[0].message.contains('Close Date From')
        );
    }

    @IsTest
    static void testNoMatchingOpportunity() {

        AI_SearchOpportunitiesAction.Request req =
            new AI_SearchOpportunitiesAction.Request();

        req.opportunityName = 'Unknown Opportunity';

        List<AI_SearchOpportunitiesAction.Response> results =
            AI_SearchOpportunitiesAction.search(
                new List<AI_SearchOpportunitiesAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(0, results[0].recordCount);
    }

    @IsTest
    static void testMaximumTwentyResults() {

        Account acc = [
            SELECT Id
            FROM Account
            WHERE Name = 'ABC Industries'
            LIMIT 1
        ];

        String stage = getActiveStage();

        List<Opportunity> extraRecords =
            new List<Opportunity>();

        for (Integer i = 0; i < 25; i++) {

            extraRecords.add(new Opportunity(
                Name = 'ABC Test Deal ' + i,
                AccountId = acc.Id,
                StageName = stage,
                CloseDate = Date.today().addDays(40),
                Amount = 10000
            ));
        }

        insert extraRecords;

        AI_SearchOpportunitiesAction.Request req =
            new AI_SearchOpportunitiesAction.Request();

        req.accountName = 'ABC Industries';

        List<AI_SearchOpportunitiesAction.Response> results =
            AI_SearchOpportunitiesAction.search(
                new List<AI_SearchOpportunitiesAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(20, results[0].recordCount);
    }

    @IsTest
    static void testMultipleRequestsRejected() {

        AI_SearchOpportunitiesAction.Request first =
            new AI_SearchOpportunitiesAction.Request();

        first.opportunityName = 'ABC';

        AI_SearchOpportunitiesAction.Request second =
            new AI_SearchOpportunitiesAction.Request();

        second.opportunityName = 'XYZ';

        Test.startTest();

        try {
            AI_SearchOpportunitiesAction.search(
                new List<AI_SearchOpportunitiesAction.Request>{
                    first, second
                }
            );

            System.assert(false, 'Expected multiple request validation.');

        } catch (
            AI_OpportunitySearchService.SearchException e
        ) {
            System.assert(
                e.getMessage().contains('one search request')
            );
        }

        Test.stopTest();
    }
}
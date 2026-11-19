@IsTest
private class AI_OpportunityAnalyticsTest {

    @TestSetup
    static void setupData() {

        Account acc = new Account(
            Name = 'Analytics Test Account'
        );
        insert acc;

        List<Opportunity> records =
            new List<Opportunity>();

        records.add(new Opportunity(
            Name = 'Analytics Deal A',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(20),
            Amount = 100000
        ));

        records.add(new Opportunity(
            Name = 'Analytics Deal B',
            AccountId = acc.Id,
            StageName = 'Qualification',
            CloseDate = Date.today().addDays(30),
            Amount = 200000
        ));

        records.add(new Opportunity(
            Name = 'Analytics Closed Deal',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            CloseDate = Date.today(),
            Amount = 50000
        ));

        insert records;
    }

    @IsTest
    static void testOpportunityDetailsByName() {

        AI_GetOpportunityDetailsAction.Request req =
            new AI_GetOpportunityDetailsAction.Request();

        req.opportunityName = 'Analytics Deal A';

        List<AI_GetOpportunityDetailsAction.Response> results =
            AI_GetOpportunityDetailsAction.getDetails(
                new List<AI_GetOpportunityDetailsAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assert(
            results[0].opportunityJson.contains('Analytics Deal A')
        );
    }

    @IsTest
    static void testOpportunityDetailsById() {

        Opportunity opp = [
            SELECT Id FROM Opportunity
            WHERE Name = 'Analytics Deal A'
            LIMIT 1
        ];

        AI_GetOpportunityDetailsAction.Request req =
            new AI_GetOpportunityDetailsAction.Request();

        req.opportunityId = String.valueOf(opp.Id);

        List<AI_GetOpportunityDetailsAction.Response> results =
            AI_GetOpportunityDetailsAction.getDetails(
                new List<AI_GetOpportunityDetailsAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
    }

    @IsTest
    static void testOpportunityDetailsNotFound() {

        AI_GetOpportunityDetailsAction.Request req =
            new AI_GetOpportunityDetailsAction.Request();

        req.opportunityName = 'Missing Opportunity';

        List<AI_GetOpportunityDetailsAction.Response> results =
            AI_GetOpportunityDetailsAction.getDetails(
                new List<AI_GetOpportunityDetailsAction.Request>{req}
            );

        System.assertEquals(false, results[0].success);
    }

    @IsTest
    static void testOpportunityDetailsMissingInput() {

        AI_GetOpportunityDetailsAction.Request req =
            new AI_GetOpportunityDetailsAction.Request();

        List<AI_GetOpportunityDetailsAction.Response> results =
            AI_GetOpportunityDetailsAction.getDetails(
                new List<AI_GetOpportunityDetailsAction.Request>{req}
            );

        System.assertEquals(false, results[0].success);
    }

    @IsTest
    static void testPipelineSummary() {

        AI_GetPipelineSummaryAction.Request req =
            new AI_GetPipelineSummaryAction.Request();

        List<AI_GetPipelineSummaryAction.Response> results =
            AI_GetPipelineSummaryAction.calculate(
                new List<AI_GetPipelineSummaryAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assert(
            results[0].summaryJson.contains('totalPipeline')
        );
    }

    @IsTest
    static void testPipelineForCurrentUser() {

        AI_GetPipelineSummaryAction.Request req =
            new AI_GetPipelineSummaryAction.Request();

        req.myOpportunitiesOnly = true;

        List<AI_GetPipelineSummaryAction.Response> results =
            AI_GetPipelineSummaryAction.calculate(
                new List<AI_GetPipelineSummaryAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
    }

    @IsTest
    static void testPipelineByAccount() {

        AI_GetPipelineSummaryAction.Request req =
            new AI_GetPipelineSummaryAction.Request();

        req.accountName = 'Analytics Test Account';

        List<AI_GetPipelineSummaryAction.Response> results =
            AI_GetPipelineSummaryAction.calculate(
                new List<AI_GetPipelineSummaryAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
    }

    @IsTest
    static void testInvalidDateRange() {

        AI_GetPipelineSummaryAction.Request req =
            new AI_GetPipelineSummaryAction.Request();

        req.closeDateFrom = Date.today().addDays(30);
        req.closeDateTo = Date.today().addDays(10);

        List<AI_GetPipelineSummaryAction.Response> results =
            AI_GetPipelineSummaryAction.calculate(
                new List<AI_GetPipelineSummaryAction.Request>{req}
            );

        System.assertEquals(false, results[0].success);
    }

    @IsTest
    static void testPipelineDateRange() {

        AI_GetPipelineSummaryAction.Request req =
            new AI_GetPipelineSummaryAction.Request();

        req.closeDateFrom = Date.today().addDays(1);
        req.closeDateTo = Date.today().addDays(25);

        List<AI_GetPipelineSummaryAction.Response> results =
            AI_GetPipelineSummaryAction.calculate(
                new List<AI_GetPipelineSummaryAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
    }
}
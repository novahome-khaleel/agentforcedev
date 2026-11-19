@IsTest
private class AI_SalesIntelligenceTest {

    @TestSetup
    static void setupData() {

        Account accountRecord = new Account(
            Name = 'AI Sales Intelligence Test Account'
        );
        insert accountRecord;

        List<Opportunity> opportunities = new List<Opportunity>{
            new Opportunity(
                Name = 'AI Won Deal 1',
                AccountId = accountRecord.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today().addDays(-10),
                Amount = 1000
            ),
            new Opportunity(
                Name = 'AI Won Deal 2',
                AccountId = accountRecord.Id,
                StageName = 'Closed Won',
                CloseDate = Date.today().addDays(-8),
                Amount = 2000
            ),
            new Opportunity(
                Name = 'AI Lost Deal 1',
                AccountId = accountRecord.Id,
                StageName = 'Closed Lost',
                CloseDate = Date.today().addDays(-5),
                Amount = 500
            )
        };

        insert opportunities;
    }

    @IsTest
    static void testOverallPerformance() {

        AI_SalesIntelligenceService.Criteria criteria =
            new AI_SalesIntelligenceService.Criteria();

        Test.startTest();
        AI_SalesIntelligenceService.PerformanceSummary result =
            AI_SalesIntelligenceService.getPerformance(criteria);
        Test.stopTest();

        System.assertEquals(3, result.totalClosedOpportunities);
        System.assertEquals(2, result.wonOpportunities);
        System.assertEquals(1, result.lostOpportunities);
        System.assertEquals(66.67, result.winRate);
        System.assertEquals(3000, result.wonRevenue);
        System.assertEquals(1500, result.averageWonDealSize);
    }

    @IsTest
    static void testAccountFilter() {

        AI_SalesIntelligenceService.Criteria criteria =
            new AI_SalesIntelligenceService.Criteria();

        criteria.accountName = 'AI Sales Intelligence Test';

        AI_SalesIntelligenceService.PerformanceSummary result =
            AI_SalesIntelligenceService.getPerformance(criteria);

        System.assertEquals(3, result.totalClosedOpportunities);
    }

    @IsTest
    static void testMyOpportunitiesFilter() {

        AI_SalesIntelligenceService.Criteria criteria =
            new AI_SalesIntelligenceService.Criteria();

        criteria.myOpportunitiesOnly = true;

        AI_SalesIntelligenceService.PerformanceSummary result =
            AI_SalesIntelligenceService.getPerformance(criteria);

        System.assertEquals(3, result.totalClosedOpportunities);
    }

    @IsTest
    static void testDateFilter() {

        AI_SalesIntelligenceService.Criteria criteria =
            new AI_SalesIntelligenceService.Criteria();

        criteria.closeDateFrom = Date.today().addDays(-9);
        criteria.closeDateTo = Date.today().addDays(-6);

        AI_SalesIntelligenceService.PerformanceSummary result =
            AI_SalesIntelligenceService.getPerformance(criteria);

        System.assertEquals(1, result.totalClosedOpportunities);
        System.assertEquals(1, result.wonOpportunities);
    }

    @IsTest
    static void testInvalidDateRange() {

        AI_SalesIntelligenceService.Criteria criteria =
            new AI_SalesIntelligenceService.Criteria();

        criteria.closeDateFrom = Date.today();
        criteria.closeDateTo = Date.today().addDays(-10);

        AI_SalesIntelligenceService.PerformanceSummary result =
            AI_SalesIntelligenceService.getPerformance(criteria);

        System.assert(
            result.message.contains('start date cannot be later')
        );
    }

    @IsTest
    static void testNoMatchingOpportunities() {

        AI_SalesIntelligenceService.Criteria criteria =
            new AI_SalesIntelligenceService.Criteria();

        criteria.accountName = 'Account That Does Not Exist';

        AI_SalesIntelligenceService.PerformanceSummary result =
            AI_SalesIntelligenceService.getPerformance(criteria);

        System.assertEquals(0, result.totalClosedOpportunities);
        System.assertEquals(0, result.winRate);
        System.assertEquals(0, result.wonRevenue);
    }

    @IsTest
    static void testInvocableAction() {

        AI_GetSalesPerformanceAction.Request request =
            new AI_GetSalesPerformanceAction.Request();

        request.myOpportunitiesOnly = true;

        Test.startTest();
        List<AI_GetSalesPerformanceAction.Response> results =
            AI_GetSalesPerformanceAction.getSalesPerformance(
                new List<AI_GetSalesPerformanceAction.Request>{ request }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        System.assertNotEquals(
            null,
            results[0].performanceSummaryJson
        );
    }
}
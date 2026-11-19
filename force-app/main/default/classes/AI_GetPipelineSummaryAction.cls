public with sharing class AI_GetPipelineSummaryAction {

    public class Request {

        @InvocableVariable(
            label='My Opportunities Only'
            description='Set true to calculate the current user\'s pipeline only'
        )
        public Boolean myOpportunitiesOnly;

        @InvocableVariable(
            label='Account Name'
            description='Optional Account name filter'
        )
        public String accountName;

        @InvocableVariable(
            label='Close Date From'
            description='Optional start date for Opportunity Close Date'
        )
        public Date closeDateFrom;

        @InvocableVariable(
            label='Close Date To'
            description='Optional end date for Opportunity Close Date'
        )
        public Date closeDateTo;
    }

    public class Response {

        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Pipeline Summary JSON')
        public String summaryJson;
    }

    @InvocableMethod(
        label='Get Pipeline Summary'
        description='Calculates authorized open Opportunity pipeline, weighted pipeline, average deal size and stage-wise breakdown. Supports current user, Account and close date filters.'
    )
    public static List<Response> calculate(
        List<Request> requests
    ) {

        List<Response> results = new List<Response>();

        if (requests == null || requests.isEmpty()) {
            return results;
        }

        if (requests.size() != 1) {
            throw new AI_PipelineAnalyticsService.AnalyticsException(
                'This analytics action accepts one request at a time.'
            );
        }

        Response res = new Response();
        res.success = false;
        res.summaryJson = '{}';

        try {

            Request req = requests[0];

            AI_PipelineAnalyticsService.Criteria criteria =
                new AI_PipelineAnalyticsService.Criteria();

            if (req != null) {
                criteria.myOpportunitiesOnly =
                    req.myOpportunitiesOnly;
                criteria.accountName = req.accountName;
                criteria.closeDateFrom = req.closeDateFrom;
                criteria.closeDateTo = req.closeDateTo;
            }

            AI_PipelineAnalyticsService.Summary summary =
                AI_PipelineAnalyticsService.calculate(criteria);

            res.success = true;
            res.summaryJson = JSON.serialize(summary);

            res.message =
                'Pipeline analytics calculated successfully.';

        } catch (
            AI_PipelineAnalyticsService.AnalyticsException e
        ) {

            res.message = e.getMessage();

        } catch (Exception e) {

            res.message =
                'Unable to calculate pipeline analytics. Verify Salesforce permissions and currency configuration.';
        }

        results.add(res);

        return results;
    }
}
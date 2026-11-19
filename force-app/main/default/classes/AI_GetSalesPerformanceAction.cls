public with sharing class AI_GetSalesPerformanceAction {

    public class Request {
        @InvocableVariable(
            label='Close Date From'
            description='Optional start date for the performance period.'
        )
        public Date closeDateFrom;

        @InvocableVariable(
            label='Close Date To'
            description='Optional end date for the performance period.'
        )
        public Date closeDateTo;

        @InvocableVariable(
            label='Account Name'
            description='Optional account name filter.'
        )
        public String accountName;

        @InvocableVariable(
            label='My Opportunities Only'
            description='Set true to include only opportunities owned by the current user.'
        )
        public Boolean myOpportunitiesOnly;
    }

    public class Response {
        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Performance Summary JSON')
        public String performanceSummaryJson;
    }

    @InvocableMethod(
        label='Get Sales Performance'
        description='Calculates closed opportunity win rate, won revenue and average won deal size.'
    )
    public static List<Response> getSalesPerformance(
        List<Request> requests
    ) {
        List<Response> responses = new List<Response>();

        if (requests == null || requests.isEmpty()) {
            return responses;
        }

        for (Request request : requests) {
            Response response = new Response();

            try {
                AI_SalesIntelligenceService.Criteria criteria =
                    new AI_SalesIntelligenceService.Criteria();

                criteria.closeDateFrom = request.closeDateFrom;
                criteria.closeDateTo = request.closeDateTo;
                criteria.accountName = request.accountName;
                criteria.myOpportunitiesOnly =
                    request.myOpportunitiesOnly;

                AI_SalesIntelligenceService.PerformanceSummary summary =
                    AI_SalesIntelligenceService.getPerformance(criteria);

                response.success =
                    !summary.message.startsWith('The start date');

                response.message = summary.message;
                response.performanceSummaryJson =
                    JSON.serialize(summary);

            } catch (Exception ex) {
                response.success = false;
                response.message =
                    'Unable to calculate sales performance. ' +
                    ex.getMessage();
                response.performanceSummaryJson = null;
            }

            responses.add(response);
        }

        return responses;
    }
}
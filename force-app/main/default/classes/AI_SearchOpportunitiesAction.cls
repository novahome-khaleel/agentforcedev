public with sharing class AI_SearchOpportunitiesAction {

    public class Request {

        @InvocableVariable(
            label='Opportunity Name'
            description='Optional full or partial Opportunity Name'
        )
        public String opportunityName;

        @InvocableVariable(
            label='Stage'
            description='Optional exact Opportunity Stage Name'
        )
        public String stageName;

        @InvocableVariable(
            label='Account Name'
            description='Optional full or partial related Account Name'
        )
        public String accountName;

        @InvocableVariable(
            label='Close Date From'
            description='Optional beginning of Close Date range'
        )
        public Date closeDateFrom;

        @InvocableVariable(
            label='Close Date To'
            description='Optional end of Close Date range'
        )
        public Date closeDateTo;

        @InvocableVariable(
            label='My Opportunities Only'
            description='Set true to search only records owned by the current user'
        )
        public Boolean myOpportunitiesOnly;
    }

    public class Response {

        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Record Count')
        public Integer recordCount;

        @InvocableVariable(label='Opportunities JSON')
        public String opportunitiesJson;
    }

    @InvocableMethod(
        label='Search Opportunities'
        description='Search Salesforce Opportunities by name, stage, Account, close date or current owner. Returns up to 20 authorized records. Read only.'
    )
    public static List<Response> search(
        List<Request> requests
    ) {

        List<Response> results = new List<Response>();

        if (requests == null || requests.isEmpty()) {
            return results;
        }

        if (requests.size() != 1) {
            throw new AI_OpportunitySearchService.SearchException(
                'This conversational search action accepts one search request at a time.'
            );
        }

        Request req = requests[0];

        Response res = new Response();
        res.success = false;
        res.recordCount = 0;
        res.opportunitiesJson = '[]';

        try {

            AI_OpportunitySearchService.SearchCriteria criteria =
                new AI_OpportunitySearchService.SearchCriteria();

            if (req != null) {
                criteria.opportunityName = req.opportunityName;
                criteria.stageName = req.stageName;
                criteria.accountName = req.accountName;
                criteria.closeDateFrom = req.closeDateFrom;
                criteria.closeDateTo = req.closeDateTo;
                criteria.myOpportunitiesOnly =
                    req.myOpportunitiesOnly;
            }

            List<Opportunity> opportunities =
                AI_OpportunitySearchService.search(criteria);

            List<Map<String, Object>> records =
                new List<Map<String, Object>>();

            for (Opportunity opp : opportunities) {

                records.add(new Map<String, Object>{
                    'opportunityId' => opp.Id,
                    'opportunityName' => opp.Name,
                    'accountId' => opp.AccountId,
                    'accountName' =>
                        opp.Account == null
                            ? null : opp.Account.Name,
                    'stageName' => opp.StageName,
                    'amount' => opp.Amount,
                    'closeDate' => opp.CloseDate,
                    'probability' => opp.Probability,
                    'ownerId' => opp.OwnerId,
                    'ownerName' =>
                        opp.Owner == null
                            ? null : opp.Owner.Name,
                    'type' => opp.Type,
                    'leadSource' => opp.LeadSource,
                    'isClosed' => opp.IsClosed,
                    'isWon' => opp.IsWon
                });
            }

            res.success = true;
            res.recordCount = records.size();
            res.opportunitiesJson = JSON.serialize(records);

            res.message = records.isEmpty()
                ? 'No matching Opportunities found.'
                : 'Found ' + records.size() +
                  ' Opportunity record(s). Maximum results: 20.';

        } catch (
            AI_OpportunitySearchService.SearchException e
        ) {

            res.message = e.getMessage();

        } catch (Exception e) {

            res.message =
                'Unable to search Opportunities. Verify search criteria and Salesforce access permissions.';
        }

        results.add(res);

        return results;
    }
}
public with sharing class AI_GetOpportunityDetailsAction {

    public class Request {

        @InvocableVariable(
            label='Opportunity ID'
            description='Salesforce Opportunity record ID, if known'
        )
        public String opportunityId;

        @InvocableVariable(
            label='Opportunity Name'
            description='Exact Salesforce Opportunity Name'
        )
        public String opportunityName;
    }

    public class Response {

        @InvocableVariable(label='Success')
        public Boolean success;

        @InvocableVariable(label='Message')
        public String message;

        @InvocableVariable(label='Opportunity JSON')
        public String opportunityJson;
    }

    @InvocableMethod(
        label='Get Opportunity Details'
        description='Retrieves complete details of one Salesforce Opportunity using its record ID or exact name. Handles duplicate names without guessing. Read only.'
    )
    public static List<Response> getDetails(
        List<Request> requests
    ) {
        List<Response> results = new List<Response>();

        if (requests == null || requests.isEmpty()) {
            return results;
        }

        if (requests.size() != 1) {
            throw new AI_OpportunityDetailsService.DetailsException(
                'This action accepts one Opportunity request at a time.'
            );
        }

        Response res = new Response();
        res.success = false;
        res.opportunityJson = '[]';

        try {
            Request req = requests[0];

            List<Opportunity> records =
                AI_OpportunityDetailsService.getDetails(
                    req == null ? null : req.opportunityId,
                    req == null ? null : req.opportunityName
                );

            if (records.isEmpty()) {
                res.message = 'No accessible Opportunity was found.';
            } else if (records.size() > 1) {
                res.message =
                    'Multiple Opportunities have this exact name. Please provide the Opportunity ID or additional identifying details.';
            } else {
                Opportunity opp = records[0];

                Map<String, Object> data =
                    new Map<String, Object>{
                        'opportunityId' => opp.Id,
                        'opportunityName' => opp.Name,
                        'accountId' => opp.AccountId,
                        'accountName' =>
                            opp.Account == null
                                ? null : opp.Account.Name,
                        'stage' => opp.StageName,
                        'amount' => opp.Amount,
                        'closeDate' => opp.CloseDate,
                        'probability' => opp.Probability,
                        'ownerId' => opp.OwnerId,
                        'ownerName' =>
                            opp.Owner == null
                                ? null : opp.Owner.Name,
                        'type' => opp.Type,
                        'leadSource' => opp.LeadSource,
                        'description' => opp.Description,
                        'isClosed' => opp.IsClosed,
                        'isWon' => opp.IsWon,
                        'createdDate' => opp.CreatedDate,
                        'lastModifiedDate' => opp.LastModifiedDate
                    };

                res.success = true;
                res.opportunityJson = JSON.serialize(data);
                res.message =
                    'Opportunity details retrieved successfully.';
            }

        } catch (
            AI_OpportunityDetailsService.DetailsException e
        ) {
            res.message = e.getMessage();

        } catch (Exception e) {
            res.message =
                'Unable to retrieve Opportunity details. Verify record access and permissions.';
        }

        results.add(res);
        return results;
    }
}
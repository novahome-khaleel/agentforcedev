public with sharing class AI_OpportunityDetailsService {

    public class DetailsException extends Exception {}

    public static List<Opportunity> getDetails(
        String opportunityId,
        String opportunityName
    ) {
        String recordId = String.isBlank(opportunityId)
            ? null : opportunityId.trim();

        String name = String.isBlank(opportunityName)
            ? null : opportunityName.trim();

        if (recordId == null && name == null) {
            throw new DetailsException(
                'Provide an Opportunity ID or Opportunity Name.'
            );
        }

        if (recordId != null && name != null) {
            throw new DetailsException(
                'Provide either Opportunity ID or Opportunity Name, not both.'
            );
        }

        if (recordId != null) {
            Id parsedId;

            try {
                parsedId = Id.valueOf(recordId);
            } catch (Exception e) {
                throw new DetailsException(
                    'The Opportunity ID is invalid.'
                );
            }

            if (parsedId.getSObjectType() != Opportunity.SObjectType) {
                throw new DetailsException(
                    'The supplied record ID is not an Opportunity ID.'
                );
            }

            return [
                SELECT Id, Name, AccountId, Account.Name,
                       StageName, Amount, CloseDate, Probability,
                       OwnerId, Owner.Name, Type, LeadSource,
                       Description, IsClosed, IsWon,
                       CreatedDate, LastModifiedDate
                FROM Opportunity
                WHERE Id = :parsedId
                WITH USER_MODE
                LIMIT 1
            ];
        }

        if (name.length() > 100) {
            throw new DetailsException(
                'Opportunity Name must be 100 characters or fewer.'
            );
        }

        return [
            SELECT Id, Name, AccountId, Account.Name,
                   StageName, Amount, CloseDate, Probability,
                   OwnerId, Owner.Name, Type, LeadSource,
                   Description, IsClosed, IsWon,
                   CreatedDate, LastModifiedDate
            FROM Opportunity
            WHERE Name = :name
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 2
        ];
    }
}
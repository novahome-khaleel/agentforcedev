public with sharing class AI_OpportunitySearchService {

    public static final Integer MAX_RESULTS = 20;

    public class SearchException extends Exception {}

    public class SearchCriteria {
        public String opportunityName;
        public String stageName;
        public String accountName;
        public Date closeDateFrom;
        public Date closeDateTo;
        public Boolean myOpportunitiesOnly;
    }

    private static String normalize(String value) {
        return String.isBlank(value) ? null : value.trim();
    }

    private static void validateFilter(String value) {
        if (value != null && value.length() > 100) {
            throw new SearchException(
                'Search filters must not exceed 100 characters.'
            );
        }
    }

    private static String likePattern(String value) {
        String result = value.replace('\\', '\\\\');
        result = result.replace('%', '\\%');
        result = result.replace('_', '\\_');

        return '%' + result + '%';
    }

    public static List<Opportunity> search(
        SearchCriteria criteria
    ) {

        if (criteria == null) {
            throw new SearchException(
                'Search criteria are required.'
            );
        }

        String oppName = normalize(criteria.opportunityName);
        String stage = normalize(criteria.stageName);
        String account = normalize(criteria.accountName);

        Boolean myOnly =
            criteria.myOpportunitiesOnly == true;

        if (criteria.closeDateFrom != null &&
            criteria.closeDateTo != null &&
            criteria.closeDateFrom > criteria.closeDateTo) {

            throw new SearchException(
                'Close Date From cannot be later than Close Date To.'
            );
        }

        validateFilter(oppName);
        validateFilter(stage);
        validateFilter(account);

        if (oppName == null &&
            stage == null &&
            account == null &&
            criteria.closeDateFrom == null &&
            criteria.closeDateTo == null &&
            !myOnly) {

            throw new SearchException(
                'Provide an Opportunity Name, Stage, Account Name, Close Date range, or request your own Opportunities.'
            );
        }

        List<String> filters = new List<String>();

        Map<String, Object> binds =
            new Map<String, Object>();

        if (oppName != null) {
            filters.add('Name LIKE :oppNamePattern');
            binds.put(
                'oppNamePattern',
                likePattern(oppName)
            );
        }

        if (stage != null) {
            filters.add('StageName = :stageValue');
            binds.put('stageValue', stage);
        }

        if (account != null) {
            filters.add('Account.Name LIKE :accountPattern');
            binds.put(
                'accountPattern',
                likePattern(account)
            );
        }

        if (criteria.closeDateFrom != null) {
            filters.add('CloseDate >= :dateFrom');
            binds.put('dateFrom', criteria.closeDateFrom);
        }

        if (criteria.closeDateTo != null) {
            filters.add('CloseDate <= :dateTo');
            binds.put('dateTo', criteria.closeDateTo);
        }

        if (myOnly) {
            filters.add('OwnerId = :currentUserId');
            binds.put('currentUserId', UserInfo.getUserId());
        }

        String soql =
            'SELECT Id, Name, AccountId, Account.Name, ' +
            'StageName, Amount, CloseDate, Probability, ' +
            'OwnerId, Owner.Name, Type, LeadSource, ' +
            'IsClosed, IsWon ' +
            'FROM Opportunity ' +
            'WHERE ' + String.join(filters, ' AND ') +
            ' ORDER BY CloseDate ASC, Name ASC LIMIT 20';

        return Database.queryWithBinds(
            soql,
            binds,
            AccessLevel.USER_MODE
        );
    }
}
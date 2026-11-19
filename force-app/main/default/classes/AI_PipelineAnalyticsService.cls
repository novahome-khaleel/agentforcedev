public with sharing class AI_PipelineAnalyticsService {

    public class AnalyticsException extends Exception {}

    public class Criteria {
        public Boolean myOpportunitiesOnly;
        public String accountName;
        public Date closeDateFrom;
        public Date closeDateTo;
    }

    public class Summary {
        public Integer opportunityCount;
        public Decimal totalPipeline;
        public Decimal averageDealSize;
        public String currencyCode;
        public List<Map<String, Object>> stageBreakdown;
    }

    public static Summary calculate(Criteria criteria) {

        if (criteria == null) {
            throw new AnalyticsException(
                'Analytics criteria are required.'
            );
        }

        String account = String.isBlank(criteria.accountName)
            ? null : criteria.accountName.trim();

        if (account != null && account.length() > 100) {
            throw new AnalyticsException(
                'Account Name must not exceed 100 characters.'
            );
        }

        if (criteria.closeDateFrom != null &&
            criteria.closeDateTo != null &&
            criteria.closeDateFrom > criteria.closeDateTo) {
            throw new AnalyticsException(
                'Close Date From cannot be later than Close Date To.'
            );
        }

        List<String> filters = new List<String>{
            'IsClosed = false',
            'Amount != null'
        };

        Map<String, Object> binds = new Map<String, Object>();

        if (account != null) {
            String escaped = account
                .replace('\\', '\\\\')
                .replace('%', '\\%')
                .replace('_', '\\_');

            filters.add('Account.Name LIKE :accountPattern');
            binds.put('accountPattern', '%' + escaped + '%');
        }

        if (criteria.closeDateFrom != null) {
            filters.add('CloseDate >= :dateFrom');
            binds.put('dateFrom', criteria.closeDateFrom);
        }

        if (criteria.closeDateTo != null) {
            filters.add('CloseDate <= :dateTo');
            binds.put('dateTo', criteria.closeDateTo);
        }

        if (criteria.myOpportunitiesOnly == true) {
            filters.add('OwnerId = :currentUserId');
            binds.put('currentUserId', UserInfo.getUserId());
        }

        String whereClause = String.join(filters, ' AND ');

        String summaryQuery =
            'SELECT COUNT(Id) opportunityCount, ' +
            'SUM(Amount) totalPipeline, ' +
            'AVG(Amount) averageDealSize ' +
            'FROM Opportunity WHERE ' + whereClause;

        AggregateResult aggregateResult =
            Database.queryWithBinds(
                summaryQuery,
                binds,
                AccessLevel.USER_MODE
            );

        Summary result = new Summary();

        result.opportunityCount =
            (Integer) aggregateResult.get('opportunityCount');

        result.totalPipeline =
            (Decimal) aggregateResult.get('totalPipeline');

        result.averageDealSize =
            (Decimal) aggregateResult.get('averageDealSize');

        if (result.totalPipeline == null) {
            result.totalPipeline = 0;
        }

        if (result.averageDealSize == null) {
            result.averageDealSize = 0;
        }

        result.currencyCode = UserInfo.getDefaultCurrency();

        result.stageBreakdown =
            new List<Map<String, Object>>();

        String stageQuery =
            'SELECT StageName stageName, ' +
            'COUNT(Id) opportunityCount, ' +
            'SUM(Amount) totalAmount ' +
            'FROM Opportunity WHERE ' + whereClause +
            ' GROUP BY StageName ORDER BY StageName';

        List<AggregateResult> stageResults =
            Database.queryWithBinds(
                stageQuery,
                binds,
                AccessLevel.USER_MODE
            );

        for (AggregateResult ar : stageResults) {

            result.stageBreakdown.add(
                new Map<String, Object>{
                    'stageName' => ar.get('stageName'),
                    'opportunityCount' => ar.get('opportunityCount'),
                    'totalAmount' => ar.get('totalAmount')
                }
            );
        }

        return result;
    }
}
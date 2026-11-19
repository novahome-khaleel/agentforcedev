public with sharing class AI_SalesIntelligenceService {

    public class Criteria {
        public Date closeDateFrom;
        public Date closeDateTo;
        public String accountName;
        public Boolean myOpportunitiesOnly;
    }

    public class PerformanceSummary {
        public Integer totalClosedOpportunities = 0;
        public Integer wonOpportunities = 0;
        public Integer lostOpportunities = 0;
        public Decimal winRate = 0;
        public Decimal wonRevenue = 0;
        public Decimal averageWonDealSize = 0;
        public String message;
    }

    public static PerformanceSummary getPerformance(Criteria criteria) {

        PerformanceSummary summary = new PerformanceSummary();

        if (criteria == null) {
            summary.message = 'Performance criteria were not provided.';
            return summary;
        }

        if (criteria.closeDateFrom != null &&
            criteria.closeDateTo != null &&
            criteria.closeDateFrom > criteria.closeDateTo) {

            summary.message = 'The start date cannot be later than the end date.';
            return summary;
        }

        String queryString =
            'SELECT IsWon, COUNT(Id) opportunityCount, ' +
            'SUM(Amount) totalAmount, AVG(Amount) averageAmount ' +
            'FROM Opportunity WHERE IsClosed = true';

        Map<String, Object> bindValues = new Map<String, Object>();

        if (criteria.closeDateFrom != null) {
            queryString += ' AND CloseDate >= :closeDateFrom';
            bindValues.put('closeDateFrom', criteria.closeDateFrom);
        }

        if (criteria.closeDateTo != null) {
            queryString += ' AND CloseDate <= :closeDateTo';
            bindValues.put('closeDateTo', criteria.closeDateTo);
        }

        if (!String.isBlank(criteria.accountName)) {
            queryString += ' AND Account.Name LIKE :accountName';
            bindValues.put(
                'accountName',
                '%' + criteria.accountName.trim() + '%'
            );
        }

        if (criteria.myOpportunitiesOnly == true) {
            queryString += ' AND OwnerId = :currentUserId';
            bindValues.put('currentUserId', UserInfo.getUserId());
        }

        queryString += ' GROUP BY IsWon';

        List<SObject> resultRows = Database.queryWithBinds(
            queryString,
            bindValues,
            AccessLevel.USER_MODE
        );

        Decimal wonAverage = 0;

        for (SObject row : resultRows) {

            AggregateResult result = (AggregateResult) row;

            Boolean isWon = (Boolean) result.get('IsWon');
            Integer countValue =
                (Integer) result.get('opportunityCount');

            Decimal totalAmount =
                (Decimal) result.get('totalAmount');

            Decimal averageAmount =
                (Decimal) result.get('averageAmount');

            summary.totalClosedOpportunities += countValue;

            if (isWon) {
                summary.wonOpportunities = countValue;
                summary.wonRevenue =
                    totalAmount == null ? 0 : totalAmount;
                wonAverage =
                    averageAmount == null ? 0 : averageAmount;
            } else {
                summary.lostOpportunities = countValue;
            }
        }

        summary.averageWonDealSize = wonAverage;

        if (summary.totalClosedOpportunities > 0) {
            Decimal wonCount = summary.wonOpportunities;
            Decimal totalCount = summary.totalClosedOpportunities;

            summary.winRate = ((wonCount / totalCount) * 100).setScale(2);
        }

        summary.message =
            summary.totalClosedOpportunities == 0
            ? 'No closed opportunities matched the selected criteria.'
            : 'Sales performance calculated successfully.';

        return summary;
    }
}
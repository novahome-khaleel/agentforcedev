public with sharing class AI_AtRiskOpportunityService {

    public class Criteria {
        public Boolean myOpportunitiesOnly;
        public String accountName;
        public Integer inactivityDays;
        public Integer closingSoonDays;
        public Integer maxRecords;
    }

    public class RiskOpportunity {
        public Id opportunityId;
        public String opportunityName;
        public String accountName;
        public String stage;
        public Decimal amount;
        public Date closeDate;
        public Date lastActivityDate;
        public String nextStep;
        public List<String> riskSignals = new List<String>();
        public Integer riskScore = 0;
    }

    public class RiskSummary {
        public Integer totalAtRisk = 0;
        public Integer overdueCount = 0;
        public Integer closingSoonCount = 0;
        public Integer inactiveCount = 0;
        public Integer missingNextStepCount = 0;
        public List<RiskOpportunity> opportunities =
            new List<RiskOpportunity>();
        public String message;
    }

    public static RiskSummary getAtRiskOpportunities(
        Criteria criteria
    ) {
        RiskSummary summary = new RiskSummary();

        if (criteria == null) {
            summary.message = 'Search criteria were not provided.';
            return summary;
        }

        Integer inactivityDays =
            criteria.inactivityDays == null
            ? 14 : criteria.inactivityDays;

        Integer closingSoonDays =
            criteria.closingSoonDays == null
            ? 30 : criteria.closingSoonDays;

        Integer maxRecords =
            criteria.maxRecords == null
            ? 50 : criteria.maxRecords;

        if (inactivityDays < 0 ||
            closingSoonDays < 0 ||
            maxRecords < 1 ||
            maxRecords > 200) {

            summary.message =
                'Invalid thresholds. Use non-negative day values ' +
                'and a record limit between 1 and 200.';
            return summary;
        }

        Date todayDate = Date.today();
        Date activityCutoff = todayDate.addDays(-inactivityDays);
        Date closeDateLimit = todayDate.addDays(closingSoonDays);

        String queryString =
            'SELECT Id, Name, Account.Name, StageName, Amount, ' +
            'CloseDate, LastActivityDate, NextStep ' +
            'FROM Opportunity WHERE IsClosed = false AND (' +
            'CloseDate <= :closeDateLimit OR ' +
            'LastActivityDate = NULL OR ' +
            'LastActivityDate <= :activityCutoff OR ' +
            'NextStep = NULL)';

        Map<String, Object> bindValues =
            new Map<String, Object>{
                'closeDateLimit' => closeDateLimit,
                'activityCutoff' => activityCutoff
            };

        if (criteria.myOpportunitiesOnly == true) {
            queryString += ' AND OwnerId = :currentUserId';
            bindValues.put(
                'currentUserId',
                UserInfo.getUserId()
            );
        }

        if (!String.isBlank(criteria.accountName)) {
            queryString += ' AND Account.Name LIKE :accountName';
            bindValues.put(
                'accountName',
                '%' + criteria.accountName.trim() + '%'
            );
        }

        queryString +=
            ' ORDER BY Amount DESC NULLS LAST LIMIT ' +
            String.valueOf(maxRecords);

        List<Opportunity> records =
            (List<Opportunity>) Database.queryWithBinds(
                queryString,
                bindValues,
                AccessLevel.USER_MODE
            );

        for (Opportunity opp : records) {

            RiskOpportunity item = new RiskOpportunity();

            item.opportunityId = opp.Id;
            item.opportunityName = opp.Name;
            item.accountName =
                opp.Account == null ? null : opp.Account.Name;
            item.stage = opp.StageName;
            item.amount = opp.Amount;
            item.closeDate = opp.CloseDate;
            item.lastActivityDate = opp.LastActivityDate;
            item.nextStep = opp.NextStep;

            if (opp.CloseDate < todayDate) {
                item.riskSignals.add('Overdue close date');
                item.riskScore += 3;
                summary.overdueCount++;

            } else if (opp.CloseDate <= closeDateLimit) {
                item.riskSignals.add('Closing within ' +
                    closingSoonDays + ' days');
                item.riskScore += 2;
                summary.closingSoonCount++;
            }

            if (opp.LastActivityDate == null ||
                opp.LastActivityDate <= activityCutoff) {

                item.riskSignals.add('No recent activity');
                item.riskScore += 2;
                summary.inactiveCount++;
            }

            if (String.isBlank(opp.NextStep)) {
                item.riskSignals.add('Next Step is missing');
                item.riskScore += 1;
                summary.missingNextStepCount++;
            }

            summary.opportunities.add(item);
        }

        summary.totalAtRisk = summary.opportunities.size();

        summary.message =
            summary.totalAtRisk == 0
            ? 'No at-risk opportunities matched the selected criteria.'
            : 'At-risk opportunity analysis completed successfully.';

        return summary;
    }
}
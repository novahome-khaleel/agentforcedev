public with sharing class AI_SalesSearchService {

    public static final Integer MAX_RESULTS = 20;
    public static final Integer MAX_REQUESTS = 20;
    public static final Integer MAX_FILTER_LENGTH = 100;

    public class SearchException extends Exception {}

    public class AccountCriteria {
        public String name;
        public String industry;
        public String billingCity;
    }

    public class ContactCriteria {
        public String name;
        public String email;
        public String accountName;
    }

    private static String normalize(String value) {
        return String.isBlank(value) ? null : value.trim();
    }

    private static void validate(String value) {
        if (value != null &&
            value.length() > MAX_FILTER_LENGTH) {
            throw new SearchException(
                'Search filters must be 100 characters or fewer.'
            );
        }
    }

    // Escape LIKE wildcards so user input remains literal.
    private static String pattern(String value) {
        String result = value.replace('\\', '\\\\');
        result = result.replace('%', '\\%');
        result = result.replace('_', '\\_');
        return '%' + result + '%';
    }

    public static List<Account> searchAccounts(
        AccountCriteria criteria
    ) {
        if (criteria == null) {
            throw new SearchException(
                'Search criteria are required.'
            );
        }

        String name = normalize(criteria.name);
        String industry = normalize(criteria.industry);
        String city = normalize(criteria.billingCity);

        if (name == null &&
            industry == null &&
            city == null) {
            throw new SearchException(
                'Provide Account Name, Industry or Billing City.'
            );
        }

        validate(name);
        validate(industry);
        validate(city);

        List<String> filters = new List<String>();
        Map<String, Object> binds = new Map<String, Object>();

        if (name != null) {
            filters.add('Name LIKE :namePattern');
            binds.put('namePattern', pattern(name));
        }

        if (industry != null) {
            filters.add('Industry = :industryValue');
            binds.put('industryValue', industry);
        }

        if (city != null) {
            filters.add('BillingCity LIKE :cityPattern');
            binds.put('cityPattern', pattern(city));
        }

        String soql =
            'SELECT Id, Name, Industry, BillingCity, ' +
            'AnnualRevenue ' +
            'FROM Account WHERE ' +
            String.join(filters, ' AND ') +
            ' ORDER BY Name ASC, Id ASC LIMIT 20';

        return Database.queryWithBinds(
            soql,
            binds,
            AccessLevel.USER_MODE
        );
    }

    public static List<Contact> searchContacts(
        ContactCriteria criteria
    ) {
        if (criteria == null) {
            throw new SearchException(
                'Search criteria are required.'
            );
        }

        String name = normalize(criteria.name);
        String email = normalize(criteria.email);
        String accountName = normalize(criteria.accountName);

        if (name == null &&
            email == null &&
            accountName == null) {
            throw new SearchException(
                'Provide Contact Name, Email or Account Name.'
            );
        }

        validate(name);
        validate(email);
        validate(accountName);

        List<String> filters = new List<String>();
        Map<String, Object> binds = new Map<String, Object>();

        if (name != null) {
            filters.add(
                '(FirstName LIKE :namePattern OR ' +
                'LastName LIKE :namePattern OR ' +
                'Name LIKE :namePattern)'
            );
            binds.put('namePattern', pattern(name));
        }

        if (email != null) {
            filters.add('Email LIKE :emailPattern');
            binds.put('emailPattern', pattern(email));
        }

        if (accountName != null) {
            filters.add('Account.Name LIKE :accountPattern');
            binds.put('accountPattern', pattern(accountName));
        }

        String soql =
            'SELECT Id, Name, Email, Phone, ' +
            'AccountId, Account.Name ' +
            'FROM Contact WHERE ' +
            String.join(filters, ' AND ') +
            ' ORDER BY Name ASC, Id ASC LIMIT 20';

        return Database.queryWithBinds(
            soql,
            binds,
            AccessLevel.USER_MODE
        );
    }
}
@IsTest
private class AI_SalesSearchActionsTest {

    @TestSetup
    static void setupData() {
        List<Account> accounts = new List<Account>{
            new Account(
                Name = 'ABC Industries',
                Industry = 'Manufacturing',
                BillingCity = 'Hyderabad',
                AnnualRevenue = 1000000
            ),
            new Account(
                Name = 'XYZ Technologies',
                Industry = 'Technology',
                BillingCity = 'Bengaluru',
                AnnualRevenue = 2500000
            )
        };

        insert accounts;

        List<Contact> contacts = new List<Contact>{
            new Contact(
                FirstName = 'John',
                LastName = 'Smith',
                Email = 'john.smith@example.com',
                Phone = '9000000001',
                AccountId = accounts[0].Id
            ),
            new Contact(
                FirstName = 'Sarah',
                LastName = 'Johnson',
                Email = 'sarah.johnson@example.com',
                AccountId = accounts[1].Id
            )
        };

        insert contacts;
    }

    @IsTest
    static void testSearchAccountByName() {
        AI_SearchAccountsAction.Request req =
            new AI_SearchAccountsAction.Request();
        req.accountName = 'ABC';

        Test.startTest();
        List<AI_SearchAccountsAction.Response> results =
            AI_SearchAccountsAction.search(
                new List<AI_SearchAccountsAction.Request>{req}
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        System.assertEquals(1, results[0].recordCount);
        System.assert(
            results[0].accountsJson.contains('ABC Industries')
        );
    }

    @IsTest
    static void testAccountIndustryAndCity() {
        AI_SearchAccountsAction.Request req =
            new AI_SearchAccountsAction.Request();
        req.industry = 'Manufacturing';
        req.billingCity = 'Hyderabad';

        List<AI_SearchAccountsAction.Response> results =
            AI_SearchAccountsAction.search(
                new List<AI_SearchAccountsAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(1, results[0].recordCount);
    }

    @IsTest
    static void testAccountNoMatch() {
        AI_SearchAccountsAction.Request req =
            new AI_SearchAccountsAction.Request();
        req.accountName = 'Nonexistent Company';

        List<AI_SearchAccountsAction.Response> results =
            AI_SearchAccountsAction.search(
                new List<AI_SearchAccountsAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(0, results[0].recordCount);
    }

    @IsTest
    static void testAccountMissingFilters() {
        AI_SearchAccountsAction.Request req =
            new AI_SearchAccountsAction.Request();

        List<AI_SearchAccountsAction.Response> results =
            AI_SearchAccountsAction.search(
                new List<AI_SearchAccountsAction.Request>{req}
            );

        System.assertEquals(false, results[0].success);
        System.assert(
            results[0].message.contains('Provide Account Name')
        );
    }

    @IsTest
    static void testContactByName() {
        AI_SearchContactsAction.Request req =
            new AI_SearchContactsAction.Request();
        req.contactName = 'John';

        List<AI_SearchContactsAction.Response> results =
            AI_SearchContactsAction.search(
                new List<AI_SearchContactsAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(1, results[0].recordCount);
        System.assert(
            results[0].contactsJson.contains('John Smith')
        );
    }

    @IsTest
    static void testContactByEmail() {
        AI_SearchContactsAction.Request req =
            new AI_SearchContactsAction.Request();
        req.email = 'sarah.johnson@example.com';

        List<AI_SearchContactsAction.Response> results =
            AI_SearchContactsAction.search(
                new List<AI_SearchContactsAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(1, results[0].recordCount);
    }

    @IsTest
    static void testContactByAccount() {
        AI_SearchContactsAction.Request req =
            new AI_SearchContactsAction.Request();
        req.accountName = 'ABC Industries';

        List<AI_SearchContactsAction.Response> results =
            AI_SearchContactsAction.search(
                new List<AI_SearchContactsAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(1, results[0].recordCount);
        System.assert(
            results[0].contactsJson.contains('John Smith')
        );
    }

    @IsTest
    static void testContactMissingFilters() {
        AI_SearchContactsAction.Request req =
            new AI_SearchContactsAction.Request();

        List<AI_SearchContactsAction.Response> results =
            AI_SearchContactsAction.search(
                new List<AI_SearchContactsAction.Request>{req}
            );

        System.assertEquals(false, results[0].success);
    }

    @IsTest
    static void testMultipleRequests() {
        AI_SearchAccountsAction.Request first =
            new AI_SearchAccountsAction.Request();
        first.accountName = 'ABC';

        AI_SearchAccountsAction.Request second =
            new AI_SearchAccountsAction.Request();
        second.accountName = 'XYZ';

        List<AI_SearchAccountsAction.Response> results =
            AI_SearchAccountsAction.search(
                new List<AI_SearchAccountsAction.Request>{
                    first, second
                }
            );

        System.assertEquals(2, results.size());
        System.assertEquals(1, results[0].recordCount);
        System.assertEquals(1, results[1].recordCount);
    }

    @IsTest
    static void testLiteralWildcardSearch() {
        AI_SearchAccountsAction.Request req =
            new AI_SearchAccountsAction.Request();
        req.accountName = '%';

        List<AI_SearchAccountsAction.Response> results =
            AI_SearchAccountsAction.search(
                new List<AI_SearchAccountsAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(0, results[0].recordCount);
    }

    @IsTest
    static void testFilterLengthValidation() {
        AI_SearchAccountsAction.Request req =
            new AI_SearchAccountsAction.Request();

        String longName = '';
        for (Integer i = 0; i < 101; i++) {
            longName += 'A';
        }
        req.accountName = longName;

        List<AI_SearchAccountsAction.Response> results =
            AI_SearchAccountsAction.search(
                new List<AI_SearchAccountsAction.Request>{req}
            );

        System.assertEquals(false, results[0].success);
    }

    @IsTest
    static void testContactNoMatch() {
        AI_SearchContactsAction.Request req =
            new AI_SearchContactsAction.Request();
        req.email = 'missing@example.com';

        List<AI_SearchContactsAction.Response> results =
            AI_SearchContactsAction.search(
                new List<AI_SearchContactsAction.Request>{req}
            );

        System.assertEquals(true, results[0].success);
        System.assertEquals(0, results[0].recordCount);
    }
}
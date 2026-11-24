@IsTest
private class WarrantyEligibilityServiceTest {

    private static final String CUSTOMER_EMAIL =
        'warranty.test@novahome.example';

    private static final String OTHER_EMAIL =
        'other.customer@novahome.example';

    private static final String ACTIVE_SERIAL = 'NH-TEST-ACTIVE';
    private static final String EXPIRED_SERIAL = 'NH-TEST-EXPIRED';
    private static final String FUTURE_SERIAL = 'NH-TEST-FUTURE';
    private static final String CLAIMED_SERIAL = 'NH-TEST-CLAIMED';
    private static final String CANCELLED_SERIAL = 'NH-TEST-CANCELLED';
    private static final String PAST_END_SERIAL = 'NH-TEST-PAST-END';
    private static final String MISSING_DATES_SERIAL = 'NH-TEST-MISSING-DATES';

    /**
     * Creates test customers and warranty records.
     */
    @TestSetup
    static void createTestData() {

        Loyalty_Member__c member = new Loyalty_Member__c(
            Name = 'Warranty Test Member',
            Email__c = CUSTOMER_EMAIL
        );

        Loyalty_Member__c otherMember = new Loyalty_Member__c(
            Name = 'Other Test Member',
            Email__c = OTHER_EMAIL
        );

        insert new List<Loyalty_Member__c>{
            member,
            otherMember
        };

        Date todayDate = Date.today();

        List<Warranty__c> warranties = new List<Warranty__c>{

            // Active warranty within coverage dates.
            new Warranty__c(
                Serial_Number__c = ACTIVE_SERIAL,
                Loyalty_Member__c = member.Id,
                Warranty_Status__c = 'Active',
                Warranty_Start_Date__c = todayDate.addDays(-30),
                Warranty_End_Date__c = todayDate.addDays(365)
            ),

            // Expired status.
            new Warranty__c(
                Serial_Number__c = EXPIRED_SERIAL,
                Loyalty_Member__c = member.Id,
                Warranty_Status__c = 'Expired',
                Warranty_Start_Date__c = todayDate.addDays(-365),
                Warranty_End_Date__c = todayDate.addDays(-1)
            ),

            // Active status but coverage starts in the future.
            new Warranty__c(
                Serial_Number__c = FUTURE_SERIAL,
                Loyalty_Member__c = member.Id,
                Warranty_Status__c = 'Active',
                Warranty_Start_Date__c = todayDate.addDays(10),
                Warranty_End_Date__c = todayDate.addDays(365)
            ),

            // Claimed warranty.
            new Warranty__c(
                Serial_Number__c = CLAIMED_SERIAL,
                Loyalty_Member__c = member.Id,
                Warranty_Status__c = 'Claimed',
                Warranty_Start_Date__c = todayDate.addDays(-30),
                Warranty_End_Date__c = todayDate.addDays(365)
            ),

            // Cancelled warranty.
            new Warranty__c(
                Serial_Number__c = CANCELLED_SERIAL,
                Loyalty_Member__c = member.Id,
                Warranty_Status__c = 'Cancelled',
                Warranty_Start_Date__c = todayDate.addDays(-30),
                Warranty_End_Date__c = todayDate.addDays(365)
            ),

            // Active status but coverage has ended.
            new Warranty__c(
                Serial_Number__c = PAST_END_SERIAL,
                Loyalty_Member__c = member.Id,
                Warranty_Status__c = 'Active',
                Warranty_Start_Date__c = todayDate.addDays(-365),
                Warranty_End_Date__c = todayDate.addDays(-1)
            ),

            // Missing coverage dates.
            new Warranty__c(
                Serial_Number__c = MISSING_DATES_SERIAL,
                Loyalty_Member__c = member.Id,
                Warranty_Status__c = 'Active'
            )
        };

        insert warranties;
    }

    /**
     * Creates an invocable request.
     */
    private static WarrantyEligibilityService.WarrantyRequest
        createRequest(String serialNumber, String customerEmail) {

        WarrantyEligibilityService.WarrantyRequest request =
            new WarrantyEligibilityService.WarrantyRequest();

        request.serialNumber = serialNumber;
        request.customerEmail = customerEmail;

        return request;
    }

    @IsTest
    static void testActiveWarrantyEligible() {

        Test.startTest();

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest(ACTIVE_SERIAL, CUSTOMER_EMAIL)
                }
            );

        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].eligible);
        System.assertEquals('Active', results[0].warrantyStatus);
        System.assert(
            results[0].message.contains('currently eligible')
        );
    }

    @IsTest
    static void testExpiredWarranty() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest(EXPIRED_SERIAL, CUSTOMER_EMAIL)
                }
            );

        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Expired', results[0].warrantyStatus);
        System.assert(
            results[0].message.contains('not currently active')
        );
    }

    @IsTest
    static void testWarrantyNotYetStarted() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest(FUTURE_SERIAL, CUSTOMER_EMAIL)
                }
            );

        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Active', results[0].warrantyStatus);
        System.assert(
            results[0].message.contains('not currently within')
        );
    }

    @IsTest
    static void testWarrantyPastEndDate() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest(PAST_END_SERIAL, CUSTOMER_EMAIL)
                }
            );

        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Active', results[0].warrantyStatus);
        System.assert(
            results[0].message.contains('not currently within')
        );
    }

    @IsTest
    static void testMissingCoverageDates() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest(MISSING_DATES_SERIAL, CUSTOMER_EMAIL)
                }
            );

        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Active', results[0].warrantyStatus);
        System.assert(
            results[0].message.contains('coverage dates are incomplete')
        );
    }

    @IsTest
    static void testClaimedWarranty() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest(CLAIMED_SERIAL, CUSTOMER_EMAIL)
                }
            );

        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Claimed', results[0].warrantyStatus);
    }

    @IsTest
    static void testCancelledWarranty() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest(CANCELLED_SERIAL, CUSTOMER_EMAIL)
                }
            );

        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Cancelled', results[0].warrantyStatus);
    }

    @IsTest
    static void testInvalidSerialNumber() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest('INVALID-SERIAL', CUSTOMER_EMAIL)
                }
            );

        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Not Found', results[0].warrantyStatus);
        System.assert(
            results[0].message.contains('could not find a warranty')
        );
    }

    @IsTest
    static void testIncorrectCustomerEmail() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest(ACTIVE_SERIAL, OTHER_EMAIL)
                }
            );

        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Not Found', results[0].warrantyStatus);
        System.assert(
            results[0].message.contains('customer details')
        );
    }

    @IsTest
    static void testMissingSerialNumber() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest(null, CUSTOMER_EMAIL)
                }
            );

        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Unknown', results[0].warrantyStatus);
        System.assert(
            results[0].message.contains('valid product serial number')
        );
    }

    @IsTest
    static void testMissingCustomerEmail() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>{
                    createRequest(ACTIVE_SERIAL, null)
                }
            );

        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Unknown', results[0].warrantyStatus);
        System.assert(
            results[0].message.contains('registered customer email')
        );
    }

    @IsTest
    static void testNullRequest() {

        List<WarrantyEligibilityService.WarrantyRequest> requests =
            new List<WarrantyEligibilityService.WarrantyRequest>{
                null
            };

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(requests);

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].eligible);
        System.assertEquals('Unknown', results[0].warrantyStatus);
    }

    @IsTest
    static void testNullRequestList() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(null);

        System.assertEquals(0, results.size());
    }

    @IsTest
    static void testEmptyRequestList() {

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(
                new List<WarrantyEligibilityService.WarrantyRequest>()
            );

        System.assertEquals(0, results.size());
    }

    @IsTest
    static void testBulkRequests() {

        List<WarrantyEligibilityService.WarrantyRequest> requests =
            new List<WarrantyEligibilityService.WarrantyRequest>{
                createRequest(ACTIVE_SERIAL, CUSTOMER_EMAIL),
                createRequest(EXPIRED_SERIAL, CUSTOMER_EMAIL),
                createRequest(FUTURE_SERIAL, CUSTOMER_EMAIL),
                createRequest('INVALID-SERIAL', CUSTOMER_EMAIL),
                createRequest(CLAIMED_SERIAL, CUSTOMER_EMAIL)
            };

        Test.startTest();

        List<WarrantyEligibilityService.WarrantyResponse> results =
            WarrantyEligibilityService.checkEligibility(requests);

        Test.stopTest();

        System.assertEquals(5, results.size());

        System.assertEquals(true, results[0].eligible);
        System.assertEquals('Expired', results[1].warrantyStatus);
        System.assertEquals(false, results[1].eligible);
        System.assertEquals(false, results[2].eligible);
        System.assertEquals('Not Found', results[3].warrantyStatus);
        System.assertEquals('Claimed', results[4].warrantyStatus);
    }
}
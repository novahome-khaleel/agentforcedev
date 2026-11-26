@IsTest
private class WarrantyClaimPromptContextTest {

    private static WarrantyClaimPromptContext.Request createRequest(
        Warranty__c warranty
    ) {
        WarrantyClaimPromptContext.Request request =
            new WarrantyClaimPromptContext.Request();
        request.WarrantyRecord = warranty;
        return request;
    }

    private static void assertMissingWarrantyResponse(
        List<WarrantyClaimPromptContext.Request> requests
    ) {
        List<WarrantyClaimPromptContext.Response> responses =
            WarrantyClaimPromptContext.getWarrantyContext(requests);

        System.assertEquals(1, responses.size());
        System.assertEquals(
            'No warranty record was provided.',
            responses[0].Prompt
        );
    }

    @IsTest
    static void testMissingWarrantyInputs() {
        assertMissingWarrantyResponse(null);
        assertMissingWarrantyResponse(
            new List<WarrantyClaimPromptContext.Request>()
        );
        assertMissingWarrantyResponse(
            new List<WarrantyClaimPromptContext.Request>{null}
        );
        assertMissingWarrantyResponse(
            new List<WarrantyClaimPromptContext.Request>{
                new WarrantyClaimPromptContext.Request()
            }
        );
        assertMissingWarrantyResponse(
            new List<WarrantyClaimPromptContext.Request>{
                createRequest(new Warranty__c())
            }
        );
    }

    @IsTest
    static void testDeletedWarrantyReturnsNotFoundResponse() {
        Loyalty_Member__c member = new Loyalty_Member__c(
            Name = 'Warranty Claim Test Member'
        );
        insert member;

        Warranty__c warranty = new Warranty__c(
            Loyalty_Member__c = member.Id,
            Serial_Number__c = 'WARRANTY-CLAIM-DELETED',
            Warranty_Status__c = 'Active'
        );
        insert warranty;
        delete warranty;

        Test.startTest();
        List<WarrantyClaimPromptContext.Response> responses =
            WarrantyClaimPromptContext.getWarrantyContext(
                new List<WarrantyClaimPromptContext.Request>{
                    createRequest(new Warranty__c(Id = warranty.Id))
                }
            );
        Test.stopTest();

        System.assertEquals(1, responses.size());
        System.assertEquals(
            'No accessible warranty record was found.',
            responses[0].Prompt
        );
    }

    @IsTest
    static void testWarrantyPromptIncludesWarrantyAndCustomerDetails() {
        Loyalty_Member__c member = new Loyalty_Member__c(
            Name = 'Warranty Claim Test Member',
            Email__c = 'warranty.claim.test@example.com',
            Phone__c = '555-0100'
        );
        insert member;

        Date purchaseDate = Date.newInstance(2025, 1, 15);
        Date startDate = Date.newInstance(2025, 1, 15);
        Date endDate = Date.newInstance(2027, 1, 15);
        Warranty__c warranty = new Warranty__c(
            Loyalty_Member__c = member.Id,
            Product_Name__c = 'NovaHome Refrigerator',
            Serial_Number__c = 'WARRANTY-CLAIM-VALID',
            Warranty_Status__c = 'Active',
            Purchase_Date__c = purchaseDate,
            Warranty_Start_Date__c = startDate,
            Warranty_End_Date__c = endDate
        );
        insert warranty;

        Test.startTest();
        List<WarrantyClaimPromptContext.Response> responses =
            WarrantyClaimPromptContext.getWarrantyContext(
                new List<WarrantyClaimPromptContext.Request>{
                    createRequest(new Warranty__c(Id = warranty.Id))
                }
            );
        Test.stopTest();

        System.assertEquals(1, responses.size());
        String prompt = responses[0].Prompt;
        System.assert(prompt.contains('Warranty ID: ' + warranty.Id));
        System.assert(prompt.contains('Product: NovaHome Refrigerator'));
        System.assert(prompt.contains('Serial Number: WARRANTY-CLAIM-VALID'));
        System.assert(prompt.contains('Warranty Status: Active'));
        System.assert(
            prompt.contains('Purchase Date: ' + String.valueOf(purchaseDate))
        );
        System.assert(
            prompt.contains('Coverage Start: ' + String.valueOf(startDate))
        );
        System.assert(
            prompt.contains('Coverage End: ' + String.valueOf(endDate))
        );
        System.assert(prompt.contains('Customer Name: ' + member.Name));
        System.assert(
            prompt.contains('Customer Email: warranty.claim.test@example.com')
        );
        System.assert(prompt.contains('Customer Phone: 555-0100'));
    }
}

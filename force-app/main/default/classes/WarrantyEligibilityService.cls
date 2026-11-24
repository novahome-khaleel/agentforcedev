/**
 * Evaluates whether a NovaHome product warranty is currently eligible.
 *
 * Verifies customer ownership using the registered email address
 * and checks warranty status and coverage dates.
 *
 * Designed for Salesforce Flow and Agentforce invocable actions.
 */
public with sharing class WarrantyEligibilityService {

    /**
     * Input supplied by Flow or Agentforce.
     */
    public class WarrantyRequest {

        @InvocableVariable(
            label='Serial Number'
            description='Unique product serial number used to locate the NovaHome warranty.'
            required=true
        )
        public String serialNumber;

        @InvocableVariable(
            label='Customer Email'
            description='Customer email address used to verify ownership of the warranty.'
            required=true
        )
        public String customerEmail;
    }

    /**
     * Result returned to Flow or Agentforce.
     */
    public class WarrantyResponse {

        @InvocableVariable(
            label='Eligible'
            description='Indicates whether the warranty is currently eligible for coverage.'
        )
        public Boolean eligible;

        @InvocableVariable(
            label='Warranty Status'
            description='Current status stored on the matching warranty record.'
        )
        public String warrantyStatus;

        @InvocableVariable(
            label='Message'
            description='Customer-facing explanation of the warranty eligibility result.'
        )
        public String message;
    }

    /**
     * Checks warranty eligibility for multiple requests.
     *
     * Eligibility requirements:
     * 1. Customer email matches the registered Loyalty Member.
     * 2. Serial number belongs to that Loyalty Member.
     * 3. Warranty status is Active.
     * 4. Coverage start and end dates are populated.
     * 5. Today's date falls within the coverage period.
     *
     * Uses one bulk SOQL query and preserves request order.
     */
    @InvocableMethod(
        label='Check Warranty Eligibility'
        description='Verifies customer ownership using email and checks warranty status and coverage dates. Supports bulk requests.'
    )
    public static List<WarrantyResponse> checkEligibility(
        List<WarrantyRequest> requests
    ) {

        List<WarrantyResponse> responses =
            new List<WarrantyResponse>();

        if (requests == null || requests.isEmpty()) {
            return responses;
        }

        Set<String> serialNumbers = new Set<String>();
        Set<String> customerEmails = new Set<String>();

        // Collect input values for bulk processing.
        for (WarrantyRequest request : requests) {

            if (request == null) {
                continue;
            }

            if (!String.isBlank(request.serialNumber)) {
                serialNumbers.add(request.serialNumber.trim());
            }

            if (!String.isBlank(request.customerEmail)) {
                customerEmails.add(request.customerEmail.trim());
            }
        }

        Map<String, Warranty__c> warrantiesByKey =
            new Map<String, Warranty__c>();

        // Retrieve matching warranties using user-mode security.
        if (!serialNumbers.isEmpty() && !customerEmails.isEmpty()) {

            for (Warranty__c warranty : [
                SELECT Id,
                       Serial_Number__c,
                       Loyalty_Member__r.Email__c,
                       Warranty_Status__c,
                       Warranty_Start_Date__c,
                       Warranty_End_Date__c
                FROM Warranty__c
                WHERE Serial_Number__c IN :serialNumbers
                AND Loyalty_Member__r.Email__c IN :customerEmails
                WITH USER_MODE
            ]) {

                String key = buildLookupKey(
                    warranty.Serial_Number__c,
                    warranty.Loyalty_Member__r.Email__c
                );

                warrantiesByKey.put(key, warranty);
            }
        }

        Date todayDate = Date.today();

        // Process each request and return one response per request.
        for (WarrantyRequest request : requests) {

            WarrantyResponse response = new WarrantyResponse();
            response.eligible = false;

            if (request == null ||
                String.isBlank(request.serialNumber)) {

                response.warrantyStatus = 'Unknown';
                response.message =
                    'Please provide a valid product serial number.';

                responses.add(response);
                continue;
            }

            if (String.isBlank(request.customerEmail)) {

                response.warrantyStatus = 'Unknown';
                response.message =
                    'Please provide your registered customer email address to verify warranty ownership.';

                responses.add(response);
                continue;
            }

            String lookupKey = buildLookupKey(
                request.serialNumber,
                request.customerEmail
            );

            Warranty__c warranty = warrantiesByKey.get(lookupKey);

            if (warranty == null) {

                response.warrantyStatus = 'Not Found';
                response.message =
                    'We could not find a warranty matching the supplied serial number and customer details. Please verify both and try again.';

                responses.add(response);
                continue;
            }

            response.warrantyStatus = warranty.Warranty_Status__c;

            if (warranty.Warranty_Status__c != 'Active') {

                response.message =
                    'This warranty is not currently active. Current warranty status: ' +
                    warranty.Warranty_Status__c + '.';

                responses.add(response);
                continue;
            }

            if (warranty.Warranty_Start_Date__c == null ||
                warranty.Warranty_End_Date__c == null) {

                response.message =
                    'We found the warranty, but its coverage dates are incomplete. Please contact NovaHome support.';

                responses.add(response);
                continue;
            }

            if (todayDate < warranty.Warranty_Start_Date__c ||
                todayDate > warranty.Warranty_End_Date__c) {

                response.message =
                    'This warranty is not currently within its coverage period.';

                responses.add(response);
                continue;
            }

            response.eligible = true;
            response.message =
                'Your product warranty is active and currently eligible for coverage.';

            responses.add(response);
        }

        return responses;
    }

    /**
     * Builds a normalized key using serial number and customer email.
     */
    private static String buildLookupKey(
        String serialNumber,
        String customerEmail
    ) {

        return serialNumber.trim().toLowerCase() +
            '|' +
            customerEmail.trim().toLowerCase();
    }
}
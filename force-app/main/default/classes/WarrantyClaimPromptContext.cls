
public with sharing class WarrantyClaimPromptContext {

    public class Request {
        @InvocableVariable(
            label='Warranty Record'
            description='Warranty record to summarize for a customer warranty claim.'
            required=true
        )
        public Warranty__c WarrantyRecord;
    }

    public class Response {
        @InvocableVariable(
            label='Warranty Prompt Context'
            description='Warranty and customer details supplied to the Warranty Claim Summary prompt.'
        )
        public String Prompt;
    }

    @InvocableMethod(
        label='Get Warranty Claim Context'
        description='Retrieves warranty and related customer details to ground the Warranty Claim Summary prompt.'
    )
    public static List<Response> getWarrantyContext(List<Request> requests) {

        List<Response> results = new List<Response>();

        if (requests == null || requests.isEmpty()
            || requests[0] == null
            || requests[0].WarrantyRecord == null
            || requests[0].WarrantyRecord.Id == null) {

            Response emptyResponse = new Response();
            emptyResponse.Prompt = 'No warranty record was provided.';
            results.add(emptyResponse);
            return results;
        }

        Id warrantyId = requests[0].WarrantyRecord.Id;

        List<Warranty__c> warranties = [
            SELECT Id, Name, Serial_Number__c, Product_Name__c,
                   Warranty_Status__c, Purchase_Date__c,
                   Warranty_Start_Date__c, Warranty_End_Date__c,
                   Loyalty_Member__r.Name,
                   Loyalty_Member__r.Email__c,
                   Loyalty_Member__r.Phone__c
            FROM Warranty__c
            WHERE Id = :warrantyId
            WITH USER_MODE
            LIMIT 1
        ];

        Response response = new Response();

        if (warranties.isEmpty()) {
            response.Prompt = 'No accessible warranty record was found.';
        } else {
            Warranty__c warranty = warranties[0];

            response.Prompt =
                'WARRANTY DETAILS\n' +
                'Warranty ID: ' + warranty.Id + '\n' +
                'Product: ' + warranty.Product_Name__c + '\n' +
                'Serial Number: ' + warranty.Serial_Number__c + '\n' +
                'Warranty Status: ' + warranty.Warranty_Status__c + '\n' +
                'Purchase Date: ' + String.valueOf(warranty.Purchase_Date__c) + '\n' +
                'Coverage Start: ' + String.valueOf(warranty.Warranty_Start_Date__c) + '\n' +
                'Coverage End: ' + String.valueOf(warranty.Warranty_End_Date__c) + '\n' +
                'CUSTOMER DETAILS\n' +
                'Customer Name: ' + warranty.Loyalty_Member__r.Name + '\n' +
                'Customer Email: ' + warranty.Loyalty_Member__r.Email__c + '\n' +
                'Customer Phone: ' + warranty.Loyalty_Member__r.Phone__c;
        }

        results.add(response);
        return results;
    }
}

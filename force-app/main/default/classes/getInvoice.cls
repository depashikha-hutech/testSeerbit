public class getInvoice {
  
       private static final String BASE_URL = 'https://seerbitapi.com/invoice/';

    private static String generateAuthorizationToken() {
        Profile__c credential = [SELECT Public_Key__c, Secret_Key__c FROM Profile__c LIMIT 1];
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://seerbitapi.com/api/v2/encrypt/keys');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        Map<String, String> requestBodyMap = new Map<String, String>{
            'key' => credential.Secret_Key__c + '.' + credential.PUBLIC_KEY__c
        };
        String requestBody = JSON.serialize(requestBodyMap);
        request.setBody(requestBody);
        HttpResponse response = http.send(request);
        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            Map<String, Object> data = (Map<String, Object>) responseMap.get('data');
            Map<String, Object> encryptedKeyData = (Map<String, Object>) data.get('EncryptedSecKey');
            String encryptedKey = (String) encryptedKeyData.get('encryptedKey');
            System.debug('Encrypted Key: ' + encryptedKey);
            return encryptedKey;
        } else {
            System.debug('HTTP request failed with status code: ' + response.getStatusCode());
            system.debug('token1');
            return null;
        }
    }

    public static void getInvoiceInfo(String publicKey, String customerEmail) {
        String apiUrl = BASE_URL + publicKey + '/customer/' + customerEmail;
        String authorizationHeader = generateAuthorizationToken();
        System.debug('Authorization Header: ' + authorizationHeader);
        HttpRequest request = new HttpRequest();
        request.setEndpoint(apiUrl);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + authorizationHeader);
        Http http = new Http();
        HttpResponse response = http.send(request);
        system.debug(request);
        system.debug(response);
        if (response.getStatusCode() == 200) { // HTTP 200 OK
           Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
           String status = (String) jsonResponse.get('status');
           Map<String, Object> data = (Map<String, Object>) jsonResponse.get('data');
         if ('SUCCESS'.equals(status)) {
              String code = (String) data.get('code');
              Map<String, Object> payload = (Map<String, Object>) data.get('payload');
               String invoiceId = (String) payload.get('invoiceId');
                    String invoiceNo = (String) payload.get('invoiceNo');
                    String totalAmount = (String)payload.get('totalAmount');
                    String businessName = (String) payload.get('businessName');
             
                    // Add more fields as needed

                    System.debug('Invoice ID: ' + invoiceId);
                    System.debug('Invoice No: ' + invoiceNo);
                    System.debug('Total Amount: ' + totalAmount);

                    // Extract and process other fields as needed
        
            } else {
                String errorMessage = (String) jsonResponse.get('message');
                System.debug('Error: ' + errorMessage);
            }
        } else {
            // Handle the case where the HTTP request was not successful
            System.debug('HTTP Request failed with status code: ' + response.getStatusCode());
        }
    }
}
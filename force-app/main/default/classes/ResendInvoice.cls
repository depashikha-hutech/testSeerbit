public class ResendInvoice {
   private static final String BASE_URL = 'https://seerbitapi.com/invoice/';

    private static String generateAuthorizationToken() {
        try {
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
                return null;
            }
        } catch (Exception e) {
            System.debug('Exception occurred during token generation: ' + e.getMessage());
            return null;
        }
    }

    public static void sendInvoice(String publicKey, String invoiceNo) {
        try {
            String apiUrl = BASE_URL + publicKey + '/send/' + invoiceNo;
            String authorizationHeader = generateAuthorizationToken();
            System.debug('Authorization Header: ' + authorizationHeader);

            if (authorizationHeader != null) {
                HttpRequest request = new HttpRequest();
                request.setEndpoint(apiUrl);
                request.setMethod('GET');
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Authorization', 'Bearer ' + authorizationHeader);

                Http http = new Http();
                HttpResponse response = http.send(request);

                System.debug(request);
                System.debug(response);

                if (response.getStatusCode() == 200) {
                    Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    String code = String.valueOf(jsonResponse.get('code'));
                    String message = String.valueOf(jsonResponse.get('message'));
                    
                    if ('00'.equals(code)) {
                        System.debug('Invoice sent successfully. Message: ' + message);
                    } else {
                        System.debug('Error: ' + message);
                    }
                } else {
                    System.debug('HTTP Request failed with status code: ' + response.getStatusCode());
                }
            }
        } catch (Exception e) {
            System.debug('Exception occurred during invoice sending: ' + e.getMessage());
        }
    }
}
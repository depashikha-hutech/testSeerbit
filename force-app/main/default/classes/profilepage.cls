public class profilepage {
 @AuraEnabled
    public static Profile__c saveProfile(Profile__c profileDetails)
    {
        System.debug('profileDetails: ' + profileDetails);
        try {
            insert profileDetails;
            return profileDetails;
        } catch(DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    
    }
     
}
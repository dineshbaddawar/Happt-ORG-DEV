public Without Sharing class LeadConversioonCompHelper {
    
    @AuraEnabled
    public static String convertLeadMethod(String recordId) {
        
        LeadTriggerHandler.runtrigger = false;
        Lead leadObj = [SELECT Id, Email, Account__c, RecordType.DeveloperName FROM Lead WHERE Id =: recordId];
        String contactId;
        try {
            contactId = [SELECT Id FROM Contact WHERE Email =: leadObj.Email LIMIT 1].Id;
        } catch (Exception e) {}
        
        try {
            // Check the lead record type
            if (leadObj.RecordType != null && leadObj.RecordType.DeveloperName == 'EPIC') {
                map<Id,List<Event>> EventListByLeadId = new map<Id,List<Event>>();
                DateTime today = DateTime.now();
                List<Event> eventList = [SELECT id,WhoId,ActivityDateTime FROM Event WHERE WhoId =:recordId AND ActivityDateTime <= :today];
                
                if(eventList.size() == 0){
                    return 'No event found or event is of a future date.';
                } else {
                    // Continue with lead conversion
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(recordId);
                    lc.setAccountId(leadObj.Account__c);
                    if (contactId != null) lc.setContactId(contactId);
                    
                    lc.setConvertedStatus('Converted');
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                    System.debug(lcr.getAccountId());
                    return lcr.getAccountId();    
                }
            }else {
                if (leadObj.Account__c == null) {
                    return 'Lead cannot be converted. Please associate an account before converting.';
                }else{
                    // Directly convert the lead without event validation
                    Database.LeadConvert lc = new Database.LeadConvert();
                    lc.setLeadId(recordId);
                    lc.setAccountId(leadObj.Account__c);
                    if (contactId != null) lc.setContactId(contactId);
                    lc.setConvertedStatus('Converted');
                    Database.LeadConvertResult lcr = Database.convertLead(lc);
                    System.debug(lcr.getAccountId());
                    return lcr.getAccountId();    
                }
             }
        } catch (DmlException  e) {
            System.debug(e.getMessage() + e.getLineNumber());
            if(e.getMessage().contains('No event found or event is of a future date')){
                return 'No event found or event is of a future date!';
            } else {
                return e.getMessage();    
            }
        }
    }
    
    
    @AuraEnabled
    public static void submitForApproval(String recordId) {
        Lead leadObj = [SELECT Id, Website_Source_URL__c, Company, CIN__c FROM Lead WHERE Id = :recordId];
        
        if (String.isBlank(leadObj.Website_Source_URL__c) || String.isBlank(leadObj.Company) || String.isBlank(leadObj.CIN__c)) {
            throw new CustomException('Please fill Company, CIN, and Website Source URL before sending the request for Account creation.');
        }
        
        // Check if an Account with the same CIN already exists
        List<Account> existingAccounts = [SELECT Id FROM Account WHERE CIN__c = :leadObj.CIN__c LIMIT 1];
        if (!existingAccounts.isEmpty()) {
            throw new CustomException('An Account with the same CIN already exists. Please review the data and try again.');
        }
        
        Lead ld = [SELECT Id, Name, OwnerId FROM Lead WHERE Id = :recordId];
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for Tagging lead to Account!!');
        req1.setObjectId(ld.Id);
        req1.setNextApproverIds(new Id[] {ld.OwnerId});
        
        Approval.ProcessResult result = Approval.process(req1);
    }
    
    
}
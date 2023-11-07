public Without Sharing class LeadConversioonCompHelper {
    @AuraEnabled
    Public Static String convertLeadMethod(String recordId){
        Lead leadObj 	= [Select Id, Email, Account__c from Lead where Id =: recordId];
        String contactId ;
        try{
            contactId	= [Select Id from Contact where Email =: leadObj.Email LIMIT 1].Id;
        }catch(Exception e){}
        
        try{
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(recordId);
            lc.setAccountId(leadObj.Account__c);
            if(contactId != null) lc.setContactId(contactId);
            
//            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
            lc.setConvertedStatus('Demo meeting done');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            system.debug(lcr.getAccountId());
            return lcr.getAccountId();
        }catch(Exception e){
            system.debug(e.getMessage());
            return e.getMessage();           
        }
    }
    
    @AuraEnabled
    public Static void submitForApproval(String recordId)
    {
        Lead leadObj 	= [Select Id, Website_Source_URL__c, Company, CIN__c from Lead where Id =: recordId];
        if(String.isBlank(leadObj.Website_Source_URL__c) || String.isBlank(leadObj.Company) || String.isBlank(leadObj.CIN__c)) {
            throw new CustomException('Please fill Company, CIN and Website Source URL before sending request for Account creation.');
        }
        System.debug('recordId'+recordId);
        Lead ld = [Select id ,Name , OwnerId  from Lead where id =:recordId];
        
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for Tagging lead to Account!!');
        req1.setObjectId(ld.id);
        System.debug('recordId'+recordId);
        req1.setNextApproverIds(new Id[] {ld.OwnerId});
        Approval.ProcessResult result = Approval.process(req1);
    }
    
}
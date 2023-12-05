public without sharing class AccountBasedOnLeadCIN {
    
    @AuraEnabled
    public static List<SobjectsWrapper>  getAccount( string recordId){
        system.debug('recordId==>'+recordId);
        List<SobjectsWrapper> sobjectData = new List<SobjectsWrapper>();
        List<List<Sobject>> AccountData = new List<List<Account>>();
        List<Account> accListWithsimCIN = new List<Account>();
        List<Account> accListWithsimDomain = new List<Account>();
        List<Lead> leadListWithsimDomain = new List<Lead>();
        SobjectsWrapper sodw = new SobjectsWrapper();
        try{
            if(recordId != null){
                Lead ld= [Select id,CIN__c,Email from Lead where id=:recordId];
                if(ld.CIN__c !=null){
                    accListWithsimCIN = [Select id,Name,CIN__c,Email__c,Website,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry,Owner.FirstName,Owner.LastName from Account where CIN__c=:ld.CIN__c ];
                    system.debug('accListWithsimCIN'+accListWithsimCIN);
                    AccountData.add(accListWithsimCIN);
                    sodw.SimCINAccountList = accListWithsimCIN;
                }
                
                if(ld.Email !=null){
                    String DoaminValue = ld.Email.split('@')[1];
                    system.debug('DoaminValue'+DoaminValue);
                    list<list<sObject>> ListOfResults = [FIND :DoaminValue IN Email FIELDS RETURNING Account(id,Name,CIN__c,Email__c,Owner.FirstName,Owner.LastName)];
                    accListWithsimDomain = ListOfResults[0];
                    system.debug('accListWithsimDomain'+accListWithsimDomain);
                    AccountData.add(accListWithsimDomain);
                    sodw.SimDomAccountList = accListWithsimDomain;
                }
                if(ld.Email !=null){
                    String DoaminValue = ld.Email.split('@')[1];
                    list<list<sObject>> ListOfResultsforLead = [FIND :DoaminValue IN Email FIELDS RETURNING Lead(Id , CIN__c ,Name ,Account__c,Account__r.Name, Email , Company WHERE Id != :recordId)];                    
                    leadListWithsimDomain = ListOfResultsforLead[0];
                    system.debug('leadListWithsimDomain'+leadListWithsimDomain);
                    sodw.SimDomLeadList = leadListWithsimDomain;
                    
                    //AccountData.add(leadListWithsimDomain);
                }
                sobjectData.add(sodw);
                if(sobjectData.size() > 0){
                    system.debug('AccountData'+AccountData);
                    return sobjectData;
                }else{
                    return null;
                }
            }   
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getLineNumber());
        }  
        return null;
    }
    
    @AuraEnabled
    public static void tagAccountToLead(string leadId , string accId){
        system.debug('leadId==>'+leadId);
        system.debug('accId==>'+accId);
        Lead ld = [Select id , name , Account__c from Lead where id = :leadId];
        ld.Account__c = accId;
        update ld;
    }
    
    public static Set<sObject> FindDuplicates(String LeadId){
        List<Lead> SobjList = [Select id , name from Lead where Id = :LeadId];
        Set<sObject> findResults = new Set<sObject>();
        try {
            Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(SobjList);
            for (Datacloud.FindDuplicatesResult findDupeResult : results) {
                for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                    for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                        for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                            findResults.add(matchRecord.getRecord());
                        }
                    }
                }
            }
        } catch (Exception e) {
            //ApexDebugLog.logError(e.getStackTraceString(), e.getMessage(), e.getTypeName(), 'Utility', 'FindDuplicates', 'Error');
            throw new AuraHandledException(e.getMessage());
        }
        return findResults;
    }
    
    @AuraEnabled
    public static void  duplicateDomainVerificaiton( string recordId){
        try{
            Lead ld = [Select id , name , Email from Lead where id = :recordId];
            String DomainValue = ld.Email.split('@').get(1);
            String mainValue = '';
            if(DomainValue.contains('.com')){
                System.debug('DomainValue'+DomainValue); 
                if(DomainValue.contains('.com')){
                    mainValue = DomainValue.removeEnd('.com');
                }
                if(DomainValue.contains('.co.in')){
                    mainValue = DomainValue.removeEnd('.com');
                }
            }
            String valueToBeSearched = mainValue.left(4);
            system.debug('valueToBeSearched'+valueToBeSearched);
            List<Lead> LeadList = [Select id , Name , Email From Lead ];
            List<Lead> leadsWithSimilarDomain = new List<Lead>();
            for(Lead LdObj : LeadList){
                if(LdObj.Email != null){
                    if(LdObj.Email.Contains(valueToBeSearched)){
                        system.debug('LdObj'+LdObj);
                        leadsWithSimilarDomain.add(LdObj);
                    }    
                }
                
            }
            system.debug('leadsWithSimilarDomain'+leadsWithSimilarDomain.size());   
        }catch(exception e ){
            system.debug('exception'+e.getMessage() + '@-->'+e.getLineNumber());   
        }
    }
    
    public class SobjectsWrapper {
        @AuraEnabled 
        public List<Account> SimCINAccountList;
        @AuraEnabled 
        public List<Account> SimDomAccountList;
        @AuraEnabled 
        public List<Lead> SimDomLeadList;
    }    
    
    
}
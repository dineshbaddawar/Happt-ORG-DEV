Public Without Sharing Class PreSalesFormHelper {
    
    @AuraEnabled
    public static oppAccWrapper getData(string recordId) {
        try{
            oppAccWrapper dtWrapper = new oppAccWrapper();
            Opportunity opp = [SELECT Id, Name, AccountId, Prospect_Grade__c, Demo_Date_Time__c, Agenda_of_the_Call__c, Owner.Name, Demo_Done__c
                               FROM Opportunity WHERE Id=:recordId LIMIT 1];
            dtWrapper.opp = opp;
            Account acc = [Select Id, Name, Region__c, Region_New__c, HRMs__c, ERP_Accounting_Software__c, Auditor__c, Current_MRR__c, CRM__c, TMC__c, 
                           NumberOfEmployees, ShippingStreet, ShippingState, ShippingCountry, ShippingCity, ShippingPostalCode
                           FROM Account WHERE Id =: opp.AccountId ];
            dtWrapper.acc = acc;
            system.debug('dtWrapper -- ' + dtWrapper);
            return dtWrapper;  
        }
        catch(Exception e){
            system.debug('Error in Updation -- ' + e.getMessage() + 'At Line No -- ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string updateData(Account acc, Opportunity opp){
        try{
            update acc;
            update opp;
            return 'SUCCESS';
        }
        catch(Exception e){
            system.debug('Error in Updation -- ' + e.getMessage() + 'At Line No -- ' + e.getLineNumber());
            return e.getMessage();
        }
    }
    
    public class oppAccWrapper{
        @AuraEnabled
        public Opportunity opp{get;set;}
        @AuraEnabled
        public Account acc{get;set;}
    }
}
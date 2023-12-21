@isTest
public class TestLeadConversionCompHelper {
    
    @isTest
    static void testConvertLeadMethod() {
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
       
        String epicRecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead' AND Name = 'EPIC' LIMIT 1].Id;
        Lead testLeadEPIC = new Lead(
            RecordTypeId = epicRecordTypeId,
            Account__c = acc.Id,
            Company = 'Test',
            FirstName = 'Rest',
            LastName = 'Test',
            Email = 'test@example.com'
        );
        insert testLeadEPIC;

        Event testEventEPIC = new Event(
            Subject = 'Meeting',
            WhoId = testLeadEPIC.Id,
            ActivityDateTime = DateTime.now().addDays(-1),
            DurationInMinutes = 60  // Set the DurationInMinutes field
        );
        insert testEventEPIC;

        String resultEPIC = LeadConversioonCompHelper.convertLeadMethod(testLeadEPIC.Id);
     
        String teRecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead' AND Name = 'Travel & Expense' LIMIT 1].Id;
        Lead testLeadOther = new Lead(
            RecordTypeId = teRecordTypeId,
            Account__c = acc.Id,
            Company = 'Test1',
            FirstName = 'Test3',
            LastName = 'Name',
            Email = 'test@example.com'
        );
        insert testLeadOther;
        String resultOther = LeadConversioonCompHelper.convertLeadMethod(testLeadOther.Id);
       
    }
    
    @isTest
    static void testSubmitForApproval() {
        Lead testLead = new Lead(
            Website_Source_URL__c = 'http://example.com',
            Company = 'Test Company',
            FirstName = 'Rest1',
            LastName = 'Test',
            CIN__c = 'L17110MH1973PLC019786'
        );
        insert testLead;
        LeadConversioonCompHelper.submitForApproval(testLead.Id);
        
        
        Lead testLeadIncomplete = new Lead(
            Website_Source_URL__c = 'http://example.com',
            Company = 'Test Company',
            FirstName = 'Rest4',
            LastName = 'Test',
            CIN__c = 'L17110MH1973PLC019786'
        );
        insert testLeadIncomplete;
        LeadConversioonCompHelper.submitForApproval(testLeadIncomplete.Id);
        
    }

    
}
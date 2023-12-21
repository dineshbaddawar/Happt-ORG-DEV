@isTest
public class LeadTriggerHandlerTest {
    
    @isTest
    static void testLeadMember() {
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName  = 'Lead',
            Company   = 'XYZ Co.',
            Status    = 'Open'
            //OwnerId   = testUser.Id
            
        );
        insert testLead;
    }
    
    @isTest
    static void testOnAfterInsert() {
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            ProfileId = profileObj.Id,
            LastName = 'Test',
            FirstName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'TUser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true
        );
        insert testUser;
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Open',
            OwnerId = testUser.Id
        );
        insert testLead;
        
        Test.startTest();
        List<Lead> leadList = new List<Lead>{ testLead };
            LeadTriggerHandler.onAfterInsert(leadList);
        Test.stopTest();
    }
    
    @isTest
    static void testOnBeforeUpdate() {
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            ProfileId = profileObj.Id,
            LastName = 'Test',
            FirstName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'TUser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true
        );
        insert testUser;
        
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Open',
            OwnerId = testUser.Id,
            Approved__c = false,
            Account__c = testAccount.Id,
            Product_Interested__c = 'Travel & Expense (T&E)'
        );
        insert testLead;
        
        Map<Id, Lead> oldLeadMap = new Map<Id, Lead>{ testLead.Id => testLead };
            testLead.Approved__c = true;
        update testLead;
        
        Test.startTest();
        Map<Id, Lead> newLeadMap = new Map<Id, Lead>{ testLead.Id => testLead };
            LeadTriggerHandler.onBeforeUpdate(newLeadMap, oldLeadMap);
        Test.stopTest();
        
    }
    
    @isTest
    static void testUpdateSalesPerson() {
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            ProfileId = profileObj.Id,
            LastName = 'Test',
            FirstName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'TUser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true
        );
        insert testUser;
        
        Account testAccount = new Account(
            Name = 'Test Account'
        );
        insert testAccount;
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Open',
            OwnerId = testUser.Id,
            Account__c = testAccount.Id,
            Product_Interested__c = 'Travel & Expense (T&E)'
        );
        insert testLead;
        
        AccountTeamMember testTeamMember = new AccountTeamMember(
            AccountId = testAccount.Id,
            UserId = testUser.Id,
            TeamMemberRole = 'Sales Rep',
            Product__c = 'Travel & Expense (T&E)'
        );
        insert testTeamMember;
        
        Test.startTest();
        
        Map<Id, Lead> newLeadMap = new Map<Id, Lead>{ testLead.Id => testLead };
            Map<Id, Lead> oldLeadMap = new Map<Id, Lead>{ testLead.Id => testLead };
                LeadTriggerHandler.updateSalesPerson(newLeadMap, oldLeadMap);
        
        Test.stopTest();
        
    }
    
    
    /*  @isTest
static void testCheckMandatoryFields() {
// Create a test lead with EPIC record type, 'Dropped/Lost' status, and a converted date in the past
RecordType epicRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Lead' AND DeveloperName = 'EPIC' LIMIT 1];
Lead testLead = new Lead(
FirstName = 'Test',
LastName = 'Lead',
Company = 'Test Company',
Status = 'Dropped/Lost',
RecordTypeId = epicRecordType.Id
);
insert testLead;

// Create a test event related to the test lead with an ActivityDateTime in the past
Event testEvent = new Event(
WhoId = testLead.Id,
DurationInMinutes = 60,
ActivityDateTime = DateTime.now().addDays(-1)
);
insert testEvent;

// Call the trigger handler method
Test.startTest();
Map<Id, Lead> leadMap = new Map<Id, Lead>{ testLead.Id => testLead };
LeadTriggerHandler.checkMandatoryFields(leadMap);
Test.stopTest();


// Create a new test lead with EPIC record type and 'Dropped/Lost' status but no related events
Lead testLeadWithoutEvent = new Lead(
FirstName = 'Test',
LastName = 'Lead',
Company = 'Test Company',
Status = 'Dropped/Lost',
RecordTypeId = epicRecordType.Id
);
insert testLeadWithoutEvent;

// Call the trigger handler method
Test.startTest();
Map<Id, Lead> leadMapWithoutEvent = new Map<Id, Lead>{ testLeadWithoutEvent.Id => testLeadWithoutEvent };
LeadTriggerHandler.checkMandatoryFields(leadMapWithoutEvent);
Test.stopTest();

}*/
    
    
    @isTest
    static void testUpdateOppRecordType() {
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'Sales' LIMIT 1];
        User testUser = new User(
            ProfileId = profileObj.Id,
            LastName = 'Test',
            FirstName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'TUser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true
        );
        insert testUser;
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Documents Shared - Qualifying',
            CloseDate = Date.today() + 30
            
        );
        insert testOpportunity;
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'Open',
            OwnerId = testUser.Id
        );
        insert testLead;
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(testLead.Id);
        lc.setConvertedStatus('Converted');
        lc.setAccountId(testAccount.Id);
        lc.setOpportunityId(testOpportunity.Id);
        List<Database.LeadConvertResult> lcr = Database.convertLead(new List<Database.LeadConvert>{lc});
        
        Test.startTest();
        
        List<Lead> leadList = [SELECT Id, ConvertedOpportunityId, ConvertedAccountId, IsConverted,OwnerId FROM Lead WHERE Id = :testLead.Id];
        Map<Id, Lead> oldLeadMap = new Map<Id, Lead>{ testLead.Id => testLead };
            LeadTriggerHandler.updateOppRecordType(leadList, oldLeadMap);
        Test.stopTest();
        
    }
    
    public static Id getNonEpicRecordTypeId() {
        String teRecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead' AND Name = 'Travel & Expense' LIMIT 1].Id;
        return teRecordTypeId;
    }
    
    
    public static Id getEpicRecordTypeId() {
        
        String epicRecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead' AND Name = 'EPIC' LIMIT 1].Id;
        return epicRecordTypeId;
    }
    
    @isTest
    static void testAddBDTeamMember() {
        
        Profile profileObj = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            ProfileId = profileObj.Id,
            LastName = 'Test',
            FirstName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser@example.com' + System.currentTimeMillis(),
            Alias = 'TUser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles',
            IsActive = true
        );
        insert testUser;
        
        Opportunity testOpportunity = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today() + 30
            
        );
        insert testOpportunity;
        
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName  = 'Lead',
            Company   = 'XYZ Co.',
            Status    = 'Open',
            OwnerId   = testUser.Id
            
        );
        insert testLead;
        
        OpportunityTeamMember teamMember = LeadTriggerHandler.addBDTeamMember(testOpportunity.Id, testLead.OwnerId);
        
    }
    
    
    
    static testmethod void testIncrement() {
        LeadTriggerHandler.justIncrement();
    }
    
}
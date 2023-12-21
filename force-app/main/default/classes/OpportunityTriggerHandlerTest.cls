@isTest
public class OpportunityTriggerHandlerTest {
    
        @isTest
    static void testAssignOwnerHelper() {
       
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'tuser@example.com',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Documents Shared - Qualifying',
            CloseDate = Date.today(),
            AccountId = testAccount.Id,
            Product_Interested__c = 'Epic Cards'
        );
        insert testOpp;

        AccountTeamMember testTeamMember = new AccountTeamMember(
            AccountId = testAccount.Id,
            UserId = testUser.Id,
            TeamMemberRole = 'Sales Rep'
        );
        insert testTeamMember;

        OpportunityTriggerHandler.AssOwner(new List<Opportunity>{testOpp});

    }
    
    
 /* @isTest
    static void testUpdateOwner() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        User testUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Alias = 'tuser',
            Username = 'user.t@example.com',
            CommunityNickname = 'testuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        System.runAs(testUser) {

            Id loggedInUserId = UserInfo.getUserId();

            Opportunity testOpp = new Opportunity(
                Name = 'Test Opportunity',
                StageName = 'Prospecting',
                CloseDate = Date.today(),
                AccountId = testAccount.Id,
                Product_Interested__c = 'Employee Tax Benefits'
            );
            insert testOpp;

            AccountTeamMember testTeamMember = new AccountTeamMember(
                AccountId = testAccount.Id,
                UserId = loggedInUserId,
                TeamMemberRole = 'Sales Rep',
                Product__c = 'Employee Tax Benefits'
            );
            insert testTeamMember;

            OpportunityTriggerHandler.onBeforeInsert(new List<Opportunity>{testOpp});
            OpportunityTriggerHandler.assignOpp(new List<Opportunity>{testOpp});
        }
    }*/
    
    
   @isTest
    static void testTagOppTeamMemberEpic() {
      
        RecordType epicRecordType = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Opportunity' AND Name = 'EPIC' LIMIT 1];

        Opportunity testOpp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Documents Shared - Qualifying',
            CloseDate = Date.today(),
            RecordTypeId = epicRecordType.Id
        );
        insert testOpp;

        Group testGroup = new Group(Name = 'Credit Risk User', Type = 'Regular');
        insert testGroup;

        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Alias = 'tuser',
            Email = 'testuser@example.com',
            Username = 'tser@example.com',
            ProfileId = UserInfo.getProfileId(),
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        Test.startTest();
       OpportunityTriggerHandler.onAfterInsert(new List<Opportunity>{testOpp});
        Test.stopTest();

    }
}
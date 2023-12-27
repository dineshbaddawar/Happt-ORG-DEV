@isTest 
public class UpdateOpportunity_Test {
    @isTest
    public static void TestMethods() {
        // Create a test Opportunity
        Account acc = TestUtility1.createAccount('Account');
        date  clsdate = system.Today();
        Opportunity testOpportunity = New Opportunity(Name = 'oppTest',AccountId= acc.id,CloseDate =  clsdate, StageName = 'Closed Won' );  
        
        insert testOpportunity;
        
        Quote quRec = new Quote();
        quRec.OpportunityId = testOpportunity.Id;
        quRec.Name = 'Test Quote';
        Insert quRec;
        
        testOpportunity.SyncedQuoteId = quRec.Id;
        update testOpportunity;
        
        Set<Id> quoteRecSet = new Set<Id>();
        quoteRecSet.add(quRec.Id);
        Test.startTest();
        UpdateOpportunity.Quote_Related_OpportunityUpdate(quoteRecSet);
        Test.stopTest();
        
    }
}
@isTest
public class UpdateOpportunity_Test {
@isTest
    static void testQuoteRelatedOpportunityUpdate() {
        // Create a test Opportunity
         Account acc = TestUtility1.createAccount('Account');
        date  clsdate = system.Today();
        Opportunity testOpportunity = New Opportunity(Name = 'oppTest',AccountId= acc.id,CloseDate =  clsdate, StageName = 'Closed Won' );  
        
        insert testOpportunity;

        // Create a test Quote related to the test Opportunity
    
 
          Quote testQuote = TestUtility1.CreateQuote(testOpportunity.id,'TestQuote',100000,100000,100000,100000);
        
      //  insert testQuote;

        // Add the Quote Id to the set for future method call
        Set<Id> quoteIds = new Set<Id>{ testQuote.Id };

        Test.startTest();
        // Call the future method using a test context
        UpdateOpportunity.Quote_Related_OpportunityUpdate(quoteIds);
        Test.stopTest();

        // Retrieve the updated Opportunity record
        Opportunity updatedOpportunity = [SELECT Id, No_of_Modules_sold_in_Travel__c, No_of_Modules_sold_in_Expense__c /* Include other fields */ 
                                          FROM Opportunity WHERE Id = :testOpportunity.Id];

        // Perform assertions to verify the expected changes in the Opportunity based on the Quote data
        //System.assertEquals(/* Expected Value */, updatedOpportunity.No_of_Modules_sold_in_Travel__c);
        //System.assertEquals(/* Expected Value */, updatedOpportunity.No_of_Modules_sold_in_Expense__c);
        // Add other assertions as needed for the updated fields
    }
}
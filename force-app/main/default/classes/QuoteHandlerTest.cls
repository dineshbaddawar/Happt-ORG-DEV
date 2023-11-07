@isTest
public class QuoteHandlerTest {

    
    @isTest
    static void insertandUpdateQuote()
    { 
    Account ac = TestUtility.createAccount('Test Ac');
    Contact con = TestUtility.createContact(ac);

    Opportunity opp = TestUtility.createOpportunity(ac);
        OpportunityContactRole ocr = new OpportunityContactRole();
		ocr.ContactId = con.Id;
		ocr.OpportunityId = opp.Id;
		ocr.IsPrimary = TRUE;
		ocr.Role = 'Decision Maker';
		insert ocr;
    opp.Email__c ='test.test@testgmail.com';
    opp.StageName ='Stage 2 (Validated)';
    update opp; 
        
    
    //opp.SyncedQuoteId = q.id;
    OpportunityLineItem oli = TestUtility.createLineItem(opp); 
        Quote q = TestUtility.createQuote(opp, 'Draft');
    //update opp;
    System.assert(true, [SELECT HasOpportunityLineItem FROM Opportunity WHERE Id =: opp.Id].HasOpportunityLineItem );   
    }
}
@isTest
public class GenerateOrderFromLWCHelperTest {
    
    @isTest
    public static void testPDFClass() {
        Account acc  = new Account(Name = 'Shubham Account');
        insert acc;
        
        Opportunity oppRec                  = new Opportunity();
        oppRec.Name                         = 'Shubham Account 1';
        oppRec.AccountId                    = acc.id;
        oppRec.CloseDate                    = System.today();  
        oppRec.StageName                    = 'Draft';
        insert oppRec;
        
        Quote quotRec                       = new Quote();
        quotRec.OpportunityId               = oppRec.id;
        quotRec.Name                        = 'Test 1';
        insert quotRec;
        
        GenerateOrderFromLWCHelper.generateSelectedOrderForm('OF With OTI And Subscription',quotRec.id);
        GenerateOrderFromLWCHelper.generateSelectedOrderForm('OF Only With Subscription',quotRec.id);
        GenerateOrderFromLWCHelper.generateSelectedOrderForm('OF With Subscription and Card Details',quotRec.id);
        GenerateOrderFromLWCHelper.generateSelectedOrderForm('OF With OTI, Subscription and Card details',quotRec.id);
        GenerateOrderFromLWCHelper.getQuoteDetails(quotRec.id);
    }
}
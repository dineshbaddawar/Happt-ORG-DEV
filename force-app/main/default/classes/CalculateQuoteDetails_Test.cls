@IsTest(SeeAllData=true)
public  class CalculateQuoteDetails_Test {
    
    @isTest
    public static void calculateOTIANDSAASPriceTest() {
        Account acc = TestUtility1.createAccount('Account');
        Opportunity opp = TestUtility1.CreateOpp('oppTest',acc.id,system.Today(),'Closed Won');  
        
        Product2 prod = new Product2();
        prod.Name = 'test'; 
        insert prod; 
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Quote testQuote = TestUtility1.CreateQuote(opp.id,'Testq',100000,100000,100000,100000);
        
        QuoteLineItem  qutlineitemtest = new QuoteLineItem(QuoteId = testQuote.id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = standardPrice.id);
        List<QuoteLineItem> QLIist = new List<QuoteLineItem>();
        QLIist.add(qutlineitemtest);
        insert QLIist;
        CalculateQuoteDetails.calculateOTIANDSAASPrice(QLIist);
        CalculateQuoteDetails.calculateQuoteDiscount(testQuote);
    }
}
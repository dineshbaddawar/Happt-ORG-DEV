@IsTest(SeeAllData=true)
public class OrderFormOnlySubscriptionwithCard_Test {
    @isTest
    public static void MethodForOrderPDF(){
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
        
        PageReference pageRef = Page.OrderForm_OnlySubscriptionWithCards; // Replace with your actual Visualforce page name
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testQuote.Id);
        
        // Create an instance of the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote);
        OrderFormOnlySubscriptionwithCard_Ctrl controllerInstance = new OrderFormOnlySubscriptionwithCard_Ctrl(sc);
        
        
        
    }
}
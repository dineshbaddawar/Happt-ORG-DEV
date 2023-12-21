@IsTest 
public class Order_SubscriptionController_Test {
    @isTest
    public static void MethodForOrderPDF(){
        Account acc = TestUtility1.createAccount('Account');
        
        Contact conrec = new Contact();
        conrec.AccountId = acc.id;
        conrec.LastName = 'testName';
        insert conrec;
        
        
        Opportunity opp = TestUtility1.CreateOpp('oppTest',acc.id,system.Today(),'Closed Won');  
        
        Product2 prod = new Product2();
        prod.Name = 'test'; 
        prod.Is_Travel_Product__c = True;
        insert prod; 
        
        list<Product2> productlist = new list<Product2>();
        Product2 prod1 = new Product2();
        prod1.Name = '*Cancellations Flights -Domestic/International (Online)'; 
        prod1.Is_Travel_Product__c = true;
        insert prod1; 
        
        Product2 prod3 = new Product2();
        prod3.Name = 'Abcd'; 
        prod3.Is_Travel_Product__c = false;
        insert prod3; 
        
        Product2 prod2 = new Product2();
        prod2.Name = 'Web Services Charges for Web based API Integration (if any)'; 
        prod2.Is_Travel_Product__c = True;
        insert prod2;
        
        Product2 prod4 = new Product2();
        prod4.Name = 'Web Services Charges for Web based API Integration (if any)'; 
        prod4.Is_Travel_Product__c = True;
        insert prod4;
        
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod3.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice3;
        
        PricebookEntry standardPrice4 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod4.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice4;
        
        Quote testQuote = TestUtility1.CreateQuote(opp.id,'Testq',100000,100000,100000,100000);
        
        Quote testQuote12 = new  Quote();
        testQuote12.id = testQuote.id;
        testQuote12.Pricebook2Id = pricebookId;
        update testQuote12;
        
        
        
        List<QuoteLineItem> QLIist = new List<QuoteLineItem>();
        QuoteLineItem  qutlineitemtest1 = new QuoteLineItem(QuoteId = testQuote12.id , Quantity = 3.00 ,UnitPrice = 14 , PricebookEntryId = standardPrice.id,Type__c = 'SAAS',SAAS_Price__c = 2000000);
        //insert qutlineitemtest1;
        QLIist.add(qutlineitemtest1);
        
        QuoteLineItem  qutlineitemtest2 = new QuoteLineItem(QuoteId = testQuote12.id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = standardPrice1.id,Type__c = 'SAAS',SAAS_Price__c = 2000000 );
        //insert qutlineitemtest2;
        QLIist.add(qutlineitemtest2);
        
        QuoteLineItem  qutlineitemtest3 = new QuoteLineItem(QuoteId = testQuote12.id , Quantity = 3.00 ,UnitPrice = 14 , PricebookEntryId = standardPrice2.id,Type__c = 'SAAS',SAAS_Price__c = 2000000);
        //insert qutlineitemtest3;
        QLIist.add(qutlineitemtest3);
        
        QuoteLineItem  qutlineitemtest4 = new QuoteLineItem(QuoteId = testQuote12.id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = standardPrice3.id,Type__c = 'SAAS',SAAS_Price__c = 2000000,Nested_Parent_Product__c = qutlineitemtest2.id);
        QLIist.add(qutlineitemtest4);
        
        QuoteLineItem  qutlineitemtest5 = new QuoteLineItem(QuoteId = testQuote12.id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = standardPrice4.id,Type__c = 'SAAS',SAAS_Price__c = 2000000 );
        //insert qutlineitemtest5;
        QLIist.add(qutlineitemtest5);
        
        insert QLIist;
        
        
        String testLbl = Label.WaterMarkDraft;
        SERVICEPROVIDERDETAILS__c custmsettingRec = new SERVICEPROVIDERDETAILS__c();
        custmsettingRec.Name =  'VA  PRIVATE LIMITED';
        custmsettingRec.StreetAddress__c = '3rd Floor, Delta Block, Sigma';
        custmsettingRec.StreetArea__c = 'Soft-Tech Park, No.7';
        custmsettingRec.StreetRoad__c = 'Whitefield Main Road';
        custmsettingRec.CityArea__c = 'Ramagodanahalli, Varthur';
        custmsettingRec.CityStatePincode__c = 'Hobli, Bangalore 560066';
        custmsettingRec.Charges__c = 'INR 15,000.00'; 
        insert custmsettingRec;
        // custmsettingRec.
        
        
        
       // PageReference pageRef = Page.OrderSubscription_Implementation_OF; // Replace with your actual Visualforce page name
       // Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testQuote12.Id);
        
        // Create an instance of the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote12);
        // Order_SubscriptionController controllerInstance = new Order_SubscriptionController(sc);
        SubscriptionWithOTIOFController controllerInstance = new SubscriptionWithOTIOFController(sc);
        
        
        
        Test.startTest();
        SubscriptionWithOTIOFController.getQuoteDetails(testQuote12.id);
        SubscriptionWithOTIOFController.getAllTheSubsctiptionProducts(testQuote12.id);
        SubscriptionWithOTIOFController.getTermandCondition(testQuote12.id);
        SubscriptionWithOTIOFController.ServiceProicderDetails(testQuote12.id);
        SubscriptionWithOTIOFController.quoteContact(testQuote12.id);
        Test.stopTest();
    }
}
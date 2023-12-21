@IsTest 
public class HappyOrderFormVFController_Test {
    @isTest
    public static void MethodForOrderPDF(){
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        string profileid = profile.id;
        User testUser = new User(
            ProfileId = profile.Id,
            LastName = 'Dinesh',
            Email = 'dinesh@mailinator.com',
            UserName = 'dinesh@mailinator.com',
            Alias = 'din',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;  
        string userid = testUser.id;
        
        Account acc = TestUtility1.createAccount('Account');
        Opportunity opp = TestUtility1.CreateOpp('oppTest',acc.id,system.Today(),'Closed Won');  
        
        Contact conRec = new Contact();
        conRec.AccountId = acc.id;
        conRec.LastName = 'Testname';
        insert conRec;
        
        Product2 prod = new Product2();
        prod.Name = 'test'; 
        prod.Is_Travel_Product__c = TRUE;
        insert prod; 
        
        Product2 prod1 = new Product2();
        prod1.Name = 'test1'; 
        prod1.Is_Travel_Product__c = false;
        insert prod1;
        
        Product2 prod2 = new Product2();
        prod2.Name = 'test2'; 
        prod2.Is_Travel_Product__c = True;
        insert prod2;
        
        Product2 prod3 = new Product2();
        prod3.Name = 'test3'; 
        prod3.Is_Travel_Product__c = True;
        insert prod3;
        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
         PricebookEntry standardPrice1 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod1.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice1;
        
        PricebookEntry standardPrice2 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod2.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice2;
        
        PricebookEntry standardPrice3 = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod3.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice3;
        
        Quote testQuote = TestUtility1.CreateQuote(opp.id,'Testq',100000,100000,100000,100000);
        
        Quote testQuote1 = new Quote();
        testQuote1.id = testQuote.id;
        testQuote1.Pricebook2Id  = pricebookId;
        update testQuote1;
        
        Term_Section_Line_Item__c tsLRec  = TestUtility1.CreateTermSection('TestTerm');
        string tsLRecId = tsLRec.id;
        Term_Attribute_Line_Item__c talRec = TestUtility1.CreateTermAttributeLI('Quartely Billing',tsLRecId,True,True,userid);
        string talRecId = talRec.id;
        Approval_Matrix__c AMRec = TestUtility1.CreateApprovalMatrix('AppTest',True,userid,talRecId,profileid,True);
        string AMRecId = AMRec.id;
        
        
        list<Terms_and_condition__c> termConditionlist = new list<Terms_and_condition__c>();
        
        Terms_and_condition__c TACRec = TestUtility1.CreateTermAndCondition(AMRecId,talRecId,tsLRecId,userid,testQuote1.ID);
        termConditionlist.add(TACRec);
        
        List<QuoteLineItem> QLIist = new List<QuoteLineItem>();
        QuoteLineItem  qutlineitemtest = new QuoteLineItem(QuoteId = testQuote1.id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = standardPrice.id,Type__c ='SAAS');
        QLIist.add(qutlineitemtest);
        
        
        QuoteLineItem  qutlineitemtest1 = new QuoteLineItem(QuoteId = testQuote1.id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = standardPrice1.id,Type__c ='OTI');
        QLIist.add(qutlineitemtest1);
        
        
        QuoteLineItem  qutlineitemtest2 = new QuoteLineItem(QuoteId = testQuote1.id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = standardPrice2.id,Type__c ='OTI');
        QLIist.add(qutlineitemtest2);
        
         QuoteLineItem  qutlineitemtest3 = new QuoteLineItem(QuoteId = testQuote1.id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = standardPrice3.id,Type__c ='OTI + SAAS');
        QLIist.add(qutlineitemtest3);
        insert QLIist;
        
        
        SERVICEPROVIDERDETAILS__c california = new SERVICEPROVIDERDETAILS__c();
        california.StreetArea__c = 'CA';
        california.CityArea__c = 'California';
        california.NAME = 'xyzabc';
        insert california;
        
        HappyCard__c california1 = new HappyCard__c();
        california1.Welcome__c = 'CA';
        california1.Wallet_to_Bank_transfer_charges__c = 'California';
        california1.NAME = 'zbcd';
        insert california1;
        
        PageReference pageRef = Page.HappyOrderFormVF; // Replace with your actual Visualforce page name
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testQuote1.Id);
        
        // Create an instance of the controller
        ApexPages.StandardController sc = new ApexPages.StandardController(testQuote1);
        HappyOrderFormVFController controllerInstance = new HappyOrderFormVFController(sc);
        Test.startTest();
        // PaymentTermApprover.paymentTermApproverLogic(testQuote.id);
        HappyOrderFormVFController.insertQuoteAttachmentPDF(testQuote1.id);
        Test.stopTest();
    }
}
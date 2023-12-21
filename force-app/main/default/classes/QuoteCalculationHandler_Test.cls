@IsTest(SeeAllData=true)
public class QuoteCalculationHandler_Test {
    @IsTest
    public static void methodQuoteCalculationHandler(){
        
        Boolean CommonSandBoxExist               =false;
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        string profileid = profile.id;
        User testUser = new User(
            ProfileId = profile.Id,
            LastName = 'sidhart',
            Email = 'sid@mailinatore.com',
            UserName = 'sid@mailinatore.com',
            Alias = 'sid',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;  
        Map<Id,Id> mapofProd2IdByEntryId12 = new Map<Id,Id>();
        List<Terms_and_condition__c> TACList = new List<Terms_and_condition__c>();
        List<Product_Lookup_Data__c> proLookuplist = new List<Product_Lookup_Data__c>();
        //  List<Product_Lookup_Data__c> proLookuplist1 = new List<Product_Lookup_Data__c>();
        List<QuoteLineItem> QLIlist = new List<QuoteLineItem>();
        List<QuoteLineItem> QLItemList = new List<QuoteLineItem>();
        List<string> qliidlist = new   List<string>();
        List<string> ProdIds = new  List<string>();
        
        map<id,Terms_and_condition__c> mapIdAndTermConditiion = new map<id,Terms_and_condition__c> ();
        string userid = testUser.id;
        Account acc = TestUtility1.createAccount('Account');
        // string accid = acc.id;
        date  clsdate = system.Today();
        Opportunity opp = TestUtility1.CreateOpp('oppTest',acc.id,clsdate,'Closed Won');  
        //  string oppid = opp.id;
        
        Quote testQuote = TestUtility1.CreateQuote(opp.id,'TestQuote',5000000,5600000,5000000,5000000);
        
        Quote testQuote1 = TestUtility1.CreateQuote(opp.id,'TestQuote1',5000000,1500000,5000000,5000000);
        testQuote1.Expense_Total_OTI__c = 1500000;
        //  testQuote1.Expense_Total_SAAS__c = 1500000;
        update testQuote1;
        
        string testQuoteid = testQuote.id;
        Term_Section_Line_Item__c tsLRec  = TestUtility1.CreateTermSection('TestTerm');
        string tsLRecId = tsLRec.id;
        Term_Attribute_Line_Item__c talRec = TestUtility1.CreateTermAttributeLI('TestTerm',tsLRecId,True,True,userid);
        string talRecId = talRec.id;
        Approval_Matrix__c AMRec = TestUtility1.CreateApprovalMatrix('AppTest',True,userid,talRecId,profileid,True);
        string AMRecId = AMRec.id;
        Terms_and_condition__c TACRec = TestUtility1.CreateTermAndCondition(AMRecId,talRecId,tsLRecId,userid,testQuoteid); 
        Product2 prod = new Product2();
        prod.Name = 'Sandboxes & Route Tracker'; 
        prod.Is_Travel_Product__c = false;  
        insert prod; 
        if(prod != null){ 
            ProdIds.add(prod.id); 
        } 
        
        Product2 prod1 = new Product2();
        prod1.Name = 'Dedicated Sandbox Environment'; 
        insert prod1;
         Product2 prod2 = new Product2();
        prod2.Name = 'Common Sandbox Environment'; 
        insert prod2;
        Id pricebookId = Test.getStandardPricebookId(); 
        
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true); 
        insert standardPrice; 
        
        if(standardPrice != null){ 
            mapofProd2IdByEntryId12.put(standardPrice.Pricebook2Id,standardPrice.id); 
        }
        
        QuoteLineItem  qliRec = new QuoteLineItem(QuoteId = testQuote1.id , Quantity = 3.00 ,UnitPrice = 1000 ,Product2Id = prod.Id,  PricebookEntryId = standardPrice.id, Account_Type__c ='SMALL',Travel_Pricing_Type__c = 'Per Booking',Travel_Offering_Type__c = 'SBT',Minimum_Commitment__c = 10,IsMultiplybyBooking__c= True, OTI_Quantity__c = 5,IsPrice_IsQuantity_Editable__c= True,OTI_Price__c  =1000,
                                                  OTI_Custom_API_Price__c = 0,   OTI_API_Pricing__c =0 ,SAAS_SFTP_Pricing__c = 0, OTI_Elite_Pricing__c = 0,OTI_Premium_Pricing__c= 0 ,OTI_Pro_Pricing__c = 0,Type__c='OTI');
        
        if(qliRec != null){
            qliidlist.add(qliRec.id);
            QLIlist.add(qliRec);
        }
        insert QLIlist;
        QuoteLineItem QLItemRec=new QuoteLineItem();
        QLItemRec.Product2Id= prod2.Id;
        QLItemRec.UnitPrice=15;
        QLItemRec.Quantity=1;
        QLItemRec.Account_Type__c='SMALL';
        if(QLItemRec.Travel_Offering_Type__c!='-None-'){
            QLItemRec.Travel_Offering_Type__c='SBT'; 
        }
        QLItemRec.Travel_Pricing_Type__c='Per Booking';
        QLItemRec.QuoteId=testQuote.id;
        QLItemRec.PricebookEntryId= standardPrice.id;
        QLItemRec.Selected__c = true;
        QLItemRec.Minimum_Commitment__c=19;
        QLItemRec.Parent_Quote_Line_Item__c = qliRec.id;
        QLItemRec.Nested_Parent_Product__c =qliRec.id;
        QLItemRec.Selected__c=true;
                                QLItemRec.IsOptionalProduct__c=true;
                                QLItemRec.SAAS_Quantity__c=0;
                                QLItemRec.OTI_Quantity__c=1;
                                QLItemRec.IsPrice_IsQuantity_Editable__c=true;
                                QLItemRec.Type__c='OTI';
        
        if(QLItemRec != null){
            QLItemList.add(QLItemRec);
        }
        insert QLItemList;  
        list<Features__c> feturelist = new list<Features__c>();
        Features__c feRec   = new Features__c(Name ='FeatureTest',ProductId__c =prod.id, Category__c = 'Bundle Options');
        feturelist.add(feRec);
        insert feturelist;
        
        Product_Lookup_Data__c ProlookRec = new Product_Lookup_Data__c(Sub_Type__c = 'Custom API',Travel_Offering_Type__c = 'TRF',FeatureId__c =feRec.id,Parent_Product__c =prod.id,SAAS_Quantity__c = 1,OTI_Quantity__c =1 ,Bundle_Product__c =prod.id,Account_Type__c='SMALL',Pricing_Type__c = 'Per Booking'  );
        proLookuplist.add(ProlookRec);
        insert proLookuplist;
        
        List<Product_Lookup_Data__c> proLookuplist1 = new List<Product_Lookup_Data__c>();
        
        Product_Lookup_Data__c ProlookRec1 = new Product_Lookup_Data__c(Sub_Type__c = 'API',Travel_Offering_Type__c = 'TRF',FeatureId__c =feRec.id,Parent_Product__c =prod.id,SAAS_Quantity__c = 1,OTI_Quantity__c =1 ,Bundle_Product__c =prod.id ,IsActive__c=true );
        proLookuplist1.add(ProlookRec1);
        insert proLookuplist1;
        
        List<Product_Lookup_Data__c> proLookuplist2 = new List<Product_Lookup_Data__c>();
        Product_Lookup_Data__c ProlookRec2 = new Product_Lookup_Data__c(Sub_Type__c = 'SFTP',Travel_Offering_Type__c = 'TRF',FeatureId__c =feRec.id,Parent_Product__c =prod.id,SAAS_Quantity__c = 1,OTI_Quantity__c =1 ,Bundle_Product__c =prod.id ,IsActive__c=true );
        proLookuplist2.add(ProlookRec2);
        insert proLookuplist2;
        
        Product_Rule__c PrRec = new Product_Rule__c(Name ='Product Rule Test',Product__c = prod.id,Criteria__c= '1 AND 2',Lookup_Object__c ='Product_Lookup_Data__c',Active__c= true);
        insert PrRec;
        list<Product_Rule_Conditions__c> productRuleConditino = new list<Product_Rule_Conditions__c>();
        Product_Rule_Conditions__c  ProRuleRec =  new Product_Rule_Conditions__c(Product_Rule__c = PrRec.id,Lookup_Object_Field_API_Name__c = 'Travel_Offering_Type__c',Quote_Line_Field_API_Name__c ='Travel_Offering_Type__c',Sequence__c =1);
        productRuleConditino.add(ProRuleRec);
        insert productRuleConditino;
        
        
        
        
        // List<Product_Rule_Conditions__c> lisOfPRC1  = new List<Product_Rule_Conditions__c>();
        //lisOfPRC1    = ProductConfigurationModal.returnActiveProductRule(ProdIds[0]);
        // insert lisOfPRC1;
      
        
        
        Test.startTest();
        QuoteCalculationHandler.QuoteRec(testQuote.id); 
        QuoteCalculationHandler.QuoteRecList(testQuote); 
        QuoteCalculationHandler.QuoteLineItemRecs(testQuote.id); 
        QuoteCalculationHandler.ChildQuoteLineItemRecs(qliRec.id); 
        QuoteCalculationHandler.InsertQuoteLineItemExpense(QLItemList,mapofProd2IdByEntryId12,'OnInsert/Update'); 
        QuoteCalculationHandler.returnMessage( ); 
        
        QuoteCalculationHandler.InsertQuoteLineItemExpense(QLIlist,mapofProd2IdByEntryId12,'OnInsert/Update');
        QuoteCalculationHandler.InsertQuoteLineItemExpense(QLItemList,mapofProd2IdByEntryId12,'On Discount');
        QuoteCalculationHandler.InsertQuoteLineItemExpense(QLIlist,mapofProd2IdByEntryId12,'On Discount');
        QuoteCalculationHandler.deleteQliLineItemsOnConfigure(qliidlist);
        QuoteCalculationHandler.QuoteLineRecList(QLItemList);
        QuoteCalculationHandler.ShowAllOptions(ProdIds,qliRec.Travel_Offering_Type__c,qliRec.Travel_Pricing_Type__c,qliRec.Account_Type__c);    
        QuoteCalculationHandler.ChildProductOption(qliRec.id,qliRec.Account_Type__c,qliRec.Travel_Pricing_Type__c);
        QuoteCalculationHandler.ConfigureLineItem(qliRec.id);
        QuoteCalculationHandler.ConfigureLineItem1(qliRec.id);
        QuoteCalculationHandler.GetQuotelineItemlist1(QLIlist,True); 
        QuoteCalculationHandler.deleteQliLineItems(qliRec.id);    
        QuoteCalculationHandler.InsertQuoteLineItem(prod.id,testQuote.id,proLookuplist,null,qliidlist,QLItemRec.Travel_Offering_Type__c,QLItemRec.Travel_Pricing_Type__c,QLItemRec.Account_Type__c,77);  
        QuoteCalculationHandler.codeCover();
        Test.stopTest();
    }
    
}
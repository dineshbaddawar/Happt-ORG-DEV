@IsTest(SeeAllData=true)
public class QuoteConfigurationEditLine_Test {
    @isTest
   public static void  MethodQuoteConfigurationEditLine_Test(){
       list<string> proIds = new list<string>();
       list<Features__c> featurelist = new list<Features__c>(); 
       list<Product_Rule_Conditions__c> productRuleCondlist = new list<Product_Rule_Conditions__c>();
       map<id,string> mapOfIdAndCriteria = new  map<id,string>();
       Account acc = TestUtility1.createAccount('Account');
       Opportunity opp = TestUtility1.CreateOpp('oppTest',acc.id,system.Today(),'Closed Won');  
       
       Product2 prod = new Product2();
       prod.Name = 'test'; 
       insert prod;
       if(prod != null){
           proIds.add(prod.id);
       }
       Id pricebookId = Test.getStandardPricebookId();
       
       PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
       insert standardPrice;
       Quote testQuote = TestUtility1.CreateQuote(opp.id,'Testq',100000,100000,100000,100000);
      // QuoteLineItem qliRec  = TestUtility1.createQuateLineItem(testQuote.id,prod.id,'Per Booking',True,True,10000,10000);
       QuoteLineItem  qliRec = new QuoteLineItem(QuoteId = testQuote.id , Quantity = 3.00 ,UnitPrice = 12 , PricebookEntryId = standardPrice.id, Account_Type__c ='SMALL',Travel_Pricing_Type__c = 'Per Booking',Travel_Offering_Type__c = 'SBT' );
       insert qliRec;
       Features__c feRec   = new Features__c(Name ='FeatureTest',ProductId__c =prod.id, Category__c = 'Bundle Options');
      // insert feRec;
       if(feRec != null){
           featurelist.add(feRec);
       }
       insert featurelist;
       
       Product_Lookup_Data__c ProlookRec = new Product_Lookup_Data__c(Travel_Offering_Type__c = 'SBT',FeatureId__c =feRec.id,Parent_Product__c =prod.id,Bundle_Product__c=prod.id ,IsActive__c = true );
       insert ProlookRec;
       
       
       Product_Rule__c PrRec = new Product_Rule__c(Name ='Product Rule Test',Product__c = prod.id,Criteria__c= 'ProCriteria');
       insert PrRec;
       Product_Rule_Conditions__c  ProRuleRec =  new Product_Rule_Conditions__c(Product_Rule__c = PrRec.id,Lookup_Object_Field_API_Name__c = 'Travel_Offering_Type__c',Quote_Line_Field_API_Name__c ='Travel_Offering_Type__c',Sequence__c =2);
       //insert ProRuleRec;
       if(ProRuleRec != null){
           productRuleCondlist.add(ProRuleRec);
       }
       insert productRuleCondlist;
       if(ProRuleRec != null){
           mapOfIdAndCriteria.put(ProRuleRec.Product_Rule__c,ProRuleRec.Product_Rule__r.Criteria__c);
       }
       
       
       
       Test.startTest();
       QuoteConfigurationEditLine.getAllFeaturesFromProduct(proIds); 
       //if(qliRec.PricebookEntryId == standardPrice.id){
           QuoteConfigurationEditLine.ShowAllOptions(proIds,qliRec.Travel_Offering_Type__c,qliRec.Travel_Pricing_Type__c,qliRec.Account_Type__c);
           
      // } 
       QuoteConfigurationEditLine.PldOptions();
       //NewPaymentTermsCondtionController.getActivePaymentTermselectionItem();
       //PaymentTermApprover.calculateApproverAuthorityMatrix(TACList,mapIdAndTermConditiion);
       Test.stopTest();
   }
}
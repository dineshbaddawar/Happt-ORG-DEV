@isTest
public class ManageProductHandlerTest {
  @isTest(seeAllData=true)
  private static void insertProducts()
 {
     Account ac = TestUtility.createAccount('Test');
     Opportunity op = TestUtility.createOpportunity(ac);
     contact con  = TestUtility.createContact(ac);
          OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = op.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Other';
        insert ocr;
     
     OpportunityLineItem oli = TestUtility.createLineItem(op);
     
      Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true,
            Product_Pricing_Type__c = 'SAAS',
            Category__c ='Primary',
            Family='Expense Management' 
          
        );
        insert prod;
     
        Id pricebookId = Test.getStandardPricebookId();
  
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = prod.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
     
      List<Pricebook2> pblist = [SELECT Id, Name, IsActive, IsStandard FROM Pricebook2 where isActive = true and isStandard =true];
     
     System.debug('test pbList'+pblist);
     Product_Bundle__c  pb = new Product_Bundle__c();
     pb.Product__c = prod.id;
     pb.Bundle_Code__c = 'Test EM Happay Enterprise';
     pb.Offering__c = 'Standard Offering';
     pb.Sort_Order__c=1;
     pb.Is_Independent__c =true;
     Pb.Is_Pricing_Dependent__c = false;
     Insert pb;
     
     Product_Bundle__c childPb =new Product_Bundle__c();
     childPb.Product__c = prod.id;
     childPb.Bundle_Code__c = 'Test Child EM Happay Enterprise';
     childPb.Offering__c = 'Standard Offering';
     childPb.Sort_Order__c=1;
     childPb.Is_Independent__c =true;
     childPb.Parent_Product_Bundle__c =pb.id;
     childPb.Is_Pricing_Dependent__c = false;
     Insert childPb;
     
     
      Test.startTest();
     ManageProductHandler.getChildProducts(pb.id);
     ManageProductHandler.getPricingTypeDetails(prod.id);
     List<ManageProductHandler.wrapperClass> wpList = new List<ManageProductHandler.wrapperClass>();
     ManageProductHandler.wrapperClass wp = new ManageProductHandler.wrapperClass();
            wp.Product2Id = pb.Product__c;
            wp.ProName =pb.Product__r.Name;
            wp.family = pb.Product__r.Family;
            wp.category = pb.Product__r.Category__c;
            wp.pricingType = pb.Product__r.Product_Pricing_Type__c;
            wp.sortOrder=pb.Sort_Order__c;
            wp.Quantity =3;
            wp.Discount =3;
            wp.UnitPrice =100;
            wp.Is_Independent =true;
            wp.Is_Pricing_Dependent =false;
            wpList.add(wp);
        ManageProductHandler.upsertProducts(wpList , op.id , 'Opportunity' ,10,10);
        OpportunityLineItem item =TestUtility.createLineItem(op);
        ManageProductHandler.deleteProducts(item.id);
        ManageProductHandler.fetchLineItems(op.id);
     
        op.StageName ='Stage 2 (Validated)';
        update op;
        Quote qt = TestUtility.createQuote(op, 'Draft');
       ManageProductHandler.upsertProducts(wpList ,qt.id , 'Quote' ,10,10);
       ManageProductHandler.fetchLineItems(qt.id);
     QuoteLineItem qitem = new QuoteLineItem();
     qitem.QuoteId = qt.id;
    // qitem.Product2Id
    // insert qitem;
    //    ManageProductHandler.deleteProducts(qitem.id);
     Test.stopTest();
 }
    
    
}
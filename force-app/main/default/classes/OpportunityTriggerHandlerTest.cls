@isTest
public class OpportunityTriggerHandlerTest {
    /* @testSetup static void setup() 
{
Account ac = TestUtility.createAccount('Test Ac');
Opportunity stdOp = TestUtility.createOpportunity(ac); 
Quote q1 =TestUtility.createQuote(stdOp ,'Draft');
OpportunityLineItem oli = TestUtility.createLineItem(stdOp);

}*/
    
    @isTest
    static void updateOpportunity()
    { 
        Account ac = TestUtility.createAccount('Test Ac');
        system.debug(ac.Region__c);
        
        contact con  = TestUtility.createContact(ac);
        system.debug('con-email'+con.Email);
        
        Opportunity stdOp1 = TestUtility.createOpportunity(ac);
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = stdOp1.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Other';
        insert ocr;
        
        stdOp1.Total_User_Potential__c = 100;
        stdOp1.StageName = 'Stage 2 (Validated)';
        stdOp1.LG_User_Potential__c = 100;
        Opportunity__c custOp1 = TestUtility.createCustomOppo(stdOp1);
        CloneOpportunityHandler.IsFirstTime= true;
        update stdOp1;
        
        Quote q1 =TestUtility.createQuote(stdOp1 ,'Draft');
        stdOp1.SyncedQuoteId = q1.id; 
        
        OpportunityLineItem oli = TestUtility.createLineItem(stdOp1);
        stdOp1.StageName ='Stage 3 (Shortlisted)';
        stdOp1.Customer_Problem_Identified__c = '0';
        CloneOpportunityHandler.IsFirstTime= true;
        update stdOp1;
    }
    
    @isTest
    static void deleteOpportunity()
    {  
        Account ac = TestUtility.createAccount('Test Ac');
        Opportunity stdOp1 = TestUtility.createOpportunity(ac);
        Opportunity__c custOp1 = TestUtility.createCustomOppo(stdOp1);
        delete stdOp1;   
    }
    
    @isTest
    static void deleteOppLineItem()
    {  
        Account ac = TestUtility.createAccount('Test Ac');
        Opportunity stdOp1 = TestUtility.createOpportunity(ac);
        OpportunityLineItem oli = TestUtility.createLineItem(stdOp1);
        
        Opportunity__c custOp1 = TestUtility.createCustomOppo(stdOp1);
        CloneOpportunityHandler.IsFirstTime= true;
        custOp1.Implementation_cost_expected__c =100;
        update custOp1;
        OpportunityLineItem__c cOppLine =TestUtility.createCustomOppLine(custOp1 ,oli);
        delete oli; 
        delete stdOp1;   
    }
    
    @isTest
    static void updateOppLineItem()
    {  
        Account ac = TestUtility.createAccount('Test Ac');
        Opportunity stdOp1 = TestUtility.createOpportunity(ac);
        QuoteSyncUtil.isRunningTest = true; 
        OpportunityLineItem oli = TestUtility.createLineItem(stdOp1);
        Opportunity__c custOp1 = TestUtility.createCustomOppo(stdOp1);
        OpportunityLineItem__c cOppLine =TestUtility.createCustomOppLine(custOp1 ,oli);
        
        oli.Quantity = 10;
        
        CloneOpportunityHandler.IsFirstTime= true;
        update oli;  
    }
    
    
}
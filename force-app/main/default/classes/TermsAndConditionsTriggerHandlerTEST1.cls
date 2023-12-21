@isTest(SeeAllData=true)
public class TermsAndConditionsTriggerHandlerTEST1 {
    
    @isTest
    public static void  TestTerms1() {
        Account acc = new Account();
        acc.Name = 'Mukesh Test';
        insert acc;
        Opportunity opp = TestUtility1.CreateOpp('oppTest',acc.id,System.today(),'Draft');  
        
        Quote quoTRec = new Quote();
        quoTRec.name = 'STED';
        quoTRec.OpportunityId = opp.id;
        quoTRec.Travel_Total_SAAS__c = 4988;
        insert quoTRec;
            
        Product2 prod = new Product2();
        prod.Name = 'DFGHJ';
        insert prod;
        
        Term_Master__c termMas = new Term_Master__c();
        termMas.Name = 'Expense Policies-OtI';
        termMas.Product__c = prod.id;
        insert termMas;
        
        Term_Section_Line_Item__c termSec = new Term_Section_Line_Item__c();
        termSec.Name = 'Quartely Billing';
        termSec.Term_Master__c = termMas.id;
        insert termSec;
        
        Term_Attribute_Line_Item__c termAtt = new Term_Attribute_Line_Item__c();
        termAtt.Name = 'Quartely Billing';
        termAtt.Term_Section_Line_Item__c = termSec.id;
        insert termAtt;
        
        
        List<Terms_and_condition__c> tcList = new List<Terms_and_condition__c>(); 
        Terms_and_condition__c termRec = new Terms_and_condition__c();
        termRec.Quote__c = quoTRec.id;
        termRec.Term_Attribute_Line_Item__c  = termAtt.id;
        termRec.Term_Section_Line_Item__c = termSec.Id;
        tcList.add(termRec);
        insert tcList;
        TermsAndConditionsTriggerHandler.calculateARRBasedOnBillingType(tcList);
    }
}
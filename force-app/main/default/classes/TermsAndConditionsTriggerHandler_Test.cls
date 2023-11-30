@IsTest(SeeAllData=true)
public with sharing class TermsAndConditionsTriggerHandler_Test {
    @isTest
    public static void  TermsAndConditionsTriggerHandler_TestMethod() {
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

        List<Terms_and_condition__c> TACList = new List<Terms_and_condition__c>();
        map<id,Terms_and_condition__c> mapIdAndTermConditiion = new map<id,Terms_and_condition__c> ();
         string userid = testUser.id;
         Account acc = TestUtility1.createAccount('Account');
         string accid = acc.id;
         date  clsdate = system.Today();
         Opportunity opp = TestUtility1.CreateOpp('oppTest',accid,clsdate,'Closed Won');  
         string oppid = opp.id;
         Quote testQuote = TestUtility1.CreateQuote(oppid,'quoteTest',100000,100000,100000,100000);
         string testQuoteid = testQuote.id;
         Term_Section_Line_Item__c tsLRec  = TestUtility1.CreateTermSection('TestTerm');
         string tsLRecId = tsLRec.id;
         Term_Attribute_Line_Item__c talRec = TestUtility1.CreateTermAttributeLI('Quartely Billing',tsLRecId,True,True,userid);
         string talRecId = talRec.id;
         Approval_Matrix__c AMRec = TestUtility1.CreateApprovalMatrix('AppTest',True,userid,talRecId,profileid,True);
         string AMRecId = AMRec.id;
         Terms_and_condition__c TACRec = TestUtility1.CreateTermAndCondition(AMRecId,talRecId,tsLRecId,userid,testQuoteid);

         if(TACRec != null && TACRec.Billing_Type__c == 'Quartely Billing'){
            TACList.add(TACRec);
            mapIdAndTermConditiion.put(TACRec.id,TACRec);
         }

         Test.startTest();
         TermsAndConditionsTriggerHandler.calculateARRBasedOnBillingType(TACList);
            //PaymentTermApprover.calculateApproverAuthorityMatrix(TACList,mapIdAndTermConditiion);
            Test.stopTest();
           
    }
}
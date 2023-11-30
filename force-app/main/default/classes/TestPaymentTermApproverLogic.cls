@isTest
public class TestPaymentTermApproverLogic {
    
    @isTest
    static void testPaymentTermApproverLogic() {
        // Create a test user
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User testUser = new User(
            ProfileId = profile.Id,
            LastName = 'samAltman',
            Email = 'samaltman@mailianatore.com',
            UserName = 'sam@mailianatore.com',
            Alias = 'tuser',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser;
        string userid = testUser.id;
       Account acc = TestUtility1.createAccount('Account');
        string accid = acc.id;
        date  clsdate = system.Today();
        Opportunity opp = TestUtility1.CreateOpp('oppTest',accid,clsdate,'Closed Won');  
        string oppid = opp.id;
        Quote testQuote = TestUtility1.CreateQuote(oppid);
        Term_Section_Line_Item__c tsLRec  = TestUtility1.CreateTermSection('TestTerm');
        string tsLRecId = tsLRec.id;
        Term_Attribute_Line_Item__c talRec = TestUtility1.CreateTermAttributeLI('TestTerm',tsLRecId,True,True,userid);
         
        
        
        Term_Attribute_Line_Item__c testTermAttribute = new Term_Attribute_Line_Item__c(
            Approval_Authority__c = testUser.Id,
            Approved_By_Team_Lead__c = true,
            Approval_Required__c = True
        );
        insert testTermAttribute;
        
        list<Terms_and_condition__c>  termCondList = new list<Terms_and_condition__c>();
        Terms_and_condition__c testTermCondition = new Terms_and_condition__c(
            Quote__c = testQuote.Id,
            Term_Attribute_Line_Item__c = testTermAttribute.Id
         );
                
        termCondList.add(testTermCondition);
        insert termCondList;
         
        map<id,Terms_and_condition__c> mapofTerAndCondition = new  map<id,Terms_and_condition__c>();
        Terms_and_condition__c testTermCondition1 = new Terms_and_condition__c(
         //  Id = testTermCondition.id;
         );
        insert testTermCondition1;
        
        
       /* Approval_Matrix__c approvalMatrix = new Approval_Matrix__c();
       //approvalMatrix.Approval_Required__c = True;
        approvalMatrix.Approving_Authority__c = testUser.Id;
        approvalMatrix.Profiles__c  = profile.Id;
        approvalMatrix.Term_Attribute_Line_Item__c = testTermAttribute.id;
        insert approvalMatrix;*/
        
        
         {
            Test.startTest();
            PaymentTermApprover.paymentTermApproverLogic(testQuote.Id);
            TermsAndConditionsTriggerHandler.calculateARRBasedOnBillingType(termCondList);
            Test.stopTest();
            
            
        }
    }
}
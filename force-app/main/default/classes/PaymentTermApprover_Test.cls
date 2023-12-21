@IsTest 
public class PaymentTermApprover_Test {
    @isTest
    public static void TestMethods() {
       Profile profile = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        string profileid = profile.id;
        string profileName = profile.Name;
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
        
        User testUser1 = new User(
            ProfileId = profile.Id,
            LastName = 'Satyam',
            ManagerId = testUser.id,
            Email = 'satyam@mailinatore.com',
            UserName = 'satyam@mailinatore.com',
            Alias = 'satya',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'America/Los_Angeles'
        );
        insert testUser1; 
        
        string userid = testUser.id;
        Map<Id,Id> mapofUseridTermConditionid = new Map<Id,Id>();
        List<Approval_Matrix__c> approvallist = new List<Approval_Matrix__c>();
        List<Terms_and_condition__c> TACList = new List<Terms_and_condition__c>();
        map<id,Terms_and_condition__c> mapIdAndTermConditiion = new map<id,Terms_and_condition__c> ();
        
        
        
        Account acc = TestUtility1.createAccount('Account');
        // string accid = acc.id;
        date  clsdate = system.Today();
        Opportunity opp = New Opportunity(Name = 'oppTest',AccountId= acc.id,CloseDate =  clsdate, StageName = 'Closed Won', OwnerId =userid);  
        insert  opp;
        
        Quote testQuote = TestUtility1.CreateQuote(opp.id,'TestQuote',100000,100000,100000,100000);
        Quote updatetestQuote = new Quote();
        updatetestQuote.id = testQuote.id;
        updatetestQuote.Approver_Authority_Level1__c = testUser.id;
        updatetestQuote.Approver_Authority_Level2__c = testUser1.id;
        updatetestQuote.Status = 'Draft';
        update updatetestQuote;
        string testQuoteid = updatetestQuote.id;
        
        Term_Section_Line_Item__c tsLRec  = TestUtility1.CreateTermSection('TestTerm');
        string tsLRecId = tsLRec.id;
        Term_Attribute_Line_Item__c talRec = TestUtility1.CreateTermAttributeLI('TestTerm',tsLRecId,True,True,userid);
        string talRecId = talRec.id;
        String loggedInUserProfileName  = testUser.profile.name;
        Approval_Matrix__c AMRec = TestUtility1.CreateApprovalMatrix('AppTest',True,userid,talRecId,profileid,True);
        string AMRecId = AMRec.id;
        Terms_and_condition__c TACRec = TestUtility1.CreateTermAndCondition(AMRecId,talRecId,tsLRecId,userid,testQuoteid);
            TACList.add(TACRec);
            mapIdAndTermConditiion.put(TACRec.id,TACRec);
            mapofUseridTermConditionid.put(TACRec.id,testUser.id ); 
       
        Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
        // approvalRequest.setComments('Submitting request for payment term approval.');
        approvalRequest.setObjectId(updatetestQuote.id);
        approvalRequest.setNextApproverIds(new List<Id>{testUser.id});
        Approval.ProcessResult result = Approval.process(approvalRequest); 
        
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Some comments if needed');
        req.setAction('Approve');

        
        Test.startTest();
        PaymentTermApprover.paymentTermApproverLogic(updatetestQuote.id);
        PaymentTermApprover.calculateApproverAuthorityMatrix(TACList,mapIdAndTermConditiion); 
        PaymentTermApprover.updateAuthorityOnTermsAndCondition(mapofUseridTermConditionid);
        // PaymentTermApprover.codeCover();
        Test.stopTest();
    }
    
    
}
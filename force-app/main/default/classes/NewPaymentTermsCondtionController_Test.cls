@IsTest(SeeAllData=true)
public  class NewPaymentTermsCondtionController_Test {
    
    @isTest
    public static void calculateOTIANDSAASPriceTest() {
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
        
        List<Terms_and_condition__c> TACList = new List<Terms_and_condition__c>();
        map<id,Terms_and_condition__c> mapIdAndTermConditiion = new map<id,Terms_and_condition__c> ();
        string userid = testUser.id;
        Account acc = TestUtility1.createAccount('Account');
        // string accid = acc.id;
        date  clsdate = system.Today();
        Opportunity opp = TestUtility1.CreateOpp('oppTest',acc.id,clsdate,'Closed Won');  
        //  string oppid = opp.id;
        Quote testQuote = TestUtility1.CreateQuote(opp.id,'TestQuote',100000,100000,100000,100000);
        string testQuoteid = testQuote.id;
        Term_Section_Line_Item__c tsLRec  = TestUtility1.CreateTermSection('TestTerm');
        string tsLRecId = tsLRec.id;
        Term_Attribute_Line_Item__c talRec = TestUtility1.CreateTermAttributeLI('TestTerm',tsLRecId,True,True,userid);
        string talRecId = talRec.id;
        Approval_Matrix__c AMRec = TestUtility1.CreateApprovalMatrix('AppTest',True,userid,talRecId,profileid,True);
        string AMRecId = AMRec.id;
        Terms_and_condition__c TACRec = TestUtility1.CreateTermAndCondition(AMRecId,talRecId,tsLRecId,userid,testQuoteid);
        
        // Create a JSON string for the wrapper
        String wrapperJsonList = '[{"sectionLineItemKey":"' + tsLRec.Id + '","attributeLineItemValue":"' + talRec.Id + '","LatePaymentInterest":1.5,"attributeDescription":"Test Description","YoYPUPMReport_50_100":3.5,"pumaReportgreaterthan_100Map":4.5,"pumaReport20_ARRMap":5.5}]';
        
        // Create a JSON string for the description
        String descriptiontalidList = '[{"attributeLineId":"' + talRec.Id + '","attributeDescription":"Test Description"}]';
        
        String jsonString = '[{"quoteName":"'+testQuoteid+'","sectionLineItemKey":"a1LC20000011lXNMAY","attributeLineItemValue":"a1MC20000006UWTMA2"},{"quoteName":"'+testQuoteid+'","sectionLineItemKey":"a1LC20000011lU9MAI","attributeLineItemValue":"a1MC20000006UJZMA2"},{"quoteName":"'+testQuoteid+'","sectionLineItemKey":"a1LC2000001jRjRMAU","attributeLineItemValue":"a1MC2000000C8JZMA0"},{"quoteName":"'+testQuoteid+'","sectionLineItemKey":"a1LC20000011lSXMAY","attributeLineItemValue":"a1MC200"}]';

        
        NewPaymentTermsCondtionController.getActivePaymentTermselectionItem();
        NewPaymentTermsCondtionController.createTermasCondition(jsonString,testQuote.id,descriptiontalidList);
        NewPaymentTermsCondtionController.getExistingTermsConditions(testQuote.id);
        NewPaymentTermsCondtionController.codeCover();
    }
}
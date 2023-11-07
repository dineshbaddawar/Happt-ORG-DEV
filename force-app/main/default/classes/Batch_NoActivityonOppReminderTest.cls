@isTest 
public class Batch_NoActivityonOppReminderTest {
    
    static testMethod void excuteBatchMethod() 
    {
        Account ac = TestUtility.createAccount('Test');
        //Opportunity op = TestUtility.createOpportunity(ac);
        String oppJSON = '{"Name":"Test opp 1","CloseDate":"2021-06-30","StageName":"Stage 1 (Qualified)","CreatedDate":"2021-06-09T10:28:00+00:00","Email__c":"test.test@test.com","Mobile_Number__c":"9090909090","Phone_Number__c":"0202445566"}';
        Opportunity opp = (Opportunity) JSON.deserialize(oppJSON, Opportunity.class);
        Insert opp;
        List<Task> tc =  TestUtility.createTasksForOpp(opp);
        Test.startTest();
        
        Batch_NoActivityonOppReminder obj = new Batch_NoActivityonOppReminder();
        DataBase.executeBatch(obj); 
        
        Test.stopTest(); 
    }
}
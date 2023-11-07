@isTest
public class customLookupLWCControllerTest {
 
    @isTest
    private static void testMethods()
    {
        Account acct = new Account(Name = 'Test Account');
		insert acct;
        customLookupLWCController.fetchLookupData('Name' ,'Name','','Account','');
        customLookupLWCController.fetchDefaultRecord(acct.Id,'Name','Account','');
    }
}
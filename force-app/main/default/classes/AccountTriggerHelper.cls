public class AccountTriggerHelper {

    public static void onAfterInsert(List<Account> newList) {
        AccountTeamAssignemnt.AccountTeamCreation(newList);
    }
    
    public static void AccountAssignment(List<Account> newList) {
        //LeadAssignmentController.addTeamMembers(newList);
    }
}
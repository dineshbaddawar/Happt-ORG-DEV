public class AccountTriggerModel {
    
    public static List<GroupMember> getGroupMembersOfProducts() {
        return [Select Id, Group.Name, GroupId, UserOrGroupId 
                from GroupMember where Group.Name like '%Employee Tax Benefits%' OR  Group.Name like '%Travel & Expense (T&E)%'];
    }

}
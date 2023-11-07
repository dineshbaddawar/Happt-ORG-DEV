public class TreeNodeDataProvider {
    @AuraEnabled public static UserRole[] getUserRoles() {
        return [SELECT Name, ParentRoleId FROM UserRole];
    }
}
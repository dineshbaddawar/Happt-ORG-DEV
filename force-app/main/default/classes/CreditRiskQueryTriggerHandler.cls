public class CreditRiskQueryTriggerHandler {

    public static void onBeforeUpdate(Map<Id, Credit_Risk_Query__c> newMap, Map<Id, Credit_Risk_Query__c> oldMap) {        
        Set<Id> creditUsers 		= new Set<Id>();
        for(GroupMember gmObj : [Select Id,UserOrGroupId from GroupMember where Group.DeveloperName = 'Credit_Risk_User']) {
            creditUsers.add(gmObj.UserOrGroupId);
        }
        
        for(Credit_Risk_Query__c creditRiskObj : newMap.values()) {
            if(creditRiskObj.Status__c != oldMap.get(creditRiskObj.Id).Status__c && creditRiskObj.Status__c == 'Resolved' &&
               !creditUsers.contains(UserInfo.getUserId())) {
                creditRiskObj.addError('You do not have permission to update status as Resolved.');
            }
        }
    }
}
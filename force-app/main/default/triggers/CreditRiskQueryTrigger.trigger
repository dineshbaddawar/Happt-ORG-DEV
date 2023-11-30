trigger CreditRiskQueryTrigger on Credit_Risk_Query__c (before update) {

    if(Trigger.isUpdate && Trigger.isBefore) CreditRiskQueryTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
}
trigger LeadTrigger on Lead (after insert, before update, after update) {

    if(Trigger.isInsert && Trigger.isAfter) {
    	LeadTriggerHandler.onAfterInsert(Trigger.new);
    }
    
    if(Trigger.isUpdate && Trigger.isBefore) {
    	LeadTriggerHandler.onBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        LeadTriggerHandler.checkMandatoryFields(Trigger.new, Trigger.newMap);
     }
    
}
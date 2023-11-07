trigger AccountTrigger on Account (after insert,before Insert) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        AccountTriggerHelper.onAfterInsert(Trigger.New);
        //LeadAssignmentController.assignaccs(Trigger.New);
    } 
    if(Trigger.isInsert && Trigger.isBefore){
        //AccountTriggerHelper.onAfterInsert(Trigger.New);
//        LeadAssignmentController.assignaccs(Trigger.New);
    }
}
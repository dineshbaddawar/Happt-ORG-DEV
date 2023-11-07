trigger TaskTrigger on Task (before insert, after insert) {
    if (Trigger.IsInsert )
    {   
        
        if(Trigger.isBefore){
            TaskHandler.markCustomOpportunityonTask(Trigger.new);
        }
        else{
            TaskHandler.chnageLeadStatus(Trigger.new);
        }
    }
}
trigger OpportunityTrigger on Opportunity (after insert,after update,before delete,before Insert,before update) {
    
    Boolean isBeforeInsert = Trigger.IsBefore && Trigger.IsInsert;
    Boolean isBeforeUpdate = Trigger.IsBefore && Trigger.IsUpdate;
    Boolean isAfterInsert = Trigger.IsAfter &&Trigger.IsInsert;
    Boolean isAfterUpdate = Trigger.IsUpdate && Trigger.isAfter;
    
    if(isBeforeInsert)
    {
        OpportunityTriggerHandler.AssOwner(Trigger.new);
        OpportunityTriggerHandler.callSetPricebook(Trigger.new);
        OpportunityTriggerHandler.setOppName(Trigger.new);
    }
    else if(isBeforeUpdate)
    {
        //OpportunityTriggerHandler.setOppName(Trigger.new);
        OpportunityTriggerHandler.setLastStageChangedDate(Trigger.new,trigger.oldMap);
        OpportunityTriggerHandler.commercialCalculation(Trigger.new);
        OpportunityTriggerHandler.onBeforeUpdate(Trigger.new,Trigger.oldMap);
    }
    else if ( isAfterInsert) {   
        OpportunityTriggerHandler.onAfterInsert(Trigger.new);
        OpportunityTriggerHandler.pmToolUtility(trigger.newMap, trigger.oldMap);        
        CloneOpportunityHandler.callCustOpp(trigger.new);    
    }
    else if(isAfterUpdate){       
        if(Trigger.new[0].Finished__c && Trigger.new[0].Finished__c != Trigger.oldMap.get(Trigger.new[0].Id).Finished__c)
        OpportunityTriggerHandler.AssOppTeamMember(Trigger.New);
      //  OpportunityTriggerHandler.onAfterUpdate(Trigger.newMap, Trigger.oldMap);
        if(CloneOpportunityHandler.IsFirstTime){
            CloneOpportunityHandler.IsFirstTime=false;
            CloneOpportunityHandler.updateCloneOpp(Trigger.new, Trigger.oldMap);
        }
        OpportunityTriggerHandler.syncOppToQuote(trigger.new,trigger.oldMap);
    }
    
    else if(Trigger.IsDelete){   
        CloneOpportunityHandler.calldeleteOpp(Trigger.old);
    }
}
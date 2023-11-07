trigger CustomOpportunityTrigger on Opportunity__c (after update ,after Insert) {  
    
   /* if(!ProcessSwitches__c.getInstance().CustOpportunityTrigger__c) {
         System.debug('Bypassing trigger due to custom setting');
         return;
     }*/

    if(Trigger.IsUpdate){
        if(CloneOpportunityHandler.IsFirstTime){// Only Executed when IsFirstTime = true
            CloneOpportunityHandler.IsFirstTime=false;
         //   CloneOpportunityHandler.callCustOppUpdate(Trigger.new ,Trigger.oldMap);
          
            CloneOpportunityHandler.updateStdOpp(Trigger.new, Trigger.oldMap);
        }    
    }
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
         CloneOpportunityHandler.callSyncTask(trigger.new);
    }
    
    
}
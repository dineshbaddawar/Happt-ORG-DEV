trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert,after update,before delete) {

   /* if(!ProcessSwitches__c.getInstance().CustOpportunityTrigger__c) {
        System.debug('Bypassing trigger due to custom setting');
        return;
    }*/
    
   if (trigger.isBefore && trigger.isInsert) {
        if (QuoteSyncUtil.isRunningTest) {
            for (OpportunityLineItem oli : trigger.new) {
                QuoteSyncUtil.populateRequiredFields(oli);
            }
        }    
        return;
    }
    
    if (Trigger.IsInsert )
    {   
       // OpportunityLineItemHandler.callItemInsert(Trigger.new);
       CloneOpportunityHandler.callCustOppLine(Trigger.new);
       OpportunityLineItemHandler.syncOpLineToQuote(Trigger.new, Trigger.oldMap);
    }
    
    else if(Trigger.IsUpdate)
    {
       System.debug('CloneOpportunityHandler.IsFirstTime'+CloneOpportunityHandler.IsFirstTime);
         if(CloneOpportunityHandler.IsFirstTime){// Only Executed when IsFirstTime = true
            CloneOpportunityHandler.IsFirstTime=false;
           // OpportunityLineItemHandler.callItemUpdate(Trigger.new, Trigger.oldMap); 
           CloneOpportunityHandler.updateCloneLineItem(Trigger.new, Trigger.oldMap);          
        }
        OpportunityLineItemHandler.syncOpLineToQuote(Trigger.new, Trigger.oldMap);
    }
    
    else if(Trigger.IsDelete){
        CloneOpportunityHandler.callItemDelete(Trigger.old);
    }
}
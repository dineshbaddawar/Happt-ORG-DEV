trigger CustomOpportunityLineItemTrigger on OpportunityLineItem__c (after update) {
    
    if(!ProcessSwitches__c.getInstance().CustomOpportunityLineItemsTrigger__c) {
        System.debug('Bypassing trigger due to custom setting');
        return;
    }
    /*if(Trigger.IsUpdate){
        if(OpportunityLineItemHandler.IsFirstTime){// Only Executed when IsFirstTime = true
            OpportunityLineItemHandler.IsFirstTime=false;
//            OpportunityLineItemHandler.callCustomItemUpdate(Trigger.new, Trigger.oldMap);              
        }
    }*/
}
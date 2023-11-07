trigger QuoteLineTrigger on QuoteLineItem (After insert,After Update,After delete) {
    
    if(Trigger.isInsert && Trigger.isAfter){
        //QuoteLineItemTrigger.TotalCalculationOnInsert(Trigger.new);
       CalculateQuoteDetails.calculateOTIANDSAASPrice(Trigger.new);
       //QuoteLineItemTrigger.InsertQuoteLineItemExpense(Trigger.new); 
    }
    if(Trigger.isUpdate && Trigger.isAfter){
       //QuoteLineItemTrigger.TotalCalCulationOnUpdate(Trigger.newMap,Trigger.oldMap); 
       CalculateQuoteDetails.calculateOTIANDSAASPrice(Trigger.new);
    }
    if(Trigger.isdelete && Trigger.isAfter){
         QuoteLineItemTrigger.UpdatequoteAfterDelete(Trigger.old); 
    }

}
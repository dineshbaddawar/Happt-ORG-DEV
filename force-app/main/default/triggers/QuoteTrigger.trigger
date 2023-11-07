trigger QuoteTrigger on Quote (After Update) {
    
    if(Trigger.IsUpdate && Trigger.IsAfter){
        quoteDiscountApproval.QuoteOverallOTIxSAASA(Trigger.newMap,Trigger.oldMap);
    }

}
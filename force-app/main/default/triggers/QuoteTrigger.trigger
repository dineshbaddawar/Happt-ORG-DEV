trigger QuoteTrigger on Quote (before Update) {
    
    if(Trigger.IsUpdate && Trigger.IsBefore){
        quoteDiscountApproval.calculateTheOverallDiscount(trigger.new,trigger.oldMap);
        quoteDiscountApproval.QuoteOverallOTIxSAASA(Trigger.newMap,Trigger.oldMap);
        quoteDiscountApproval.finallizedAprovalAuthority(Trigger.new,Trigger.oldMap);
    }

}
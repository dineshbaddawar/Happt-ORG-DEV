trigger QuoteTrigger on Quote (before Update,after update) {
    
    if(Trigger.IsUpdate && Trigger.IsBefore){
        quoteDiscountApproval.calculateTheOverallDiscount(trigger.new,trigger.oldMap);
        quoteDiscountApproval.QuoteOverallOTIxSAASA(Trigger.newMap,Trigger.oldMap);
        quoteDiscountApproval.finallizedAprovalAuthority(Trigger.new,Trigger.oldMap);
    }
    if(trigger.isAfter && trigger.isUpdate){
        SendOrderEmailAttachementHelper.SendOrderFormWithAttachmentEmail(trigger.newMap,trigger.oldMap);
        SendOrderEmailAttachementHelper.sendOrderApprovedEmail(trigger.newMap,trigger.oldMap);
    }

}
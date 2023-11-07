trigger QuoteLineSyncTrigger on QuoteLineItem (before insert, after insert, after update) {
 
    if (trigger.isBefore && trigger.isInsert) { 
        if (QuoteSyncUtil.isRunningTest) {
            for (QuoteLineItem qli : trigger.new) {
                QuoteSyncUtil.populateRequiredFields(qli);
            }
        }    
        return;
    } 
  
   if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate))
   {
       QuoteHandler.quoteLineSync(Trigger.new , Trigger.oldMap);
   }
}
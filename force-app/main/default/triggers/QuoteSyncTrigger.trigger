trigger QuoteSyncTrigger on Quote (after insert, after update) {
  if(Trigger.isAfter && (Trigger.isInsert))
  {
      QuoteHandler.quoteSync(Trigger.new, Trigger.oldMap);
  }
    if(Trigger.isAfter && (Trigger.isUpdate))
    {
        QuoteHandler.quoteSync(Trigger.new, Trigger.oldMap);
         
    }
 
    
}
public class OpportunityLineItemHandler {
	public static Boolean IsFirstTime = true;
    public static void syncOpLineToQuote(List<OpportunityLineItem> newProList, Map<Id, OpportunityLineItem> oldProMap)
    {
         if (TriggerStopper.stopOppLine) return;
       
    Set<String> quoteLineFields = QuoteSyncUtil.getQuoteLineFields();
    List<String> oppLineFields = QuoteSyncUtil.getOppLineFields();
    
    String qliFields = QuoteSyncUtil.getQuoteLineFieldsString();
    
    String oliFields =  QuoteSyncUtil.getOppLineFieldsString();
    
    String oliIds = '';
    for (OpportunityLineItem oli : newProList) {
        if (oliIds != '') oliIds += ', ';
        oliIds += '\'' + oli.Id + '\'';
    }

    String oliQuery = 'select Id, OpportunityId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + oliFields + ' from OpportunityLineItem where Id in (' + oliIds + ') order by OpportunityId, SortOrder ASC';
    //System.debug(oliQuery); 
     
    List<OpportunityLineItem> olis = Database.query(oliQuery);
    
    Map<Id, List<OpportunityLineItem>> oppToOliMap = new Map<Id, List<OpportunityLineItem>>();    
    
    for (OpportunityLineItem oli : olis) {
        List<OpportunityLineItem> oliList = oppToOliMap.get(oli.OpportunityId);
        if (oliList == null) {
            oliList = new List<OpportunityLineItem>();
        } 
        oliList.add(oli);  
        oppToOliMap.put(oli.OpportunityId, oliList);       
    }

    Set<Id> oppIds = oppToOliMap.keySet();
    Map<Id, Opportunity> opps = new Map<Id, Opportunity>([select id, SyncedQuoteId from Opportunity where Id in :oppIds and SyncedQuoteId != null]);
    
    String quoteIds = '';
    for (Opportunity opp : opps.values()) {
        if (opp.SyncedQuoteId != null) {
           if (quoteIds != '') quoteIds += ', ';
           quoteIds += '\'' + opp.SyncedQuoteId + '\'';         
        }
    }
    sync(quoteIds , qliFields ,opps ,oppToOliMap,oldProMap,quoteLineFields);
    
    }
    
    public static void sync(String quoteIds ,
                                 String qliFields ,
                                 Map<Id, Opportunity> opps,
                                 Map<Id, List<OpportunityLineItem>> oppToOliMap,
                                 Map<Id, OpportunityLineItem> oldProMap,
                                Set<String> quoteLineFields)
    {
        
        if (quoteIds != '') {
           
        String qliQuery = 'select Id, QuoteId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + qliFields + ' from QuoteLineItem where QuoteId in (' + quoteIds + ') order by QuoteId, SortOrder ASC';   
        //System.debug(qliQuery);    
               
        List<QuoteLineItem> qlis = Database.query(qliQuery);
        
        Map<Id, List<QuoteLineItem>> quoteToQliMap = new Map<Id, List<QuoteLineItem>>();
        
        for (QuoteLineItem qli : qlis) {
            List<QuoteLineItem> qliList = quoteToQliMap.get(qli.QuoteId);
            if (qliList == null) {
                qliList = new List<QuoteLineItem>();
            } 
            qliList.add(qli);  
            quoteToQliMap.put(qli.QuoteId, qliList);       
        }
             
        Set<QuoteLineItem> updateQlis = new Set<QuoteLineItem>();
        Set<OpportunityLineItem> updateOlis = new Set<OpportunityLineItem>();
                        
        method1(opps ,quoteToQliMap ,oppToOliMap ,oldProMap,updateQlis,quoteLineFields,updateOlis);

        TriggerStopper.stopOpp = true;
        TriggerStopper.stopQuote = true;        
        TriggerStopper.stopOppLine = true;        
        TriggerStopper.stopQuoteLine = true;    
                    
        if (!updateOlis.isEmpty()) {  
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            oliList.addAll(updateOlis);
                           
            Database.update(oliList);              
        }
        
        if (!updateQlis.isEmpty()) { 
            List<QuoteLineItem> qliList = new List<QuoteLineItem>();   
            qliList.addAll(updateQlis);
                          
            Database.update(qliList);            
        }                             
        
        TriggerStopper.stopOpp = false;
        TriggerStopper.stopQuote = false;         
        TriggerStopper.stopOppLine = false;          
        TriggerStopper.stopQuoteLine = false; 
    }
    }
    
    public static void method1(Map<Id, Opportunity> opps ,
                               Map<Id, List<QuoteLineItem>> quoteToQliMap ,
                               Map<Id, List<OpportunityLineItem>> oppToOliMap,
                               Map<Id, OpportunityLineItem> oldProMap,
                               Set<QuoteLineItem> updateQlis,
                              Set<String> quoteLineFields,
                               Set<OpportunityLineItem> updateOlis)
    {
       for (Opportunity opp : opps.values()) {  
        
            List<QuoteLineItem> quotelines = quoteToQliMap.get(opp.SyncedQuoteId);  
            
            // for opp line insert, there will not be corresponding quote line
            if (quotelines == null) continue;      
        
            Set<QuoteLineItem> matchedQlis = new Set<QuoteLineItem>();        
        
            for (OpportunityLineItem oli : oppToOliMap.get(opp.Id)) {
 
                boolean updateQli = false;
                OpportunityLineItem oldOli = null;
                
                if (trigger.isUpdate) {
                    //System.debug('Old oli: ' + oldOli.UnitPrice + ', ' + oldOli.Quantity + ', ' + oldOli.Discount + ', ' + oldOli.ServiceDate);
                    //System.debug('New oli: ' + oli.UnitPrice + ', ' + oli.Quantity + ', ' + oli.Discount + ', ' + oli.ServiceDate);
                                 
                    oldOli = oldProMap.get(oli.Id);
                    boolean olicheck = oli.UnitPrice == oldOli.UnitPrice
                        && oli.Quantity == oldOli.Quantity
                        && oli.Discount == oldOli.Discount
                        && oli.ServiceDate == oldOli.ServiceDate
                        && oli.SortOrder == oldOli.SortOrder ;
                    if (olicheck)
                        updateQli = true;  
                }
                                                   
                boolean hasChange = false;
                boolean match = false;
                
                
                for (QuoteLineItem qli : quotelines) {
                    boolean QlineQliCheck = oli.pricebookentryid == qli.pricebookentryId 
                        && oli.UnitPrice == qli.UnitPrice 
                        && oli.Quantity == qli.Quantity 
                        && oli.Discount == qli.Discount
                        && oli.ServiceDate == qli.ServiceDate
                        && oli.SortOrder == qli.SortOrder;
                    if (QlineQliCheck) {                      
                        if (updateQlis.contains(qli) || matchedQlis.contains(qli)) continue;
                        
                        matchedQlis.add(qli);                                                    
                                                                               
                        for (String qliField : quoteLineFields) {
                            String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                            Object oliValue = oli.get(oliField);                          
                            Object qliValue = qli.get(qliField);
                            boolean isUpdateAndNotUpdateQli = trigger.isUpdate && !updateQli;
                            boolean isUpdateAndUpdateQli = trigger.isUpdate && updateQli;
                            
                            if (oliValue != qliValue) { 
                                                        
                                if (trigger.isInsert) {
                                    if (qliValue == null) oli.put(oliField, null);
                                    else oli.put(oliField, qliValue);
                                    hasChange = true;

                                } else if (isUpdateAndNotUpdateQli /*&& oldOli != null*/) {
                                    //Object oldOliValue = oldOli.get(oliField); 
                                    //if (oliValue == oldOliValue) {                                    
                                        if (qliValue == null) oli.put(oliField, null);
                                        else oli.put(oliField, qliValue);
                                        hasChange = true;
                                    //}    
                                                                        
                                } else if (isUpdateAndUpdateQli) {
                                    if (oliValue == null) qli.put(qliField, null);
                                    else qli.put(qliField,  oliValue);
                                    hasChange = true;
                                }
                            }
                        }
                        if (hasChange) {
                            boolean isInsertOrUpdateAndupdateQli = trigger.isInsert || (trigger.isUpdate && !updateQli);
                            boolean chnagedUpdateAndupdateQli = trigger.isUpdate && updateQli;
                            if (isInsertOrUpdateAndupdateQli) { 
                                updateOlis.add(oli);
                            } else if (chnagedUpdateAndupdateQli) { 
                                updateQlis.add(qli);
                            }                    
                        }
                        
                        match = true;                       
                        break;                
                    } 
                }
                //something();                                                
                // NOTE: this cause error when there is workflow field update that fired during record create
                //if (trigger.isUpdate && updateQli) System.assert(match, 'No matching quoteline');     
            }
        } 
    }
}
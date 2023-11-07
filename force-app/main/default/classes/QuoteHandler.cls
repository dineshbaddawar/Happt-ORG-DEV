public class QuoteHandler {
    
    public static void quoteSync(List<Quote> quoteList, Map<id , Quote> oldQuote)
    {
        if (TriggerStopper.stopQuote) return;
        
        TriggerStopper.stopQuote = true;    
        
        Set<String> quoteFields = QuoteSyncUtil.getQuoteFields();
        List<String> oppFields = QuoteSyncUtil.getOppFields();
        
        String quote_fields = QuoteSyncUtil.getQuoteFieldsString();
        
        String opp_fields = QuoteSyncUtil.getOppFieldsString();
        
        system.debug('quote_fields -- ' + quote_fields);
        Map<Id, Id> startSyncQuoteMap = new Map<Id, Id>();
        String quoteIds = '';
        
        for (Quote quote : quoteList) {
            boolean SyncandOldsync = quote.isSyncing && !oldQuote.get(quote.Id).isSyncing;
            if (SyncandOldsync) {
                startSyncQuoteMap.put(quote.Id, quote.OpportunityId);
            }
            
            if (quoteIds != '') quoteIds += ', ';
            quoteIds += '\'' + quote.Id + '\'';
        }
        
        String quoteQuery = 'select Id, OpportunityId, isSyncing' + quote_fields + ' from Quote where Id in (' + quoteIds + ')';
        //System.debug(quoteQuery);     
        
        List<Quote> quotes = Database.query(quoteQuery);
        
        String oppIds = '';    
        Map<Id, Quote> quoteMap = new Map<Id, Quote>();
        
        for (Quote quote : quotes) {
            boolean InsertOrUpdateSync = trigger.isInsert || (trigger.isUpdate && quote.isSyncing);
            if (InsertOrUpdateSync) {
                quoteMap.put(quote.OpportunityId, quote);
                if (oppIds != '') oppIds += ', ';
                oppIds += '\'' + quote.opportunityId + '\'';            
            }
        }
        
        if (oppIds != '') {
            String oppQuery = 'select Id, HasOpportunityLineItem' + opp_fields + ' from Opportunity where Id in (' + oppIds + ')';
            //System.debug(oppQuery);     
            
            List<Opportunity> opps = Database.query(oppQuery);
            List<Opportunity> updateOpps = new List<Opportunity>();
            List<Quote> updateQuotes = new List<Quote>();        
            
            for (Opportunity opp : opps) {
                Quote quote = quoteMap.get(opp.Id);
                boolean InsertAndoppHasOpportunityLineItem =trigger.isInsert && opp.HasOpportunityLineItem;
                // store the new quote Id if corresponding opportunity has line items
                if (InsertAndoppHasOpportunityLineItem) {
                    QuoteSyncUtil.addNewQuoteId(quote.Id);
                }
                
                boolean hasChange = false;
                for (String quoteField : quoteFields) {
                    String oppField = QuoteSyncUtil.getQuoteFieldMapTo(quoteField);
                    Object oppValue = opp.get(oppField);
                    Object quoteValue = quote.get(quoteField);
                    if (oppValue != quoteValue) {                   
                        if (trigger.isInsert && (quoteValue == null || (quoteValue instanceof Boolean && !Boolean.valueOf(quoteValue)))) {
                            quote.put(quoteField, oppValue);
                            hasChange = true;                          
                        } else if (trigger.isUpdate) {
                            if (quoteValue == null) opp.put(oppField, null);
                            else opp.put(oppField, quoteValue);
                            hasChange = true;                          
                        }                    
                    }                     
                }    
                if (hasChange) {
                    if (trigger.isInsert) { 
                        updateQuotes.add(quote);
                    } else if (trigger.isUpdate) {
                        updateOpps.add(opp);                
                    }               
                }                                  
            } 
            
            system.debug('updateQuotes -- ' + updateQuotes);
            
            if (trigger.isInsert) {
                Database.update(updateQuotes);
            } else if (trigger.isUpdate) {
                TriggerStopper.stopOpp = true; 
                system.debug('Hello am inside Quote Trigger');
                Database.update(updateOpps);
                TriggerStopper.stopOpp = false;              
            }    
        }
        
        TriggerStopper.stopQuote = false;
    }
    
    public static void quoteLineSync(List<QuoteLineItem> quoteLineList , Map<id, QuoteLineItem> oldQuoteLine)
    {
        if (TriggerStopper.stopQuoteLine) return;
        
        Set<String> quoteLineFields = QuoteSyncUtil.getQuoteLineFields();
        List<String> oppLineFields = QuoteSyncUtil.getOppLineFields();
        
        String qliFields = QuoteSyncUtil.getQuoteLineFieldsString();
        
        String oliFields = QuoteSyncUtil.getOppLineFieldsString();
        
        String qliIds = '';
        for (QuoteLineItem qli : quoteLineList) {
            if (qliIds != '') qliIds += ', ';
            qliIds += '\'' + qli.Id + '\'';
        }
        
        String qliQuery = 'select Id, QuoteId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + qliFields + ' from QuoteLineItem where Id in (' + qliIds + ') order by QuoteId, SortOrder ASC';
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
        
        Set<Id> quoteIds = quoteToQliMap.keySet();
        Map<Id, Quote> quotes = new Map<Id, Quote>([select id, OpportunityId, isSyncing,CreatedDate from Quote where Id in :quoteIds]);
        
        DateTime dtNow = System.now();
        DateTime dtNow5 = dtNow.addSeconds(-5);
        
        
        String oppIds = '';
        Set<Id> filterQuoteIds = new Set<Id>();
        for (Quote quote : quotes.values()) {
            // Only sync quote line item that are inserted for a new Quote or on a isSyncing Quote
            //if ((trigger.isInsert && QuoteSyncUtil.isNewQuote(quote.Id)) || quote.isSyncing) {
            if ((trigger.isInsert && (quote.CreatedDate > dtNow5)) || quote.isSyncing) {
                if (oppIds != '') oppIds += ', ';
                oppIds += '\'' + quote.OpportunityId + '\'';         
            } else {
                filterQuoteIds.add(quote.Id);
            }
        }
        
        //System.debug('Filter quote ids: ' + filterQuoteIds);
        
        quoteIds.removeAll(filterQuoteIds);
        for (Id id : filterQuoteIds) {
            quotes.remove(id);
            quoteToQliMap.remove(id);
        }   
        
        if (oppIds != '') {   
            String oliQuery = 'select Id, OpportunityId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + oliFields + ' from OpportunityLineItem where OpportunityId in (' + oppIds + ') order by OpportunityId, SortOrder ASC';   
            //System.debug(qliQuery);    
            
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
            
            Set<OpportunityLineItem> updateOlis = new Set<OpportunityLineItem>();
            Set<QuoteLineItem> updateQlis = new Set<QuoteLineItem>();
            
            for (Quote quote : quotes.values()) {
                
                List<OpportunityLineItem> opplines = oppToOliMap.get(quote.OpportunityId);
                
                // for quote line insert, there will not be corresponding opp line
                if (opplines == null) continue;        
                
                Set<OpportunityLineItem> matchedOlis = new Set<OpportunityLineItem>();
                
                for (QuoteLineItem qli : quoteToQliMap.get(quote.Id)) {
                    
                    boolean updateOli = false;
                    QuoteLineItem oldQli = null;
                    
                    if (trigger.isUpdate) {
                        oldQli = oldQuoteLine.get(qli.Id);
                        //System.debug('Old qli: ' + oldQli.UnitPrice + ', ' + oldQli.Quantity + ', ' + oldQli.Discount + ', ' + oldQli.ServiceDate);
                        //System.debug('New qli: ' + qli.UnitPrice + ', ' + qli.Quantity + ', ' + qli.Discount + ', ' + qli.ServiceDate);
                        boolean qliChangeCheck = qli.UnitPrice == oldQli.UnitPrice
                            && qli.Quantity == oldQli.Quantity
                            && qli.Discount == oldQli.Discount
                            && qli.ServiceDate == oldQli.ServiceDate
                            && qli.SortOrder == oldQli.SortOrder;
                        
                        if (qliChangeCheck)
                            updateOli = true;                       
                    }
                    
                    
                    boolean hasChange = false;
                    boolean match = false;
                    
                    for (OpportunityLineItem oli : opplines) {
                        boolean oliChageCheck = oli.pricebookentryid == qli.pricebookentryId  
                            && oli.UnitPrice == qli.UnitPrice
                            && oli.Quantity == qli.Quantity
                            && oli.Discount == qli.Discount
                            && oli.ServiceDate == qli.ServiceDate
                            && oli.SortOrder == qli.SortOrder;
                        
                        if (oliChageCheck) {                        
                            if (updateOlis.contains(oli) || matchedOlis.contains(oli)) continue;  
                            
                            matchedOlis.add(oli);                       
                            
                            for (String qliField : quoteLineFields) {
                                String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                                Object oliValue = oli.get(oliField);
                                Object qliValue = qli.get(qliField);
                                if (oliValue != qliValue) { 
                                    boolean InsertQliCheck = trigger.isInsert && (qliValue == null || (qliValue instanceof Boolean && !Boolean.valueOf(qliValue)));
                                    boolean elseUpdateNotupdateOliCheck = trigger.isUpdate && !updateOli;
                                    boolean elseUpdateupdateOliCheck = trigger.isUpdate && updateOli;
                                    if (InsertQliCheck) {
                                        
                                        //System.debug('Insert trigger, isSyncing: ' + quote.isSyncing + ', new quote ids: ' + QuoteSyncUtil.getNewQuoteIds());
                                        
                                        // If it's a newly created Quote, don't sync the "Description" field value, 
                                        // because it's already copied from Opportunity Line Item on create. 
                                        //if (quote.isSyncing || (QuoteSyncUtil.isNewQuote(quote.Id) && !qliField.equalsIgnoreCase('description'))) {  
                                        boolean syncQuoteCheck = quote.isSyncing || ((quote.CreatedDate > dtNow5) && !qliField.equalsIgnoreCase('description'));
                                        
                                        if (syncQuoteCheck) {
                                            qli.put(qliField, oliValue);
                                            hasChange = true; 
                                        }    
                                        
                                    } else if (elseUpdateNotupdateOliCheck /*&& oldQli != null*/) {
                                        //Object oldQliValue = oldQli.get(qliField);
                                        //if (qliValue == oldQliValue) {
                                        if (oliValue == null) qli.put(qliField, null);
                                        else qli.put(qliField, oliValue);
                                        hasChange = true;
                                        //}     
                                        
                                    } else if (elseUpdateupdateOliCheck) {
                                        if (qliValue == null) oli.put(oliField, null);
                                        else oli.put(oliField, qliValue);
                                        hasChange = true;  
                                    }
                                }    
                            }
                            
                            if (hasChange) {
                                boolean InsertORUpdateAndupdateOlicheck = trigger.isInsert || (trigger.isUpdate && !updateOli);
                                boolean UpdateAndupdateOlicheck = trigger.isUpdate && updateOli;
                                if (InsertORUpdateAndupdateOlicheck) { 
                                    updateQlis.add(qli);
                                } else if (UpdateAndupdateOlicheck) {                               
                                    updateOlis.add(oli);
                                }                    
                            } 
                            
                            match = true;      
                            break;                          
                        } 
                    }
                    
                    // NOTE: this cause error when there is workflow field update that fired during record create
                    //if (trigger.isUpdate && updateOli) System.assert(match, 'No matching oppline');     
                }
            }
            
            TriggerStopper.stopOpp = true;
            TriggerStopper.stopQuote = true;             
            TriggerStopper.stopOppLine = true;
            TriggerStopper.stopQuoteLine = true;    
            
            if (!updateOlis.isEmpty()) { 
                List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                oliList.addAll(updateOlis);
                
                Database.update(olilist);              
            }
            
            if (!updateQlis.isEmpty()) {
                List<QuoteLineItem> qliList = new List<QuoteLineItem>();   
                qliList.addAll(updateQlis);
                
                Database.update(qliList);            
            }
            
            if (Trigger.isInsert) {
                QuoteSyncUtil.removeAllNewQuoteIds(quoteIds);
            }                             
            
            TriggerStopper.stopOpp = false;
            TriggerStopper.stopQuote = false;                
            TriggerStopper.stopOppLine = false;          
            TriggerStopper.stopQuoteLine = false;           
        }    
    }
    

}
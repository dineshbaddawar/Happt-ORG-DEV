public class OpportunityTriggerHandler {
    
    public static void AssOwner(List<Opportunity> newList) {
        OpportunityAssignmentController.assignOwnerHelper(newList);
    }
    
    public static void AssOppTeamMember(List<Opportunity> newList) {
        //OpportunityAssignmentController.assignOppTeamMembers(newList);
    }
    
    public static void onBeforeInsert(List<Opportunity> newList) {
        OpportunityTriggerService.updateOwner(newList);
    }
    
    public static void assignOpp(List<Opportunity> newList) {
        OpportunityTriggerService.updateOwner(newList);
    }
    
    public static void onAfterInsert(List<Opportunity> newList) {
        //OpportunityTriggerService.createOpportunityTeam(newList);
        OpportunityTriggerService.tagOppTeamMemberEpic(newList);
    }
    
    public static void onAfterUpdate(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        OpportunityTriggerService.createPreSalesOppTeamMember(newMap, oldMap);
    }
    
    public static void onBeforeUpdate(List<Opportunity> newOppList, Map<Id, Opportunity> oldMap) {
        OpportunityTriggerService.teamMemberValidation(newOppList,oldMap);
        OpportunityTriggerService.mandatoryFields1stStageEPIC(newOppList, oldMap);
        OpportunityTriggerService.mandatoryFields2ndStageEPIC(newOppList, oldMap);
        OpportunityTriggerService.mandatoryFields3rdStageEPIC(newOppList, oldMap);
        OpportunityTriggerService.mandatoryFieldsAtWonStageEPIC(newOppList, oldMap);
    }
    
    /*Required*/
    public static void pmToolUtility(Map<Id, Opportunity> newOppMap,  Map<Id, OPportunity> oldOppMap){
        /*
try{
Type pcu = System.Type.forName('MPM4_BASE', 'Milestone1_Project_Creation_Utility');
if(pcu != null){
MPM4_BASE.Milestone1_Project_Creation_Utility projCreationUtil = (MPM4_BASE.Milestone1_Project_Creation_Utility) pcu.newInstance();
projCreationUtil.CreateChildProject(oldOppMap, newOppMap, new Map<string, object>{
'projectCreationField' => 'Project_Template__c',

'projectLookupField1' => 'MPM4_BASE__Opportunity__c',

'projectLookupField2' => 'MPM4_BASE__Account__c',

'secondaryLookup' => 'AccountId',

'projectNamingConventionField' => 'Name'

});
}
}
catch(Exception ex)
{

ErrorLogger.createLogError('OpportunityTriggerHandler', 'Apex Class',ex.getTypeName(),ex.getMessage(), String.valueOf(ex.getLineNumber()),
'pmToolUtility', ex.getStackTraceString());

}*/
    }
    
    /*Required*/
    Public static void callSetPricebook(List<Opportunity> opList){
        
        try{
            List<Pricebook2> stdPBL =  [select id from Pricebook2 where IsStandard = TRUE];
            System.debug('Standard Pricebook'+stdPBL);
            if(!stdPBL.isEmpty()){
                for(Opportunity o: opList)
                    o.PriceBook2Id = stdPBL[0].id;
            }
        }
        catch(Exception ex)
        {
            
            ErrorLogger.createLogError('OpportunityTriggerHandler', 'Apex Class',ex.getTypeName(),ex.getMessage(), String.valueOf(ex.getLineNumber()),
                                       'callSetPricebook', ex.getStackTraceString());
        }
    }
    
    /*Required*/
    //set Name of the Opportunity 
    public static void setOppName(List<Opportunity> oppList){
        try{
            Set<Id>acIds = new Set<Id>();
            for(Opportunity op:oppList)
            {
                System.debug('op.Product_Interested__c::::'+op.Product_Interested__c);
                if(op.Product_Interested__c == 'Employee Tax Benefits')
                    op.RecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Employee Tax Benefits').getRecordTypeId();
                if(op.Product_Interested__c == 'Travel & Expense (T&E)')    {
                    op.RecordTypeId  	= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Travel & Expense').getRecordTypeId();
                    op.StageName 		= 'Sales qualification';	
                }
                if(op.Product_Interested__c == 'Epic Cards')    {
                    System.debug('Line 99:::');
                    op.RecordTypeId  	= Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EPIC').getRecordTypeId();
                    op.StageName 		= 'Documents Shared - Qualifying';	
                }
                acIds.add(op.AccountId);
            }
            Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Name FROM Account WHERE Id IN :acIds]);
            System.debug(accountMap);
            for(Opportunity op:oppList)
            {
                String name = accountMap.get(op.AccountId).Name ;
                System.debug(name);
                DateTime dt;
                
                if(Trigger.isUpdate)
                {
                    dt = op.CreatedDate;
                }
                else{
                    dt = System.now();
                }
                String month = dt.format('MMM');
                String year = dt.format('YYYY');
                Decimal SalesUserPotential = op.LG_User_Potential__c==null?0:op.LG_User_Potential__c ;
                // Decimal SalesUserPotential = op.Sales_User_Potential__c==null?0:op.Sales_User_Potential__c ;
                system.debug(month+'/'+year);
                //op.Name = name  +' | '+SalesUserPotential+' | '+op.Product_Interested__c +' | '+ month+'-'+year;
                op.Name = name + ' | '+ month+'-'+year +' | '+op.Product_Interested__c ;
                System.debug('Opp Name-->'+op.Name);
            } }  
        catch(Exception ex)
        {
            
            ErrorLogger.createLogError('OpportunityTriggerHandler', 'Apex Class',ex.getTypeName(),ex.getMessage(), String.valueOf(ex.getLineNumber()),
                                       'setOppName', ex.getStackTraceString());
        }
    }
    
    
    public static void setLastStageChangedDate(List<Opportunity> oppList, Map<Id, Opportunity> oldOppMap){
        
        for(Opportunity opp:oppList)
        {
            if(opp.StageName!=oldOppMap.get(opp.Id).StageName)
            {
                opp.LastStageChangeDate__c = System.Now();
            }
        }
    }
    
    /*Required*/
    public static void syncOppToQuote(List<Opportunity> newOppList, Map<Id, Opportunity> oldOppMap){
        
        try{ 
            if (TriggerStopper.stopOpp) return;
            
            TriggerStopper.stopOpp = true;    
            
            Set<String> quoteFields = QuoteSyncUtil.getQuoteFields();
            List<String> oppFields = QuoteSyncUtil.getOppFields();
            
            String quote_fields = QuoteSyncUtil.getQuoteFieldsString();
            
            String opp_fields = QuoteSyncUtil.getOppFieldsString();    
            
            
            String oppIds = '';
            
            Map<id ,id> startSyncQuoteMap = setStartSyncQuoteMap(oppIds,newOppList,oldOppMap);   
            
            
            if (oppIds != '') {
                String oppQuery = 'select Id, SyncedQuoteId' + opp_fields + ' from Opportunity where Id in (' + oppIds + ') and SyncedQuoteId != null';
                //System.debug(oppQuery);     
                
                List<Opportunity> opps = Database.query(oppQuery);
                
                String quoteIds = '';
                Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
                
                for (Opportunity opp : opps) {
                    if (opp.SyncedQuoteId != null) {
                        oppMap.put(opp.Id, opp);
                        if (quoteIds != '') quoteIds += ', ';
                        quoteIds += '\'' + opp.SyncedQuoteId + '\'';            
                    }
                }
                
                if (quoteIds != '') { 
                    String quoteQuery = 'select Id, OpportunityId' + quote_fields + ' from Quote where Id in (' + quoteIds + ')';
                    //System.debug(quoteQuery);
                    
                    List<Quote> quotes = Database.query(quoteQuery);
                    
                    
                    updateQuote(quotes,oppMap,quoteFields);
                }
                
                // Check start sync quote with matching opp lines and quote lines
                
                if (!startSyncQuoteMap.isEmpty()) {
                    
                    String syncQuoteIds = '';
                    String syncOppIds = '';
                    
                    for (Id quoteId : startSyncQuoteMap.keySet()) {
                        if (syncQuoteIds != '') syncQuoteIds += ', ';
                        syncQuoteIds += '\'' + quoteId + '\'';
                        
                        if (syncOppIds != '') syncOppIds += ', ';
                        syncOppIds += '\'' + startSyncQuoteMap.get(quoteId) + '\'';
                    }
                    
                    
                    String qliFields = QuoteSyncUtil.getQuoteLineFieldsString();    
                    String oliFields = QuoteSyncUtil.getOppLineFieldsString(); 
                    
                    String qliQuery = 'select Id, QuoteId, PricebookEntryId, UnitPrice, Quantity, Discount, SortOrder' + qliFields + ' from QuoteLineItem where QuoteId in (' + syncQuoteIds + ') order by QuoteId, SortOrder ASC';           
                    String oliQuery = 'select Id, OpportunityId, PricebookEntryId, UnitPrice, Quantity, Discount, SortOrder' + oliFields + ' from OpportunityLineItem where OpportunityId in (' + syncOppIds + ') order by OpportunityId, SortOrder ASC';   
                    
                    List<QuoteLineItem> qlis = Database.query(qliQuery);   
                    List<OpportunityLineItem> olis = Database.query(oliQuery);
                    
                    Map<Id, List<OpportunityLineItem>> oppToOliMap = new Map<Id, List<OpportunityLineItem>>();
                    Map<Id, List<QuoteLineItem>> quoteToQliMap = new Map<Id, List<QuoteLineItem>>();        
                    
                    for (QuoteLineItem qli : qlis) {
                        List<QuoteLineItem> qliList = quoteToQliMap.get(qli.QuoteId);
                        if (qliList == null) {
                            qliList = new List<QuoteLineItem>();
                        } 
                        qliList.add(qli);  
                        quoteToQliMap.put(qli.QuoteId, qliList);        
                    }
                    
                    for (OpportunityLineItem oli : olis) {
                        List<OpportunityLineItem> oliList = oppToOliMap.get(oli.OpportunityId);
                        if (oliList == null) {
                            oliList = new List<OpportunityLineItem>();
                        } 
                        oliList.add(oli);  
                        oppToOliMap.put(oli.OpportunityId, oliList);       
                    }        
                    
                    
                    List<OpportunityLineItem> updateOliList = new List<OpportunityLineItem>(); 
                    Set<String> quoteLineFields = QuoteSyncUtil.getQuoteLineFields();
                    
                    Set<OpportunityLineItem> updateOliSet= set_updateOliSet(startSyncQuoteMap,quoteToQliMap,oppToOliMap,quoteLineFields);
                    
                    if (!updateOliSet.isEmpty()) {
                        updateOliList.addAll(updateOliSet);
                        
                        TriggerStopper.stopQuote = true;             
                        TriggerStopper.stopOppLine = true;
                        TriggerStopper.stopQuoteLine = true;  
                        
                        Database.update(updateOliList);
                        updateOliSet.clear();
                        updateOliList.clear();
                        
                        TriggerStopper.stopQuote = false;             
                        TriggerStopper.stopOppLine = false;
                        TriggerStopper.stopQuoteLine = false;                               
                    }                
                }
                
                TriggerStopper.stopOpp = false; 
                
            }
        }
        catch(Exception ex)
        {
            
            ErrorLogger.createLogError('OpportunityTriggerHandler', 'Apex Class',ex.getTypeName(),ex.getMessage(), String.valueOf(ex.getLineNumber()),
                                       'setOppName', ex.getStackTraceString());
        }
    }
    
    
    
    public static  Set<OpportunityLineItem> set_updateOliSet( Map<id ,id> startSyncQuoteMap,
                                                             Map<Id, List<QuoteLineItem>> quoteToQliMap,
                                                             Map<Id, List<OpportunityLineItem>> oppToOliMap,
                                                             Set<String> quoteLineFields)
    {
        Set<OpportunityLineItem> updateOliSet = new Set<OpportunityLineItem>(); 
        for (Id quoteId : startSyncQuoteMap.keySet()) {
            Id oppId = startSyncQuoteMap.get(quoteId);
            List<QuoteLineItem> quotelines = quoteToQliMap.get(quoteId);
            List<OpportunityLineItem> opplines = oppToOliMap.get(oppId);
            boolean quoteCheck = quotelines != null && opplines != null && !quotelines.isEmpty() && !opplines.isEmpty();
            if (quoteCheck) {
                
                for (QuoteLineItem qli : quotelines) {
                    boolean hasChange = false;
                    
                    for (OpportunityLineItem oli : opplines) {
                        Boolean checkIfallSame = oli.pricebookentryid == qli.pricebookentryId  && oli.UnitPrice == qli.UnitPrice && oli.Quantity == qli.Quantity && oli.Discount == qli.Discount&& oli.SortOrder == qli.SortOrder;
                        
                        if (checkIfallSame) {
                            
                            if (updateOliSet.contains(oli)) continue; 
                            
                            //System.debug('########## qliId: ' + qli.Id + '     oliId: ' + oli.Id);
                            
                            for (String qliField : quoteLineFields) {
                                String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                                Object oliValue = oli.get(oliField);
                                Object qliValue = qli.get(qliField);
                                if (oliValue != qliValue) {
                                    hasChange = true;
                                    if (qliValue == null) oli.put(oliField, null);
                                    else oli.put(oliField, qliValue);                                                                
                                }    
                            }
                            
                            if (hasChange) {
                                updateOliSet.add(oli);
                            }
                            
                            break;        
                        }                        
                    }
                }
            }
        }
        return updateOliSet;
    }
    public static Map<Id, Id> setStartSyncQuoteMap(String oppIds,List<Opportunity> newOppList,Map<Id, OPportunity> oldOppMap)
    {
        Map<Id, Id> startSyncQuoteMap = new Map<Id, Id>(); 
        for (Opportunity opp : newOppList) {
            System.debug('opp.SyncedQuoteId '+opp.SyncedQuoteId );
            System.debug(opp.SyncedQuoteId != oldOppMap.get(opp.Id).SyncedQuoteId);
            if (opp.SyncedQuoteId != oldOppMap.get(opp.Id).SyncedQuoteId) {
                if (opp.SyncedQuoteId != null) {
                    startSyncQuoteMap.put(opp.SyncedQuoteId, opp.Id);
                }                
                continue;
            }    
            if (oppIds != '') oppIds += ', ';
            oppIds += '\'' + opp.Id + '\'';
        }
        return startSyncQuoteMap;
    }
    
    public static void updateQuote(List<Quote> quotes,
                                   Map<Id, Opportunity> oppMap,
                                   Set<String> quoteFields)
    {
        List<Quote> updateQuotes = new List<Quote>();
        for (Quote quote : quotes) {
            Opportunity opp = oppMap.get(quote.OpportunityId);
            boolean hasChange = false;
            for (String quoteField : quoteFields) {
                String oppField = QuoteSyncUtil.getQuoteFieldMapTo(quoteField);
                Object oppValue = opp.get(oppField);
                Object quoteValue = quote.get(quoteField);
                if (oppValue != quoteValue) {
                    hasChange = true;
                    if (oppValue == null) quote.put(quoteField, null);
                    else quote.put(quoteField, oppValue);                                             
                }                     
            }
            if (hasChange) updateQuotes.add(quote);                                  
        } 
        TriggerStopper.stopQuote = true;           
        Database.update(updateQuotes);
        TriggerStopper.stopQuote = false;             
    }
    public static void commercialCalculation(List<Opportunity> oppList){
        for(Opportunity opp: oppList){
            System.debug(opp.Is_Opportunity_Forecast_Projectable__c);
            if(!opp.Is_Opportunity_Forecast_Projectable__c)
            {
                opp.ForecastCategoryName = 'Omitted ';
            }
            else if(opp.StageName == 'Stage 1 (Qualified)'||opp.StageName =='Stage 2 (Validated)')
            {
                opp.ForecastCategoryName = 'Pipeline ';
            }
            else if(opp.StageName == 'Stage 3 (Shortlisted)')
            {
                opp.ForecastCategoryName = 'Best Case ';
            }
            
            else if(opp.StageName == 'Stage 4 (Selected)')
            {
                opp.ForecastCategoryName = 'Commit  ';
            }
            
            else if(opp.StageName == 'Won')
            {
                opp.ForecastCategoryName = 'Closed';
            }
            
            opp.Annual_Contract_Value__c = opp.Is_Opportunity_Forecast_Projectable__c==false? 0:opp.ACV_annual_contract_value__c;
        }
    }
}
public class TermsAndConditionsTriggerHandler {
    
    public static void calculateARRBasedOnBillingType(List<Terms_and_condition__c> tcList){
        Map<Id,integer> mapofQuoteIdByMultiplier = new Map<Id,Integer>();
        for(Terms_and_condition__c tc : tcList){
          //  if(tc.Term_Section_Line_Item__c == 'a1LC20000011lXNMAY'){ 
                /*if(tc.Billing_Type__c == 'Monthly'){
                    mapofQuoteIdByMultiplier.put(tc.Quote__c,1);
                }else if(tc.Billing_Type__c == 'Quarterly'){
                    mapofQuoteIdByMultiplier.put(tc.Quote__c,3);
                }else if(tc.Billing_Type__c == 'Semi Annualy'){
                    mapofQuoteIdByMultiplier.put(tc.Quote__c,6);
                }else if(tc.Billing_Type__c == 'Annually'){
                    mapofQuoteIdByMultiplier.put(tc.Quote__c,12);
                }*/
                if(tc.Billing_Type__c == 'Quartely Billing'){
                    mapofQuoteIdByMultiplier.put(tc.Quote__c,3);
                }else if(tc.Billing_Type__c =='Halfyearly'){
                    mapofQuoteIdByMultiplier.put(tc.Quote__c,6);
                }else if(tc.Billing_Type__c =='Yearly'){
                    mapofQuoteIdByMultiplier.put(tc.Quote__c,12);
                }
          //  }
            
        }
        
        if(!mapofQuoteIdByMultiplier.isEmpty()){
            List<Quote> quoteRec = [select id,Travel_Total_SAAS__c,Expense_Total_SAAS__c,Travel_Final_ARR__c,Expense_FInal_ARR__c from quote where id in: mapofQuoteIdByMultiplier.keySet()];
            system.debug('quoteRec====='+quoteRec);
            if(!quoteRec.isEmpty()){
                for(Quote qu : quoteRec){
                    if(qu.Travel_Total_SAAS__c != null && mapofQuoteIdByMultiplier.containsKey(qu.Id) && mapofQuoteIdByMultiplier.get(qu.Id) != null){
                        qu.Travel_Final_ARR__c = qu.Travel_Total_SAAS__c * mapofQuoteIdByMultiplier.get(qu.Id);
                        qu.Billing_Type_Multiplier__c = mapofQuoteIdByMultiplier.get(qu.Id);
                    }
                    
                    if(qu.Expense_Total_SAAS__c != null && mapofQuoteIdByMultiplier.containsKey(qu.Id) && mapofQuoteIdByMultiplier.get(qu.Id) != null){
                        qu.Expense_FInal_ARR__c = qu.Expense_Total_SAAS__c * mapofQuoteIdByMultiplier.get(qu.Id);
                    }
                }
              update quoteRec;
            }
        }
    }
}
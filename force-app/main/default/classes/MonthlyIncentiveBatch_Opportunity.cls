global class MonthlyIncentiveBatch_Opportunity implements Database.Batchable<AggregateResult>  {
    global Iterable<AggregateResult> start(Database.BatchableContext bc) {
        String query= 'Select Owner.Id oppOwner,GROUPING(Owner.Id) OpportunityOwnerId,Count(Id) totalOpportunity ,SUM(Amount) totalAmount from Opportunity where CreatedDate>=2023-01-01T15:08:10.000+0000 and CloseDate<=:todayDate GROUP BY CUBE(Owner.Id)';
        System.debug('Query::'+query);
        return new AggregateResultIterable(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        Decimal totalAmount;
        Map<Id,Incentive_Model__c> incentiveModelMap=new Map<Id,Incentive_Model__c>([Select Id,Name,Incentive_Profile__c,Incentive_Object__c from Incentive_Model__c where Incentive_Object__c='Opportunity']);
        System.debug('IncentiveModelMap::'+incentiveModelMap);
        Map<Id,Incentive_Model_Criteria__c> incentiveModelCriteriaMap=new Map<Id,Incentive_Model_Criteria__c>([Select Id,Name,Incentive_Model__c from Incentive_Model_Criteria__c where Incentive_Model__c IN: incentiveModelMap.keySet()]);
        System.debug('incentiveModelCriteriaMap::'+incentiveModelCriteriaMap);
        List<Monthly_Incentive_Component__c> monthCompList=new List<Monthly_Incentive_Component__c>();
        Map<Id,Incentive_Slabs__c> slabs=new Map<Id, Incentive_Slabs__c>([SELECT Id, Name,Upper_Bound__c,Lower_Bound__c,Operator__c,Incentive_to_be_given__c,Incentive_Model_Criteria__c FROM Incentive_Slabs__c where Incentive_Model_Criteria__c IN:incentiveModelCriteriaMap.keySet()]);
        System.debug('slabs::'+slabs);
        Incentive_Model__c incentiveModelVar;
        Incentive_Model_Criteria__c incentiveCriteria;
        
        try{
            for(Id key : slabs.keySet()){
				Incentive_Slabs__c incentiveSlab=slabs.get(key);
                incentiveCriteria=incentiveModelCriteriaMap.get(incentiveSlab.Incentive_Model_Criteria__c);
                incentiveModelVar=incentiveModelMap.get(incentiveCriteria.Incentive_Model__c);

                for(sObject sObj : scope) {
                    AggregateResult arResult = (AggregateResult)sObj;
                    //System.debug('arResult::'+arResult);
                    totalAmount=(Decimal)arResult.get('totalAmount');
                    if(incentiveSlab.Lower_Bound__c!=null && totalAmount>=incentiveSlab.Lower_Bound__c && incentiveSlab.Upper_Bound__c!=null && totalAmount<=slabs.get(key).Upper_Bound__c){
                        if(incentiveSlab.Operator__c!='%'){
                            Monthly_Incentive_Component__c monthCompRec=new Monthly_Incentive_Component__c();
                            monthCompRec.Name = 'Incentive '+incentiveModelVar.Incentive_Object__c+' '+MonthlyIncentiveHelper.getCurrentMonth();
                            monthCompRec.Incentive_Amount__c = incentiveSlab.Incentive_to_be_given__c;
                            monthCompRec.Incentive_Slab__c = incentiveSlab.id;
                            monthCompRec.Total_Sale__c = (Integer)totalAmount;
                            monthCompRec.User__c = (Id)arResult.get('oppOwner');
                            monthCompList.add(monthCompRec);
                        }else{
                            //For Calculating Incentive Amount based on percentage.
                            Decimal incentiveAmount=totalAmount*incentiveSlab.Incentive_to_be_given__c/100;
                            Monthly_Incentive_Component__c monthCompRec=new Monthly_Incentive_Component__c();
                            monthCompRec.Name='Incentive '+incentiveModelVar.Incentive_Object__c+' '+MonthlyIncentiveHelper.getCurrentMonth();
                            monthCompRec.Incentive_Amount__c=incentiveAmount;
                            monthCompRec.Incentive_Slab__c=incentiveSlab.id;
                            monthCompRec.Total_Sale__c=(Integer)totalAmount;
                            monthCompRec.User__c=(Id)arResult.get('oppOwner');
                            monthCompList.add(monthCompRec);
                        }
                    }
                }
            }
            if(monthCompList.size()>0){
                insert monthCompList;
            }
            
        }Catch(Exception ex){
            System.debug('Exception Message::'+ex.getMessage()+'Stack Trace::'+ex.getStackTraceString());
        }
        
    }    
    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    	
}
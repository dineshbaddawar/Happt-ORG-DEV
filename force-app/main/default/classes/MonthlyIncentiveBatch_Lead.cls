global class MonthlyIncentiveBatch_Lead implements Database.Batchable<AggregateResult>{
    global Iterable<AggregateResult> start(Database.BatchableContext BC){
        Date startOfMonth = Date.today().toStartOfMonth();
        String query='Select Owner.id leadOwner,SUM(No_of_Calls__c) totalCalls,SUM(No_of_Emails__c) totalEmails from Lead where createdDate>=2023-01-01T15:08:10.000+0000 GROUP BY CUBE(Owner.id)';
        System.debug('Query::'+query);
        return new AggregateResultIterable(query);   
    }
    global void execute(Database.BatchableContext BC, List<sobject> scope){
        Map<Id,Incentive_Model__c> incentiveModelMap=new Map<Id,Incentive_Model__c>([Select Id,Name,Incentive_Profile__c,Incentive_Object__c from Incentive_Model__c where Incentive_Object__c='Lead']);
        System.debug('IncentiveModelMap::'+incentiveModelMap);
        Map<Id,Incentive_Model_Criteria__c> incentiveModelCriteriaForEmail=new Map<Id,Incentive_Model_Criteria__c>([Select Id,Name,Evaluation_Field__c,Incentive_Model__c from Incentive_Model_Criteria__c where Incentive_Model__c IN: incentiveModelMap.keySet() and Evaluation_Field__c='Email']);
        System.debug('incentiveModelCriteriaForEmail::'+incentiveModelCriteriaForEmail);
        Map<Id,Incentive_Model_Criteria__c> incentiveModelCriteriaForCalls=new Map<Id,Incentive_Model_Criteria__c>([Select Id,Name,Evaluation_Field__c,Incentive_Model__c from Incentive_Model_Criteria__c where Incentive_Model__c IN: incentiveModelMap.keySet() and Evaluation_Field__c='Phone']);
        System.debug('incentiveModelCriteriaForCalls::'+incentiveModelCriteriaForCalls);
		Map<Id,Incentive_Slabs__c> slabs_call=new Map<Id, Incentive_Slabs__c>([SELECT Id, Name,Upper_Bound__c,Lower_Bound__c,Operator__c,Incentive_to_be_given__c,Incentive_Model_Criteria__c FROM Incentive_Slabs__c where Incentive_Model_Criteria__c IN:incentiveModelCriteriaForCalls.keySet()]);
        System.debug('slabs_call::'+slabs_call);


        List<Monthly_Incentive_Component__c> monthCompList_call=new List<Monthly_Incentive_Component__c>();
		List<Monthly_Incentive_Component__c> monthCompList_email=new List<Monthly_Incentive_Component__c>();

        Map<Id,Incentive_Slabs__c> slabs_email=new Map<Id, Incentive_Slabs__c>([SELECT Id, Name,Upper_Bound__c,Lower_Bound__c,Operator__c,Incentive_to_be_given__c,Incentive_Model_Criteria__c FROM Incentive_Slabs__c where Incentive_Model_Criteria__c IN:incentiveModelCriteriaForEmail.keySet()]);
        System.debug('slabs_email::'+slabs_email.keySet());

        Incentive_Model__c incentiveModelVar;
        Incentive_Model_Criteria__c incentiveCriteria;
        Decimal totalCalls=0;
        Decimal totalEmails=0;
        try{           
            /*for(Id key : slabs_call.keySet()){
                    Incentive_Slabs__c incentiveSlab=slabs_call.get(key);
                    incentiveCriteria=incentiveModelCriteriaForCalls.get(incentiveSlab.Incentive_Model_Criteria__c);
                    incentiveModelVar=incentiveModelMap.get(incentiveCriteria.Incentive_Model__c);
                for(sObject sObj : scope) {
                    AggregateResult arResult = (AggregateResult)sObj;
                    if(arResult.get('totalCalls')!=null){
                        totalCalls=(Decimal)arResult.get('totalCalls');
                        if(totalCalls>=incentiveSlab.Lower_Bound__c && totalCalls<=incentiveSlab.Upper_Bound__c){
                            Monthly_Incentive_Component__c monthCompRec=new Monthly_Incentive_Component__c();
                            monthCompRec.Name = 'Incentive '+incentiveModelVar.Incentive_Object__c+'and '+incentiveCriteria.Evaluation_Field__c+' '+MonthlyIncentiveHelper.getCurrentMonth();
                            monthCompRec.Incentive_Amount__c = incentiveSlab.Incentive_to_be_given__c; 
                            monthCompRec.Incentive_Slab__c = incentiveSlab.id;
                            monthCompRec.Total_Sale__c = (Integer)totalCalls;
                            monthCompRec.User__c = (Id)arResult.get('leadOwner');
                            monthCompList_call.add(monthCompRec);
                        }  
                    }
                   
                    System.debug('arResult::'+arResult);
                }    
            }
            if(monthCompList_email.size()>0){
                System.debug('monthCompList_email::'+monthCompList_email);
				insert monthCompList_email;
            }*/
            for(Id key : slabs_email.keySet()){
                Incentive_Slabs__c incentiveSlab=slabs_email.get(key);
                System.debug('incentiveSlab::'+incentiveSlab.Incentive_Model_Criteria__c);
                incentiveCriteria=incentiveModelCriteriaForEmail.get(incentiveSlab.Incentive_Model_Criteria__c);
                incentiveModelVar=incentiveModelMap.get(incentiveCriteria.Incentive_Model__c);
                for(sObject sObj : scope) {
                    AggregateResult arResult = (AggregateResult)sObj;
                    if(arResult.get('totalEmails')!=null){
                        totalEmails=(Decimal)arResult.get('totalEmails');
                        if(totalCalls>=incentiveSlab.Lower_Bound__c && totalCalls<=incentiveSlab.Upper_Bound__c){
                            Monthly_Incentive_Component__c monthCompRec=new Monthly_Incentive_Component__c();
                            monthCompRec.Name = 'Incentive '+incentiveModelVar.Incentive_Object__c+'and '+incentiveCriteria.Evaluation_Field__c+' '+MonthlyIncentiveHelper.getCurrentMonth();
                            monthCompRec.Incentive_Amount__c = incentiveSlab.Incentive_to_be_given__c;
                            monthCompRec.Incentive_Slab__c = incentiveSlab.id;
                            monthCompRec.Total_Sale__c = (Integer)totalEmails;
                            monthCompRec.User__c = (Id)arResult.get('leadOwner');
                            monthCompList_email.add(monthCompRec);
                        }  
                    }
                   
                    System.debug('arResult::'+arResult);
                }    
            }

             if(monthCompList_call.size()>0){
                 System.debug('monthCompList_call::'+monthCompList_call);
                insert monthCompList_call;
            }
        }catch(Exception ex){
			System.debug('Exception Message::'+ex.getMessage()+'Stack Trace::'+ex.getStackTraceString());
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
    }
}
public with sharing class IncentivePlanEditCtrl {
 
    @AuraEnabled
    public static IncentiveWrapper fetchIncentivePlan(Id recordId){
        IncentiveWrapper wrapper=new IncentiveWrapper();
        Set<Id> incentiveModelIds=new Set<Id>();
        Set<Id> modelCriteriaIds=new Set<Id>();
        try{
                Incentive_Plan__c incentivePlanRec=[Select Id,Name,Start_Date__c,End_Date__c from Incentive_Plan__c where Id=:recordId];
                List<Incentive_Model__c> incentiveModelRec=[Select Id,Name,Incentive_Object__c,Incentive_Profile__c from Incentive_Model__c where Incentive_Profile__c=:incentivePlanRec.Id];
                for(Incentive_Model__c inModel:incentiveModelRec){
                    incentiveModelIds.add(inModel.id);
                }
                List<Incentive_Model_Criteria__c> inModeCriteria=[Select Id,Name,Evaluation_Field__c,Incentive_Model__c  from Incentive_Model_Criteria__c where Incentive_Model__c IN:incentiveModelIds];
                for(Incentive_Model_Criteria__c criteria:inModeCriteria){
                    modelCriteriaIds.add(criteria.Id);
                }

                List<Incentive_Slabs__c> incentiveSlab=[Select Id,Name,Applicable_incentive_Type__c,Incentive__c,Incentive_to_be_given__c,Incentive_Model_Criteria__c,Lower_Bound__c,Upper_Bound__c from Incentive_Slabs__c where Incentive_Model_Criteria__c IN:modelCriteriaIds];
                wrapper.incentivePlan=incentivePlanRec;
                wrapper.incentiveModel=incentiveModelRec;
                wrapper.incentiveModelCriteria=inModeCriteria;
                wrapper.incentiveSlabs=incentiveSlab;
        }catch(Exception ex){
            System.debug('Exception Message::'+ex.getMessage()+'Exception Line Number::'+ex.getStackTraceString());
        }
        System.debug('wrraperer:'+wrapper);
        return wrapper;    
    }
  

    public class IncentiveWrapper{
        @AuraEnabled
        public Incentive_Plan__c incentivePlan{get;set;}
        @AuraEnabled
        public List<Incentive_Model__c> incentiveModel{get;set;}
        @AuraEnabled
        public List<Incentive_Model_Criteria__c> incentiveModelCriteria{get;set;}
        @AuraEnabled
        public List<Incentive_Slabs__c> incentiveSlabs{get;set;}
    }
}
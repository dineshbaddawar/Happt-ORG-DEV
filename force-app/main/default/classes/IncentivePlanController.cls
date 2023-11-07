public with sharing class IncentivePlanController {
    @AuraEnabled(Cacheable = true)
    public static List<Account> getAccounts(){
        return [SELECT Id, Name,Industry, Type, Phone, Rating, AccountNumber FROM Account ORDER BY Name LIMIT 10];
    }
    public static List<Incentive__mdt> fetchCustomMetadata(){
        return [SELECT Fields__c,isActive__c,Objects__c,Profile__c  FROM Incentive__mdt where isActive__c=true];
    }
    @AuraEnabled(cacheable=true)
    public static IncentiveWrapper pickListValueDynamically() {
        IncentiveWrapper wrapper=new IncentiveWrapper();
        List<string> profileList=new List<String>();
        List<String> objectList=new List<String>();
        List<String> fieldList=new List<String>();
        try{
            for(Incentive__mdt inRec: fetchCustomMetadata()){
                profileList.add(inRec.Profile__c);
                objectList.add(inRec.Objects__c);
                fieldList.add(inRec.Fields__c);
            }        
            wrapper.profileList=profileList;
            wrapper.objectList=objectList;
            wrapper.fieldList=fieldList;
        }Catch(Exception ex){
            System.debug('Exception Message::'+ex.getMessage()+'Exception Line Number::'+ex.getLineNumber());
        }
        return wrapper;
    }
     @AuraEnabled
    public static Id processIncentiveRecords(InputWrapper wrapperRecord){
        Set<Incentive_Slabs__c > incentiveSlabList=new Set<Incentive_Slabs__c>();
        List<Incentive_Model__c> incentiveModelList=new List<Incentive_Model__c>();
        List<Incentive_Model_Criteria__c> incentiveModelCriteriaList=new List<Incentive_Model_Criteria__c>();

        Map<String,Id> modelIds=new Map<String,Id>();
        Map<String,Id> modelCriteriaId=new Map<String,Id>();
        Map<String,String> modelMap=new Map<String,String>();
        Map<String,Set<String>> modelVsFieldCriteriaEntry=new Map<String,Set<String>>();
        Map<String,String> modelVsFieldCriteriaEntryVSField=new Map<String,String>();
        Map<String,List<String>> modelNewCriteriaMap=new Map<String,List<String>>();
        Incentive_Plan__c incentivePlanRec;
        Map<String,List<Incentive_Slabs__c>> slabMapVSRec=new Map<String,List<Incentive_Slabs__c>>();
        try{
            List<String> objList=wrapperRecord.object_Nm;
            List<String> fieldList=wrapperRecord.evaluationField;
            String key;    
            for(integer i=0; i<objList.size(); i++){
                key=wrapperRecord.profile_Nm+'_'+objList[i];
                System.debug(key);
                
                if(modelNewCriteriaMap.size()>0 && modelNewCriteriaMap.containskey(key)){
                   List<String> fieldListData=modelNewCriteriaMap.get(key);
                   fieldListData.add(wrapperRecord.profile_Nm+'_'+objList[i]+'_'+fieldList[i]+'_'+wrapperRecord.lowerBound[i]+'_'+wrapperRecord.upperBound[i]);
                   modelNewCriteriaMap.put(key,fieldListData);
                }else{
                    modelNewCriteriaMap.put(key,new List<String>{wrapperRecord.profile_Nm+'_'+objList[i]+'_'+fieldList[i]+'_'+wrapperRecord.lowerBound[i]+'_'+wrapperRecord.upperBound[i]});
                    modelMap.put(key,objList[i]);
                }
                if(slabMapVSRec.size()>0 && slabMapVSRec.containskey(wrapperRecord.profile_Nm+'_'+objList[i]+'_'+fieldList[i])){
                     Incentive_Slabs__c incentiveSlab=new Incentive_Slabs__c(
                        Incentive_to_be_given__c=(Integer)wrapperRecord.incentiveAmount[i],
                        Lower_Bound__c=(Integer)wrapperRecord.lowerBound[i],
                        Upper_Bound__c=(Integer)wrapperRecord.upperBound[i],
                        Applicable_incentive_Type__c=wrapperRecord.applicableIncentiveType[i]
                    );
                    List<Incentive_Slabs__c> slabsRecords=slabMapVSRec.get(wrapperRecord.profile_Nm+'_'+objList[i]+'_'+fieldList[i]);
                    slabsRecords.add(incentiveSlab);
                    slabMapVSRec.put(wrapperRecord.profile_Nm+'_'+objList[i]+'_'+fieldList[i],slabsRecords);
                }else{
                    Incentive_Slabs__c incentiveSlab=new Incentive_Slabs__c(
                        Incentive_to_be_given__c=(Integer)wrapperRecord.incentiveAmount[i],
                        Lower_Bound__c=(Integer)wrapperRecord.lowerBound[i],
                        Upper_Bound__c=(Integer)wrapperRecord.upperBound[i],
                        Applicable_incentive_Type__c=wrapperRecord.applicableIncentiveType[i]
                    );
                     slabMapVSRec.put(wrapperRecord.profile_Nm+'_'+objList[i]+'_'+fieldList[i],new List<Incentive_Slabs__c>{incentiveSlab});                
                }

                 if(modelVsFieldCriteriaEntry.size()>0 && modelVsFieldCriteriaEntry.containskey(key)){
                    Set<String> fieldCriteriaSet=modelVsFieldCriteriaEntry.get(key);
                    fieldCriteriaSet.add(wrapperRecord.profile_Nm+'_'+objList[i]+'_'+fieldList[i]);
                    modelVsFieldCriteriaEntry.put(key,fieldCriteriaSet);
                    modelVsFieldCriteriaEntryVSField.put(wrapperRecord.profile_Nm+'_'+objList[i]+'_'+fieldList[i],fieldList[i]);

                }else{
                    modelVsFieldCriteriaEntryVSField.put(wrapperRecord.profile_Nm+'_'+objList[i]+'_'+fieldList[i],fieldList[i]);
                    modelVsFieldCriteriaEntry.put(key,new Set<String>{wrapperRecord.profile_Nm+'_'+objList[i]+'_'+fieldList[i]});
                }
                
            }
            System.debug('c=='+JSON.serialize(modelNewCriteriaMap));
            System.debug('modelVsFieldCriteriaEntry=='+JSON.serialize(modelVsFieldCriteriaEntry));
            System.debug('slabMapVSRec=='+JSON.serialize(slabMapVSRec));
            //Inserting Incentive Plan Record
            incentivePlanRec=new Incentive_Plan__c(
                Name=wrapperRecord.profile_Nm,
                Start_Date__c=wrapperRecord.startDate,
                End_Date__c=wrapperRecord.endDate,
                Active__c=wrapperRecord.isEnabled
            );
            insert incentivePlanRec;


             for(String key1:modelNewCriteriaMap.keySet()){
                Incentive_Model__c incentiveModel=new Incentive_Model__c(
                Name=key1,
                Incentive_Profile__c=incentivePlanRec.id,
                Incentive_Object__c=modelMap.get(key1)
                );
                incentiveModelList.add(incentiveModel);
            }
            Database.insert(incentiveModelList, true);
            for(Incentive_Model__c modelRec:incentiveModelList){
                    modelIds.put(modelRec.Name,modelRec.Id); 
            }

             for(String key2:modelVsFieldCriteriaEntry.keySet()){

                 List<String> criterialList=new List<String>(modelVsFieldCriteriaEntry.get(key2));
                    for(String criteriaName:criterialList){
                        Incentive_Model_Criteria__c incentiveModelCriteria=new Incentive_Model_Criteria__c(
                        Name=criteriaName,
                        Evaluation_Field__c=modelVsFieldCriteriaEntryVSField.get(criteriaName),
                        Incentive_Model__c=modelIds.get(key2));   
                        incentiveModelCriteriaList.add(incentiveModelCriteria);
                    }
            }

            Database.insert(incentiveModelCriteriaList, true);
            for(Incentive_Model_Criteria__c modelCriteriaRec:incentiveModelCriteriaList){
                    modelCriteriaId.put(modelCriteriaRec.Name,modelCriteriaRec.Id);  
            }
             for(String key5:slabMapVSRec.keyset()){
                List<Incentive_Slabs__c> slabList = slabMapVSRec.get(key5);
                for(Incentive_Slabs__c slabRec:slabList){
                    slabRec.Incentive_Model_Criteria__c=modelCriteriaId.get(key5);
                     incentiveSlabList.add(slabRec);
                }
            }
            Database.insert(new List<Incentive_Slabs__c>(incentiveSlabList), true);
        }catch(Exception ex){
            System.debug('Exception Message::'+ex.getMessage()+'Exception Line Number::'+ex.getLineNumber());
        }
        return incentivePlanRec.id;
    }
    @AuraEnabled
    public static Map<String,String> getApplicableIncentiveTypeValues(String ObjectName,String fieldName){
        Map<String,String> appIncentiveTypeMap=new Map<String,String>();  
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
            Schema.DescribeSObjectResult r = s.getDescribe() ;
            Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ple){
                appIncentiveTypeMap.put(pickListVal.getLabel(),pickListVal.getValue());
            }    
            System.debug(appIncentiveTypeMap);
        }catch(Exception ex){
            System.debug('Exception Message::'+ex.getMessage()+'Exception Line Number::'+ex.getLineNumber());
        }
        return appIncentiveTypeMap;
    }  
    public with sharing class IncentiveWrapper {
        @auraEnabled 
        public List<String> profileList {get;set;}
        @auraEnabled 
        public List<String> objectList{get;set;}
        @AuraEnabled
        public List<String> fieldList{get;set;} 
    }
    public with sharing class InputWrapper{
        @AuraEnabled 
        public String profile_Nm{get;set;}
        @AuraEnabled 
        public boolean isEnabled{get;set;}
        @AuraEnabled 
        public Date startDate{get;set;}
        @AuraEnabled 
        public Date endDate{get;set;}
        @AuraEnabled 
        public List<String> object_Nm{get;set;}
        @AuraEnabled 
        public List<String> evaluationField{get;set;}
        @AuraEnabled 
        public List<Integer> upperBound{get;set;}
        @AuraEnabled 
        public List<Integer> lowerBound{get;set;}
        @AuraEnabled 
        public List<Integer> incentiveAmount{get;set;}
        @AuraEnabled
        public List<String> applicableIncentiveType{get;set;}
    }
}
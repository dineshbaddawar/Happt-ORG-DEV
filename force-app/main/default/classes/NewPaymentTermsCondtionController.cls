public without sharing class NewPaymentTermsCondtionController {
    
    public class WrapperTermConditionClass {
        @AuraEnabled 
        public String sectionLineItemKey { get; set; }
        @AuraEnabled 
        public String attributeLineItemValue { get; set; }
        @AuraEnabled 
        public integer LatePaymentInterest { get; set; }
        @AuraEnabled 
        public integer YoYPUPMReport_50_100 { get; set; }
        @AuraEnabled 
        public integer pumaReportgreaterthan_100Map { get; set; }
        @AuraEnabled 
        public integer pumaReport20_ARRMap { get; set; }
    }
    
    public class ALIidDescriptionWrapper{
        @AuraEnabled 
        public String attributeLineId { get; set; }
        @AuraEnabled 
        public String attributeDescription { get; set; }
    }
    
    public class TermsAndConditionsWrapper {
        @AuraEnabled public Id termId;
        @AuraEnabled public String termName;
        @AuraEnabled public Id termAttributeLineItemId;
        @AuraEnabled public String termAttributeLineItemName;
        @AuraEnabled public Id termSectionLineItemId;
        @AuraEnabled public String termSectionLineItemName;
        @AuraEnabled public Id quoteId;
        @AuraEnabled public String quoteName;
    }
    
    @AuraEnabled
    public static  list<Term_Section_Line_Item__c>  getActivePaymentTermselectionItem() {
        try{
            String ProfileId = UserInfo.getProfileId();
            String profileName = [select Id, Name from Profile WHERE Id=:ProfileId].Name; 
            System.debug('profileName ====> '+profileName);
            Set<String> TermSectionLineItemsList = new Set<String>();
            List<String> sectionNameList = new List<String>();
            List<Terms_Contion_Section_Data__mdt> listofSectionProfileList = [SELECT Id,Label,Section_Name__c,Profile_Name__c FROM Terms_Contion_Section_Data__mdt];
            Map<String,List<String>> mapofProfileNameSectionList = new Map<String,List<String>>();
            for(Terms_Contion_Section_Data__mdt mtd : listofSectionProfileList){
                mapofProfileNameSectionList.put(mtd.Profile_Name__c,mtd.Section_Name__c.split(','));
            }
            //  sectionNameList = mapofProfileNameSectionList.get(profileName);
            if(String.isNotBlank(profileName)){
                if(profileName == Constant.PROFILE_INSIDE_SALES_TEAM){
                    TermSectionLineItemsList = new Set<String>{'OTI Payment Milestone', 'SAAS Start Date', 'Billing Type', 'Delay Payment Interest', 'Change Request', 'Payment Due Date', 'Lock In Perod', 'Contract Period', 'Contract Period','YoY | PUPM/Report >100'};
                        }
                else if(profileName == Constant.PROFILE_ENTERPRISE_TEAM){
                    TermSectionLineItemsList = new Set<String>{'OTI Payment Milestone', 'SAAS Start Date', 'Billing Type', 'Delay Payment Interest', 'Change Request', 'Payment Due Date', 'Lock In Perod', 'Contract Period', 'Contract Period', 'YoY | PUPM/Report 50-100', 'YoY | PUPM/Report >100'};
                        }
                else if(profileName == Constant.PROFILE_AM_TEAM){
                    TermSectionLineItemsList = new Set<String>{'OTI Payment Milestone', 'SAAS Start Date', 'Billing Type', 'Delay Payment Interest', 'Change Request', 'Payment Due Date', 'Lock In Perod', 'Contract Period', 'Contract Period', 'YoY | PUPM/Report 50-100', 'YoY | PUPM/Report >100', 'YoY | AMC 10-20% of ARR'};
                        }else{
                            TermSectionLineItemsList = new Set<String>{'OTI Payment Milestone', 'SAAS Start Date', 'Billing Type', 'Delay Payment Interest', 'Change Request', 'Payment Due Date', 'Lock In Perod', 'Contract Period', 'Contract Period', 'YoY | PUPM/Report 50-100', 'YoY | PUPM/Report >100', 'YoY | AMC 10-20% of ARR'};
                                } 
            }   
            Set<Id> TeamAttLI = new Set<Id>();
            Set<Id> TermSLI = new Set<Id>();
            List<Approval_Matrix__c> getProfileBaseAppMatList = [SELECT Id,Name,Profiles__c,Term_Attribute_Line_Item__c	 FROM Approval_Matrix__c WHERE Profiles__c =:profileName];
            for(Approval_Matrix__c app : getProfileBaseAppMatList){
                TeamAttLI.add(app.Term_Attribute_Line_Item__c);
            }     
            List<Term_Attribute_Line_Item__c> ListOfALI = [SELECT Id,Name,Description__c,Term_Section_Line_Item__c FROM Term_Attribute_Line_Item__c WHERE Id NOT IN:TeamAttLI];
            for(Term_Attribute_Line_Item__c tali : ListOfALI){
                TermSLI.add(tali.Term_Section_Line_Item__c);
            }
            list<Term_Section_Line_Item__c> TermSectionLineItemList =  [Select Id, Name,(SELECT Term_Section_Line_Item__c,Sequence__c,Inputbox__c,Comments__c,Description__c,Change_Request__c,Late_Payment_Interest__c, Name,Custom_Entry_Require__c, Id FROM Term_Attribute_Line_Items__r  ORDER BY Sequence__c ASC ) from Term_Section_Line_Item__c WHERE Name IN:TermSectionLineItemsList AND Is_Active__c=:true ORDER BY Sequence__c ASC];
            System.debug('TermSectionLineItemList ==== Size == >'+TermSectionLineItemList.size());
            return TermSectionLineItemList;
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    } 
    
    @AuraEnabled
    public static string createTermasCondition(string wrapperJsonList,String recordId,string descriptiontalidList){
        System.debug('wrapperJsonList ==== >'+wrapperJsonList);
        try{
            if(wrapperJsonList !=null && recordId !=null){
                string st;
                List<Terms_and_condition__c> termRecords = new List<Terms_and_condition__c>();
                List<Terms_and_condition__c> availableTermsAndCondition = new List<Terms_and_condition__c>();
                Map<Id,Id> mapofattributeIdByTCId = new Map<Id,Id>();
                Map<Id,String> mapOfSecaliDescription = new Map<Id,String>();
                availableTermsAndCondition = [select id,Term_Attribute_Line_Item__c,Term_Section_Line_Item__c from Terms_and_condition__c where Quote__c =: recordId];
                for(Terms_and_condition__c tc : availableTermsAndCondition){
                    mapofattributeIdByTCId.put(tc.Term_Section_Line_Item__c,tc.Id);
                }
                List<ALIidDescriptionWrapper> wrapperListdescription = (List<ALIidDescriptionWrapper>) JSON.deserialize(descriptiontalidList, List<ALIidDescriptionWrapper>.class);
                for(ALIidDescriptionWrapper wrap : wrapperListdescription){
                    if(wrap.attributeLineId !=null && String.isNotBlank(wrap.attributeDescription)){
                        mapOfSecaliDescription.put(wrap.attributeLineId,wrap.attributeDescription);
                    }
                }
                List<WrapperTermConditionClass> wrapperList = (List<WrapperTermConditionClass>) JSON.deserialize(wrapperJsonList, List<WrapperTermConditionClass>.class);
                for(WrapperTermConditionClass wrapper : wrapperList) {
                    Terms_and_condition__c termRecord = new Terms_and_condition__c();
                    if(wrapper.sectionLineItemKey != null && mapofattributeIdByTCId.containsKey(wrapper.sectionLineItemKey)){
                        termRecord.Id = mapofattributeIdByTCId.get(wrapper.sectionLineItemKey);
                    }
                    termRecord.Term_Section_Line_Item__c = wrapper.sectionLineItemKey;
                    termRecord.Term_Attribute_Line_Item__c = wrapper.attributeLineItemValue;
                    termRecord.Quote__c = recordId;
                    System.debug('wrapper.YoYPUPMReport_50_100 === >'+wrapper.YoYPUPMReport_50_100 +' && wrapper.pumaReportgreaterthan_100Map === >'+wrapper.pumaReportgreaterthan_100Map +' && wrapper.pumaReport20_ARRMap === >'+wrapper.pumaReport20_ARRMap +' && wrapper.LatePaymentInterest ==== >'+wrapper.LatePaymentInterest);
                    if(wrapper.LatePaymentInterest !=null){
                        termRecord.Late_Payment_Interest__c=wrapper.LatePaymentInterest; 
                    }
                    if(mapOfSecaliDescription.get(wrapper.attributeLineItemValue) !=null){
                        termRecord.Comments__c=mapOfSecaliDescription.get(wrapper.attributeLineItemValue); 
                    }
                    if(wrapper.YoYPUPMReport_50_100 !=null){
                        termRecord.YoY_PUPM_Report__c=wrapper.YoYPUPMReport_50_100;
                    }
                    if(wrapper.pumaReportgreaterthan_100Map !=null){
                        termRecord.YoY_PUPM_Report_100__c=wrapper.pumaReportgreaterthan_100Map;
                    }
                    if(wrapper.pumaReport20_ARRMap !=null){
                        termRecord.YoY_AMC_10_20_of_ARR__c=wrapper.pumaReport20_ARRMap;
                    }
                    termRecords.add(termRecord);
                }
                if(!termRecords.isEmpty()){
                    upsert termRecords;
                    system.debug('Inserted Record Size ====>'+ termRecords.size());
                }
                st = 'success';
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Terms_and_condition__c> getTermsConditions(id recordId){
        return [Select Id, name,Quote__c,Term_Attribute_Line_Item__c,Late_Payment_Interest__c,Change_Request__c,Term_Section_Line_Item__c,Comments__c from Terms_and_condition__c Where Quote__c =: recordId];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<TermsAndConditionsWrapper> getTermsAndConditions(Id quoteId) {
        List<Terms_and_condition__c> termsAndConditions = [SELECT Id, Name, Term_Attribute_Line_Item__c, Term_Attribute_Line_Item__r.Name, Term_Section_Line_Item__c, Term_Section_Line_Item__r.Name, Quote__c, Quote__r.Name FROM Terms_and_condition__c WHERE Quote__c = :quoteId];
        List<TermsAndConditionsWrapper> termsAndConditionsWrappers = new List<TermsAndConditionsWrapper>();
        for (Terms_and_condition__c term : termsAndConditions) {
            TermsAndConditionsWrapper wrapper = new TermsAndConditionsWrapper();
            wrapper.termId = term.Id;
            wrapper.termName = term.Name;
            wrapper.termAttributeLineItemId = term.Term_Attribute_Line_Item__c;
            wrapper.termAttributeLineItemName = term.Term_Attribute_Line_Item__r.Name;
            wrapper.termSectionLineItemId = term.Term_Section_Line_Item__c;
            wrapper.termSectionLineItemName = term.Term_Section_Line_Item__r.Name;
            wrapper.quoteId = term.Quote__c;
            wrapper.quoteName = term.Quote__r.Name;
            termsAndConditionsWrappers.add(wrapper);
        }
        System.debug('Size === >'+termsAndConditionsWrappers.size());
        return termsAndConditionsWrappers;
    }
    
}
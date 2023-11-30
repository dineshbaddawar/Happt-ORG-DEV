/**
* @description       : 
* @author            : Dhanush Babu
* @group             : 
* @last modified on  : 03-07-2023
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class PaymentTermsAndConditionsLWCController {
    
    public class WrapperClass {
        @AuraEnabled 
        public String quoteName { get; set; }
        @AuraEnabled 
        public String sectionLineItemKey { get; set; }
        @AuraEnabled 
        public String attributeLineItemValue { get; set; }
        @AuraEnabled 
        public String Comment { get; set; }
        @AuraEnabled 
        public integer LatePaymentInterest { get; set; }
        @AuraEnabled 
        public integer changeRequest { get; set; }
        @AuraEnabled 
        public integer Report50100 { get; set; }
    }

    public class opportunityWrapper {
        @auraEnabled
        public list<Term_Section_Line_Item__c> termsectionlist= new list<Term_Section_Line_Item__c>();
        @auraEnabled
        public Map<Term_Attribute_Line_Item__c,Approval_Matrix__c > stage2= new Map<Term_Attribute_Line_Item__c,Approval_Matrix__c >();
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

    //  Method old
    @AuraEnabled(Cacheable = true)
    public static  list<Term_Section_Line_Item__c>  PaymentTermselectionItem() {
        String ProfileId = UserInfo.getProfileId();
        String profileName = [select Id, Name from Profile WHERE Id=:ProfileId].Name; 
        Set<String> TermSectionLineItemsList = new Set<String>();

        if(String.isNotBlank(profileName)){
            if(profileName == 'Inside Sales'){
                TermSectionLineItemsList = new Set<String>{'Saas Start Date','Payment Due Date','Delay Payment Interest','OTI payment Milestone','Change Request','YoY | PUPM/Report >100','Lock In Perod','Contract Period'};
            }
            else if(profileName == 'Enterprise'){
                TermSectionLineItemsList = new Set<String>{'Saas Start Date','Payment Due Date','OTI payment Milestone','Change Request','YoY | PUPM/Report 50-100','Lock In Perod','Contract Period','Delay Payment Interest'};
            }
            else if(profileName == 'AM'){
                TermSectionLineItemsList = new Set<String>{'Saas Start Date','Payment Due Date','OTI payment Milestone','Change Request','YoY | PUPM < 50','Delay Payment Interest','Lock In Perod','Contract Period'};
            }else{
                TermSectionLineItemsList = new Set<String>{'OTI Payment Milestone', 'SAAS Start Date', 'Billing Type', 'Delay Payment Interest', 'Change Request', 'Payment Due Date', 'Lock In Perod', 'Contract Period', 'Contract Period', 'YoY | PUPM/Report 50-100', 'YoY | PUPM/Report >100', 'YoY | AMC 10-20% of ARR'};
            } 
        }
        System.debug('profileName ====> '+profileName);
        System.debug('TermSectionLineItemsList ====> '+TermSectionLineItemsList);

        Set<Id> TeamAttLI = new Set<Id>();
        Set<Id> TermSLI = new Set<Id>();
        List<Approval_Matrix__c> getProfileBaseAppMatList = [SELECT Id,Name,Profiles__c,Term_Attribute_Line_Item__c	 FROM Approval_Matrix__c WHERE Profiles__c =:profileName];
        for(Approval_Matrix__c app : getProfileBaseAppMatList){
            System.debug('App Profile Nmae === >'+app.Profiles__c);
            TeamAttLI.add(app.Term_Attribute_Line_Item__c);
        }
      //  System.debug('TeamAttLI === >'+TeamAttLI);        
        List<Term_Attribute_Line_Item__c> ListOfALI = [SELECT Id,Name,Description__c,Term_Section_Line_Item__c FROM Term_Attribute_Line_Item__c WHERE Id NOT IN:TeamAttLI];
      //  System.debug('ListOfALI Size === >'+ListOfALI.size());
      //  System.debug('ListOfALI Record === >'+ListOfALI);
        for(Term_Attribute_Line_Item__c tali : ListOfALI){
            TermSLI.add(tali.Term_Section_Line_Item__c);
        }
      // System.debug('TermSLI === >'+TermSLI);
        
        opportunityWrapper newWrap = new opportunityWrapper ();
       // for Profile Name Filter list<Term_Section_Line_Item__c> TermSectionLineItemList =  [Select Id, Name,(SELECT Term_Section_Line_Item__c,Sequence__c,Inputbox__c,Comments__c,Description__c,Change_Request__c,Late_Payment_Interest__c, Name,Custom_Entry_Require__c, Id FROM Term_Attribute_Line_Items__r WHERE ID NOT IN:TeamAttLI  ORDER BY Sequence__c ASC ) from Term_Section_Line_Item__c WHERE ID IN:TermSLI];
        list<Term_Section_Line_Item__c> TermSectionLineItemList =  [Select Id, Name,(SELECT Term_Section_Line_Item__c,Sequence__c,Inputbox__c,Comments__c,Number_Input__c,Description__c,Change_Request__c,Late_Payment_Interest__c,Waiver_Off_Check__c, Name,Custom_Entry_Require__c, Id FROM Term_Attribute_Line_Items__r  ORDER BY Sequence__c ASC ) from Term_Section_Line_Item__c WHERE Name IN:TermSectionLineItemsList AND Is_Active__c=:true];
        
        for(Term_Section_Line_Item__c termsection: TermSectionLineItemList){
            System.debug('TSLI Name === >'+termsection.Name);
            newWrap.termsectionlist.add (termsection);
        }
        System.debug('TermSectionLineItemList ==== Size == >'+TermSectionLineItemList.size());
        return TermSectionLineItemList;
    }
    
    // method New
     @AuraEnabled
    public static  list<Term_Section_Line_Item__c>  getActivePaymentTermselectionItem() {
        String ProfileId = UserInfo.getProfileId();
        String profileName = [select Id, Name from Profile WHERE Id=:ProfileId].Name; 
        System.debug('profileName ====> '+profileName);
        Set<String> TermSectionLineItemsList = new Set<String>();
        if(String.isNotBlank(profileName)){
            if(profileName == Constant.PROFILE_INSIDE_SALES_TEAM){
                TermSectionLineItemsList = new Set<String>{'Saas Start Date','Payment Due Date','Delay Payment Interest','OTI payment Milestone','Change Request','YoY | PUPM/Report >100','Lock In Perod','Contract Period'};
                    }
            else if(profileName == Constant.PROFILE_ENTERPRISE_TEAM){
                TermSectionLineItemsList = new Set<String>{'Saas Start Date','Payment Due Date','OTI payment Milestone','Change Request','YoY | PUPM/Report 50-100','Lock In Perod','Contract Period','Delay Payment Interest'};
                    }
            else if(profileName == Constant.PROFILE_AM_TEAM){
                TermSectionLineItemsList = new Set<String>{'Saas Start Date','Payment Due Date','OTI payment Milestone','Change Request','YoY | PUPM < 50','Delay Payment Interest','Lock In Perod','Contract Period'};
                    }else{
                        TermSectionLineItemsList = new Set<String>{'OTI Payment Milestone', 'SAAS Start Date', 'Billing Type', 'Delay Payment Interest', 'Change Request', 'Payment Due Date', 'Lock In Perod', 'Contract Period', 'Contract Period', 'YoY | PUPM/Report 50-100', 'YoY | PUPM/Report >100', 'YoY | AMC 10-20% of ARR'};
                            } 
        }
        Set<Id> TeamAttLI = new Set<Id>();
        Set<Id> TermSLI = new Set<Id>();
        List<Approval_Matrix__c> getProfileBaseAppMatList = [SELECT Id,Name,Profiles__c,Term_Attribute_Line_Item__c	 FROM Approval_Matrix__c WHERE Profiles__c =:profileName];
        for(Approval_Matrix__c app : getProfileBaseAppMatList){
            System.debug('App Profile Nmae === >'+app.Profiles__c);
            TeamAttLI.add(app.Term_Attribute_Line_Item__c);
        }     
        List<Term_Attribute_Line_Item__c> ListOfALI = [SELECT Id,Name,Description__c,Term_Section_Line_Item__c FROM Term_Attribute_Line_Item__c WHERE Id NOT IN:TeamAttLI];
        for(Term_Attribute_Line_Item__c tali : ListOfALI){
            TermSLI.add(tali.Term_Section_Line_Item__c);
        }
        list<Term_Section_Line_Item__c> TermSectionLineItemList =  [Select Id, Name,(SELECT Term_Section_Line_Item__c,Sequence__c,Inputbox__c,Comments__c,Description__c,Change_Request__c,Late_Payment_Interest__c,Waiver_Off_Check__c, Name,Custom_Entry_Require__c, Id FROM Term_Attribute_Line_Items__r  ORDER BY Sequence__c ASC ) from Term_Section_Line_Item__c WHERE Name IN:TermSectionLineItemsList AND Is_Active__c=:true];
        System.debug('TermSectionLineItemList ==== Size == >'+TermSectionLineItemList.size());
        return TermSectionLineItemList;
    } 
    
    
    @AuraEnabled(Cacheable = true)
    Public Static list<Approval_Matrix__c> getMatrixByProfile(){
        Id profileId = UserInfo.getProfileId();
        String userProfileName = [SELECT Name FROM Profile WHERE Id = :profileId].Name;
        System.debug('User Profile Name: ' + userProfileName);
        list<Approval_Matrix__c> approvalMatrixlist = [SELECT Id, Name, Profiles__c, Approving_Authority__c, Term_Attribute_Line_Item__c, Allowed__c FROM Approval_Matrix__c Where Profiles__c =: userProfileName ];
        return approvalMatrixlist;
    }
    @AuraEnabled(Cacheable = true)
    Public Static list<Terms_and_condition__c> getAvailableTermsAndCondition (Id quoteId){
        List<Terms_and_condition__c> availableTermsAndCondition = new List<Terms_and_condition__c>();
        availableTermsAndCondition = [select id,Term_Attribute_Line_Item__c from Terms_and_condition__c where Quote__c =: quoteId];
        return availableTermsAndCondition;
    }
    
    @AuraEnabled
    public static string saveTC(List<Terms_and_condition__c> tcList,Id quoteId){
        System.debug('tcList size === >'+tcList.size());
        try {
            List<Terms_and_condition__c> availableTermsAndCondition = new List<Terms_and_condition__c>();
            List<Terms_and_condition__c> termRecords = new List<Terms_and_condition__c>();
            Map<Id,Id> mapofattributeIdByTCId = new Map<Id,Id>();
            availableTermsAndCondition = [select id,Term_Attribute_Line_Item__c,Term_Section_Line_Item__c from Terms_and_condition__c where Quote__c =: quoteId];
            for(Terms_and_condition__c tc : availableTermsAndCondition){
                mapofattributeIdByTCId.put(tc.Term_Section_Line_Item__c,tc.Id);
            }
           System.debug('mapofattributeIdByTCId === >'+mapofattributeIdByTCId);
            for(Terms_and_condition__c tcRec : tcList){
                System.debug('tcRec First Record === >'+tcRec);
                Terms_and_condition__c termRecord = new Terms_and_condition__c();
                system.debug('termRecord.Term_Section_Line_Item__c ==== >'+termRecord.Term_Section_Line_Item__c);
                system.debug('mapofattributeIdByTCId.containsKey(termRecord.Term_Section_Line_Item__c) === >'+mapofattributeIdByTCId.containsKey(termRecord.Term_Section_Line_Item__c));
                if(tcRec.Term_Section_Line_Item__c != null && mapofattributeIdByTCId.containsKey(tcRec.Term_Section_Line_Item__c)){
                    termRecord.Id = mapofattributeIdByTCId.get(tcRec.Term_Section_Line_Item__c);
                }
                termRecord.Term_Section_Line_Item__c = tcRec.Term_Section_Line_Item__c;
                termRecord.Term_Attribute_Line_Item__c = tcRec.Term_Attribute_Line_Item__c;
                termRecord.Quote__c = quoteId;
                System.debug('termRecord Last ==== >'+termRecord);
                termRecords.add(termRecord);
                
            }
            if(!termRecords.isEmpty()){
                upsert termRecords;
                System.debug('termRecords Size ==== >'+termRecords.size());
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        return 'success';
    }

    @AuraEnabled
    public static String createTC(String wrapperListJson, id recordId){
        System.debug('wrapperListJson Method 1 ==== >'+wrapperListJson);
        string st;
        List<Terms_and_condition__c> availableTermsAndCondition = new List<Terms_and_condition__c>();
        Map<Id,Id> mapofattributeIdByTCId = new Map<Id,Id>();
        availableTermsAndCondition = [select id,Term_Attribute_Line_Item__c,Term_Section_Line_Item__c from Terms_and_condition__c where Quote__c =: recordId];
        for(Terms_and_condition__c tc : availableTermsAndCondition){
            mapofattributeIdByTCId.put(tc.Term_Section_Line_Item__c,tc.Id);
        }
        System.debug('mapofattributeIdByTCId Map ==== >'+mapofattributeIdByTCId);
        //list<Approval_Matrix__c> ApprovalMatrixList = getMatrixByProfile();
        List<WrapperClass> wrapperList = (List<WrapperClass>) JSON.deserialize(wrapperListJson, List<WrapperClass>.class);
        system.debug('wrapperList ==== >'+wrapperList);
        List<Terms_and_condition__c> termRecords = new List<Terms_and_condition__c>();
        try{
            for(WrapperClass wrapper : wrapperList) {
                System.debug('wrapper ==== >'+wrapper);
                Terms_and_condition__c termRecord = new Terms_and_condition__c();
                if(wrapper.sectionLineItemKey != null && mapofattributeIdByTCId.containsKey(wrapper.sectionLineItemKey)){
                    termRecord.Id = mapofattributeIdByTCId.get(wrapper.sectionLineItemKey);
                }
                termRecord.Term_Section_Line_Item__c = wrapper.sectionLineItemKey;
                termRecord.Term_Attribute_Line_Item__c = wrapper.attributeLineItemValue;
                termRecord.Quote__c = recordId;
                termRecord.Comments__c=wrapper.Comment;
                termRecord.Late_Payment_Interest__c=wrapper.LatePaymentInterest; 	
                termRecord.Change_Request__c=wrapper.changeRequest; 
                termRecord.YoY_PUPM_Report__c=wrapper.Report50100;
                termRecords.add(termRecord);
            }
            system.debug('termRecords Before Upsert === >'+termRecords);
            if(!termRecords.isEmpty()){
                upsert termRecords;
                system.debug('Inserted Record Size ====>'+ termRecords.size());
            }
            st = 'success';
        }
        catch(Exception e){
            system.debug(e.getMessage()+ ' is '+ e.getLineNumber());
            st = e.getMessage()+ ' is '+ e.getLineNumber();
        }
        return st;
        
    }
    
    @AuraEnabled(cacheable=true)
    public static list<Terms_and_condition__c> getTermsConditions(id recordId){
        return [Select Id, name,Quote__c,Term_Attribute_Line_Item__c,Late_Payment_Interest__c,Change_Request__c,Term_Section_Line_Item__c,Comments__c from Terms_and_condition__c Where Quote__c =: recordId];
        
    }
    
}
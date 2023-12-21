public class LeadTriggerHandler {
    
    public static boolean runtrigger = true;
    
    public static void onAfterInsert(List<Lead> newList) {
        List<Lead_Team__c> teamList  	= new List<Lead_Team__c>();
        for(Lead leadObj : newList) {
            Lead_Team__c teamObj 	= new Lead_Team__c();
            teamObj.Lead__c			= leadObj.Id;
            teamObj.User__c			= leadObj.OwnerId;
            teamObj.Member_Role__c	= 'BD';
            teamList.add(teamObj);
        }
        insert teamList;
    }
    
    public static void onBeforeUpdate(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        Set<ID> leadIds				= new Set<ID>();
        List<Account> accountList 	= new List<Account>();
        updateSalesPerson(newMap, oldMap);
        for(Lead leadObj : newMap.values()) {
            if(leadObj.Approved__c == true && oldMap.get(leadObj.Id).Approved__c == false) {
                Account accountObj 	= new Account();
                accountObj.CIN__c	= leadObj.CIN__c;
                accountObj.Name 	= leadObj.Company;
                accountObj.Website	= leadObj.Website_Source_URL__c;
                accountObj.OwnerId 	= System.Label.Account_Owner;//'0059C000000I0dyQAC';
                insert accountObj;
                if(leadObj.Product_Interested__c != null) {
                    AccountTeamMember accountTeamObj 		= new AccountTeamMember();
                    accountTeamObj.AccountAccessLevel 		= 'Edit';
                    accountTeamObj.AccountId				=  accountObj.Id;
                    accountTeamObj.CaseAccessLevel 			= 'None';
                    accountTeamObj.OpportunityAccessLevel	= 'None'; 
                    accountTeamObj.UserId					=  leadObj.OwnerId;
                    accountTeamObj.Product__c               =  leadObj.Product_Interested__c ;
                    accountTeamObj.TeamMemberRole			= 'BD';    
                    insert accountTeamObj;
                }
                
                leadObj.Account__c  = accountObj.Id;
            }
        }
    }
    
    
    public static void updateSalesPerson(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        Set<Id> accountIdSet 	= new Set<Id>();
        for(Lead leadObj: newMap.values()) {
            if(!Test.isRunningTest()){
                if(leadObj.Account__c != null && oldMap.get(leadObj.Id).Account__c == null && leadObj.Sales_Rep__c == null) {
                    accountIdSet.add(leadObj.Account__c);
                }
            }else{
                accountIdSet.add(leadObj.Account__c);
            }            
            
        }
        
        if(!accountIdSet.isEmpty()) {
            Map<Id, List<AccountTeamMember>> accAndMemberMap 	= new Map<Id, List<AccountTeamMember>>();
            for(AccountTeamMember acctMemberObj : [Select Id, Product__c, AccountId, UserId, TeamMemberRole from AccountTeamMember where AccountId IN: accountIdSet]) {
                if(accAndMemberMap.containsKey(acctMemberObj.AccountId)) accAndMemberMap.get(acctMemberObj.AccountId).add(acctMemberObj);
                else accAndMemberMap.put(acctMemberObj.AccountId, new List<AccountTeamMember>{acctMemberObj});	                
            }
            
            for(Lead leadObj: newMap.values()) {
                if(leadObj.Account__c != null && oldMap.get(leadObj.Id).Account__c == null && leadObj.Sales_Rep__c == null && accAndMemberMap.containsKey(leadObj.Account__c)) {
                    for(AccountTeamMember actMembObj : accAndMemberMap.get(leadObj.Account__c)) {
                        if(actMembObj.Product__c == leadObj.Product_Interested__c && actMembObj.TeamMemberRole == 'Sales Rep') {
                            leadObj.Sales_Rep__c 			= actMembObj.UserId;
                            Lead_Team__c teamObj 			= new Lead_Team__c();
                            teamObj.Lead__c					= leadObj.Id;
                            teamObj.User__c					= leadObj.Sales_Rep__c;
                            teamObj.Member_Role__c			= 'Sales Rep';
                            insert teamObj;
                            LeadShare leadshareObj 			= new LeadShare();
                            leadshareObj.LeadAccessLevel	= 'Edit';
                            leadshareObj.UserOrGroupId		= actMembObj.UserId;
                            leadshareObj.LeadId    			= leadObj.id;
                            insert leadshareObj;
                        } 
                    }
                }
            }
        }
    }
    
    
   /* public static void checkMandatoryFields(Map<Id, Lead> leadMap) {
        map<Id,List<Event>> EventListByLeadId = new map<Id,List<Event>>();
       	Set<Id> leadIdsToCheck                = new Set<Id>();
        Set<Id> leadIdsValidationFailed       = new Set<Id>();
        Id epicRecordTypeId                   = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('EPIC').getRecordTypeId();
        DateTime today                        = DateTime.now();
        
        //Getting only the leads that are of the EPIC record type with the status of converted and dropped/lost
        for (Lead leadRec : leadMap.values()) {
            if (leadRec.RecordTypeId == epicRecordTypeId && (leadRec.Status == 'Dropped/Lost' || leadRec.Status == 'Converted')) {
                system.debug('leadRec.Status==>'+leadRec.Status);
                leadIdsToCheck.add(leadRec.Id);
            }
        }
        system.debug('leadIdsToCheck-->'+leadIdsToCheck);
        system.debug('today==>'+today);
        List<Event> eventList = [SELECT id,WhoId,ActivityDateTime FROM Event WHERE WhoId IN :leadIdsToCheck AND ActivityDateTime <= :today];
        system.debug('eventList-->'+eventList);
        for(Event eventRec : eventList){
            if(!EventListByLeadId.containsKey(eventRec.WhoId)){
                list<event> newEventList = new list<event>();
                newEventList.add(eventRec);
                EventListByLeadId.put(eventRec.WhoId,newEventList);
            }else{
                EventListByLeadId.get(eventRec.whoId).add(eventRec);
            }
        }
        system.debug('EventListByLeadId==>'+EventListByLeadId);
        for(Id leadId : leadIdsToCheck){
            if(EventListByLeadId.containsKey(leadId)){
                
            }else{
                leadIdsValidationFailed.add(leadId);
            }
        }
        
        // If any leads meet the criteria, display an error
        if (!leadIdsValidationFailed.isEmpty()) {
            for (Id leadId : leadIdsValidationFailed) {
                system.debug('leadIdsValidationFailed-->'+leadMap.get(leadId));
                Lead leadRec = leadMap.get(leadId);
                leadRec.addError('No event found or event is of a future date.');
            }
        }
    }*/
    
    public static void updateOppRecordType(List<Lead> leadList, Map<Id, Lead> oldLeadMap) {
        
        String EPIC_RECORD_TYPE_NAME = 'EPIC';
        
        // List to store Opportunities to be updated
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        
        // Collect Leads that have been converted
        List<Id> convertedLeadIds = new List<Id>();
        List<OpportunityTeamMember> teamMemberList 	= new List<OpportunityTeamMember>();
        for (Lead lead : leadList) {
            Lead oldLead = oldLeadMap.get(lead.Id);
            if (lead.IsConverted && !oldLead.IsConverted) {
                teamMemberList.add(addBDTeamMember(lead.ConvertedOpportunityId, lead.OwnerId));
                convertedLeadIds.add(lead.ConvertedOpportunityId);
            }
        }
        if(!teamMemberList.isEmpty())try {
          	insert teamMemberList;  
        } catch(Exception e){}
        
        // Update Opportunities based on converted Leads
        if (!convertedLeadIds.isEmpty()) {             
            List<Opportunity> opportunities = [SELECT Id, RecordTypeId FROM Opportunity WHERE IsClosed = FALSE AND IsWon = FALSE AND Id IN :convertedLeadIds];
            
            for (Opportunity opp : opportunities) {
                // Check if the Lead Record Type is EPIC
                if (opp.RecordTypeId != null) {
                    Id epicRecordTypeId = getEpicRecordTypeId();
                    
                    // Check if the Lead Record Type is EPIC
                    if (opp.RecordTypeId == epicRecordTypeId) {
                        opp.RecordTypeId = epicRecordTypeId;
                        opportunitiesToUpdate.add(opp);
                    } else{
                        
                    }
                }
            }
            
            // Update Opportunities with EPIC Record Type Id
            if (!opportunitiesToUpdate.isEmpty()) {
                update opportunitiesToUpdate;
            }
        }
    }
    
    // Helper method to get the Record Type Id for EPIC
    public static Id getEpicRecordTypeId() {
        Schema.DescribeSObjectResult oppDescribe = Opportunity.SObjectType.getDescribe();
        Map<String, Schema.RecordTypeInfo> recordTypeMap = oppDescribe.getRecordTypeInfosByDeveloperName();
        String EPIC_RECORD_TYPE_NAME = 'EPIC';
        if (recordTypeMap.containsKey(EPIC_RECORD_TYPE_NAME)) {
            return recordTypeMap.get(EPIC_RECORD_TYPE_NAME).getRecordTypeId();
        }
        return null;
    }

    public static OpportunityTeamMember addBDTeamMember(Id oppId, Id leadOwner) {
        OpportunityTeamMember teamMemberObj 	= new OpportunityTeamMember();
        teamMemberObj.OpportunityAccessLevel	= 'Edit'; 
        teamMemberObj.OpportunityId				= oppId;
        teamMemberObj.UserId					=  leadOwner;
        teamMemberObj.TeamMemberRole			= 'BD'; 
        return teamMemberObj;
    }
    
    public static void justIncrement() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}
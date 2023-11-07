public class LeadTriggerHandler {
    
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
                accountObj.OwnerId 	= '0059C000000I0dyQAC';
                insert accountObj;
                if(leadObj.Product_Interested__c.contains('Travel & Expense (T&E)')) {
                    AccountTeamMember accountTeamObj 		= new AccountTeamMember();
                    accountTeamObj.AccountAccessLevel 		= 'Edit';
                    accountTeamObj.AccountId				=  accountObj.Id;
                    accountTeamObj.CaseAccessLevel 			= 'None';
                    accountTeamObj.OpportunityAccessLevel	= 'None'; 
                    accountTeamObj.UserId					=  leadObj.OwnerId;
                    accountTeamObj.Product__c               =  'Travel & Expense (T&E)';
                    accountTeamObj.TeamMemberRole			= 'BD';    
                    insert accountTeamObj;
                }
                
                leadObj.Account__c  = accountObj.Id;
            }
        }
    }
    
    
    static void updateSalesPerson(Map<Id, Lead> newMap, Map<Id, Lead> oldMap) {
        Set<Id> accountIdSet 	= new Set<Id>();
        for(Lead leadObj: newMap.values()) {
            if(leadObj.Account__c != null && oldMap.get(leadObj.Id).Account__c == null && leadObj.Sales_Rep__c == null) {
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
    
    public static void checkMandatoryFields(List<Lead> leadList, Map<Id, Lead> leadMap){
        
        Set<Id> leadIdsToCheck = new Set<Id>();
        
        Id epicRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('EPIC').getRecordTypeId();
        
        for (Lead lead : leadList) {
            // Check if the Lead meets the criteria
            if (lead.RecordTypeId == epicRecordTypeId &&
                (lead.Status == 'Dropped/Lost' || lead.Status == 'Converted') &&
                (lead.Monthly_Credit_Limit_Required__c == null || getRelatedEventCount(lead.Id) == 0)) {
                    leadIdsToCheck.add(lead.Id);
                }
        }
        system.debug('leadIdsToCheck' + leadIdsToCheck);
        // If any leads meet the criteria, display an error
        if (!leadIdsToCheck.isEmpty()) {
            for (Id leadId : leadIdsToCheck) {
                Lead lead = leadMap.get(leadId);
                lead.addError('Monthly Credit Limit Required and at least one Event are required when changing to Dropped/Lost or Converted.');
            }
        }
    }
    
    // Helper method to count related events for a Lead
    public static Integer getRelatedEventCount(Id leadId) {
        
        return [SELECT COUNT() FROM Event WHERE WhoId = :leadId];
    }
}
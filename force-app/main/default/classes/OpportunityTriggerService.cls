public class OpportunityTriggerService {
    
    public static void updateOwner(List<Opportunity> newList) {
        Set<Id> accountIdSet = new Set<Id>();
        Map<Id, List<AccountTeamMember>> accAndMemberMap = new Map<Id, List<AccountTeamMember>>();
        Id loggedInUserId = UserInfo.getUserId();
        
        for (Opportunity oppObj : newList) {
            accountIdSet.add(oppObj.AccountId);
            
            /*if (oppObj.RecordTypeId == '012C2000000C3oXIAS') {
                // Set ownerId to logged-in user if the opportunity is of EPIC record type
                oppObj.OwnerId = loggedInUserId;
            }*/
            
            if (oppObj.Product_Interested__c == 'Employee Tax Benefits') {
                oppObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Employee Tax Benefits')
                    .getRecordTypeId();
            }
            
            if (oppObj.Product_Interested__c == 'Travel & Expense (T&E)') {
                oppObj.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Travel & Expense')
                    .getRecordTypeId();
            }
        }
        
        for (AccountTeamMember acctMemberObj : [SELECT Id, Product__c, AccountId, UserId, TeamMemberRole
                                                FROM AccountTeamMember WHERE AccountId IN: accountIdSet]) {
                                                    if (accAndMemberMap.containsKey(acctMemberObj.AccountId)) {
                                                        accAndMemberMap.get(acctMemberObj.AccountId).add(acctMemberObj);
                                                    } else {
                                                        accAndMemberMap.put(acctMemberObj.AccountId, new List<AccountTeamMember>{acctMemberObj});
                                                    }
                                                }
        
        for (Opportunity oppObj : newList) {
            if (accAndMemberMap.get(oppObj.AccountId) != null) {
                for (AccountTeamMember actMembObj : accAndMemberMap.get(oppObj.AccountId)) {
                    if (actMembObj.Product__c == oppObj.Product_Interested__c && actMembObj.TeamMemberRole == 'Sales Rep') {
                        oppObj.BD_Team_Member__c = oppObj.OwnerId;
                        oppObj.OwnerId = actMembObj.UserId;
                        oppObj.Sales_Rep__c = actMembObj.UserId;
                        oppObj.Presales_Rep__c = null;
                    }
                }
            }
            
            if (oppObj.Product_Interested__c.contains('Travel & Expense (T&E)')) {
                // Commented by Anjali 
                // oppObj.Presales_Rep__c = [Select Id from User where PreSales_Team_Member_of_Products__c = 'Travel & Expense (T&E)' LIMIT 1].Id;
            }
            if (oppObj.Product_Interested__c.contains('Employee Tax Benefits')) {
                oppObj.Presales_Rep__c = [SELECT Id FROM User WHERE PreSales_Team_Member_of_Products__c = 'Employee Tax Benefits' LIMIT 1].Id;
            }
        }
    }
    
    
    public static void createOpportunityTeam(List<Opportunity> newList) {
        
        List<OpportunityTeamMember> optList = new List<OpportunityTeamMember>();
        List<String> accids = new List<String>();
        map<Id,AccountTeamMember> accIdByTeamMember = new map<Id,AccountTeamMember>();
        for(Opportunity opp : newList){
            accids.add(opp.AccountId);
        }
        
        List<AccountTeamMember> bdTeamMember = [Select UserId, AccountId from AccountTeamMember where AccountId IN: accids AND TeamMemberRole = 'BD' LIMIT 1];
        Map<Id, Id> mapOfAccIdWithBdUserId = new Map<Id, Id>();
        for(AccountTeamMember tMember : bdTeamMember){
            mapOfAccIdWithBdUserId.put(tMember.AccountId, tMember.UserId)  ;    
        }
        
        List<AccountTeamMember> salesRepTeamMember = [Select UserId, AccountId from AccountTeamMember where AccountId IN: accids AND TeamMemberRole = 'Sales Rep' LIMIT 1];
        Map<Id, Id> mapOfAccIdWithSalesRepUserId = new Map<Id, Id>();
        for(AccountTeamMember tMember : salesRepTeamMember){
            mapOfAccIdWithSalesRepUserId.put(tMember.AccountId, tMember.UserId)  ;    
        }
        
        for(Opportunity opp : newList){
            OpportunityTeamMember optObj 	= new OpportunityTeamMember();
            optObj.OpportunityAccessLevel 	= 'Edit';
            if(mapOfAccIdWithBdUserId.containsKey(opp.AccountId) && mapOfAccIdWithBdUserId.get(opp.AccountId) != null){
                optObj.UserId 				= mapOfAccIdWithBdUserId.get(opp.AccountId);
            }
            //optObj.UserId 					= [Select UserId from AccountTeamMember where AccountId =: opp.AccountId AND TeamMemberRole = 'BD' LIMIT 1].UserId;
            
            optObj.OpportunityId			= opp.Id;
            optobj.Product__c               = 'Travel & Expense (T&E)';
            optObj.TeamMemberRole			= 'BD';
            OpportunityTeamMember optObj1 	= new OpportunityTeamMember();
            optObj1.OpportunityAccessLevel 	= 'Edit';
            if(mapOfAccIdWithSalesRepUserId.containsKey(opp.AccountId) && mapOfAccIdWithSalesRepUserId.get(opp.AccountId) != null){
                optObj1.UserId 				= mapOfAccIdWithSalesRepUserId.get(opp.AccountId);
            }            
            //optObj1.UserId 					= [Select UserId from AccountTeamMember where AccountId =: opp.AccountId AND TeamMemberRole = 'Sales Rep' LIMIT 1].UserId;
            optObj1.OpportunityId			= opp.Id;
            optObj1.Product__c              = 'Travel & Expense (T&E)';
            optObj1.TeamMemberRole			= 'Sales Rep';
            optList.add(optObj);
            optList.add(optObj1);
            //            opp.OwnerId = optObj1.UserId;
        }        
        if(!optList.isEmpty()) insert optList;
    }
    
    public static void createPreSalesOppTeamMember(Map<Id, Opportunity> newMap, Map<Id, Opportunity> oldMap) {
        List<OpportunityTeamMember> optList 			= new List<OpportunityTeamMember>();
        for(Opportunity oppObj : newMap.values()) {
            if(oppObj.Presales_Rep__c != oldMap.get(oppObj.Id).Presales_Rep__c && oppObj.Presales_Rep__c != null) {
                OpportunityTeamMember optObj 	= new OpportunityTeamMember();
                optObj.OpportunityAccessLevel 	= 'Edit';
                optObj.UserId 					= oppObj.Presales_Rep__c;
                optObj.OpportunityId			= oppObj.Id;
                optObj.TeamMemberRole			= 'Pre-Sales';
                optList.add(optObj);
            }
        }
        if(!optList.isEmpty()) insert optList;
    }
    
    static OpportunityLineItem createProducts(Opportunity oppObj) {
        
        OpportunityLineItem oppLineObj 	= new OpportunityLineItem();
        oppLineObj.OpportunityId 		= oppObj.Id;
        oppLineObj.Quantity 			= 1;
        
        //oppLineObj.UseStandardPrice		= true;
        if(oppObj.Product_Interested__c.contains('Employee Tax Benefits')) {
            oppLineObj.PricebookEntryId	= [Select Id from PricebookEntry where Product2.Name = 'Employee Advance Module - OTI' AND Pricebook2.Name = 'Standard Price Book'].Id;	
            oppLineObj.UnitPrice 		= 100000.00;
            return oppLineObj;
        }
        if(oppObj.Product_Interested__c.contains('Travel & Expense (T&E)')) {
            oppLineObj.UnitPrice 		= 120;
            oppLineObj.PricebookEntryId	= [Select Id from PricebookEntry where Product2.Name = 'EM Happay Standard' AND Pricebook2.Name = 'Standard Price Book'].Id;	
            return oppLineObj;
        }
        return null;        
    }    
    
    
    public static void mandatoryFields1stStageEPIC(List<Opportunity> oppList, Map<Id, Opportunity> oppMap) {
        
        Set<Id> opportunityIdsToCheck = new Set<Id>();
        
        for (Opportunity opp : oppList) {
            Opportunity oldOpp = oppMap.get(opp.Id);
            
            if (opp.StageName != oldOpp.StageName && oldOpp.StageName == 'Documents Shared - Qualifying') {
                system.debug('opp.StageName' + opp.StageName);
                system.debug('oldOpp.StageName' + oldOpp.StageName);
                // Check if Necessary Documents are uploaded or not
                if (opp.Type__c == null || opp.Audit_Financials_Current_Years__c == FALSE || opp.Provisional_Financial_Current_Year__c == FALSE || opp.Current_Year_Financials_till_date__c == FALSE 
                    || opp.Top_10_Supplier_Customer_List__c == FALSE || opp.KYC_Company_PAN_All_Directors_Chairman__c == FALSE || opp.Short_term_Debt_Long_Term_Debt__c == FALSE || 
                    opp.Bank_Statements_6_months_1_year__c == FALSE || opp.Audit_Financials_Previous_Years__c == FALSE) {
                        
                        opp.addError('Please verify all the required documents and fill in the Type field.');
                    } else {
                        opportunityIdsToCheck.add(opp.Id);
                    }
            }
        }
        
        // Query Credit Risk Queries related to the selected Opportunities
        Map<Id, Credit_Risk_Query__c> creditRiskQueriesMap = new Map<Id, Credit_Risk_Query__c>();
        
        for (Credit_Risk_Query__c riskQuery : [SELECT Opportunity__c, Status__c FROM Credit_Risk_Query__c WHERE Opportunity__c IN :opportunityIdsToCheck
                                               AND RecordType.DeveloperName = 'Document_Shared']) {
                                                   creditRiskQueriesMap.put(riskQuery.Opportunity__c, riskQuery);
                                               }
        
        for (Opportunity opp : oppList) {
            Credit_Risk_Query__c riskQuery = creditRiskQueriesMap.get(opp.Id);
            if (riskQuery != null && riskQuery.Status__c != 'Resolved') {
                opp.addError('Opportunity stage cannot be changed when there are open Credit Risk Queries.');
            }
        }
    }
    
    
    public static void mandatoryFields2ndStageEPIC(List<Opportunity> oppList, Map<Id, Opportunity> oppMap) {
        
        Set<Id> opportunityIdsToCheck = new Set<Id>();
        
        for (Opportunity opp : oppList) {
            Opportunity oldOpp = oppMap.get(opp.Id);
            
            if (opp.StageName != oldOpp.StageName && oldOpp.StageName == 'Internal Underwriting') {
                // Check if Credit_Limit_Proposed__c is not filled
                if (opp.Credit_Limit_Proposed__c == null || opp.CFP__c == null || opp.Credit_Rating__c == null ) {
                    opp.addError('Credit Limit Proposed, CFP and Credit Rating is required to change the stage.');
                } else {
                    opportunityIdsToCheck.add(opp.Id);
                }
            }
        }
        
        // Query Credit Risk Queries related to the selected Opportunities
        Map<Id, Credit_Risk_Query__c> creditRiskQueriesMap = new Map<Id, Credit_Risk_Query__c>();
        
        for (Credit_Risk_Query__c riskQuery : [SELECT Opportunity__c, Status__c FROM Credit_Risk_Query__c WHERE Opportunity__c IN :opportunityIdsToCheck
                                               AND RecordType.DeveloperName = 'Internal_Underwriting']) {
                                                   creditRiskQueriesMap.put(riskQuery.Opportunity__c, riskQuery);
                                               }
        
        for (Opportunity opp : oppList) {
            Credit_Risk_Query__c riskQuery = creditRiskQueriesMap.get(opp.Id);
            if (riskQuery != null && riskQuery.Status__c != 'Resolved') {
                opp.addError('Opportunity stage cannot be changed when there are open Credit Risk Queries.');
            }
        }
    }
    
    public static void mandatoryFields3rdStageEPIC(List<Opportunity> oppList, Map<Id, Opportunity> oppMap) {
        
        Set<Id> opportunityIdsToCheck = new Set<Id>();
        
        for (Opportunity opp : oppList) {
            Opportunity oldOpp = oppMap.get(opp.Id);
            
            if (opp.StageName != oldOpp.StageName && oldOpp.StageName == 'CFP Underwriting') {
                // Check if Sanction_Limit__c is not filled
                if (opp.Sanction_Limit__c == null || opp.CFP_Point_of_Contact__c == null || opp.Sanction_Expiry_Date__c == null) {
                    opp.addError('Sanction Limit, Sanction Expiry Date and CFP point of contact is required to change the stage.');
                } else {
                    opportunityIdsToCheck.add(opp.Id);
                }
            }
        }
        
        // Query Credit Risk Queries related to the selected Opportunities
        Map<Id, Credit_Risk_Query__c> creditRiskQueriesMap = new Map<Id, Credit_Risk_Query__c>();
        
        for (Credit_Risk_Query__c riskQuery : [SELECT Opportunity__c, Status__c FROM Credit_Risk_Query__c WHERE Opportunity__c IN :opportunityIdsToCheck
                                               AND RecordType.DeveloperName = 'CFP_Underwriting']) {
                                                   creditRiskQueriesMap.put(riskQuery.Opportunity__c, riskQuery);
                                               }
        
        for (Opportunity opp : oppList) {
            Credit_Risk_Query__c riskQuery = creditRiskQueriesMap.get(opp.Id);
            if (riskQuery != null && riskQuery.Status__c != 'Resolved') {
                opp.addError('Opportunity stage cannot be changed when there are open Credit Risk Queries.');
            }
        }
    }
    
    public static void mandatoryFieldsAtWonStageEPIC (List<Opportunity> oppList, Map<Id, Opportunity> oppMap) {
        
        for (Opportunity opp : oppList) {
            Opportunity oldOpp = oppMap.get(opp.Id);
            
            if (opp.StageName != oldOpp.StageName && oldOpp.StageName == 'Onboarded' && opp.StageName == 'Won') {
                // Check the conditions for each field
                if (!opp.COI__c                                  ||
                    !opp.GST__c                                  ||
                    !opp.KYC_Company__c                          ||
                    !opp.KYC_Directors__c                        ||
                    !opp.FL__c                                   ||
                    !opp.BR__c                                   ||
                    !opp.Beneficial_Owner_Details__c             ||
                    opp.POC_Contact__c                   == null || 
                    opp.POC_Contact_2__c                 == null ||
                    opp.Use_Case__c                      == null ||
                    opp.Program__c                       == null ||
                    opp.Cost_of_Funds__c                 == null ||
                    opp.Renewal_Date_of_Sanction_Line__c == null ||
                    String.isBlank(opp.CIF_ID__c)                ||
                    String.isBlank(opp.ORG_ID__c)                ||
                    String.isBlank(opp.CORP_ID__c)) {
                        opp.addError('All required fields must be filled before marking as Closed Won from the Onboarded stage.');
                    }
            }
        }
    }
    
    public static void tagOppTeamMemberEpic(List<Opportunity> newList) {
        
        List<OpportunityTeamMember> optTeamMemberList = new List<OpportunityTeamMember>();
        List<Id> epicOppIds = new List<Id>();
        for(Opportunity oppRec : newList){
            String recordTypeName = Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosById().get(oppRec.RecordTypeId).getName(); 
            if(recordTypeName == 'EPIC'){
                epicOppIds.add(oppRec.Id);
            }
        }
        List<GroupMember> groupMembers = [SELECT UserOrGroupId, Group.Name FROM GroupMember WHERE Group.Name = 'Credit Risk User'];
        
        if (groupMembers != null) {
            for(Id oppRecId : epicOppIds){
                for(GroupMember groupMemberRec : groupMembers){
                    OpportunityTeamMember teamMember 	= new OpportunityTeamMember();
                    teamMember.OpportunityId 			= oppRecId;
                    teamMember.UserId 					= groupMemberRec.UserOrGroupId; 
                    teamMember.TeamMemberRole			= 'Credit Risk';
                    teamMember.OpportunityAccessLevel	= 'Edit';
                    optTeamMemberList.add(teamMember);
                }
            } 
        }
        if(optTeamMemberList.size() > 0){
            system.debug('optTeamMemberList---->'+optTeamMemberList);
            insert optTeamMemberList;
        }
    }
    /*
public static void teamMemberValidation(List<Opportunity> newList, Map<Id, Opportunity> oldOppMap) {
string UserId = userInfo.GetUserId();
List<Id> oppTeamMemberIds = new List<Id>();
map<String,List<Id>> oppTeamMembersByOppId = new map<String,List<Id>>();
List<OpportunityTeamMember> opportunityTeamMembers = [SELECT OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId IN :newList];
for(OpportunityTeamMember oppTeamMemberRec : opportunityTeamMembers){
if(!oppTeamMembersByOppId.containsKey(oppTeamMemberRec.OpportunityId)){
List<Id> oppTeamMembersId = new List<Id>();
oppTeamMembersId.add(oppTeamMemberRec.UserId);
oppTeamMembersByOppId.Put(oppTeamMemberRec.OpportunityId,oppTeamMembersId);
}else{
oppTeamMembersByOppId.get(oppTeamMemberRec.OpportunityId).add(oppTeamMemberRec.UserId);
}
}
system.debug('oppTeamMembersByOppId-->'+oppTeamMembersByOppId);
for(Opportunity oppRec : newList){
//'012C2000000C3oXIAS'
if(oldOppMap.get(oppRec.Id).StageName != oppRec.StageName && oppRec.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('E{IC').getRecordTypeId()){
system.debug('the list is -->'+oppTeamMembersByOppId.get(oppRec.Id));
if(!oppTeamMembersByOppId.get(oppRec.Id).Contains(UserId)){
oppRec.addError('You do not have permission to edit status for this Opportunity.');    
}
}
}
}*/
    
    public static void teamMemberValidation(List<Opportunity> newList, Map<Id, Opportunity> oldOppMap) {
        Set<Id> creditUsers 		= new Set<Id>();
        for(GroupMember gmObj : [Select Id,UserOrGroupId from GroupMember where Group.DeveloperName = 'Credit_Risk_User']) {
            creditUsers.add(gmObj.UserOrGroupId);
        }
        
        for(Opportunity oppRec : newList){
            //'012C2000000C3oXIAS'
            if(oldOppMap.get(oppRec.Id).StageName != oppRec.StageName && 
               oppRec.RecordTypeId == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('EPIC').getRecordTypeId() &&
               !creditUsers.contains(UserInfo.getUserId())){
                   oppRec.addError('You do not have permission to edit status for this Opportunity.');    
               }
        }
    }
    
}
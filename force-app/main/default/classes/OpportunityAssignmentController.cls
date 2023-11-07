public class OpportunityAssignmentController {
    
    Static Map<Id,List<Assignment_Group_Member__C>> mapofAGIdByAGMList 			= new Map<Id,List<Assignment_Group_Member__C>>();
    Static Map<Id,Integer> 							mapofAGIdByLAID 			= new Map<Id,Integer>();
    Static Map<Id,Map<Integer,Id>> 					mapofAGIdByMapOfAIDByuserId	= new Map<Id,Map<Integer,Id>>();
    Static Map<Id,String>							mapOfAGIdByRoleName			= new Map<Id,String>();
    
    public static void assignOppTeamMembers(List<Opportunity> OppsToBeAssigned){
        List<OpportunityTeamMember> oppTeamTobeUpdate = new List<OpportunityTeamMember>();
        prepareGroupAndGroupMemberMap();
        List<Task> taskList 	= new List<Task>();
        for(Opportunity opp: OppsToBeAssigned){
            for(Id groupId: mapofAGIdByAGMList.keySet()){
                if(groupId != null){
                    Boolean isAssigned = false;
                    Integer qMemberSize = 1;
                    
                    While(mapofAGIdByAGMList != null && qMemberSize != null && mapofAGIdByAGMList.get(groupId) != null && isAssigned == false && qMemberSize <= mapofAGIdByAGMList.get(groupId).size()){
                        Integer currentRRid, LastRRid; 
                        String QnameAndRRid, qMemberID;
                        if(mapofAGIdByLAID.get(groupId) != null)
                            LastRRid = mapofAGIdByLAID.get(groupId); 
                        if(LastRRid == null || LastRRid < 1){
                            mapofAGIdByLAID.remove(groupId);
                            mapofAGIdByLAID.put(groupId, 0);
                            currentRRid = 1;
                        }
                        if(LastRRid < mapofAGIdByAGMList.get(groupId).size()){
                            currentRRid = LastRRid + 1;
                        }
                        else{
                            currentRRid = 1;
                            LastRRid = 0;
                        }
                        
                        OpportunityTeamMember oppTeamObj	= new OpportunityTeamMember();
                        oppTeamObj.OpportunityAccessLevel 	= 'Edit';
                        oppTeamObj.OpportunityId			=  opp.Id;
                        oppTeamObj.UserId					=  MapofAGIdByMapOfAIDByuserId.get(groupId).get(currentRRid);
                        oppTeamObj.Product__c               =  'Travel & Expense (T&E)';
                        oppTeamObj.TeamMemberRole			= mapOfAGIdByRoleName.get(groupId);
                        oppTeamTobeUpdate.add(oppTeamObj);
                        isAssigned = true;
                        mapofAGIdByLAID.remove(groupId);
                        mapofAGIdByLAID.put(groupId, LastRRid +1);
                        qMemberSize ++;
                        
                    }
                }
            }    
            if(opp.Finished__c == true){
                Task tsk 		= new Task();
                tsk.Subject 	= 'Assign / Verify Pre Sales Task';
                tsk.WhatId 		=  opp.Id;
                tsk.OwnerId 	= '0055g00000ARzDg';
                tsk.Status 		= 'Not Started';
                tsk.Type 		= 'Other';
                taskList.add(tsk);
            }
        }

        
        List<Assignment_Group__c> QtoBeUpdated = new List<Assignment_Group__c>();
        if(!mapofAGIdByLAID.keySet().isEmpty())
        {
            List<Assignment_Group__c> updateQrId = new List<Assignment_Group__c>();
            updateQrId = [Select id, name, Last_Allocated_RRid__c  from Assignment_Group__c where Id IN: mapofAGIdByLAID.keySet()];
            for(Assignment_Group__c Q: updateQrId)
            {
                Q.Last_Allocated_RRid__c = mapofAGIdByLAID.get(Q.Id);
                QtoBeUpdated.add(q);
            }
        }
        if(!QtoBeUpdated.isEmpty())
            Database.update(QtoBeUpdated, false);        
        if(!oppTeamTobeUpdate.isEmpty()){
            Database.insert(oppTeamTobeUpdate, false);
        }
        if(!taskList.isEmpty())
            Database.update(taskList, false);
    }
  /*  public static void assignOppTeamMembers(List<Opportunity> OppsToBeAssigned){
        
        List<Group> queues = [SELECT Id,(Select Id, UserOrGroupId FROM GroupMembers Order By ID ASC)FROM Group Where NAme = 'Travel & Expense (T&E) - Presales Team'];
        system.debug('queues'+queues);
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
        round_robin__c lrr = round_robin__c.getOrgDefaults();
        Integer userIndex = (lrr.get('User_Index__c') == null || Integer.valueOf(lrr.get('User_Index__c')) < -1) ? -1 : Integer.valueOf(lrr.get('User_Index__c'));
        Task tsk 		= new Task();
        if (queues.size() > 0 && queues.get(0).GroupMembers.size() > 0) {
            Id queueId = queues.get(0).Id;
            system.debug('queueId'+queueId);
            Integer groupMemberSize = queues.get(0).GroupMembers.size();
            for (Opportunity opp : OppsToBeAssigned) {
                if(opp.Finished__c == true){
                    Integer leadUserIndex =  (userIndex + 1) >= groupMemberSize ? 0 : userIndex + 1;
                    system.debug('UserId===>'+queues.get(0).GroupMembers.get(leadUserIndex).UserOrGroupId);
                    OpportunityTeamMember otm = new OpportunityTeamMember(OpportunityId = opp.id,UserId = queues.get(0).GroupMembers.get(leadUserIndex).UserOrGroupId,TeamMemberRole = 'Pre Sales', Product__c = 'Travel & Expense (T&E)');
                    //opp.OwnerId = queues.get(0).GroupMembers.get(leadUserIndex).UserOrGroupId;
                    otmList.add(otm);
                    userIndex = leadUserIndex;  
                    //Task 
                    tsk.Subject 	= 'Assign / Verify Pre Sales Task';
                    tsk.WhatId 		=  opp.Id;
                    tsk.OwnerId 	= '0055g00000ARzDg';
                    tsk.Status 		= 'Not Started';
                    tsk.Type 		= 'Other';
                }
                
            }
            // Update the custom settings user index with the last lead assigned user
            insert otmList;
            insert tsk;
            lrr.User_Index__c = userIndex;
            update lrr;
        }
        
        
    }*/
    
    public static void prepareGroupAndGroupMemberMap(){
        Map<String,List<Assignment_Group_Member__C>> mapofGroupNameByGroupMemberList = new Map<String,List<Assignment_Group_Member__C>>();
        List<Assignment_Group_Member__C> agmList = [select id,Active__c,Assignment_Group__c,Assignment_Id__c,Group_Member__c,
                                                    Assignment_Group__r.Is_Active__c,Assignment_Group__r.Last_Allocated_RRid__c,
                                                    Assignment_Group__r.Round_Robin_Queue_Name__c,Assignment_Group__r.Name,
                                                    Assignment_Group__r.Id,Assignment_Group__r.Role_Name__c
                                                    from Assignment_Group_Member__C
                                                    where Assignment_Group__r.Is_Active__c = true AND Assignment_Group__r.Name = 'Pre-Sales Group(Travel & Expense)'];
        
        
        if(agmList != null && !agmList.isEmpty()){
            for(Assignment_Group_Member__C agm : agmList){
                if(mapofAGIdByAGMList.ContainsKey(agm.Assignment_Group__r.Id)){
                    mapofAGIdByAGMList.get(agm.Assignment_Group__r.Id).add(agm);
                }else{
                    mapofAGIdByAGMList.put(agm.Assignment_Group__r.Id,New List<Assignment_Group_Member__C>{agm});
                    mapofAGIdByLAID.put(agm.Assignment_Group__r.Id,Integer.ValueOf(agm.Assignment_Group__r.Last_Allocated_RRid__c));
                    mapOfAGIdByRoleName.put(agm.Assignment_Group__r.Id,agm.Assignment_Group__r.Role_Name__c);
                }
                
                if(MapofAGIdByMapOfAIDByuserId.containsKey(agm.Assignment_Group__r.Id)){
                    MapofAGIdByMapOfAIDByuserId.get(agm.Assignment_Group__r.Id).put(Integer.ValueOf(agm.Assignment_Id__c),agm.Group_Member__c);
                }else{
                    MapofAGIdByMapOfAIDByuserId.put(agm.Assignment_Group__r.Id,New Map<Integer,Id>{Integer.ValueOf(agm.Assignment_Id__c) => agm.Group_Member__c});
                }
            }
        }
        
    }
    
    public static void assignaccs(List<Account> accsToBeAssigned){
        
        List<AccountTeamMember> GroupMembers = [Select Id, Product__c, AccountId, UserId, TeamMemberRole from AccountTeamMember where AccountId IN: accsToBeAssigned AND (TeamMemberRole = 'Sales Rep' OR TeamMemberRole = 'BD') ];
        List<Id> UserIds = new List<Id>();
        for(AccountTeamMember at  : GroupMembers){
            UserIds.add(at.UserId);
        }
        
        List<User> UserList = [Select Id , name , BD_Team_Member_of_Products__c , PreSales_Team_Member_of_Products__c , Sales_Team_Member_of_Products__c From User where Id IN:UserIds];
        Map<Id,User> mapOfUserByUserID = new Map<Id,User>();
        
        for(User us : UserList){
            mapOfUserByUserID.put(us.Id,us);
        }
        
        AccountTeamMember ATM = NEW AccountTeamMember();
        round_robin__c lrr = round_robin__c.getOrgDefaults();
        Integer userIndex = (lrr.get('User_Index__c') == null || Integer.valueOf(lrr.get('User_Index__c')) < -1) ? -1 : Integer.valueOf(lrr.get('User_Index__c'));
        
        if (GroupMembers.size() > 0 ) {
            Integer groupMemberSize = GroupMembers.size();
            for (Account acc : accsToBeAssigned) {
                Integer leadUserIndex =  (userIndex + 1) >= groupMemberSize ? 0 : userIndex + 1;
                acc.OwnerId = GroupMembers.get(leadUserIndex).UserId;
                userIndex = leadUserIndex;
                ATM.Id = GroupMembers.get(leadUserIndex).Id;
                if(GroupMembers.get(leadUserIndex).TeamMemberRole == 'Sales Rep'){
                    if(mapOfUserByUserID.get(GroupMembers.get(leadUserIndex).UserId).Sales_Team_Member_of_Products__c != null){
                        ATM.Product__c =  mapOfUserByUserID.get(GroupMembers.get(leadUserIndex).UserId).Sales_Team_Member_of_Products__c;      
                    }
                }else if(GroupMembers.get(leadUserIndex).TeamMemberRole == 'BD'){
                    if(mapOfUserByUserID.get(GroupMembers.get(leadUserIndex).UserId).BD_Team_Member_of_Products__c != null){
                        ATM.Product__c =  mapOfUserByUserID.get(GroupMembers.get(leadUserIndex).UserId).BD_Team_Member_of_Products__c;
                    }
                }
            }
            lrr.User_Index__c = userIndex;
            update lrr;
        }
    }
    
    public static void assignOwnerHelper(List<Opportunity> OppsToBeAssigned){ 
        List<String> accids = new List<String>();
        map<Id,AccountTeamMember> accIdByTeamMember = new map<Id,AccountTeamMember>();
        for(Opportunity opp : OppsToBeAssigned){
            accids.add(opp.AccountId);
        }
        system.debug('accids'+accids);
        List<AccountTeamMember> accTeamMemberList = [Select id , UserId ,AccountId from AccountTeamMember where AccountId IN : accids ANd TeamMemberRole = 'Sales Rep'];
        for(AccountTeamMember acc : accTeamMemberList){
            accIdByTeamMember.put(acc.AccountId,acc);
        }
        for(Opportunity opp : OppsToBeAssigned){
            if(accIdByTeamMember.containsKey(opp.AccountId) && accIdByTeamMember.get(opp.AccountId).UserId != null){
                opp.OwnerId = accIdByTeamMember.get(opp.AccountId).UserId;
            }
        }
    }
}
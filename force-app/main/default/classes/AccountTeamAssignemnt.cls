public class AccountTeamAssignemnt {
    Static Map<Id,List<Assignment_Group_Member__C>> mapofAGIdByAGMList 			= new Map<Id,List<Assignment_Group_Member__C>>();
    Static Map<Id,Integer> 							mapofAGIdByLAID 			= new Map<Id,Integer>();
    Static Map<Id,Map<Integer,Id>> 					mapofAGIdByMapOfAIDByuserId	= new Map<Id,Map<Integer,Id>>();
    Static Map<Id,String>							mapOfAGIdByRoleName			= new Map<Id,String>();
    
    public static void AccountTeamCreation(List<Account> accountList){
        List<AccountTeamMember> accTeamTobeUpdate = new List<AccountTeamMember>();
        prepareGroupAndGroupMemberMap();
        
        for(Account acc: accountList){
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
                        
                        AccountTeamMember accountTeamObj 		= new AccountTeamMember();
                        accountTeamObj.AccountAccessLevel 		= 'Edit';
                        accountTeamObj.AccountId				=  acc.Id;
                        accountTeamObj.CaseAccessLevel 			= 'None';
                        accountTeamObj.OpportunityAccessLevel	= 'None'; 
                        accountTeamObj.UserId					=  MapofAGIdByMapOfAIDByuserId.get(groupId).get(currentRRid);
                        accountTeamObj.Product__c               =  'Travel & Expense (T&E)';
                        accountTeamObj.TeamMemberRole			= mapOfAGIdByRoleName.get(groupId);
                        accTeamTobeUpdate.add(accountTeamObj);
                        isAssigned = true;
                        mapofAGIdByLAID.remove(groupId);
                        mapofAGIdByLAID.put(groupId, LastRRid +1);
                        qMemberSize ++;
                        
                    }
                }
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
        if(!accTeamTobeUpdate.isEmpty()){
            Database.insert(accTeamTobeUpdate, false);
        }
    }
    
    public static void prepareGroupAndGroupMemberMap(){
        Map<String,List<Assignment_Group_Member__C>> mapofGroupNameByGroupMemberList = new Map<String,List<Assignment_Group_Member__C>>();
        List<Assignment_Group_Member__C> agmList = [select id,Active__c,Assignment_Group__c,Assignment_Id__c,Group_Member__c,
                                                    Assignment_Group__r.Is_Active__c,Assignment_Group__r.Last_Allocated_RRid__c,
                                                    Assignment_Group__r.Round_Robin_Queue_Name__c,Assignment_Group__r.Name,
                                                    Assignment_Group__r.Id,Assignment_Group__r.Role_Name__c
                                                    from Assignment_Group_Member__C
                                                    where Assignment_Group__r.Is_Active__c = true AND Assignment_Group__r.Name != 'Pre-Sales Group(Travel & Expense)'];
        
        
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
}
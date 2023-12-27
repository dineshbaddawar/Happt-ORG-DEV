public class PaymentTermApprover {
    
    public static Boolean reccursiveHandler = true;
    
    /*@auraEnabled
    public static void paymentTermApproverLogic(Id quoteId){
        Id loggedInUserId = UserInfo.getUserId();
        Id managerId	= [select userName,id,manager.name,manager.Id, manager.profile.name from user where id =: loggedInUserId].manager.Id;
        List<Approval.ProcessSubmitRequest> approvalRequestList = new List<Approval.ProcessSubmitRequest>();
        Set<Id> approverUserIdSet = new Set<Id>();
        List<Terms_and_condition__c> termConditionList = [select id,Term_Attribute_Line_Item__c,Term_Attribute_Line_Item__r.Approval_Required__c from Terms_and_condition__c where Quote__c =: quoteId and Term_Attribute_Line_Item__r.Approval_Required__c = true];
        Set<Id> termAttributeIdSet = new Set<Id>();
        if(!termConditionList.isEmpty()){
            for(Terms_and_condition__c tc : termConditionList){
                termAttributeIdSet.add(tc.Term_Attribute_Line_Item__c);
            }
            if(!termAttributeIdSet.isEmpty()){
                List<Term_Attribute_Line_Item__c> termAttroibuteLine = [select id,Approval_Authority__c,Approved_By_Team_Lead__c from Term_Attribute_Line_Item__c];
                for(Term_Attribute_Line_Item__c tali : termAttroibuteLine){
                    if(tali.Approved_By_Team_Lead__c){
                        approverUserIdSet.add(managerId);
                    }
                    if(tali.Approval_Authority__c != null){
                        approverUserIdSet.add(tali.Approval_Authority__c);
                    }
                }
            }
        }
        
        // Quote testQuote = [sELECT Id,Name,Status,Approver_Authority_Level1__c from Quote where id =: quoteId];
         //system.debug('testQuote ===> '+testQuote);
        system.debug('approverUserIdSet ===> '+approverUserIdSet);
        if(!approverUserIdSet.isEmpty()){
            for(Id userId : approverUserIdSet){
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('Submitting request for payment term approval.');
                approvalRequest.setObjectId(quoteId);
                approvalRequest.setNextApproverIds(new List<Id>{userId});
                approvalRequestList.add(approvalRequest);
            }
            Approval.process(approvalRequestList);
        }
    }*/
    
    
    public static void calculateApproverAuthorityMatrix(List<Terms_and_condition__c> tcList,map<Id,Terms_and_condition__c> oldMap){ 
        
        
        List<User> UserList = [Select Id,ManagerId,profile.name From User where isActive = true and Id =: UserInfo.getUserId()];
        String loggedInUserProfileName 						= UserList[0].profile.name;
        if(loggedInUserProfileName == 'System Administrator'){
            loggedInUserProfileName = 'Enterprise';
        }
        String level2AuthId = '';
        if(UserList[0].profile.name == 'AM'){
            level2AuthId = System.Label.Level2AmProfile;
        }else{
            level2AuthId = System.Label.Level2OtherProfile;
        }
        
        List<Quote> quoteListTobeUpdate = new List<Quote>();
        
        Map<Id,Id> mapOfQuoteIdByLevel1AuthId = new Map<Id,Id>();
        Map<Id,Id> mapOfQuoteIdByLevel2AuthId = new Map<Id,Id>();
        Map<Id,Id> mapofQuoteIdByLevel3AuthId = new Map<Id,Id>();
        
        
        Set<Id> termAtrributeIdSet = new Set<Id>();
        
        Set<Id> QuoteIdSet 						= new Set<Id>();
        
        Map<Id,Id> mapofTCIdByAuthorityId = new Map<Id,Id>();
        Map<Id,Id> mapofTCIDbyQuId = new Map<Id,Id>();
        for(Terms_and_condition__c tc : tcList){
            if((tc.Term_Attribute_Line_Item__c != null && oldMap != null && tc.Term_Attribute_Line_Item__c != oldMap.get(tc.Id).Term_Attribute_Line_Item__c)
              || (tc.Term_Attribute_Line_Item__c != null && oldMap == null)){
                QuoteIdSet.add(tc.Quote__c);
                termAtrributeIdSet.add(tc.Term_Attribute_Line_Item__c);
            }
        }
        Map<Id,Approval_Matrix__c> mapofTALIIdByApprovalMatrix = new Map<Id,Approval_Matrix__c>();
     
        if(!termAtrributeIdSet.isEmpty()){
            List<Approval_Matrix__c> approvalMatrixList = [Select Id,Term_Attribute_Line_Item__c,Approval_Required__c,Team_Lead_Approver__c,Approving_Authority__c,Higher_Authority__c from Approval_Matrix__c Where Term_Attribute_Line_Item__c in: termAtrributeIdSet and Profiles__c =:loggedInUserProfileName];
             System.debug('approvalMatrixList size === >'+approvalMatrixList.size());
            if(!approvalMatrixList.isEmpty()){
                for(Approval_Matrix__c matrix : approvalMatrixList){
                    mapofTALIIdByApprovalMatrix.put(matrix.Term_Attribute_Line_Item__c,matrix);
                }
                
                if(!mapofTALIIdByApprovalMatrix.isEmpty()){
                    for(Terms_and_condition__c tc : tcList){
                        if(!mapofTALIIdByApprovalMatrix.isEmpty() && mapofTALIIdByApprovalMatrix.containsKey(tc.Term_Attribute_Line_Item__c)){
                            system.debug('mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Team_Lead_Approver__c::'+mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Team_Lead_Approver__c);
                            system.debug('Second Level'+(!mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Higher_Authority__c && mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Approving_Authority__c != null));
                            system.debug('Third Level'+(mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Higher_Authority__c && mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Approving_Authority__c != null));
                            if(mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Team_Lead_Approver__c){
                                mapOfQuoteIdByLevel1AuthId.put(tc.Quote__c,UserList[0].ManagerId);
                                mapofTCIdByAuthorityId.put(tc.Id,UserList[0].ManagerId);
                                mapofTCIDbyQuId.put(tc.Id,tc.Quote__c);
                            }else if(!mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Higher_Authority__c && mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Approving_Authority__c != null){
                                mapOfQuoteIdByLevel1AuthId.put(tc.Quote__c,UserList[0].ManagerId);
                                mapOfQuoteIdByLevel2AuthId.put(tc.Quote__c,mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Approving_Authority__c);
                                mapofTCIdByAuthorityId.put(tc.Id,mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Approving_Authority__c);
                                mapofTCIDbyQuId.put(tc.Id,tc.Quote__c);
                            }else if(mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Higher_Authority__c && mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Approving_Authority__c != null){
                                mapOfQuoteIdByLevel1AuthId.put(tc.Quote__c,UserList[0].ManagerId);
                                mapOfQuoteIdByLevel2AuthId.put(tc.Quote__c,level2AuthId);
                                mapofQuoteIdByLevel3AuthId.put(tc.Quote__c,mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Approving_Authority__c);
                                mapofTCIdByAuthorityId.put(tc.Id,mapofTALIIdByApprovalMatrix.get(tc.Term_Attribute_Line_Item__c).Approving_Authority__c);
                                mapofTCIDbyQuId.put(tc.Id,tc.Quote__c);
                            }else{
                                mapofTCIdByAuthorityId.put(tc.Id,null);
                                mapofTCIDbyQuId.put(tc.Id,tc.Quote__c);
                            }   
                        }
                    }
                    
                    system.debug('mapOfQuoteIdByLevel1AuthId::'+mapOfQuoteIdByLevel1AuthId);
                    system.debug('mapOfQuoteIdByLevel2AuthId::'+mapOfQuoteIdByLevel2AuthId);
                    system.debug('mapofQuoteIdByLevel3AuthId::'+mapofQuoteIdByLevel3AuthId);
                    if(!QuoteIdSet.isEmpty()){
                        for(Id quoteId : QuoteIdSet){
                            Quote qu = new Quote();
                            qu.Id = quoteId;
                            if(!mapOfQuoteIdByLevel1AuthId.isEmpty() && mapOfQuoteIdByLevel1AuthId.containsKey(qu.Id)){
                                qu.Authority_1__c = mapOfQuoteIdByLevel1AuthId.get(qu.Id);
                            }
                            if(!mapOfQuoteIdByLevel2AuthId.isEmpty() && mapOfQuoteIdByLevel2AuthId.containsKey(qu.Id)){
                                qu.Authority_2__c = mapOfQuoteIdByLevel2AuthId.get(qu.Id);
                            }
                            if(!mapofQuoteIdByLevel3AuthId.isEmpty() && mapofQuoteIdByLevel3AuthId.containsKey(qu.Id)){
                                qu.Authority_3__c = mapofQuoteIdByLevel3AuthId.get(qu.Id);
                            }
                            quoteListTobeUpdate.add(qu);
                        }
                    }
                     
                    if(!quoteListTobeUpdate.isEmpty()){
                        update quoteListTobeUpdate;
                        system.debug('quoteListTobeUpdate === >'+quoteListTobeUpdate);
                    }
                    system.debug(' mapofTCIdByAuthorityId === >'+mapofTCIdByAuthorityId);
                    if(!mapofTCIdByAuthorityId.isEmpty()){
                        System.debug('Inside Method called');
                        updateAuthorityOnTermsAndCondition(mapofTCIdByAuthorityId,mapofTCIDbyQuId);
                    }else{
                         System.debug('Outside Method called');
                    }
                }
            }
        }
    }
    
    @future 
    public static void updateAuthorityOnTermsAndCondition(Map<Id,Id> mapofTCIdByAuthorityId,Map<Id,Id> mapofTCIDbyQuId){
        system.debug(' mapofTCIdByAuthorityId future === >'+mapofTCIdByAuthorityId);
        Set<Id> quoteIdSet = new Set<Id>();
        List<Terms_and_condition__c> tcListTobeUpdate = new List<Terms_and_condition__c>();
        for(Id mapKey : mapofTCIdByAuthorityId.keySet()){
            Terms_and_condition__c tc = new Terms_and_condition__c();
            tc.Id = mapKey;
            tc.Approval_Authority__c = mapofTCIdByAuthorityId.get(mapKey);
            tcListTobeUpdate.add(tc);
            quoteIdSet.add(mapofTCIDbyQuId.get(mapKey));
        }
        
        if(!tcListTobeUpdate.isEmpty()){
            update tcListTobeUpdate;
        }
        
        List<Terms_and_condition__c> listOfTC = new List<Terms_and_condition__c>();
        List<Quote> quoteListTobeUpdate = new List<Quote>();
        listOfTC = [select id from Terms_and_condition__c where Quote__c in:quoteIdSet and Approval_Authority__c != null];
        
        if(listOfTC.size() == 0){
            for(Id qu : quoteIdSet){
                quote q = new quote();
                q.Id = qu;
                q.Authority_1__c = null;
                q.Authority_2__c = null;
                q.Authority_3__c = null;
                quoteListTobeUpdate.add(q);
            }
            
            if(!quoteListTobeUpdate.isEmpty()){
                update quoteListTobeUpdate;
            }
        }
        
    }
   
   
}
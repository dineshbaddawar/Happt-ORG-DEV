public class PaymentTermApprover {
    
    @auraEnabled
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
        
        system.debug('approverUserIdSet::'+approverUserIdSet);
        
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
        
    }
    
    public static void calculateApproverAuthorityMatrix(List<Terms_and_condition__c> tcList){
        Id loggedInUserId = UserInfo.getUserId();
        
        Map<Id,Id> mapOfActiveUserByManagerId	= new Map<Id,Id>();
        Map<Id,Id> mapOfTALIIdByOwnerId			= new Map<Id,Id>();
        Map<Id,Id> mapOfQuoteIdByLevel1AuthId = new Map<Id,Id>();
        Map<Id,Id> mapOfQuoteIdByLevel2AuthId = new Map<Id,Id>();
        Map<Id,Id> mapofTALIByApproverLevel1Id	 = new Map<Id,Id>();
        Map<Id,Id> mapofTALIByApproverLevel2Id	 = new Map<Id,Id>();
        Map<Id,Id> mapofTALIIdByTCId			= new Map<Id,Id>();
        Map<Id,Id> mapofTCIdByQuoteId			= new Map<Id,Id>();
        Set<Id> termAtrributeIdSet = new Set<Id>();
        Set<Id> QuoteIdSet 						= new Set<Id>();
        
        
        List<User> activeUserList	= [select userName,id,manager.name,manager.Id, manager.profile.name from user where isActive = true];
        if(!activeUserList.isEmpty()){
            for(User us : activeUserList){
                mapOfActiveUserByManagerId.put(us.Id,us.manager.Id);
            }
        }
        for(Terms_and_condition__c tc : tcList){
            QuoteIdSet.add(tc.Quote__c);
            termAtrributeIdSet.add(tc.Term_Attribute_Line_Item__c);
            mapofTALIIdByTCId.put(tc.Term_Attribute_Line_Item__c,tc.Id);
            mapofTCIdByQuoteId.put(tc.Id,tc.Quote__c);
            mapOfTALIIdByOwnerId.put(tc.Term_Attribute_Line_Item__c,tc.OwnerId);
        }
        
        if(!termAtrributeIdSet.isEmpty()){
            List<Term_Attribute_Line_Item__c> termALIList = [select id,Approval_Required__c,Approval_Authority__c,Approved_By_Team_Lead__c 
                                                             from Term_Attribute_Line_Item__c 
                                                             where id in: termAtrributeIdSet and Approval_Required__c = true];
            if(!termALIList.isEmpty()){
                for(Term_Attribute_Line_Item__c tali : termALIList){
                    if(tali.Approval_Required__c && tali.Approved_By_Team_Lead__c){
                        mapofTALIByApproverLevel1Id.put(tali.Id,mapOfActiveUserByManagerId.get(mapOfTALIIdByOwnerId.get(tali.Id)));
                    }else if(tali.Approval_Required__c && tali.Approval_Authority__c != null){
                        mapofTALIByApproverLevel2Id.put(tali.Id,tali.Approval_Authority__c);
                    }
                }
                
                if(!mapofTALIByApproverLevel1Id.isEmpty()){
                    for(Id mapKey : mapofTALIByApproverLevel1Id.keySet()){
                        if(mapofTALIByApproverLevel1Id.get(mapKey) != null){
                            mapOfQuoteIdByLevel1AuthId.put(mapofTCIdByQuoteId.get(mapofTALIIdByTCId.get(mapKey)),mapofTALIByApproverLevel1Id.get(mapKey));
                        }
                    }
                }
                
                if(!mapofTALIByApproverLevel2Id.isEmpty()){
                    for(Id mapKey : mapofTALIByApproverLevel2Id.keySet()){
                        if(mapofTALIByApproverLevel2Id.get(mapKey) != null){
                            mapOfQuoteIdByLevel2AuthId.put(mapofTCIdByQuoteId.get(mapofTALIIdByTCId.get(mapKey)),mapofTALIByApproverLevel2Id.get(mapKey));
                        }
                    }
                }
                Map<Id,Quote> QuoteIdXQuoteRec=new Map<Id,Quote>();
                
                if(!QuoteIdSet.isEmpty()){
                    List<Quote> QuoteRecList=[Select Id,Approver_Authority_Level1__c,Approver_Authority_Level2__c,Approval_Authority_Level2B__c From Quote where Id=:QuoteIdSet];
                    for(Quote Q:QuoteRecList){
                        
                        if(QuoteIdXQuoteRec.containsKey(Q.Id)){
                            QuoteIdXQuoteRec.Put(Q.Id,QuoteIdXQuoteRec.get(Q.Id));
                        }else{
                            QuoteIdXQuoteRec.Put(Q.Id,Q);
                        }
                    } 
                }
                
                 Quote QuoteRec=new Quote();
                
                if(!QuoteIdSet.isEmpty()){
                    List<Quote> quoteListTobeUpdate = new List<Quote>();
                    for(Id quId : QuoteIdSet){
                        
                        if(!mapOfQuoteIdByLevel1AuthId.isEmpty() || !mapOfQuoteIdByLevel2AuthId.isEmpty()){
                            Quote qu = new Quote();
                            qu.Id = quId;
                            if(mapOfQuoteIdByLevel1AuthId.containsKey(quId) && mapOfQuoteIdByLevel1AuthId.get(quId) != null){
                                qu.Approver_Authority_Level1__c = mapOfQuoteIdByLevel1AuthId.get(quId);
                            }
                            if(mapOfQuoteIdByLevel2AuthId.containsKey(quId) && mapOfQuoteIdByLevel2AuthId.get(quId) != null){
                                
                                    if(QuoteIdXQuoteRec.containsKey(quId)){ 
                                        QuoteRec= QuoteIdXQuoteRec.get(quId);
                                        
                                        if(QuoteRec.Approver_Authority_Level2__c==null){
                                           qu.Approver_Authority_Level2__c = mapOfQuoteIdByLevel2AuthId.get(quId);
                                            
                                        }else if(QuoteRec.Approver_Authority_Level2__c!=null){
                                            Id AuthorityId=QuoteRec.Approver_Authority_Level2__c;
                                            
                                            if(AuthorityId== mapOfQuoteIdByLevel2AuthId.get(quId)){
                                                system.debug('This Approver Authority already Exist In Level 2');
                                            }else{
                                              qu.Approval_Authority_Level2B__c = mapOfQuoteIdByLevel2AuthId.get(quId);  
                                            }
                                             
                                        }
                                    }
                                
                            }
                            
                            quoteListTobeUpdate.add(qu);
                        }
                    } 
                    if(!quoteListTobeUpdate.isEmpty()){
                        update quoteListTobeUpdate;
                    }
                }
                
                
            }
            
        }
    }
}
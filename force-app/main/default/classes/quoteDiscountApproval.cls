public class quoteDiscountApproval {
    
    Public static void QuoteOverallOTIxSAASA(Map<Id,Quote>newMap,Map<Id,Quote>oldMap){
        List<Discount_Approval_Matrix__c> otiDAMList 	= new List<Discount_Approval_Matrix__c>();
        List<Discount_Approval_Matrix__c> saasDAMList 	= new List<Discount_Approval_Matrix__c>();
        Map<Id,boolean> mapofUserIdByAuthorityCheckList = new Map<Id,Boolean>();
        
        Id LoginUserId 									= UserInfo.getUserId();
        string level2UserId = '';
        List<User> UserList = [Select Id,ManagerId,profile.name From User where isActive = true and Id =: LoginUserId];
        String loggedInUserProfile 						= UserList[0].profile.name;
        
        if(loggedInUserProfile == 'System Administrator'){
            loggedInUserProfile = 'Enterprise';
        }
        
        
        List<Discount_Approval_Matrix__c> damList = [Select Id,Discount_Type__c,End_Range__c,Profile__c,
                                                     Start_Range__c,Team_Lead__c,User__c,Higher_Authority__c
                                                     from Discount_Approval_Matrix__c 
                                                     where Profile__c =: loggedInUserProfile];
        
        
        
        if(!damList.isEmpty()){
            for(Discount_Approval_Matrix__c dam : damList){
                if(!dam.Team_Lead__c && !dam.Higher_Authority__c){
                    level2UserId = dam.User__c;
                }
                if(!dam.Team_Lead__c){
                    mapofUserIdByAuthorityCheckList.put(dam.User__c,dam.Higher_Authority__c);
                }
                
                if(dam.Discount_Type__c == 'OTI'){
                    otiDAMList.add(dam);
                }else{
                    saasDAMList.add(dam);
                }
            }
        }
        
        if(!UserList.isEmpty()){
            for(Quote qu : newMap.values()){
                if(qu.Overall_OTI_Discount__c != null && qu.Overall_OTI_Discount__c != oldMap.get(qu.Id).Overall_OTI_Discount__c){
                    for(Discount_Approval_Matrix__c dam : otiDAMList){
                        if(qu.Overall_OTI_Discount__c >= dam.Start_Range__c
                           && qu.Overall_OTI_Discount__c <= dam.End_Range__c){
                               qu.DAuthority1__c = null;
                               qu.DAuthority2__c = null;
                               qu.DAuthority3__c = null;
                               
                               if(dam.Team_Lead__c){
                                   qu.DAuthority1__c = UserList[0].ManagerId;
                               }
                               
                               if(mapofUserIdByAuthorityCheckList.containsKey(dam.User__c) && !mapofUserIdByAuthorityCheckList.get(dam.User__c)){
                                   qu.DAuthority1__c = UserList[0].ManagerId;
                                   qu.DAuthority2__c = dam.User__c;
                               }
                               
                               if(mapofUserIdByAuthorityCheckList.containsKey(dam.User__c) && mapofUserIdByAuthorityCheckList.get(dam.User__c)){
                                   qu.DAuthority1__c = UserList[0].ManagerId;
                                   qu.DAuthority2__c = level2UserId;
                                   qu.DAuthority3__c = dam.User__c;
                               }
                           }
                    }
                }
                
                if(qu.Overall_ARR_Discount__c != null && qu.Overall_ARR_Discount__c != oldMap.get(qu.Id).Overall_ARR_Discount__c){
                    for(Discount_Approval_Matrix__c dam : saasDAMList){
                        system.debug('dam::'+dam);
                        system.debug('qu.Overall_OTI_Discount__c::'+qu.Overall_OTI_Discount__c);
                        system.debug('dam.Start_Range__c::'+dam.Start_Range__c);
                        system.debug('dam.End_Range__c::'+dam.End_Range__c);
                        if(qu.Overall_ARR_Discount__c >= dam.Start_Range__c
                           && qu.Overall_ARR_Discount__c <= dam.End_Range__c){
                               qu.SAAS_Authority1__c = null;
                               qu.SAAS_Authority2__c = null;
                               qu.SAAS_Authority3__c = null;
                               system.debug('inside dam loop');
                               if(dam.Team_Lead__c){
                                   qu.SAAS_Authority1__c = UserList[0].ManagerId;
                               }
                               
                               if(mapofUserIdByAuthorityCheckList.containsKey(dam.User__c) && !mapofUserIdByAuthorityCheckList.get(dam.User__c)){
                                   qu.SAAS_Authority1__c = UserList[0].ManagerId;
                                   qu.SAAS_Authority2__c = dam.User__c;
                               }
                               
                               if(mapofUserIdByAuthorityCheckList.containsKey(dam.User__c) && mapofUserIdByAuthorityCheckList.get(dam.User__c)){
                                   qu.SAAS_Authority1__c = UserList[0].ManagerId;
                                   qu.SAAS_Authority2__c = level2UserId;
                                   qu.SAAS_Authority3__c = dam.User__c;
                               }
                           }
                    }
                }
            }
        }
    }
    
    
    public static void finallizedAprovalAuthority(List<Quote> quoteList,Map<Id,Quote> oldMap){
        for(Quote qu : quoteList){
            if(qu.Authority_3__c != null && qu.Authority_3__c != oldMap.get(qu.id).Authority_3__c){
                qu.Approval_Authority_Level2B__c = qu.Authority_3__c;
            }else if(qu.DAuthority3__c !=null && qu.DAuthority3__c != oldMap.get(qu.Id).DAuthority3__c){
                qu.Approval_Authority_Level2B__c = qu.DAuthority3__c;
            }else if(qu.SAAS_Authority3__c != null && qu.SAAS_Authority3__c != oldMap.get(qu.Id).SAAS_Authority3__c){
                qu.Approval_Authority_Level2B__c = qu.SAAS_Authority3__c;
            }else if(qu.Authority_3__c == null && qu.DAuthority3__c == null && qu.SAAS_Authority3__c == null){
                qu.Approval_Authority_Level2B__c = null;
            }
            
            if(qu.Authority_2__c != null && qu.Authority_2__c != oldMap.get(qu.id).Authority_2__c){
                qu.Approver_Authority_Level2__c = qu.Authority_2__c;
            }else if(qu.DAuthority2__c !=null && qu.DAuthority2__c != oldMap.get(qu.Id).DAuthority2__c){
                qu.Approver_Authority_Level2__c = qu.DAuthority2__c;
            }else if(qu.SAAS_Authority2__c != null && qu.SAAS_Authority2__c != oldMap.get(qu.Id).SAAS_Authority2__c){
                qu.Approver_Authority_Level2__c = qu.SAAS_Authority2__c;
            }else if(qu.Authority_2__c == null && qu.DAuthority2__c == null && qu.SAAS_Authority2__c == null){
                qu.Approver_Authority_Level2__c = null;
            }
            
            if(qu.Authority_1__c != null && qu.Authority_1__c != oldMap.get(qu.id).Authority_1__c){
                qu.Approver_Authority_Level1__c = qu.Authority_1__c;
            }else if(qu.DAuthority1__c !=null && qu.DAuthority1__c != oldMap.get(qu.Id).DAuthority1__c){
                qu.Approver_Authority_Level1__c = qu.DAuthority1__c;
            }else if(qu.SAAS_Authority1__c != null && qu.SAAS_Authority1__c != oldMap.get(qu.Id).SAAS_Authority1__c){
                qu.Approver_Authority_Level1__c = qu.SAAS_Authority1__c;
            }else if(qu.Authority_1__c == null && qu.DAuthority1__c == null && qu.SAAS_Authority1__c == null){
                qu.Approver_Authority_Level1__c = null;
            }
        }
    }
    
    public static void calculateTheOverallDiscount(List<Quote> quoteList,Map<Id,Quote> oldMapQuote){
        for(quote qu : quoteList){
            if(qu.Travel_ARR_Discount__c != null &&qu.Travel_ARR_Discount__c != 0 && qu.Expense_ARR_Discount__c != null && qu.Expense_ARR_Discount__c != 0){
                qu.Overall_ARR_Discount__c = qu.Travel_ARR_Discount__c + qu.Expense_ARR_Discount__c - (qu.Travel_ARR_Discount__c * qu.Expense_ARR_Discount__c)/100;
                //qu.Overall_OTI_Discount__c = (qu.Travel_ARR_Discount__c + qu.Travel_OTI_Discount__c)/2;
            }else if(qu.Travel_ARR_Discount__c == null || qu.Travel_ARR_Discount__c == 0){
                qu.Overall_ARR_Discount__c = qu.Expense_ARR_Discount__c;
            }else if(qu.Expense_ARR_Discount__c != null || qu.Expense_ARR_Discount__c == 0){
                qu.Overall_ARR_Discount__c = qu.Travel_ARR_Discount__c;
            }
            
            if(qu.Travel_OTI_Discount__c != null && qu.Travel_OTI_Discount__c != 0 && qu.Expense_OTI_Discount__c != null && qu.Expense_OTI_Discount__c != 0){
                qu.Overall_OTI_Discount__c = qu.Expense_OTI_Discount__c + qu.Travel_OTI_Discount__c - (qu.Expense_OTI_Discount__c * qu.Travel_OTI_Discount__c)/100;
                //qu.Overall_ARR_Discount__c = (qu.Expense_OTI_Discount__c + qu.Expense_ARR_Discount__c)/2;
            }else if(qu.Travel_OTI_Discount__c == null || qu.Travel_OTI_Discount__c == 0){
                qu.Overall_OTI_Discount__c = qu.Expense_OTI_Discount__c;
            }else if(qu.Expense_OTI_Discount__c == null || qu.Expense_OTI_Discount__c == 0){
                qu.Overall_OTI_Discount__c = qu.Travel_OTI_Discount__c;
            }
        }
    }
}
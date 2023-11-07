public class quoteDiscountApproval {
    
    Public static void QuoteOverallOTIxSAASA(Map<Id,Quote>newMap,Map<Id,Quote>oldMap){
        
        Id LoginUserId= UserInfo.getUserId();
        system.debug('LoginUserId--'+LoginUserId);
         
        List<User> UserList=[Select Id,ManagerId From User where isActive = true];
         system.debug('UserList--'+UserList);
        
         Map<Id,Id>UserIdXManager=new Map<Id,Id>();
        for(User U:UserList){
            if(UserIdXManager.containsKey(U.Id)){
                UserIdXManager.put(U.Id,UserIdXManager.get(U.Id)); 
            }else{
                UserIdXManager.put(U.Id,U.ManagerId);
            }
        }
         system.debug('UserIdXManager--'+UserIdXManager);
        
        User Userrec=[Select Id From User Where Name='Himanshu Singh'];
        List<Quote> QuoteList=new List<Quote>();
        Quote QRec=new Quote();
        for(Quote Q:newMap.values()){
            
            if((Q.Overall_OTI_Discount__c!=null || Q.Overall_OTI_Discount__c!=0) || (Q.Overall_ARR_Discount__c!=null || Q.Overall_ARR_Discount__c!=0)){
                system.debug('Overall_OTI_Discount__c--'+Q.Overall_OTI_Discount__c);
                 system.debug('Overall_ARR_Discount__c--'+Q.Overall_ARR_Discount__c);
 
                if((Q.Overall_OTI_Discount__c!=oldMap.get(Q.Id).Overall_OTI_Discount__c) || (Q.Overall_ARR_Discount__c!=oldMap.get(Q.Id).Overall_ARR_Discount__c)){
                    QRec.Id=Q.Id;
                      system.debug('Check For Approval');
                    if(Q.Overall_OTI_Discount__c < 10 && Q.Overall_ARR_Discount__c < 15){
                        
                            system.debug('No Approval Required');
                        
                    }else if((Q.Overall_OTI_Discount__c >= 10 && Q.Overall_OTI_Discount__c <= 20) || (Q.Overall_ARR_Discount__c >= 15 && Q.Overall_ARR_Discount__c <= 30)){
                          
                            if(Q.Approver_Authority_Level1__c==null){
                                system.debug('Approver_Authority_Level1__c--'+Q.Approver_Authority_Level1__c);
                                QRec.Approver_Authority_Level1__c=UserIdXManager.get(LoginUserId);
                                system.debug('Assigned To Team Lead');
                                QuoteList.add(QRec);
                            }
                            system.debug('Approval For Team Lead');
                    }else if((Q.Overall_OTI_Discount__c > 30) || (Q.Overall_ARR_Discount__c > 30)){
                            
                             system.debug('Approval For Himanshu');
                        
                            if(Q.Approver_Authority_Level2__c==null){ 
                                system.debug('Approver_Authority_Level2__c--'+Q.Approver_Authority_Level2__c);
                                QRec.Approver_Authority_Level2__c=Userrec.Id;
                                system.debug('Assigned To Himanshu Level 2');
                                QuoteList.add(QRec);
                            }else if(Q.Approval_Authority_Level2B__c==null){ 
                                system.debug('Approval_Authority_Level2B__c--'+Q.Approval_Authority_Level2B__c);
                                QRec.Approval_Authority_Level2B__c=Userrec.Id;
                                system.debug('Assigned To Himanshu Level 2B');
                                QuoteList.add(QRec);
                            }
                            
                    }
                }
            } 
        }
        
        if(!QuoteList.isEmpty()){
            system.debug('QuoteList--'+QuoteList);
            update QuoteList;
        }
    }
    
    

}
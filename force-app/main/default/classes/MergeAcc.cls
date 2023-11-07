public class MergeAcc {
    
    public static void mergeAccV1(){
        try{
            Map<String, List<Account>> accountListByCinNo = new Map<String, List<Account>>();
            
            List<Account> accList = [Select Name, BillingState , Type, Rating, No_of_Contact__c,No_of_Opportunties__c, AnnualRevenue , AccountSource , Industry, Sic , SicDesc , AccountNumber , Org_ID__c , CIN_Registration_Number__c, NumberOfEmployees, Region__c , Industries__c , Employee_Strength__c  , Employee_Strength_Slab__c, HRMs__c , ERP__c , ERP_Accounting_Software__c , Auditor__c , TMC__c , CRM__c,Id  From Account where Is_Duplicate__c = true and CIN_Registration_Number__c != 'NA' limit 1000];
            for(Account acc : accList){
                if(accountListByCinNo.containsKey(acc.CIN_Registration_Number__c )){
                    List<Account> accListToAdd = accountListByCinNo.get(acc.CIN_Registration_Number__c );
                    accListToAdd.add(acc);
                    accountListByCinNo.put(acc.CIN_Registration_Number__c,accListToAdd);
                }else{
                    accountListByCinNo.put(acc.CIN_Registration_Number__c,new List<Account>{acc});
                }
            }
            system.debug('accountListByCinNo ===> ' + accountListByCinNo);
            if(!accountListByCinNo.isEmpty()){
                
                list<Account> AllMasterAccountList = new List<Account>();
                for(String cinNo : accountListByCinNo.keySet()){
                    integer countOfAccount = accountListByCinNo.get(cinNo).size();
                    List<Account> masterAccountList = new List<Account>();
                    Account masterAccount= new Account();
                    system.debug('accountListByCinNo.get(cinNo) ===> ' + accountListByCinNo.get(cinNo));
                    for(Account accRec : accountListByCinNo.get(cinNo)){
                        Account duplicateAccount = new Account();
                        
                        if(masterAccountList.isEmpty()){
                            masterAccountList.add(accRec);
                        }else{
                            if(masterAccountList[0].No_of_Opportunties__c != null && accRec.No_of_Opportunties__c != null && masterAccountList[0].No_of_Opportunties__c < accRec.No_of_Opportunties__c){
                                duplicateAccount = masterAccountList[0];
                                masterAccountList[0] = accRec;
                            }else if(masterAccountList[0].No_of_Opportunties__c != null && accRec.No_of_Opportunties__c != null && masterAccountList[0].No_of_Opportunties__c > accRec.No_of_Opportunties__c){
                                duplicateAccount = accRec;
                            }else if(masterAccountList[0].No_of_Opportunties__c != null && accRec.No_of_Opportunties__c == null  ){
                                duplicateAccount = accRec;
                            }else if(masterAccountList[0].No_of_Opportunties__c == null && accRec.No_of_Opportunties__c != null){
                                duplicateAccount = masterAccountList[0];
                                masterAccountList[0] = accRec;
                            }else if(masterAccountList[0].No_of_Contact__c != null && accRec.No_of_Contact__c != null &&  masterAccountList[0].No_of_Contact__c < accRec.No_of_Contact__c){
                                duplicateAccount = masterAccountList[0];
                                masterAccountList[0] = accRec;
                            }else if(masterAccountList[0].No_of_Contact__c != null && accRec.No_of_Contact__c != null &&  masterAccountList[0].No_of_Contact__c > accRec.No_of_Contact__c){
                                duplicateAccount = accRec;
                            }else if(masterAccountList[0].No_of_Contact__c != null && accRec.No_of_Contact__c == null){
                                duplicateAccount = accRec;
                            }else if(masterAccountList[0].No_of_Contact__c == null && accRec.No_of_Contact__c != null){
                                duplicateAccount = masterAccountList[0];
                                masterAccountList[0] = accRec;
                            }
                            
                            if(masterAccountList[0] != null && duplicateAccount.id != null ){
                              
                                Database.MergeResult results = Database.merge(masterAccountList[0],duplicateAccount);
                            }
                        }
                    }
                }
            }
            
        }catch(exception e){
            system.debug('The error has occured due to :::: ' + e.getMessage() );
            system.debug('The error has occured at line number :::: ' + e.getLineNumber() );
        }
        
    }
}
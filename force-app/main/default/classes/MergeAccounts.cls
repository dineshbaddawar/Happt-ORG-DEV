public class MergeAccounts {
    public static void mergeAcc(){
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
        if(!accountListByCinNo.isEmpty()){
            
            for(String cinNo : accountListByCinNo.keySet()){
                integer countOfAccount = accountListByCinNo.get(cinNo).size();
                List<Account> masterAccountList = new List<Account>();
                Account masterAccount= new Account();
                for(Account accRec : accountListByCinNo.get(cinNo)){
                    Account duplicateAccount = new Account();
                    
                    if(masterAccountList.isEmpty()){
                        masterAccountList.add(accRec);
                    }else{
                        if(masterAccountList[0].No_of_Opportunties__c != null && accRec.No_of_Opportunties__c != null && masterAccountList[0].No_of_Contact__c != null && accRec.No_of_Contact__c != null && masterAccountList[0].No_of_Opportunties__c < accRec.No_of_Opportunties__c && masterAccountList[0].No_of_Contact__c < accRec.No_of_Contact__c ){
                            duplicateAccount = masterAccountList[0];
                            masterAccountList[0] = accRec;
                            
                        }else if(masterAccountList[0].No_of_Opportunties__c != null && accRec.No_of_Opportunties__c != null && masterAccountList[0].No_of_Contact__c != null && accRec.No_of_Contact__c != null && masterAccountList[0].No_of_Opportunties__c < accRec.No_of_Opportunties__c && masterAccountList[0].No_of_Contact__c > accRec.No_of_Contact__c ){
                            duplicateAccount = masterAccountList[0];
                            masterAccountList[0] = accRec;
                        }else if(masterAccountList[0].No_of_Opportunties__c == null && accRec.No_of_Opportunties__c != null){
                            duplicateAccount = masterAccountList[0];
                            masterAccountList[0] = accRec;
                        }else if(masterAccountList[0].No_of_Opportunties__c == null && accRec.No_of_Opportunties__c == null && masterAccountList[0].No_of_Contact__c != null && accRec.No_of_Contact__c != null &&  masterAccountList[0].No_of_Contact__c < accRec.No_of_Contact__c){
                            duplicateAccount = masterAccountList[0];
                            masterAccountList[0] = accRec;
                        }else if(masterAccountList[0].No_of_Opportunties__c == null && accRec.No_of_Opportunties__c == null && masterAccountList[0].No_of_Contact__c == null && accRec.No_of_Contact__c != null){
                            duplicateAccount = masterAccountList[0];
                            masterAccountList[0] = accRec;
                        }
                        if(masterAccountList[0] != null && duplicateAccount != null){
                            Database.MergeResult results = Database.merge(masterAccountList[0],duplicateAccount);
                            masterAccount = new Account( Id = masterAccountList[0].Id );
                        }
                    }
                }
            }
        }
    }
    
    
    public static void mergeInactiveAccounts(){
        
        Set<String> cinNo = new set<String>();
        List<Account> allDuplicateAccList = new List<Account>();
        Map<String, List<Account>> accListByCin = new Map<String, List<Account>>();
        List<Account> accList = [Select Name, LastModifiedDate,BillingState , Type, Rating, No_of_Contact__c,No_of_Opportunties__c, AnnualRevenue , AccountSource , Industry, Sic , SicDesc , AccountNumber , Org_ID__c , CIN_Registration_Number__c, NumberOfEmployees, Region__c , Industries__c , Employee_Strength__c  , Employee_Strength_Slab__c, HRMs__c , ERP__c , ERP_Accounting_Software__c , Auditor__c , TMC__c , CRM__c,Id  From Account where Is_Duplicate__c = true and CIN_Registration_Number__c != 'NA' order by LastModifiedDate Desc];
        for(Account acc : accList){
            cinNo.add(acc.CIN_Registration_Number__c);
        }
        system.debug('accList-->'+accList.size());
        
        if(!cinNo.isEmpty()){
            allDuplicateAccList = [select Name, LastModifiedDate,BillingState , Type, Rating, No_of_Contact__c,No_of_Opportunties__c, AnnualRevenue , AccountSource , Industry, Sic , SicDesc , AccountNumber , Org_ID__c , CIN_Registration_Number__c, NumberOfEmployees, Region__c , Industries__c , Employee_Strength__c  , Employee_Strength_Slab__c, HRMs__c , ERP__c , ERP_Accounting_Software__c , Auditor__c , TMC__c , CRM__c,Id from account where CIN_Registration_Number__c in :cinNo];
            if(!allDuplicateAccList.isEmpty()){
                for(Account accRec : allDuplicateAccList){
                    if(accListByCin.containsKey(accRec.CIN_Registration_Number__c)){
                        List<Account> accToAdd = accListByCin.get(accRec.CIN_Registration_Number__c);
                        accToAdd.add(accRec);
                        accListByCin.put(accRec.CIN_Registration_Number__c, accToAdd);
                    }else{
                        accListByCin.put(accRec.CIN_Registration_Number__c, new List<Account>{ accRec });
                    }
                }
                if(!accListByCin.isEMpty()){
                    for(String cinNumnber : accListByCin.keyset()){
                        List<Account> duplicateAccounts = new List<Account>();
                        Account masterAccount = new Account();
                        integer i=1;
                        string orgId = '';
                        
                        for(Account accRec : accListByCin.get(cinNumnber)){
                            if(!String.isBlank(accRec.Org_ID__c))
                                orgId = accRec.Org_ID__c;
                            if(i == 1){
                                Account accRecord = assignValues(accRec);
                                masterAccount = accRecord;
                            }else{
                                if((masterAccount.Org_ID__c != null && accRec.Org_ID__c != null && masterAccount.Org_ID__c == accRec.Org_ID__c) || (accRec.Org_ID__c == null) ){
                                    if(masterAccount.No_of_Opportunties__c != null && accRec.No_of_Opportunties__c != null && masterAccount.No_of_Opportunties__c < accRec.No_of_Opportunties__c ){
                                        duplicateAccounts.add(masterAccount);
                                        Account accRecord = assignValues(accRec);
                                        masterAccount = accRecord;
                                    }else if(masterAccount.No_of_Opportunties__c != null && accRec.No_of_Opportunties__c != null && masterAccount.No_of_Opportunties__c > accRec.No_of_Opportunties__c ){
                                        Account accRecord = assignValues(accRec);
                                        duplicateAccounts.add(accRecord);
                                    }else if(masterAccount.No_of_Opportunties__c != null && accRec.No_of_Opportunties__c != null && masterAccount.No_of_Opportunties__c == accRec.No_of_Opportunties__c ){
                                        if(masterAccount.No_of_Contact__c != null && accRec.No_of_Contact__c != null && masterAccount.No_of_Contact__c > accRec.No_of_Contact__c){
                                            Account accRecord = assignValues(accRec);
                                            duplicateAccounts.add(accRecord);
                                        }else if(masterAccount.No_of_Contact__c != null && accRec.No_of_Contact__c != null && masterAccount.No_of_Contact__c < accRec.No_of_Contact__c){
                                            duplicateAccounts.add(masterAccount);
                                            Account accRecord = assignValues(accRec);
                                            masterAccount = accRecord;
                                        }else if(masterAccount.No_of_Contact__c != null && accRec.No_of_Contact__c == null){
                                            Account accRecord = assignValues(accRec);
                                            duplicateAccounts.add(accRecord);
                                        }else if(masterAccount.No_of_Contact__c == null && accRec.No_of_Contact__c != null){
                                            duplicateAccounts.add(masterAccount);
                                            Account accRecord = assignValues(accRec);
                                            masterAccount = accRecord;
                                        }else if(masterAccount.No_of_Contact__c != null && accRec.No_of_Contact__c != null && masterAccount.No_of_Contact__c > accRec.No_of_Contact__c){
                                            if(masterAccount.LastModifiedDate < accRec.LastModifiedDate){
                                                duplicateAccounts.add(masterAccount);
                                                Account accRecord = assignValues(accRec);
                                                masterAccount = accRecord;
                                            }else if(masterAccount.LastModifiedDate > accRec.LastModifiedDate){
                                                Account accRecord = assignValues(accRec);
                                                duplicateAccounts.add(accRecord);
                                            }
                                        }
                                    }else if(masterAccount.No_of_Opportunties__c != null && accRec.No_of_Opportunties__c == null){
                                        Account accRecord = assignValues(accRec);
                                        duplicateAccounts.add(accRecord);
                                    }else if(masterAccount.No_of_Opportunties__c == null && accRec.No_of_Opportunties__c != null){
                                        duplicateAccounts.add(masterAccount);
                                        Account accRecord = assignValues(accRec);
                                        masterAccount = accRecord;
                                    }else if(masterAccount.No_of_Opportunties__c == null && accRec.No_of_Opportunties__c == null){
                                        if(masterAccount.No_of_Contact__c != null && accRec.No_of_Contact__c != null && masterAccount.No_of_Contact__c > accRec.No_of_Contact__c){
                                            Account accRecord = assignValues(accRec);
                                            duplicateAccounts.add(accRecord);
                                        }else if(masterAccount.No_of_Contact__c != null && accRec.No_of_Contact__c != null && masterAccount.No_of_Contact__c < accRec.No_of_Contact__c){
                                            duplicateAccounts.add(masterAccount);
                                            Account accRecord = assignValues(accRec);
                                            masterAccount = accRecord;
                                        }else if(masterAccount.No_of_Contact__c != null && accRec.No_of_Contact__c == null){
                                            Account accRecord = assignValues(accRec);
                                            duplicateAccounts.add(accRecord);
                                        }else if(masterAccount.No_of_Contact__c == null && accRec.No_of_Contact__c != null){
                                            duplicateAccounts.add(masterAccount);
                                            Account accRecord = assignValues(accRec);
                                            masterAccount = accRecord;
                                        }
                                    }                                    
                                }else if(masterAccount.Org_ID__c == null && accRec.Org_ID__c != null ){
                                    duplicateAccounts.add(masterAccount);
                                    Account accRecord = assignValues(accRec);
                                    masterAccount = accRecord;
                                }
                            }
                            i++;
                            
                        }
                        if(masterAccount != null && duplicateAccounts.size() != 0){
                            Database.MergeResult[] results = Database.merge(masterAccount,duplicateAccounts);
                        }
                    }
                }
            }
        }
    }
    
    public static Account assignValues(Account accRecordToUpdate){
        account accountRec = new account();
        accountRec.Id = accRecordToUpdate.Id;
        accountRec.Name = 	accRecordToUpdate.Name;
        accountRec.BillingState = 	accRecordToUpdate.BillingState;
        accountRec.Type	= accRecordToUpdate.Type;
        accountRec.Rating= accRecordToUpdate.Rating;
        accountRec.AnnualRevenue = accRecordToUpdate.AnnualRevenue;
        accountRec.AccountSource = 	accRecordToUpdate.AccountSource;
        accountRec.Industry	= accRecordToUpdate.Industry;
        accountRec.Sic = accRecordToUpdate.Sic ;
        accountRec.SicDesc = accRecordToUpdate.SicDesc;
        accountRec.AccountNumber = 	accRecordToUpdate.AccountNumber;
        accountRec.Org_ID__c = accRecordToUpdate.Org_ID__c;
        accountRec.CIN_Registration_Number__c = accRecordToUpdate.CIN_Registration_Number__c;
        accountRec.NumberOfEmployees = accRecordToUpdate.NumberOfEmployees;
        accountRec.Region__c = 	accRecordToUpdate.Region__c;
        accountRec.Industries__c = accRecordToUpdate.Industries__c;
        accountRec.Employee_Strength__c = accRecordToUpdate.Employee_Strength__c;
        accountRec.Employee_Strength_Slab__c = accRecordToUpdate.Employee_Strength_Slab__c;
        accountRec.HRMs__c = accRecordToUpdate.HRMs__c;
        accountRec.ERP__c = accRecordToUpdate.ERP__c;
        accountRec.ERP_Accounting_Software__c = accRecordToUpdate.ERP_Accounting_Software__c;
        accountRec.Auditor__c = accRecordToUpdate.Auditor__c;
        accountRec.TMC__c = accRecordToUpdate.TMC__c;
        accountRec.CRM__c = accRecordToUpdate.CRM__c;
        return accountRec;
    }
}
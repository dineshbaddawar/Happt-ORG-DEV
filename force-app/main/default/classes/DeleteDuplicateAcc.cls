public class DeleteDuplicateAcc {
    
    public static void mergeAccountsByCIN() {
       
        List<Account> accountsWithSameCIN = [SELECT Id, Name, CIN__c FROM Account WHERE CIN__c != null ORDER BY CIN__c];
        
        Map<String, List<Account>> cinToAccountsMap = new Map<String, List<Account>>();
        for (Account acc : accountsWithSameCIN) {
            if (!cinToAccountsMap.containsKey(acc.CIN__c)) {
                cinToAccountsMap.put(acc.CIN__c, new List<Account>());
            }
            cinToAccountsMap.get(acc.CIN__c).add(acc);
        }
       
        for (List<Account> accounts : cinToAccountsMap.values()) {
            mergeAccounts(accounts);
        }
    }
    
    public static void mergeAccounts(List<Account> accounts) {
        if (accounts.size() > 1) {
            // Sort accounts based on Total_Opportunity_Count__c
            accounts = sortAccountsByTotalOpportunities(accounts);
            
            // Getting the account with the least opportunities
            Account accountToDelete = accounts[0];
            
            // Getting the account with the highest opportunities
            Account accountToMergeInto = accounts[accounts.size() - 1];
            
            // Moving the contacts and opportunities from the account to be deleted to the account to merge into
            moveContactsAndOpportunities(accountToDelete, accountToMergeInto);
            
            // Delete the account with the least opportunities
            deleteAccount(accountToDelete);
        }
    }
    
    public static void moveContactsAndOpportunities(Account fromAccount, Account toAccount) {
        
        List<Contact> contactsToMove          = [SELECT Id FROM Contact WHERE AccountId = :fromAccount.Id];
        List<Opportunity> opportunitiesToMove = [SELECT Id FROM Opportunity WHERE AccountId = :fromAccount.Id];
        
        for (Contact contact : contactsToMove) {
            contact.AccountId = toAccount.Id;
        }
        
        for (Opportunity opportunity : opportunitiesToMove) {
            opportunity.AccountId = toAccount.Id;
        }
        
        update contactsToMove;
        update opportunitiesToMove;
    }
    
    public static void deleteAccount(Account account) {
        
        List<Contact> relatedContacts          = [SELECT Id FROM Contact WHERE AccountId = :account.Id];
        List<Opportunity> relatedOpportunities = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id];
        
        if (relatedContacts.isEmpty() && relatedOpportunities.isEmpty()) {
            delete account;
        } else {
            System.debug('Cannot delete account ' + account.Name + ' due to related records.');
        }
    }
    
    public static List<Account> sortAccountsByTotalOpportunities(List<Account> accounts) {
        
        accounts.sort(new TotalOpportunityComparator());
        return accounts;
    }
    
    public class TotalOpportunityComparator implements Comparator<Account> { 
       
        public Integer compare(Account a, Account b) {
            if (a.Total_Opportunity_Count__c < b.Total_Opportunity_Count__c) {
                return -1;
            } else if (a.Total_Opportunity_Count__c > b.Total_Opportunity_Count__c) {
                return 1;
            } else {
                return 0;
            }
        }
    }
}
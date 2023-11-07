public class AccountTriggerService {
    
    public static void addTeamMembers(List<Account> newList) {
        //get all users sales team member / pre sales member ..(tax benefit / Travel Expense)
		//Map<String, Product_Team_Mapping__mdt> productMappingMap 	= Product_Team_Mapping__mdt.getAll();
		List<GroupMember> gpMemberList 					= new List<GroupMember>();
        
        //List<GroupMember> gpMemberListValuepreSales 	= [Select Id, Group.Name, GroupId, UserOrGroupId from GroupMember where Group.Name = 'Travel & Expense (T&E) - Presales Team'];
        List<GroupMember> gpMemberListValueBDTeam   	= [Select Id, Group.Name, GroupId, UserOrGroupId from GroupMember where Group.Name = 'Travel & Expense (T&E) - BD Team' LIMIT 1];
        List<GroupMember> gpMemberListValueSalesTeam 	= [Select Id, Group.Name, GroupId, UserOrGroupId from GroupMember where Group.Name = 'Travel & Expense (T&E) - Sales Team' LIMIT 1];
        
        List<AccountTeamMember> accountTeamList 		= new List<AccountTeamMember>();
        gpMemberList									= AccountTriggerModel.getGroupMembersOfProducts();
        for(Account accountObj : newList) {
            Boolean isBDTravelFound = false;
            Boolean isBDTaxFound = false;
            Boolean isSalesTravelFound = false;
            Boolean isSalesTaxFound = false;
            for(GroupMember GroMem : gpMemberListValueBDTeam) {
                AccountTeamMember accountTeamObj 		= new AccountTeamMember();
                accountTeamObj.AccountAccessLevel 		= 'Edit';
                accountTeamObj.AccountId				=  accountObj.Id;
                accountTeamObj.CaseAccessLevel 			= 'None';
                accountTeamObj.OpportunityAccessLevel	= 'None'; 
                accountTeamObj.UserId					=  GroMem.UserOrGroupId;
                accountTeamObj.Product__c               =  'Travel & Expense (T&E)';
                accountTeamObj.TeamMemberRole			= 'BD';
                accountTeamList.add(accountTeamObj);
            }
            for(GroupMember GroMem : gpMemberListValueSalesTeam) {
                AccountTeamMember accountTeamObj 		= new AccountTeamMember();
                accountTeamObj.AccountAccessLevel 		= 'Edit';
                accountTeamObj.AccountId				=  accountObj.Id;
                accountTeamObj.CaseAccessLevel 			= 'None';
                accountTeamObj.OpportunityAccessLevel	= 'None'; 
                accountTeamObj.UserId					= GroMem.UserOrGroupId;
                accountTeamObj.Product__c               =  'Travel & Expense (T&E)';
                accountTeamObj.TeamMemberRole			= 'Sales Rep';
                accountTeamList.add(accountTeamObj);
            }            
        }
        if(!accountTeamList.isEmpty()) insert accountTeamList;
    }
}
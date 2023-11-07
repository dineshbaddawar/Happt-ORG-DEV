public class MergeContacts {
    public static void mergingContacts(){
        try{
            // Query for duplicate contacts with matching phone and email
            List<Contact> contactsToMerge = [SELECT Id,Phone,email,Name FROM Contact WHERE Account.Is_Duplicate__c = true];
            Map<String, List<Contact>> conlistbyemail = new Map<String, List<Contact>>();
            
            for(Contact con : contactsToMerge){
                if(conlistbyemail.containsKey(con.Email)){
                    List<Contact> conToAdd = conlistbyemail.get(con.Email);
                    conToAdd.add(con);
                    conlistbyemail.put(con.Email, conToAdd);
                }else{
                    conlistbyemail.put(con.Email, new List<Contact> {con});
                }
            }
            system.debug('conlistbyemail-->'+conlistbyemail);
            // Check if there are any duplicates
            if (!conlistbyemail.isEmpty()) {
                for(String conEmail : conlistbyemail.keyset()){
                    system.debug('conlistbyemail.get(conEmail).size()--->'+conlistbyemail.get(conEmail).size());
                    if(conlistbyemail.get(conEmail).size() == 2){
                        List<Contact> conlistToMerge = conlistbyemail.get(conEmail);
                        Database.MergeResult mergeResult = Database.merge(conlistToMerge[0], conlistToMerge[1]);
                    }else{
                        
                    }
                    
                }
            }
        }catch(exception e){
            system.debug('The error has occured due to :::: ' + e.getMessage() );
            system.debug('The error has occured at line number :::: ' + e.getLineNumber() );
        }   
    }
}
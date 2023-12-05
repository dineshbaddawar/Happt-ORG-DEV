public class UpdateStageOnLeadController {
    
    @AuraEnabled        
    public static List<String> getPickListValuesIntoList(String recordId) {
        Lead leadObj 	= [Select Id, RecordType.Name from Lead where Id =: recordId];
        if(leadObj.RecordType.Name == 'EPIC') {
            List<String> pickListValuesList = new List<String>();
            pickListValuesList.add('Open');
            pickListValuesList.add('Contacted');
            pickListValuesList.add('Prospecting-Meeting Fixed');
            pickListValuesList.add('Prospecting-Meeting Done');
            pickListValuesList.add('Dropped/Lost');
            pickListValuesList.add('Converted');
            return pickListValuesList;
        }
        if(leadObj.RecordType.Name == 'Travel & Expense') {
            List<String> pickListValue = new List<String>();
            pickListValue.add('Open');
            pickListValue.add('Preliminary assesment');
            pickListValue.add('Dropped');
            pickListValue.add('On Hold');
            pickListValue.add('Converted');
            return pickListValue;
        }
        return null;
    }
    
    
    @AuraEnabled        
    public static String updateLeadStatus(Lead leadRec,String recordId){
        
        if(leadRec.Status == 'Converted'){
            return LeadConversioonCompHelper.convertLeadMethod(recordId);
        }else{
            try {
                system.debug('leadRec-->'+recordId);
                leadRec.Id = recordId;
                update leadRec;
                return 'Success';
            }
            catch(DmlException  e){
                string errorMessage = '';
                for (Integer i = 0; i < e.getNumDml(); i++) {
                    errorMessage = e.getDmlMessage(i);
                }
                return errorMessage;
            }
        }
    }
}
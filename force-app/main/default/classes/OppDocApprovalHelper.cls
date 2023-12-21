public class OppDocApprovalHelper {
    
    @AuraEnabled
    public static string docApproval(String oppId, String comment){
        try {
            String result;
            List<Opportunity> oppList = [SELECT Id, Name, OwnerId, Approved_Quotes__c, Accepted_Quotes__c FROM Opportunity WHERE Id =: oppId LIMIT 1];
            List<ProcessInstance> recordUnderApproval = [Select ID, Status,TargetObjectID, TargetObject.Name From ProcessInstance Where Status = 'Pending' AND TargetObjectID =:oppId];
            System.debug('RecordUnderApproval----'+recordUnderApproval);
            if(oppList[0].Accepted_Quotes__c > 0){
                if(recordUnderApproval.size()>0){
                    result = 'Pending';
                }
                result = doApproval(oppId, 'Document_Approval', comment);
            }
            else if(oppList[0].Accepted_Quotes__c == 0){
                result = 'Quote not approved';
            }       
            system.debug('result -- ' + result);
            return result;
        } 
        catch (Exception e) {
            system.debug('Error :: ' + e.getMessage() + 'At Line No :: ' + e.getLineNumber());
            return e.getMessage();
        }
    }
    
    public static string doApproval(Id objId, String approvalName, String comments){
        try{
            String res;
            Map<Id, Approval.ProcessSubmitRequest> caseToapprovalRequestMap = new Map<Id, Approval.ProcessSubmitRequest>();
            Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
            approvalRequest.setComments(comments);
            approvalRequest.setObjectId(objId);
            approvalRequest.setProcessDefinitionNameOrId(approvalName);
            caseToapprovalRequestMap.put(objId, approvalRequest);
            
            if(!caseToapprovalRequestMap.isEmpty()){
                List<Approval.ProcessResult> result = Approval.process(caseToapprovalRequestMap.values());
                res = 'Success';
            }
            return res;
        }
        catch(Exception e){
            system.debug('ERROR :: ' + e.getMessage() + 'AT LINE NUMBER :: ' + e.getLineNumber());
            return e.getMessage();
        }           
    }
}
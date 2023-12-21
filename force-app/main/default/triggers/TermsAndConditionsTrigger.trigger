trigger TermsAndConditionsTrigger on Terms_and_condition__c (after insert,after update) {
    if(Trigger.isInsert && Trigger.isAfter){
        //TermsAndConditionsTriggerHandler.calculateARRBasedOnBillingType(Trigger.new);
        //if(PaymentTermApprover.reccursiveHandler){
            PaymentTermApprover.calculateApproverAuthorityMatrix(Trigger.new,trigger.oldMap);   
        //}
        
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        //TermsAndConditionsTriggerHandler.calculateARRBasedOnBillingType(Trigger.new);
        //if(PaymentTermApprover.reccursiveHandler){
            PaymentTermApprover.calculateApproverAuthorityMatrix(Trigger.new,trigger.oldMap); 
        //}
        
    }
}
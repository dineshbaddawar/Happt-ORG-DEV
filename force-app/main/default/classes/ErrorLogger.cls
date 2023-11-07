public without sharing class ErrorLogger {
    
    public static String createLogError(String ComponentName, String ComponentType,
                                          String ErrorMessage, String ErrorDescription, String ErrorCode,
                                          String RecordReference, String AdditionalInfo)
    {
        Error_Log__c er = new Error_Log__c();
        
        er.Component_Name__c=ComponentName;
        er.Component_Type__c=ComponentType;
        
        er.ErrorMessage__c=ErrorMessage;
        er.Error_Description__c=ErrorDescription;
        er.Error_Code__c=ErrorCode;
        
        er.Record_Reference__c = RecordReference;
        er.Additional_Info__c=AdditionalInfo;
        
        er.Logged_In_User__c=UserInfo.getUserId();
        insert er;
        return er.Name; 
    }
    
    public static Error_Log__c LogError(String ComponentName, String ComponentType,
                                  String ErrorMessage, String ErrorDescription, String ErrorCode,
                                  String RecordReference, String AdditionalInfo)
    {
        Error_Log__c er = new Error_Log__c();
        
        er.Component_Name__c=ComponentName;
        er.Component_Type__c=ComponentType;
        
        er.ErrorMessage__c=ErrorMessage;
        er.Error_Description__c=ErrorDescription;
        er.Error_Code__c=ErrorCode;
        
        er.Record_Reference__c = RecordReference;
        er.Additional_Info__c=AdditionalInfo;
        
        er.Logged_In_User__c=UserInfo.getUserId();
        return er;

    }

}
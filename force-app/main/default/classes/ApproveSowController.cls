public without sharing class ApproveSowController {

    @AuraEnabled
    public static String updateSowApprove(String oppId){
    String result;
      try{
          List<Opportunity> oppList = [SELECT ID,Name,SOW_Approved__c FROM Opportunity WHERE Id =:oppId];
         
         oppList[0].SOW_Approved__c = TRUE;
         update oppList;
         result = 'SUCCESS';
  
      }catch(Exception e){
          System.debug('Exception Message-->'+e.getMessage());
          System.debug('Exception Line Number-->'+e.getLineNUmber());
          result = e.getMessage();
      }
      return result;
    }

}
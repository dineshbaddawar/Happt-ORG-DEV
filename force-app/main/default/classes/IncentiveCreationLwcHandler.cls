/**
 * @description       : 
 * @author            : Dhanush Babu
 * @group             : 
 * @last modified on  : 03-02-2023
 * @last modified by  : Dhanush Babu
**/
public with sharing class IncentiveCreationLwcHandler {
   

    @AuraEnabled(cacheable=true)
    public static list<Profile> getProfiles(){
    
             List<Profile> profileList = [Select Name from Profile];
    
        return profileList;
    }




    public class IncentiveInput {
        @AuraEnabled
        public String obj { get; set; }
        @AuraEnabled
        public String objfield { get; set; }
        @AuraEnabled
        public String profile { get; set; }
         @AuraEnabled
        public String computationField { get; set; }
    }
    
    @AuraEnabled
    public static Incentive_Master__c createIncentive(IncentiveInput input) {
        String result = '';
       // try {
            Incentive_Master__c inc = new Incentive_Master__c();
            inc.Target_Object__c = input.obj;
            inc.Evaluation_Field__c = input.objfield;
            inc.Profile__c = input.profile;
            inc.Incentive_computation_on__c = input.computationField;
            insert inc;
           system.debug('Incentives are>>>'+ inc);
            
        // } catch (Exception e) {
        //     result = e.getMessage()  +' on line - ' + e.getLineNumber();
        // }
        return inc;
    }
    
}
@isTest
public class TaskHandlerTest {
   /* static testMethod void insertTaskForLead(){
        Lead l = TestUtility.createLead();
        Account ac = TestUtility.createAccount('Test Acc');
        Contact con = TestUtility.createContact(ac);
        Task t = new Task(WhatId =l.id ,WhoId=l.id,Subject='Send Letter',Status='New',Priority='Normal');
        System.debug(t);
        Insert t;
        System.debug(t);
    }*/
    
        static testMethod void insertTaskForOpp(){
       
        Account ac = TestUtility.createAccount('Test Acc');
        Contact con = TestUtility.createContact(ac);
        Opportunity opp = TestUtility.createOpportunity(ac);
        Opportunity__c custOp1 = TestUtility.createCustomOppo(opp);
        //Task t = new Task(Subject='Call',Status='New',Priority='Normal',CallType='Outbound', WhatId =opp.id ,WhoId=opp.id);
        //Insert t;
    }
}
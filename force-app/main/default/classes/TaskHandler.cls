public class TaskHandler {
    private static set<id> leadIds = new Set<id>();
    private static List<Lead> leadList = new List<Lead>();
    private static List<Lead> leadToUpdate = new List<Lead>();
    
    public static void chnageLeadStatus(List<Task> taskList)
    {
        System.debug(taskList);
        String lead_prefix = Schema.SObjectType.Lead.getKeyPrefix();
        for(Task t: taskList)
        {
            System.debug('t.whoId'+t.whoId);
            //System.debug('((String)t.WhoId).startsWith(lead_prefix)'+((String)t.WhoId).startsWith(lead_prefix));
            if(t.WhoId != null && ((String)t.WhoId).startsWith(lead_prefix))
            {
                leadIds.add(t.WhoId);
            }
            
        }
        System.debug('LeadId'+leadIds);
        if(!leadIds.isEmpty())
        {
            leadList =[select id ,Status from Lead where id IN:leadIds and Status ='Qualified'];
            System.debug('Leads to update-->'+leadList);
            for(Lead l : leadList)
            {
                l.Status = 'Contacted';
                leadToUpdate.add(l);
            }
         
            if(!leadToUpdate.isEmpty())
            {
                Update leadToUpdate;
                System.debug('Lead Stages Updated');
            }
        }
        
    }   
    
    /* Code to Mark Custom Opportunity on Tasks */
    public static void markCustomOpportunityonTask(List<Task> taskList){
        Set<Id> OpportunityIdSet = new Set<Id>();
        String opp_prefix = Schema.SObjectType.Opportunity.getKeyPrefix();
        System.debug(opp_prefix);
        for(Task t: taskList)
        {
            
            System.debug(t.WhatId);
            Boolean isWhatIdOpp = t.WhatId != null && ((String)t.WhatId).startsWith(opp_prefix);
            System.debug('isWhatIdOpp'+isWhatIdOpp);
            System.debug('((String)t.WhatId)'+t.WhatId);
            if(isWhatIdOpp)
            {
                OpportunityIdSet.add(t.WhatId);
            }
            
        }
        
        Map<Id, Opportunity__c> standardToCustomOpportunityMap = new Map<Id, Opportunity__c>();        
        if(!OpportunityIdSet.isEmpty()){
            List<Opportunity__c> customOppList = [SELECT Id, Name, AccountId__c, Standard_Opportunity__c FROM Opportunity__c 
                                                  WHERE Standard_Opportunity__c in :OpportunityIdSet];

            for(Opportunity__c copp: customOppList)
            {
                standardToCustomOpportunityMap.put(copp.Standard_Opportunity__c, copp);
            }
            
            System.debug(standardToCustomOpportunityMap);
            for(Task t: taskList)
            {
                Boolean isWhatIdOpp = t.WhatId != null && ((String)t.WhatId).startsWith(opp_prefix);
                if(isWhatIdOpp)
                {
                    if(standardToCustomOpportunityMap.containsKey(t.WhatId))
                    {
                        t.Custom_Opportunity__c = standardToCustomOpportunityMap.get(t.WhatId).Id;
                    }
                }
                
            }
        }
        
        
    }
}
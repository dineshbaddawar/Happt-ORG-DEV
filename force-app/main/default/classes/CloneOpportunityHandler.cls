public class CloneOpportunityHandler {
    Private static Set<Id> oppIdSet = new Set<Id>();
    Private static Set<Id> custOpIds = new Set<Id>();
    
    public static boolean IsFirstTime = true;
    
    //Delete the Custom Opportunity when Standard Opportunity is Deleted 
    public static void calldeleteOpp(List<Opportunity> oldOpList)
    {
        for(Opportunity opp:oldOpList){
            oppIdSet.add(opp.Id);
        }
        System.debug('Opp to Delete in trigger-->'+oppIdSet);
        for(Opportunity__c op : [select id from Opportunity__c where Standard_Opportunity__c IN:oppIdSet ])
        {
            custOpIds.add(op.id);
        }
        deleteOpportunities(custOpIds);
    }
    
   @future
    public static void deleteOpportunities(set<Id> custOpId )
    {
        List <Opportunity__C> custOpList =[select id from Opportunity__C where id IN: custOpId];
        System.debug('custom Opportunities to delete-->'+custOpList);
        if(!custOpList.isEmpty())
        {
            DELETE custOpList;
            System.debug('Custom Opportunity Deleted..!');
        }
    }
    
    
    //Delete the Custom Product when Standard Product is Deleted 
    public static void callItemDelete(List<OpportunityLineItem> olineList)
    {
        Set<Id> oppLineIdSet = new Set<Id>();
        Set<Id> custOplIds = new Set<Id>();
        for(OpportunityLineItem opp:olineList){
            oppLineIdSet.add(opp.Id);
        }
        System.debug('Opp to Delete in trigger-->'+oppLineIdSet);
        for(OpportunityLineItem__C opl : [select id from OpportunityLineItem__c where Standard_Opportunity_Product__c IN:oppLineIdSet ])
        {
            custOplIds.add(opl.id);
        }
        deleteProducts(custOplIds);
    } 
    @future
    public static void deleteProducts(set<id> custProIds)
    {
        List<OpportunityLineItem__c> custproList =[select id from OpportunityLineItem__c where id IN: custProIds];
        System.debug('custom Opportunity Line items to delete-->'+custproList);
        if(!custproList.isEmpty())
        {
            DELETE custproList;
            System.debug('Custom Opportunity Line items Deleted..!');
        }
    }
    
    ///--------------------------------------------------------------------///
    //Updating Clone from Std Opp
    public static void updateCloneOpp(List<Opportunity> oppList, Map<Id, Opportunity> oldOppMap)
    {
        //Fetch all metadate for Opportunity Clone
        //
        
        Map<String, String> stdtoCloneFieldMap = CloneOpportunityHandler.getAllCloneMetadata('Opportunity');
        
        Set<String> fieldsToCheck = stdtoCloneFieldMap.keySet();
        Set<Id> OppCloneUpdateRequiredIds = new Set<Id>();
        if(!fieldsToCheck.isEmpty())
        {
            for(Opportunity opp:oppList)
            {
                for(String fieldApiName: fieldsToCheck)
                {
                    Opportunity oldOpp  = oldOppMap.get(opp.Id);
                    if(opp.get(fieldApiName)!=oldOpp.get(fieldApiName))
                    {
                        OppCloneUpdateRequiredIds.add(opp.Id);
                    }
                }
            }
            
            String selectedCloneFields ='';
            for(String cloneAPIName: stdtoCloneFieldMap.values())
            {
                selectedCloneFields  = selectedCloneFields  + cloneAPIName+ ', ';
            }
            selectedCloneFields = selectedCloneFields.removeEnd(', ');
            String ClonedOppQuery = 'Select Id,Standard_Opportunity__c,'+selectedCloneFields+' From Opportunity__c where Standard_Opportunity__c in :OppCloneUpdateRequiredIds';
            
            
            List<Opportunity__c> clonedOpportunityList = Database.query(ClonedOppQuery);
            
            Map<Id,Opportunity__c> stdtoCloneOppMap = new Map<Id, Opportunity__c>();
            
            for(Opportunity__c copp: clonedOpportunityList)
            {
                stdtoCloneOppMap.put(copp.Standard_Opportunity__c,copp);
            }
            cloneValuesforCustomOpportunity(stdtoCloneOppMap,OppCloneUpdateRequiredIds,oppList,fieldsToCheck,stdtoCloneFieldMap);
           
        }
    }
    
    public static  void cloneValuesforCustomOpportunity(Map<Id,Opportunity__c> stdtoCloneOppMap,
                                                        Set<Id> OppCloneUpdateRequiredIds,
                                                        List<Opportunity> oppList,
                                                        Set<String> fieldsToCheck,
                                                        Map<String, String> stdtoCloneFieldMap)
    {
        List<Opportunity__c> clonedOppListToUpdate = new List<Opportunity__c>();
        for(Opportunity opp:oppList)
        {
            if(OppCloneUpdateRequiredIds.contains(opp.id) && stdtoCloneOppMap.containsKey(Opp.Id))
            {
                Opportunity__c clonedOpp = stdtoCloneOppMap.get(Opp.Id);
                for(String fieldApiName: fieldsToCheck)
                {
                    clonedOpp.put(stdtoCloneFieldMap.get(fieldApiName),opp.get(fieldApiName));
                }
                clonedOppListToUpdate.add(clonedOpp);
            }
        }   
        Database.update(clonedOppListToUpdate,false);
    }
    
    //Updating Standard from clone Opp
    public static void updateStdOpp(List<Opportunity__c> oppList, Map<Id, Opportunity__c> oldOppMap)
    {
        Map<String, String> cloneToStdeFieldMap = CloneOpportunityHandler.getAllCloneMetadata('cOpportunity');
        System.debug(cloneToStdeFieldMap);
        Set<String> fieldsToCheck = cloneToStdeFieldMap.keySet();
        Set<Id> OppCloneUpdateRequiredIds = new Set<Id>();
        
        if(!fieldsToCheck.isEmpty())
        {
            for(Opportunity__c opp:oppList)
            {
                for(String fieldApiName: fieldsToCheck)
                {
                    Opportunity__c oldOpp  = oldOppMap.get(opp.Id);
                    if(opp.get(fieldApiName)!=oldOpp.get(fieldApiName))
                    {
                        OppCloneUpdateRequiredIds.add(opp.Standard_Opportunity__c);
                    }
                }
            }
            
            System.debug(OppCloneUpdateRequiredIds);
            String selectedStdFields ='';
            for(String stdAPIName: cloneToStdeFieldMap.keySet())
            {
                selectedStdFields  = selectedStdFields  + stdAPIName+ ', ';
            }
            selectedStdFields = selectedStdFields.removeEnd(', ');
            String ClonedOppQuery = 'Select Id,'+selectedStdFields+' From Opportunity where Id in :OppCloneUpdateRequiredIds';
            
            
            List<Opportunity> stdOpportunityList = Database.query(ClonedOppQuery);
            Map<Id,Opportunity> stdOppMap = new Map<Id, Opportunity>();
            
            for(Opportunity opp: stdOpportunityList)
            {
                stdOppMap.put(opp.id,opp);
            }
            
            System.debug(stdOppMap);
            cloneValuesforStdOpportunity(stdOppMap,OppCloneUpdateRequiredIds,oppList,fieldsToCheck,cloneToStdeFieldMap);
        }
        
    }
    
    public static void cloneValuesforStdOpportunity (Map<Id,Opportunity> stdOppMap,
                                                     Set<Id> OppCloneUpdateRequiredIds,
                                                     List<Opportunity__c> oppList,
                                                     Set<String> fieldsToCheck,
                                                     Map<String, String> cloneToStdeFieldMap)
    {
        List<Opportunity> stdOppListToUpdate = new List<Opportunity>();
          for(Opportunity__c opp:oppList)
            {               
                Boolean isRequiredToUpdate = OppCloneUpdateRequiredIds.contains(opp.Standard_Opportunity__c) && stdOppMap.containsKey(Opp.Standard_Opportunity__c);
                if(isRequiredToUpdate)
                {
                    Opportunity clonedOpp = stdOppMap.get(Opp.Standard_Opportunity__c);
                    for(String fieldApiName: fieldsToCheck)
                    {
                        clonedOpp.put(cloneToStdeFieldMap.get(fieldApiName),opp.get(fieldApiName));
                    }
                    stdOppListToUpdate.add(clonedOpp);
                }
            }   
        	System.debug(stdOppListToUpdate);
            Database.update(stdOppListToUpdate,false);
    }
    
    public static void callCustOpp(List<Opportunity> opList)
    {
        set<id> opIds = new Set<id>();
        
        for(Opportunity op: opList)
        {
            opIds.add(op.id);
        }
        System.debug('Calling Future Method-->'+opIds);
        createCustOpp(opIds);
    }
    
    
    //create Custom Opportunity
    @future
    public static void createCustOpp(set<Id> setOpIds)
    {
        System.debug('Creating Custom Opportunities');
        Map<String, String> stdtoCloneFieldMap = CloneOpportunityHandler.getAllCloneMetadata('Opportunity');
        
        String selectedCloneFields ='';
        for(String cloneAPIName: stdtoCloneFieldMap.keySet())
        {
            selectedCloneFields  = selectedCloneFields  + cloneAPIName+ ', ';
        }
        selectedCloneFields = selectedCloneFields.removeEnd(', ');
        
        String StdOppQuery = 'Select Id ,'+selectedCloneFields+' From Opportunity where id in :setOpIds';  
        List<Opportunity> stdOpportunityList = Database.query(StdOppQuery);  
        List<Opportunity__c> clonedOppListToInsert = new List<Opportunity__c>();
        
        
        for(Opportunity opp:stdOpportunityList)
        {
            Opportunity__c clonedOpp = new Opportunity__c();
            clonedOpp.Standard_Opportunity__c = opp.Id;
            for(String fieldApiName: stdtoCloneFieldMap.keySet())
            {
                clonedOpp.put(stdtoCloneFieldMap.get(fieldApiName),opp.get(fieldApiName));
            }
            clonedOpp.Name = (clonedOpp.Name).left(79);
            clonedOppListToInsert.add(clonedOpp);
            
        }
        System.debug('cOpportunities to Insert'+clonedOppListToInsert);
        Database.SaveResult[] srList= Database.Insert(clonedOppListToInsert,false);   
        System.debug('REsult-->'+srList);
        for (Database.SaveResult sr : srList) {
      if (sr.isSuccess()) {
        // Operation was successful, so get the ID of the record that was processed
        System.debug('Successfully inserted cOpportunity. cOpportunity ID: ' + sr.getId());
    }
    else {
        // Operation failed, so get all errors                
        for(Database.Error err : sr.getErrors()) {
            System.debug('The following error has occurred.');                    
            System.debug(err.getStatusCode() + ': ' + err.getMessage());
            System.debug(' fields that affected this error: ' + err.getFields());
        }
    }
}
    }
    
    //Update custom Product from Standard Product
    public static void updateCloneLineItem(List<OpportunityLineItem> oppLineList, Map<Id, OpportunityLineItem> oldOppMap)
    {   
        System.debug('updating the Custom Product');
        Map<String, String> stdtoCloneFieldMap = CloneOpportunityHandler.getAllCloneMetadata('OpportunityLineItem');
        System.debug(stdtoCloneFieldMap);
        Set<String> fieldsToCheck = stdtoCloneFieldMap.keySet();
        Set<Id> OppCloneUpdateRequiredIds = new Set<Id>();
        System.debug(fieldsToCheck);
        if(!fieldsToCheck.isEmpty())
        {
            
            for(OpportunityLineItem oppLine:oppLineList)
            {
                for(String fieldApiName: fieldsToCheck)
                {
                    OpportunityLineItem oldOppLine  = oldOppMap.get(oppLine.Id);
                    if(oppLine.get(fieldApiName)!=oldOppLine.get(fieldApiName))
                    {
                        OppCloneUpdateRequiredIds.add(oppLine.Id);
                    }
                }
            }
            System.debug(OppCloneUpdateRequiredIds);
            
            String selectedCloneFields ='';
            
            for(String cloneAPIName: stdtoCloneFieldMap.values())
            {
                selectedCloneFields  = selectedCloneFields  + cloneAPIName+ ', ';
            }
            selectedCloneFields = selectedCloneFields.removeEnd(', ');
            String ClonedOppLineQuery = 'Select Id ,Standard_Opportunity_Product__c,'+selectedCloneFields+' From OpportunityLineItem__c where Standard_Opportunity_Product__c in :OppCloneUpdateRequiredIds';
            System.debug(ClonedOppLineQuery);
            List<OpportunityLineItem__c> clonedOpportunityList = Database.query(ClonedOppLineQuery);
            System.debug(clonedOpportunityList);
            Map<Id,OpportunityLineItem__c> stdtoCloneOppMap = new Map<Id, OpportunityLineItem__c>();
            
            for(OpportunityLineItem__c coppLine: clonedOpportunityList)
            {
                stdtoCloneOppMap.put(coppLine.Standard_Opportunity_Product__c,coppLine);
            }
            
          cloneValuesforCustomOppLine(stdtoCloneOppMap,OppCloneUpdateRequiredIds,oppLineList,fieldsToCheck,stdtoCloneFieldMap);
        }
    }
    
    public static void cloneValuesforCustomOppLine(Map<Id,OpportunityLineItem__c> stdtoCloneOppMap,
                                                   Set<Id> OppCloneUpdateRequiredIds,
                                                   List<OpportunityLineItem> oppLineList,
                                                   Set<String> fieldsToCheck,
                                                   Map<String, String> stdtoCloneFieldMap)
    {
        System.debug('new Func');
        List<OpportunityLineItem__c> clonedOppLineListToUpdate = new List<OpportunityLineItem__c>();
           for(OpportunityLineItem oppLine:oppLineList)
            {
                if(OppCloneUpdateRequiredIds.contains(oppLine.id) && stdtoCloneOppMap.containsKey(oppLine.Id))
                {
                    OpportunityLineItem__c clonedOpp = stdtoCloneOppMap.get(oppLine.Id);
                    for(String fieldApiName: fieldsToCheck)
                    {
                        clonedOpp.put(stdtoCloneFieldMap.get(fieldApiName),oppLine.get(fieldApiName));
                    }
                    System.debug('clonedOpp'+clonedOpp);
                    clonedOppLineListToUpdate.add(clonedOpp);
                }
            }
            
            Database.update(clonedOppLineListToUpdate,false);   
    }
    
    public static void callCustOppLine(List<OpportunityLineItem> opLineList)
    {
        set<id> opLineIds = new Set<id>();
        
        for(OpportunityLineItem op: opLineList)
        {
            opLineIds.add(op.id);
        }
        System.debug('Calling Future Method-->'+opLineIds);
        createCustLineItem(opLineIds);
    }
    
    
    //create Custom Opportunity Line Items
    @future
    public static void createCustLineItem(set<Id> setLineIds)
    {
        System.debug('Creating Custom Line Items');
        Map<String, String> stdtoCloneFieldMap = CloneOpportunityHandler.getAllCloneMetadata('OpportunityLineItem');
        
        String selectedStdFields ='';
        for(String cloneAPIName: stdtoCloneFieldMap.keySet())
        {
            selectedStdFields  = selectedStdFields  + cloneAPIName+ ', ';
        }
        selectedStdFields = selectedStdFields.removeEnd(', ');
        
        String StdOppQuery = 'Select Id,opportunityId,'+selectedStdFields+' From OpportunityLineItem where id in :setLineIds';
        System.debug(StdOppQuery);
        List<OpportunityLineItem> stdLineItemList = Database.query(StdOppQuery);  
        List<OpportunityLineItem__c> clonedLineItemsToListToInsert = new List<OpportunityLineItem__c>();
        
        //
        //
        //for setting up the Custom opp Lookup
        //
        // 
        Set<id> stdOpIds = new Set<id>();  
        for(OpportunityLineItem ol : stdLineItemList)
        {
            stdOpIds.add(ol.OpportunityId);
        }
        List<Opportunity__c> custOpList = [select id,Standard_Opportunity__c from Opportunity__C where Standard_Opportunity__c IN :stdOpIds];
        Map<Id , Opportunity__c> proIdCustOpMap = new Map<Id, Opportunity__C>();
        for(Opportunity__c co : custOpList)
        {
            proIdCustOpMap.put(co.Standard_Opportunity__c ,co);
        }
        
        for(OpportunityLineItem item:stdLineItemList)
        {
            
            if(proIdCustOpMap.containsKey(item.opportunityId))
            {
             OpportunityLineItem__c clonedOpp = new OpportunityLineItem__c();
            clonedOpp.Opportunity__c = proIdCustOpMap.get(item.opportunityId).id;
            clonedOpp.Standard_Opportunity_Product__c =item.id;
            for(String fieldApiName: stdtoCloneFieldMap.keySet())
            {
                clonedOpp.put(stdtoCloneFieldMap.get(fieldApiName),item.get(fieldApiName));
            }
            clonedLineItemsToListToInsert.add(clonedOpp);
            }
        }
        System.debug('cOpportunities to Insert'+clonedLineItemsToListToInsert);
        Database.SaveResult[] srList= Database.Insert(clonedLineItemsToListToInsert,false);   
        System.debug('Result-->'+srList);
    }
    
    
        
    public static void callSyncTask(List<Opportunity__c> oplist)
    {
        Set<id> setOpId = new set<id>();
        for(Opportunity__c op : opList)
        {
            setOpId.add(op.Standard_Opportunity__c);
        }
        system.debug('opIds'+setOpId);
        syncTask2(setOpId);
    }
    
  /*  @future
    public static void syncTask(set<id> setOpId)
    {
        List<Task> taskList =[select id ,whatid,Subject,Status,OwnerId from Task where whatid IN: setOpId];
        Map<id , List<Task>> opIdTaskMap = new Map<id, List<Task>>();
        System.debug(taskList);
        for(Task ts : taskList)
        {
            if(!opIdTaskMap.containsKey(ts.whatid))
            {
                opIdTaskMap.put(ts.WhatId,new List<Task>{ts});
            }
            else 
            {
                List<Task> existingTasks = opIdTaskMap.get(ts.WhatId);
                existingTasks.add(ts);  
            }
        }
        System.debug('Task Map-->'+opIdTaskMap);
        List<Opportunity__c> custOpList = [select id,Standard_Opportunity__c from Opportunity__C where Standard_Opportunity__c IN: setOpId];
        List<Task> taksToUpdate = new List<Task>();
        for(Opportunity__c op: custOpList)
        {
         List<Task> tasks = opIdTaskMap.get(op.Standard_Opportunity__c);
         System.debug('Tasks-->'+tasks); 
            
        if(!tasks.isEmpty())
        {   
         for(Task t : tasks)
         {
             t.custom_opportunity__c = op.id;
             taksToUpdate.add(t);
         }  
        }  
        }

        if(!taksToUpdate.isEmpty())
        {
            Update taksToUpdate;
            System.debug('Task For Custom Opp are Updated..!');
        }
    }   */
        
 
    public static void syncTask2(set<id> setOpId)
    {
        List<Task> taskList =[select id ,whatid,Subject,Status,OwnerId from Task where whatid IN: setOpId];
        Map<id , List<Task>> opIdTaskMap = new Map<id, List<Task>>();
        System.debug(taskList);
        for(Task ts : taskList)
        {
            if(!opIdTaskMap.containsKey(ts.whatid))
            {
                opIdTaskMap.put(ts.WhatId,new List<Task>{ts});
            }
            else 
            {
                List<Task> existingTasks = opIdTaskMap.get(ts.WhatId);
                existingTasks.add(ts);  
            }
        }
        System.debug('Task Map-->'+opIdTaskMap);
        List<Opportunity__c> custOpList = [select id,Standard_Opportunity__c from Opportunity__C where Standard_Opportunity__c IN: setOpId];
        List<Task> taksToUpdate = new List<Task>();
        for(Opportunity__c op: custOpList)
        {
            if(opIdTaskMap.containsKey(op.Standard_Opportunity__c)){
         List<Task> tasks = opIdTaskMap.get(op.Standard_Opportunity__c);
         System.debug('Tasks-->'+tasks); 
            
        if(!tasks.isEmpty())
        {   
         for(Task t : tasks)
         {
             t.custom_opportunity__c = op.id;
             taksToUpdate.add(t);
         }  
        } 
            }
        }

        if(!taksToUpdate.isEmpty())
        {
            Update taksToUpdate;
            System.debug('Task For Custom Opp are Updated..!');
        }
    }  
    
    
    
    public static Map<String, String>  getAllCloneMetadata(String ObjectType)
    {
        Map<String, String> requiredMap = new  Map<String, String>();
        List<Clone_Opportunity_Fields__mdt> metadataList =  [SELECT Id, Object_Type__c, Standard_Obj_Field_API_Name__c, Custom_Obj_Field_API_Name__c, Label, MasterLabel, DeveloperName
                                                             FROM Clone_Opportunity_Fields__mdt where Object_Type__c= :ObjectType];
        
        if(!metadataList.isEmpty())
        {
            for(Clone_Opportunity_Fields__mdt coppmdt : metadataList)  {
                if(ObjectType=='Opportunity'||ObjectType=='OpportunityLineItem')
                {
                    requiredMap.put(coppmdt.Standard_Obj_Field_API_Name__c, coppmdt.Custom_Obj_Field_API_Name__c);
                }
                else{//CustomOpportunity
                    requiredMap.put(coppmdt.Custom_Obj_Field_API_Name__c, coppmdt.Standard_Obj_Field_API_Name__c);
                }
            }
        }
        return requiredMap;
    }
    
}
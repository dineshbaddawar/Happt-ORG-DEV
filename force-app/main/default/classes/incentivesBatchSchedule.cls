global class incentivesBatchSchedule implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        // Implement any logic to be scheduled
       
        // We now call the batch class to be scheduled
        IncentiveModuleBatch b = new IncentiveModuleBatch (3, 2022);
       
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,200);
    }
   
}
/*
    public static void incentive(){
        Integer monthToRun= 3, yearToRun= 2022;  

     
            
            string batchQuery = 'SELECT Id,(SELECT Id FROM Achieved_Targets__r WHERE CALENDAR_MONTH(Achieved_Month__c) = :monthToRun AND CALENDAR_YEAR(Achieved_Month__c) = :yearToRun LIMIT 1), User__r.Profile.Name FROM Goal__c WHERE Active__c = true' ;
            list<Goal__c> goalList = Database.query(batchQuery);
              try{
            System.debug('@@@@@@'+goalList);
            Map<Id,Goal__c> repToGoal = new Map<Id,Goal__c>();
            Map<Id,Achieved_Target__c> goalXUserthismonthTargetMap = new Map<Id,Achieved_Target__c>();
            Map<Id, Achieved_Target__c> targetMap = new Map<Id, Achieved_Target__c>();
            for(Goal__c goal: goalList){
                repToGoal.put(goal.User__c, goal);
                System.debug('>>>>>>>'+ goal.Achieved_Targets__r);
                if(!goal.Achieved_Targets__r.isEmpty()) {
                    goalXUserthismonthTargetMap.put(goal.User__c, goal.Achieved_Targets__r[0]);
                    targetMap.put(goal.Achieved_Targets__r[0].Id, goal.Achieved_Targets__r[0]);
                }
            }
            System.debug('--- goalXthismonthTargetMap'+goalXUserthismonthTargetMap);
            System.debug('--- targetMap'+targetMap);
            IncentiveModuleHelper helperInstance = new IncentiveModuleHelper();
            if(!repToGoal.isEmpty()) {
                Map<Id, list<Achievement__c>> targetXachievementMap;
                if(!targetMap.isEmpty())
                targetXachievementMap = helperInstance.getAchievementsByTarget(targetMap.keySet());
                Map<Id, Achieved_Target__c> targetToInsertMap = new Map<Id, Achieved_Target__c>();
                Map<Id, List<Achievement__c>> achievementsToInsertMap = new Map<Id, List<Achievement__c>>();
                
                List<Achieved_Target__c> targetToUpsert = new List<Achieved_Target__c>();
                List<Achievement__c> achievementsToUpsert = new List<Achievement__c>();
                List<Achievement__c> achievementsToInsert = new List<Achievement__c>();
                Set<Id> userIdSet = new Set<Id>();
                map<id,Decimal> leadIncentiveMap= new  map<id,Decimal>();
                Map<Id,Achievement__c> repXnewCustomerAchievement = new Map<Id,Achievement__c>();
                System.debug('--- targetXachievementMap'+targetXachievementMap);
                for(Id repId: repToGoal.keySet()) {
                    Achieved_Target__c thisMonthTarget;
                    
                    if(goalXUserthismonthTargetMap.containsKey(repId) && targetXachievementMap.containsKey(goalXUserthismonthTargetMap.get(repId).Id)) {
                        thisMonthTarget = goalXUserthismonthTargetMap.get(repId);
                        // Map<String,Achievement__c> targetXachievement = targetXachievementMap.get(thisMonthTarget.Id);
                        System.debug('This Month Target >>>>>'+ thisMonthTarget);
                        Goal__c goal = repToGoal.get(repId);
                        leadIncentiveMap = helperInstance.leadIncentive(goal.User__r.Profile.Name);
                        System.debug('leadIncentiveMap@@@@'+ leadIncentiveMap);
                        achievementsToUpsert = targetXachievementMap.get(thisMonthTarget.id);
                          System.debug('achievementsToUpsert@@@@'+ achievementsToUpsert);
                        targetToUpsert.add(thisMonthTarget);
                    }else{
                      
                        Date achievedMonth = Date.newInstance(yearToRun, monthToRun, 1); //Hardcoded for good.
                        //create one
                        thisMonthTarget = new Achieved_Target__c(Goal__c = repToGoal.get(repId).Id,  Achieved_Month__c = achievedMonth);
                        targetToInsertMap.put(repId, thisMonthTarget);
                        Goal__c goal = repToGoal.get(repId);
                        system.debug('goal is'+goal);
                        leadIncentiveMap = helperInstance.leadIncentive(goal.User__r.Profile.Name);
                        
                        List<Achievement__c> newList= new List<Achievement__c>();
                        Achievement__c ach = new Achievement__c();
                        
                        ach.Achieved_Amount__c = leadIncentiveMap.get(repId);
                        ach.User__c= repId;
                        system.debug('Achieved_Amount__c' +  ach.Achieved_Amount__c + ' @@@ '+leadIncentiveMap.get(repId));
                        newList.add(ach);
                        achievementsToInsertMap.put(repId, newList);
                        //achievementsToInsert.put(thisMonthTarget.id, new list<Achieved_Amount__c = leadIncentiveMap.get(repId));
                        
                        
                    }
                }
                Savepoint sp = Database.setSavepoint();
                try{
                    if(!targetToInsertMap.isEmpty()) {
                        System.debug('--- insertion');
                        insert targetToInsertMap.values();
                        System.debug('--- insertion@@@@@@' +  targetToInsertMap.values());
                    }
                    List<Achievement__c> achievementsToInsert1 = new List<Achievement__c>();
                    List<Achievement__c> newCustomerAchievementList = new List<Achievement__c>();
                    for(Id repId : achievementsToInsertMap.keySet()) {
                        if(targetToInsertMap.containsKey(repId)) {
                            for(Achievement__c ac : achievementsToInsertMap.get(repId)){
                                ac.Achieved_Target__c = targetToInsertMap.get(repId).Id;
                                achievementsToInsert1.add(ac);
                                
                                newCustomerAchievementList.add(ac);
                            }
                        }
                    }
                    insert achievementsToInsert1;
                    System.debug('--- insertion@@@@@@------' +  achievementsToInsert1);
                    if(!targetToUpsert.isEmpty()){
                        upsert targetToUpsert;
                        System.debug('--- insertion@@@@@@>>>>>>>' +  achievementsToInsert1);
                    }
                    
                }catch(exception e){
                    System.debug('Error '+e.getMessage() +' In '+ e.getLineNumber());
                }
            }
        }Catch(Exception e){
            System.debug('Error '+e.getMessage() +' In '+ e.getLineNumber());
            
        }
        
    }
}*/
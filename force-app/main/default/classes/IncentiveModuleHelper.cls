/**
* @description       : Intencive module helper class  to get allthe
* @author            : Dhanush Babu K N
* @group             : 
* @last modified on  : 03-06-2023
* @last modified by  : Dhanush Babu
*
*/

public  class IncentiveModuleHelper {
   
   static IncentiveModuleHelper instance = null;
     Integer month,year;     
    public static  IncentiveModuleHelper getInstance(Integer month, Integer year) {
        if(instance == null)
            instance = new IncentiveModuleHelper();
        instance.month = month;
        instance.year = year;
        return instance;
    }

    public static IncentiveModuleHelper getInstance() {
        if(instance == null)
            instance = new IncentiveModuleHelper();
        return instance;
    }
     
    public class LeadsWrapperClass{
        public Decimal totalnumberOfTouchPoints {get; set;}
        public Decimal totalExpectedAcv {get; set;}
    }
    public class OpportunityWrapperClass{
        public Decimal totalNumberOfDemos {get; set;}
        public Decimal totalAmount {get; set;}
        
    }
        
    Public   map<string,Incentive_Master__c> getIncentiveMasters(){
        map<string,Incentive_Master__c> MapofIncentiveMaster = new map<string,Incentive_Master__c>();
        list<Incentive_Master__c> IncentiveMasterList = [SELECT Id, Name, Target_Object__c, Incentive_computation_on__c, Evaluation_Field__c, Preferred_type__c, Profile__c FROM Incentive_Master__c];
        for(Incentive_Master__c incmaster: IncentiveMasterList){
            if(!MapofIncentiveMaster.containsKey(incmaster.Profile__c)){
                 MapofIncentiveMaster.put(incmaster.Profile__c, incmaster);
            }
        }
         System.debug('IncentiveMasterMap>>'+ MapofIncentiveMaster);
        return MapofIncentiveMaster;
    }
    
    //Method to create a map of userId and its All records Where sObject will be the object seleceted in the Incentive Master 
    public   Map<id,list<SObject>> getUsersAndRecords(String profileName){
      list<User> userList = [SELECT ID From User Where Profile.Name =:profileName];
        list<Goal__c> goalList = [SELECT id, Name, User__c, Active__c from Goal__c Where User__c IN: userList AND Active__c =true ];
        system.debug('Goal List is'+goalList);
        
        set<id> userIdset = new set<id>();
        for(Goal__c goal : goalList){
            userIdset.add(goal.User__c);     
        }

        map<string,Incentive_Master__c> incentiveMasterMap = getIncentiveMasters();
        Incentive_Master__c inc = incentiveMasterMap.get(profileName);
        string query; 
        System.debug('incesssss>>>>>'+inc);
        if(inc != null){
        if(inc.Incentive_computation_on__c != inc.Evaluation_Field__c){
          query = 'Select id, Name, CreatedById, '+inc.Incentive_computation_on__c+ ','+ inc.Evaluation_Field__c+ ' From ' +inc.Target_Object__c +' Where CreatedById IN:userIdset AND CALENDAR_MONTH(CreatedDate) =:month AND CALENDAR_YEAR(CreatedDate) =:year';
           System.debug('Query is'+ query);
             system.debug('month year'+ month);
            system.debug('month year'+ this.month);
        }
        else{
             query = 'Select id, Name, CreatedById, '+ inc.Evaluation_Field__c+ ' From ' +inc.Target_Object__c +' Where CreatedById IN:userIdset AND CALENDAR_MONTH(CreatedDate) = :month AND CALENDAR_YEAR(CreatedDate) = :year';
        }
        }
        Map<id,list<SObject>> userRecordsMaps = new  Map<id,list<SObject>>();
        Set<id> createdbyIdset = new set<id>();
        try{
         
        for(sObject sobj:  Database.query(query)){
           
            Id createdById = (Id) sobj.get('CreatedById');
            createdbyIdset.add(createdById);
           
            if (!userRecordsMaps.containsKey(createdById)) {
                userRecordsMaps.put(createdById, new List<SObject>());
            }
            userRecordsMaps.get(createdById).add(sobj);
        }
             System.debug('createdbyIdset'+ createdbyIdset);
        system.debug('userRecordsMaps>>>'+ userRecordsMaps.size());
         }catch(exception e){
                    System.debug('Error '+e.getMessage() +' In '+ e.getLineNumber());
                }
    
        return userRecordsMaps;    
    }
    
      public  Map<Id, list<Achievement__c>> getAchievementsByTarget(Set<Id> targetIdSet) {
        Map<Id, list<Achievement__c>> targetXachievementMap = new Map<Id,list<Achievement__c>>();
        for(Achievement__c at: [SELECT id, Achieved_Target__c,  Achieved_Amount__c, Incentive_amount__c  FROM Achievement__c WHERE Achieved_Target__c IN :targetIdSet]) {
           System.debug('Achivement>>'+ at );
            if(targetXachievementMap.containsKey(at.Achieved_Target__c)) {
                targetXachievementMap.get(at.Achieved_Target__c).add(at);
            }else {
                targetXachievementMap.put(at.Achieved_Target__c,new list<Achievement__c>{at});
            }
        }
         System.debug('targetXachievementMap>>'+ targetXachievementMap );
        return targetXachievementMap;
    }
    
    public   map<id,LeadsWrapperClass> leadCalculations(map<id,list<sObject>> userRecordsMap){
     
        map<id,LeadsWrapperClass> leadWrapperMap  = new map<id,LeadsWrapperClass>();
        for(id UserId : userRecordsMap.keySet()){
            Decimal totalTouchPoints = 0.00;
            Decimal totalExpetedAcv =0.00;
            list<sObject> sobList = userRecordsMap.get(UserId);
            for(sObject lead: sobList ){
                totalTouchPoints += (Decimal)lead.get('No_of_Touch_Points__c');
                if(lead != null && lead.get('Expected_ACV__c') != null){
                    totalExpetedAcv += (Decimal)lead.get('Expected_ACV__c');
                }  }
            LeadsWrapperClass wrapper =new LeadsWrapperClass();
            wrapper.totalnumberOfTouchPoints = totalTouchPoints;
            wrapper.totalExpectedAcv = totalExpetedAcv.setScale(2);
            leadWrapperMap.put(UserId,wrapper);
        }
        System.debug('leadWrapperMap>>>'+leadWrapperMap);
        return leadWrapperMap;
    }
    public map<id,decimal> leadAmount( String profileName){
             map<id,Decimal> userAmountMap = new  map<id,Decimal>();
      //  try{
        Map<Id,list<sObject>> userRecords = getUsersAndRecords(profileName);
        map<id,LeadsWrapperClass> mapOfUserRecords =  leadCalculations(userRecords);
        
        list<Incentive_Slabs__c> slabList = [Select Id, Name , Upper_Bound__c, Lower_Bound__c,/* Applicable_incentive_Type__c ,*/ Incentive_to_be_given__c From Incentive_Slabs__c];
        list<Achievement__c> achivementListToCreate = new list<Achievement__c>();
        
       
        for(id userid :mapOfUserRecords.keySet()){
          system.debug('userid'+ userid);
            LeadsWrapperClass wrapper = mapOfUserRecords.get(userid);
              userAmountMap.put(userid,wrapper.totalExpectedAcv.setScale(2));
        }
        return userAmountMap;
    }
   public   map<id,Decimal>  leadIncentive( String profileName){
        map<id,Decimal> userIncentiveAmountMap = new  map<id,Decimal>();
      //  try{
        Map<Id,list<sObject>> userRecords = getUsersAndRecords(profileName);
        map<id,LeadsWrapperClass> mapOfUserRecords =  leadCalculations(userRecords);
        
        list<Incentive_Slabs__c> slabList = [Select Id, Name , Upper_Bound__c, Lower_Bound__c, Applicable_incentive_Type__c , Incentive_to_be_given__c From Incentive_Slabs__c];
        list<Achievement__c> achivementListToCreate = new list<Achievement__c>();
        
       
        for(id userid :mapOfUserRecords.keySet()){
          system.debug('userid'+ userid);
            LeadsWrapperClass wrapper = mapOfUserRecords.get(userid);
            for(Incentive_Slabs__c  slabs :slabList ){
                if(wrapper.totalnumberOfTouchPoints <= slabs.Upper_Bound__c && wrapper.totalnumberOfTouchPoints >= slabs.Lower_Bound__c){
                    if(slabs.Applicable_incentive_Type__c == 'By %'){
                        Decimal percentToAmount = ((slabs.Incentive_to_be_given__c)/100)*wrapper.totalExpectedAcv;
                        userIncentiveAmountMap.put(userid,percentToAmount.setScale(2));
                    }    
                }
                else{
                     userIncentiveAmountMap.put(userid,0.00);
                }
            }     
        }
       // }catch(Exception e){
         //   System.debug('Error '+e.getMessage() +' In '+ e.getLineNumber());
        //}
        // insert achivementListToCreate;
        System.debug('Achivement to create'+userIncentiveAmountMap);
        return userIncentiveAmountMap;
      }
    
    public   map<id,OpportunityWrapperClass> opportunityCalculations(map<id,list<sObject>> userRecordsMap){
       
        map<id,OpportunityWrapperClass> opportunityWrapper  = new map<id,OpportunityWrapperClass>();
        
        for(id UserId : userRecordsMap.keySet()){
            Integer totalDemos = 0;
            Decimal totalAmount = 0.00;
            list<sObject> sobList = userRecordsMap.get(UserId);
            for(sObject sob: sobList ){
                if((boolean)sob.get('IsWon') == true){
                totalDemos += (Integer)sob.get('No_of_Demos__c');
                   if(sob != null && sob.get('Amount') != null){
                      totalAmount += (Decimal)sob.get('Amount');
                   }
                }
            }
            OpportunityWrapperClass wrapper =new OpportunityWrapperClass();
            wrapper.totalNumberOfDemos = totalDemos;
            wrapper.totalAmount = totalAmount.setScale(2);
            opportunityWrapper.put(UserId,wrapper);
        }
        System.debug('opportunityWrapper>>>'+opportunityWrapper);
            return opportunityWrapper;
      
    }
    
    public   map<id,Decimal>  opportunityIncentive( String profileName){
        Map<Id,list<sObject>> userRecords = getUsersAndRecords(profileName);
        map<id,OpportunityWrapperClass> mapOfUserRecords =  opportunityCalculations(userRecords);
        
        list<Incentive_Slabs__c> slabList = [Select Id, Name , Upper_Bound__c, Lower_Bound__c, Applicable_incentive_Type__c , Incentive_to_be_given__c From Incentive_Slabs__c];
        list<Achievement__c> achivementListToCreate = new list<Achievement__c>();
        
        map<id,Decimal> userOppIncentiveAmountMap = new  map<id,Decimal>();
        for(id userid :mapOfUserRecords.keySet()){
          
            OpportunityWrapperClass wrapper = mapOfUserRecords.get(userid);
            for(Incentive_Slabs__c  slabs :slabList ){
                if(wrapper.totalNumberOfDemos <= slabs.Upper_Bound__c && wrapper.totalNumberOfDemos >= slabs.Lower_Bound__c){
                    if(slabs.Applicable_incentive_Type__c == 'By %'){
                        Decimal percentToAmount = ((slabs.Incentive_to_be_given__c)/100)*wrapper.totalAmount;
                        userOppIncentiveAmountMap.put(userid,percentToAmount.setScale(2));
                    }    
                }
                else{
                     userOppIncentiveAmountMap.put(userid,0.00);
                }
            }     
        }
        // insert achivementListToCreate;
        System.debug('Achivement to create'+userOppIncentiveAmountMap);
        return userOppIncentiveAmountMap;
      }
    
    
   /*public static void updateGoalsWithIncentive(){
        map<id,Decimal> incentiveAmountMap = achivementCreator();
        Map<Id,list<sObject>> userRecords = getUsersAndRecords();
        map<id,LeadsWrapperClass> mapOfUserRecords =  leadCalculations(userRecords);
        list<Goal__c> goalList = new List<Goal__c>();
        list<Incentive_Master__c> incentiveMasterList = getIncentiveMasters();
        set<string> profileNames = new set<string>();
        
        for(Incentive_Master__c incMaster : incentiveMasterList ){
            profileNames.add(incMaster.Profile__c);
        }
        
        list<User> userList = [SELECT ID From User Where Profile.Name IN:profileNames];
        list<Goal__c> goalsList = [SELECT id, Name, User__c, Active__c from Goal__c Where User__c IN: userList AND Active__c =true ];
        for(Goal__c goal: goalsList){
            if(incentiveAmountMap.containsKey(goal.User__c) && mapOfUserRecords.containsKey(goal.User__c)){
                LeadsWrapperClass wrapp = mapOfUserRecords.get(goal.User__c);
                goal.Incentive_Amount__c = incentiveAmountMap.get(goal.User__c);
                goal.Lead_Amount__c = Wrapp.totalExpectedAcv;
                goalList.add(goal); 
            }
        }
        update goalList;
        
        System.debug('goalList is>>'+ goalList);
    }
    
   public static  map<id,OpportunityWrapperClass> opportunityCalculations(map<id,list<sObject>> userRecordsMap){
       
        map<id,OpportunityWrapperClass> opportunityWrapper  = new map<id,OpportunityWrapperClass>();
        
        for(id UserId : userRecordsMap.keySet()){
            Integer totalDemos = 0;
            Decimal totalAmount = 0.00;
            list<sObject> sobList = userRecordsMap.get(UserId);
            for(sObject sob: sobList ){
                if((boolean)sob.get('IsWon') == true){
                totalDemos += (Integer)sob.get('No_of_Demos__c');
                   if(sob != null && sob.get('Amount') != null){
                      totalAmount += (Decimal)sob.get('Amount');
                   }
                }
            }
            OpportunityWrapperClass wrapper =new OpportunityWrapperClass();
            wrapper.totalNumberOfDemos = totalDemos;
            wrapper.totalAmount = totalAmount.setScale(2);
            opportunityWrapper.put(UserId,wrapper);
        }
        System.debug('opportunityWrapper>>>'+opportunityWrapper);
            return opportunityWrapper;
      
        
    }
    
     public static void updateGoalsWithIncentiveforOpportunity(){
        map<id,Decimal> incentiveAmountMap = achivementCreator();
        Map<Id,list<sObject>> userRecords = getUsersAndRecords();
        map<id,OpportunityWrapperClass> mapOfOppUserRecords =  opportunityCalculations(userRecords);
        list<Goal__c> goalList = new List<Goal__c>();
        list<Incentive_Master__c> incentiveMasterList = getIncentiveMasters();
        set<string> profileNames = new set<string>();
        
        for(Incentive_Master__c incMaster : incentiveMasterList ){
            profileNames.add(incMaster.Profile__c);
        }
        
        list<User> userList = [SELECT ID From User Where Profile.Name IN:profileNames];
        list<Goal__c> goalsList = [SELECT id, Name, User__c, Active__c from Goal__c Where User__c IN: userList AND Active__c =true ];
        for(Goal__c goal: goalsList){
            if(incentiveAmountMap.containsKey(goal.User__c) && mapOfOppUserRecords.containsKey(goal.User__c)){
                OpportunityWrapperClass wrapp = mapOfOppUserRecords.get(goal.User__c);
                goal.Incentive_Amount__c = incentiveAmountMap.get(goal.User__c);
                goal.Opportunity_Amount__c = Wrapp.totalAmount;
                goalList.add(goal);
            }
        }
        update goalList;
        
        System.debug('goalList is>>'+ goalList);
    }*/
}
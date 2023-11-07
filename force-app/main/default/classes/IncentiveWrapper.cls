global class IncentiveWrapper {
   global class IncentivePlan{
        @AuraEnabled 
        public String profile_Nm{get;set;}
        @AuraEnabled 
        public boolean isEnabled{get;set;}
        @AuraEnabled 
        public Date startDate{get;set;}
        @AuraEnabled 
        public Date endDate{get;set;}
        @AuraEnabled 
        public List<IncentiveModel> models;
   }
   global Class IncentiveModel{
        @AuraEnabled 
        public String object_Nm{get;set;}
        @AuraEnabled 
        public Id incentivePlanId{get;set;}
        @AuraEnabled 
        public List<IncentiveModelCriteria> modelCriterias;
    }
   global Class IncentiveModelCriteria{
        @AuraEnabled 
        public List<String> evaluationField{get;set;}
         @AuraEnabled 
        public Id IncetiveModelId{get;set;}
        @AuraEnabled public List<IncentiveSlabs> incentiveSlabs;
    }
   global Class IncentiveSlabs{
      @AuraEnabled 
      public Integer upperBound{get;set;}
      @AuraEnabled 
      public Integer lowerBound{get;set;}
      @AuraEnabled 
      public Integer incentiveAmount{get;set;}
      @AuraEnabled
      public String applicableIncentiveType{get;set;}
      @AuraEnabled
      public Id IncentiveModelCriteria{get;set;}
   }
}
public class SubscriptionWithOTIOFControllerNew {
    
    public static Quote quoteDetails{get;set;}
    public static SERVICEPROVIDERDETAILS__c serviceProviderDetails{get;set;}
    public static dataWrapper dataWrapperObj{get;set;}
    public integer currentIndex {get;set;}
    Public Static Decimal TotalMonthlyTravelExpenseTotal {get;set;}
    Public Static Decimal TotalACV  {get;set;}

    public Static List<QuoteLineItem> getExpenseOTTSAASList {get;set;}
    Public Static Decimal getExpenseOTTSAASAmount  {get;set;}
    Public static Integer getExpenseOTTSAASListSize {get;set;}

    public Static List<QuoteLineItem> getTravelOTTSAASList {get;set;}
    Public Static Decimal getTravelOTTSAASAmount  {get;set;}
    Public static Integer getTravelOTTSAASListSize {get;set;}

    Public Static Decimal OTISubTotal  {get;set;}
    Public Static Decimal OTIDiscount  {get;set;}
    public static list<Terms_and_condition__c> termsList { get; set; }
    public Static TermsCondtion__mdt termsmetaData {get;set;}
    Public Static Contact getContactDetails {get;set;}
    
    Public SubscriptionWithOTIOFControllerNew(ApexPages.StandardController controller){
        Id recordId= ApexPages.currentPage().getParameters().get('id');
        currentIndex = 0;
        dataWrapperObj = new dataWrapper();
        getQuoteDetails(recordId);
        getTermandCondition(recordId);
        getAllTheSubsctiptionProducts(recordId);
    }
    
    Public Static void getQuoteDetails(Id recordId){
        system.debug('recordId::'+recordId);
        termsList = [ SELECT Id, Name,Comments__c, Quote__c, Late_Payment_Interest__c, YoY_PUPM_Report__c, YoY_PUPM_Report_100__c, YoY_AMC_10_20_of_ARR__c, Term_Attribute_Line_Item__r.Name,  Term_Section_Line_Item__r.Name FROM Terms_and_condition__c  WHERE Quote__c =:recordId  ]; 
        
        termsmetaData = [SELECT Term1__c,Term10__c,Term11__c,Term12__c,Term13__c,Term14__c,Term2__c,Term3__c,Term4__c,Term5__c,Term6__c,Term7__c,Term8__c,Term9__c,Term_15__c,Term_16__c FROM TermsCondtion__mdt LIMIT 1];
        
        dataWrapperObj.quoteDetails = [Select Id,Name,Subscription_Billing_Start_Date__c,Contact.Name,Expense_FInal_ARRs__c,Travel_Final_ARR__c,ExpirationDate,Contact.Email,Expense_Total_SAAS__c,Travel_Total_SAAS__c,Contact.Phone,Account.Name,Account.BillingStreet,Account.CIN__c,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry,Expense_ACV__c,Travel_Total_OTI__c,Expense_Total_OTI__c,Travel_OTI_Discount__c,Expense_OTI_Discount__c,AccountId from Quote where Id =: recordId];
        
        if(!String.isBlank( dataWrapperObj.quoteDetails.AccountId)){
            getContactDetails = [SELECT Id,Name,Email FROM Contact WHERE AccountId=:dataWrapperObj.quoteDetails.AccountId LIMIT 1];
        }
        if( dataWrapperObj.quoteDetails.Travel_Total_OTI__c !=null && dataWrapperObj.quoteDetails.Expense_Total_OTI__c !=null){
            OTISubTotal = dataWrapperObj.quoteDetails.Travel_Total_OTI__c + dataWrapperObj.quoteDetails.Expense_Total_OTI__c;
        }
        if(dataWrapperObj.quoteDetails.Expense_ACV__c !=null){
            TotalACV = dataWrapperObj.quoteDetails.Expense_ACV__c;
        }else{
            TotalACV = 0;
        }
        if(dataWrapperObj.quoteDetails.Travel_OTI_Discount__c !=null && dataWrapperObj.quoteDetails.Expense_OTI_Discount__c !=null){
            OTIDiscount = dataWrapperObj.quoteDetails.Travel_OTI_Discount__c + dataWrapperObj.quoteDetails.Expense_OTI_Discount__c;
        }
    }
    public static void ServiceProicderDetails(Id recordId){
        dataWrapperObj.serviceProviderDetails = [SELECT id,Name,StreetArea__c,CityArea__c,CityStatePincode__c,StreetRoad__c,StreetAddress__c,Charges__c FROM SERVICEPROVIDERDETAILS__c LIMIT 1];
    }
    
    public static void getTermandCondition(Id recordId){
        dataWrapperObj.termsDetilsList = [select id,Name,Term_Section_Line_Item__r.Name,Term_Attribute_Line_Item__r.Name,Term_Attribute_Description__c,Comments__c,Late_Payment_Interest__c,YoY_PUPM_Report__c,YoY_PUPM_Report_100__c,YoY_AMC_10_20_of_ARR__c from Terms_and_condition__c where Quote__c =:recordId ];
    }
    
    public static void getAllTheSubsctiptionProducts(Id recordId){
        try{
            
            List<QuoteLineItem> listOfQLI = [SELECT Id,Type__c,Product2.Name,Travel_Pricing_Type__c,SAAS_Price__c,Is_Travel_Product__c,SAAS_Quantity__c,TotalPrice from QuoteLineItem where QuoteId =: recordId ];
            
            dataWrapperObj.subscriptionExpenseQLIList 	= new List<QuoteLineItem>();
            dataWrapperObj.subscriptionTravelQLIList 	= new List<QuoteLineItem>();
            dataWrapperObj.implementationExpenseQLIList = new List<QuoteLineItem>();
            dataWrapperObj.implementationTravelQLIList 	= new List<QuoteLineItem>();
            
            getExpenseOTTSAASAmount = 0;
            getExpenseOTTSAASListSize = 0;
            getTravelOTTSAASAmount = 0;
            
            for(QuoteLineItem qli : listOfQLI){
                if(qli.Type__c == 'SAAS' || qli.Type__c == 'OTI + SAAS'){
                    if(!qli.Is_Travel_Product__c && !qli.Product2.Name.contains('Web Services Charges for Web based API Integration (if any)')){
                        dataWrapperObj.subscriptionExpenseQLIList.add(qli);
                    }else if(qli.Is_Travel_Product__c && !qli.Product2.Name.contains('Web Services Charges for Web based API Integration (if any)')){
                        dataWrapperObj.subscriptionTravelQLIList.add(qli);
                    }else if(qli.Product2.Name.contains('Web Services Charges for Web based API Integration (if any)')){
                        dataWrapperObj.expenceWebChargeQLIRecord = qli;
                    }
                }else if(qli.Type__c == 'OTI' || qli.Type__c == 'OTI + SAAS'){
                    if(!qli.Is_Travel_Product__c && !qli.Product2.Name.contains('Web Services Charges for Web based API Integration (if any)')){
                        dataWrapperObj.implementationExpenseQLIList.add(qli);
                    }else if(qli.Is_Travel_Product__c && !qli.Product2.Name.contains('Web Services Charges for Web based API Integration (if any)')){
                        dataWrapperObj.implementationTravelQLIList.add(qli);
                    }
                }
            }
            if(!dataWrapperObj.subscriptionExpenseQLIList.isEmpty()){
                dataWrapperObj.subscriptionExpenseQLIListSize = dataWrapperObj.subscriptionExpenseQLIList.size();
            }else if(!dataWrapperObj.subscriptionTravelQLIList.isEmpty()){
                dataWrapperObj.subscriptionTravelQLIListSize = dataWrapperObj.subscriptionTravelQLIList.Size();
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    Public Class dataWrapper{
        public Quote quoteDetails{get;set;}
        public SERVICEPROVIDERDETAILS__c serviceProviderDetails{get;set;}
        public List<Terms_and_condition__c> termsDetilsList{get;set;}
        
        public List<QuoteLineItem> subscriptionExpenseQLIList{get;set;}
        public List<QuoteLineItem> subscriptionTravelQLIList{get;set;}
        
        public List<QuoteLineItem> implementationTravelQLIList{get;set;}
        public List<QuoteLineItem> implementationExpenseQLIList{get;set;}
        
        public QuoteLineItem expenceWebChargeQLIRecord{get;set;}
        
        public List<QuoteLineItem> implementationQLIList{get;set;}
        
        Public Integer subscriptionExpenseQLIListSize{get;set;}
        Public Integer subscriptionTravelQLIListSize{get;set;}
        Public Integer implementationExpenseQLIListSize{get;set;}
        Public Integer implementationTravelQLIListSize{get;set;}
        
        
        Public Integer implementationQLIListSize{get;set;}
        Public Decimal subscriptionQLIAmount{get;set;}
        
        
        
    } 
    
}
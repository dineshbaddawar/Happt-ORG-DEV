public class SubscriptionWithOTIOFController {
    
    public static Quote quoteDetails{get;set;}
    public static SERVICEPROVIDERDETAILS__c serviceProviderDetails{get;set;}
    public static dataWrapper dataWrapperObj{get;set;}
    public integer currentIndex {get;set;}
    public Static TermsCondtion__mdt termsmetaData {get;set;}
    Public Static Contact getContactDetails {get;set;}
    Public static String WaterMarkisTrue {get;set;}
    Public static string currencySymbol{get;set;}
    
    
    Public SubscriptionWithOTIOFController(ApexPages.StandardController controller){
        Id recordId= ApexPages.currentPage().getParameters().get('id');
        
        currentIndex = 0;
        dataWrapperObj = new dataWrapper();
        dataWrapperObj.addOnModules = false;
        getQuoteDetails(recordId);
        getTermandCondition(recordId);
        getAllTheSubsctiptionProducts(recordId);
        getTermsAndCondition(recordId);
        currencySymbol = '₹';
    }
    
    public static void quoteContact(Id recordId){
        getContactDetails = [SELECT Id,Name,Email FROM Contact WHERE AccountId=:dataWrapperObj.quoteDetails.AccountId LIMIT 1];
    }
    
    public static void getTermsAndCondition(Id recordId){
        termsmetaData = [SELECT Term1__c,Term10__c,Term11__c,Term12__c,Term13__c,Term14__c,Term2__c,Term3__c,Term4__c,Term5__c,Term6__c,Term7__c,Term8__c,Term9__c,Term_15__c,Term_16__c FROM TermsCondtion__mdt LIMIT 1];
    }
    
    Public Static void getQuoteDetails(Id recordId){
        system.debug('recordId::'+recordId); 
        
        dataWrapperObj.quoteDetails = [Select Id,Name,Status,Contact.Name,Notes__c,SAAS_Start_Date__c,Change_Request__c,Expense_Total_OTI__c,AccountId,Travel_Total_OTI__c,Travel_Minimum_Commitment__c,Travel_SAAS_ARR__c,Expense_FInal_ARRs__c,OTI_Total_Amount__c,OTI_Sub_Total__c,Overall_ARR_Discount__c,Overall_OTI_Discount__c,Expense_Minimum_Commitment__c,Travel_Total_SAAS__c,ExpirationDate,Contact.Email,Expense_Total_SAAS__c,Contact.Phone,Account.Name,Account.BillingStreet,Account.CIN__c,Account.BillingCity,Account.BillingState,Account.BillingPostalCode,Account.BillingCountry from Quote where Id =: recordId];
        if(dataWrapperObj.quoteDetails.Status == 'Submitted for Approval'){
            WaterMarkisTrue = System.Label.WaterMarkDraft;
        }else{
            WaterMarkisTrue = System.Label.WatermarkBlankWhite;
        }
        system.debug('dataWrapperObj.quoteDetails::'+dataWrapperObj.quoteDetails);
        dataWrapperObj.ExpenseMonthlyAmount = 0;
        if(dataWrapperObj.quoteDetails.Expense_Total_SAAS__c !=null){
            dataWrapperObj.ExpenseMonthlyAmount = dataWrapperObj.quoteDetails.Expense_Total_SAAS__c;            
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
            List<QuoteLineItem> listOfQLI = [SELECT Id,Type__c,Product2.Name,Sub_Type__c,Nested_Parent_Product__c,Nested_Parent_Product__r.Product2.Name,Quantity,Travel_Pricing_Type__c,SAAS_Price__c,Is_Travel_Product__c,SAAS_Quantity__c from QuoteLineItem where QuoteId =: recordId ];
            dataWrapperObj.subscriptionExpenseQLIList = new List<QuoteLineItem>();
            dataWrapperObj.subscriptionTravelQLIList = new List<QuoteLineItem>();
            Set<Id> nestedBundleSet = new Set<Id>();
            dataWrapperObj.implementationExpenseQLI = new List<QuoteLineItem>();
            dataWrapperObj.implementationTravelQLI = new List<QuoteLineItem>();
            dataWrapperObj.subscriptionTravelCancelation = new List<QuoteLineItem>();
            dataWrapperObj.expenceWebChargeQLIRecord = new QuoteLineItem();
            dataWrapperObj.subscriptionQLIAmount = 0;
            for(QuoteLineItem qli : listOfQLI){
                if(qli.Type__c == 'SAAS' || qli.Type__c == 'OTI + SAAS'){
                    
                    if(!qli.Is_Travel_Product__c){
                        if((qli.Nested_Parent_Product__c != null && qli.Nested_Parent_Product__r.Product2.Name != 'Modules in Standard') || (qli.Nested_Parent_Product__c == null && qli.Product2.Name != 'Expense Bundle' && qli.Product2.Name != 'Modules in Standard')){
                            dataWrapperObj.addOnModules = true;
                        }
                        
                    }
                    
                    if(!qli.Is_Travel_Product__c && !qli.Product2.Name.contains('Web Services Charges for Web based API Integration (if any)')){
                        dataWrapperObj.subscriptionExpenseQLIList.add(qli);
                        system.debug(dataWrapperObj.subscriptionExpenseQLIList.Size());
                    }
                    else if(qli.Is_Travel_Product__c && !qli.Product2.Name.contains('Web Services Charges for Web based API Integration (if any)') &&
                             !qli.Product2.Name.contains('*Cancellations Flights -Domestic/International (Online)') && 
                             !qli.Product2.Name.contains('*Cancellations Hotels -Domestic/International (Online)')){
                                 dataWrapperObj.subscriptionTravelQLIList.add(qli);
                             }
                    else if(qli.Product2.Name.contains('*Cancellations Flights -Domestic/International (Online)') || qli.Product2.Name.contains('*Cancellations Hotels -Domestic/International (Online)')){
                                 dataWrapperObj.subscriptionTravelCancelation.add(qli);
                             }
                    else if(qli.Product2.Name.contains('Web Services Charges for Web based API Integration (if any)')){
                                 dataWrapperObj.webServiceChargeQLI = qli;
                                 dataWrapperObj.webCharges = qli.Quantity * qli.SAAS_Price__c;
                                 dataWrapperObj.woWebChargePricing = dataWrapperObj.ExpenseMonthlyAmount - dataWrapperObj.webCharges;
                                 
                             }
                    
                    
                    
                }
                if(qli.Type__c == 'OTI' || qli.Type__c == 'OTI + SAAS'){
                    if(!qli.Is_Travel_Product__c){
                        dataWrapperObj.implementationExpenseQLI.add(qli);
                    }else if(qli.Is_Travel_Product__c){
                        dataWrapperObj.implementationTravelQLI.add(qli);
                    }
                }
            }
            if(dataWrapperObj.subscriptionTravelCancelation.size()>0){
                Decimal tempAmount = 0;
                for(QuoteLineItem qli : dataWrapperObj.subscriptionTravelCancelation){
                    tempAmount = tempAmount + (qli.quantity * qli.SAAS_Price__c);
                }
                
                if(tempAmount > 0){
                    dataWrapperObj.travelPriceWithoutCancelation = dataWrapperObj.quoteDetails.Travel_Total_SAAS__c - tempAmount;
                }else{
                    dataWrapperObj.travelPriceWithoutCancelation = dataWrapperObj.quoteDetails.Travel_Total_SAAS__c;
                }
            }
            
            
            
           /* system.debug('nestedBundleSet::'+nestedBundleSet);
            if(!nestedBundleSet.isEmpty() && nestedBundleSet.size() > 1){
                dataWrapperObj.addOnModules = true;
            }*/
            if(dataWrapperObj.woWebChargePricing == null){
                dataWrapperObj.woWebChargePricing = dataWrapperObj.ExpenseMonthlyAmount;
            }
            
            if(!dataWrapperObj.subscriptionExpenseQLIList.isEmpty()){
                dataWrapperObj.subscriptionExpenseQLIListSize = dataWrapperObj.subscriptionExpenseQLIList.Size();
            }
            if(!dataWrapperObj.subscriptionTravelQLIList.isEmpty()){
                dataWrapperObj.subscriptionTravelQLIListSize = dataWrapperObj.subscriptionTravelQLIList.Size();
            }
            if(!dataWrapperObj.implementationExpenseQLI.isEmpty()){
                dataWrapperObj.implementationExpenseQLISize = dataWrapperObj.implementationExpenseQLI.size();
            }if(!dataWrapperObj.implementationTravelQLI.isEmpty()){
                dataWrapperObj.implementationTravelQLISize = dataWrapperObj.implementationTravelQLI.Size();
            }
            dataWrapperObj.totalMonthlypricing = dataWrapperObj.quoteDetails.Travel_Total_SAAS__c + dataWrapperObj.ExpenseMonthlyAmount;
            dataWrapperObj.subscriptionACV = dataWrapperObj.quoteDetails.Expense_FInal_ARRs__c + dataWrapperObj.quoteDetails.Travel_SAAS_ARR__c;
            
            
            if(dataWrapperObj.subscriptionACV == null)
                dataWrapperObj.subscriptionACV = 0;
            
            dataWrapperObj.quoteACV = dataWrapperObj.quoteDetails.OTI_Total_Amount__c + dataWrapperObj.subscriptionACV;
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    Public Class dataWrapper{
        public boolean addOnModules{get;set;}
        public Quote quoteDetails{get;set;}
        public SERVICEPROVIDERDETAILS__c serviceProviderDetails{get;set;}
        public List<Terms_and_condition__c> termsDetilsList{get;set;}
        public decimal travelPriceWithoutCancelation{get;set;}
        public List<QuoteLineItem> subscriptionExpenseQLIList{get;set;}
        public List<QuoteLineItem> subscriptionTravelQLIList{get;set;}
        Public List<QuoteLineItem> subscriptionTravelCancelation{get;set;}
        Public List<QuoteLineItem> implementationExpenseQLI{get;set;}
        Public List<QuoteLineItem> implementationTravelQLI{get;set;}
        Public QuoteLineItem 	   webServiceChargeQLI{get;set;}
        
        Public Integer subscriptionExpenseQLIListSize{get;set;}
        Public Integer subscriptionTravelQLIListSize{get;set;}
        Public Integer implementationExpenseQLISize{get;set;}
        Public Integer implementationTravelQLISize{get;set;}
        
        public Decimal webCharges{get;set;}
        Public Decimal ExpenseMonthlyAmount{get;set;}
        Public Decimal woWebChargePricing{get;set;}
        Public Decimal totalMonthlypricing{get;set;}
        Public Decimal subscriptionACV{get;Set;}
        
        
        Public Decimal subscriptionExpenseQLIAmount{get;set;}
        Public Decimal subscriptionTravelQLIAmount{get;set;}
        Public Decimal implementationExpenseQLIAmount{get;set;}
        Public Decimal implementationTravelQLIAmount{get;set;}
        Public Decimal quoteACV{get;set;}
        
        Public Decimal subscriptionQLIAmount{get;set;}
        public List<QuoteLineItem> travelQLIList {get;set;}
        public List<QuoteLineItem> expenceQLIList {get;set;}
        
        public QuoteLineItem expenceWebChargeQLIRecord {get;set;}
    } 
    
}
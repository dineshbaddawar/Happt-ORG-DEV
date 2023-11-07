/**
 * @author [Dinesh B]
 * @email dinesh.b@utilitarianLab.com
 * @create date 2023-04-04 11:33:13
 * @modify date 2023-04-04 11:33:13
 * @desc [description]
 */

public class HappyOrderFormVFController {
    
    public Static SERVICEPROVIDERDETAILS__c serviceData {get;set;}
    public Static HappyCard__c happcardData {get;set;}
    public Static TermsCondtion__mdt termsmetaData {get;set;}
    public Static Quote getQuotedata {get;set;}
    Public Static Account getAccountDetails {get;set;}
    Public Static Contact getContactDetails {get;set;}
    Public Static List<QuoteLineItem> getQuoteLineitemList {get;set;}
    public Static Boolean IsExpenseTrue {get;set;}
    public Static Boolean IsTravelTrue {get;set;}
    public Static Decimal SubtotalTravel {get;set;}
    public Static Decimal SubTotalExpense {get;set;}
    Public Static String TotalExpTra  {get;set;}
    
    public HappyOrderFormVFController(ApexPages.StandardController controller) {
       
        try{
            serviceData = [SELECT id,Name,StreetArea__c,CityArea__c,CityStatePincode__c,StreetRoad__c,StreetAddress__c,Charges__c FROM SERVICEPROVIDERDETAILS__c LIMIT 1];
            happcardData = [SELECT Id,Welcome__c,Wallet_to_Bank_transfer_charges__c,Operational__c,Happay_Fee__c,ATM_Withdrawal_Fee__c,ATM_Pin_Reissuance_Fee__c,ATM_Balance_Inquiry__c,Year_1__c,Year2__c,Year3__c FROM HappyCard__c LIMIT 1];
            termsmetaData = [SELECT Term1__c,Term10__c,Term11__c,Term12__c,Term13__c,Term14__c,Term2__c,Term3__c,Term4__c,Term5__c,Term6__c,Term7__c,Term8__c,Term9__c FROM TermsCondtion__mdt LIMIT 1];
            string recordId= ApexPages.currentPage().getParameters().get('id');
            if(!String.isBlank(recordId)){
                getQuotedata = [SELECT Id,Name,AccountId,Travel_Total_OTI__c,Travel_ARR_Discount__c,Expense_ARR_Discount__c,Expense_OTI_Discount__c,Travel_OTI_Discounted__c,Expense_ARR_Discounted__c,Travel_OTI_Discount__c,Travel_ARR_Discounted__c,Travel_Total_SAAS__c,Expense_Total_OTI__c,Expense_OTI_Discounted__c,Expense_Total_SAAS__c,QuoteNumber,ExpirationDate,OpportunityId,Description,Subscription_Billing_Start_Date__c,Advance_Billing_Cycle__c,Payment_Due_Date__c,Delayed_Payment_Interest__c,Subscription_Term__c,Yearly_Price_Escalation__c FROM Quote WHERE Id=:recordId];
                if(getQuotedata.Travel_Total_OTI__c !=null || getQuotedata.Travel_Total_OTI__c != 0){
                    IsTravelTrue = true;
                    System.debug('IsTravelTrue ===> '+IsTravelTrue);
                    if(getQuotedata.Travel_ARR_Discounted__c !=null && getQuotedata.Expense_ARR_Discounted__c !=null){
                        SubtotalTravel = getQuotedata.Travel_ARR_Discounted__c + getQuotedata.Expense_ARR_Discounted__c;  
                        System.debug('SubtotalTravel ==> '+SubtotalTravel);
                    }
                   
                }else{
                    IsTravelTrue = false;
                   
                }
                if(getQuotedata.Expense_Total_OTI__c !=null || getQuotedata.Expense_Total_OTI__c != 0){
                    IsExpenseTrue = true;
                    System.debug('IsExpenseTrue ==> '+IsExpenseTrue);
                    if(getQuotedata.Travel_OTI_Discounted__c !=null && getQuotedata.Expense_OTI_Discounted__c !=null){
                        SubTotalExpense = getQuotedata.Travel_OTI_Discounted__c + getQuotedata.Expense_OTI_Discounted__c;
                        System.debug('SubTotalExpense ==> '+SubTotalExpense);
                    }
                    
                }else{
                    IsExpenseTrue = false;
                }
                System.debug('getQuotedata ====> '+getQuotedata);
                if(SubtotalTravel !=null && SubTotalExpense !=null){
                    TotalExpTra = String.valueOf(SubtotalTravel + SubTotalExpense);
                }
                getQuoteLineitemList = [SELECT Id,Product2Id,UnitPrice,Product2.Name,Travel_Offering_Type__c,Account_Type__c,Travel_Pricing_Type__c,Type__c,Quantity,SAAS_Price__c,OTI_Price__c FROM QuoteLineItem WHERE QuoteId =:recordId ];
                System.debug('getQuoteLineitemList Size ====> '+getQuoteLineitemList.size());
                System.debug('getQuoteLineitemList Recprd ====> '+getQuoteLineitemList);
                if(!String.isBlank(getQuotedata.AccountId)){
                    getAccountDetails = [SELECT Id,Name,CIN__c,BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry FROM Account WHERE Id=:getQuotedata.AccountId];
                    System.debug('getAccountDetails ====> '+getAccountDetails);
                    if(!String.isBlank(getAccountDetails.Id)){
                        getContactDetails = [SELECT Id,Name,Email FROM Contact WHERE AccountId=:getAccountDetails.Id LIMIT 1];
                        System.debug('getContactDetails ==== >'+getContactDetails);
                    }
                }
            }
        }catch(Exception e){
                System.debug('The Error '+e.getMessage() + ' &&& Erron Line' +e.getLineNumber());
            }
    }

    @AuraEnabled
    public static string insertQuoteAttachmentPDF(String recordId){
        try {
            String insertId ;
            if(!String.isBlank(recordId)){
                List<Attachment> attachList = new List<Attachment>();
                Quote quote = [SELECT Id,Name FROM Quote WHERE Id=:recordId];
                if(!String.isBlank(quote.id)){
                    PageReference pdfPage = Page.HappyOrderFormVF;   
                    pdfPage.getParameters().put('id',recordId);
                    blob pdfBody;
                    pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('Fake content'));
                    Attachment attach = new Attachment(); 
                    attach.Body = pdfBody;
                    attach.Name = quote.Name+'_'+System.now()+'_.Pdf';
                    attach.IsPrivate = false;
                    attach.ParentId = quote.Id;
                    attach.ContentType = 'application/pdf';
                    attachList.add(attach);
                }
                if(!attachList.isEmpty()){
                    insert attachList;
                    System.debug('Inserted Attachment ID ===>'+attachList[0].Id);
                    insertId = attachList[0].Id;
                }
            }
            System.debug('Inserted ID ===>'+insertId);
            return insertId;
        } catch (Exception e) {
           System.debug('Error Message ==> '+e.getMessage() + ' && Error Line ==>'+e.getLineNumber());
           return 'ERROR';
        }
        
    }
}
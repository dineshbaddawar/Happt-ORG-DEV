/**
* @author [Dinesh B]
* @email dinesh.b@utilitarianLab.com
* @create date 2023-11-20 12:44:48
* @modify date 2023-11-20 12:44:48
* @desc [description]
*/

public with sharing class GenerateOrderFromLWCHelper {
    
    @AuraEnabled
    public static string generateSelectedOrderForm(String orderformName,string recordId){
        try{
            List<Attachment> attachList = new List<Attachment>();
            if(recordId !=null){
                blob pdfBody;
                string filename;
                Quote quote = [SELECT Id,Name FROM Quote WHERE Id=:recordId];
                if(!String.isBlank(quote.id) &&  orderformName != null){
                    if(orderformName == 'OF With OTI And Subscription'){ 
                        PageReference pdfPage = Page.SubscriptionWithOTIOF;   
                        pdfPage.getParameters().put('id',recordId);
                        pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('For Test Class content'));
                        filename = 'SubscriptionWithOTIOF';
                    }
                    if(orderformName == 'OF Only With Subscription'){
                        PageReference pdfPage = Page.OrderFormSubsOnly;   
                        pdfPage.getParameters().put('id',recordId);
                        pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('For Test Class Fake content'));
                        filename = 'OrderFormForSubsOnly';
                    }
                    if(orderformName == 'OF With Subscription and Card Details'){ 
                        PageReference pdfPage = Page.OrderFormSubsWithCard;   
                        pdfPage.getParameters().put('id',recordId);
                        pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('For Test Class Fake content'));
                        filename = 'OrderFormSubsOnlyWithCard';
                    }
                    if(orderformName == 'OF With OTI, Subscription and Card details'){
                        PageReference pdfPage = Page.SubscriptionOTICardOF;   
                        pdfPage.getParameters().put('id',recordId);
                        pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('For Test Class Fake content'));
                        filename = 'OrderFormForCardDeal';
                    }
                    Attachment attach = new Attachment(); 
                    attach.Body = pdfBody;
                    attach.Name =  filename+'_'+System.now()+'_.Pdf';
                    attach.IsPrivate = false;
                    attach.ParentId = quote.Id;
                    attach.ContentType = 'application/pdf';
                    attachList.add(attach);
                }
                if(!attachList.isEmpty()){
                    insert attachList;
                    return 'SUCCESS';
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    
    @AuraEnabled
    public static Quote getQuoteDetails(String recordId){
        try{
            if(recordId !=null){
                return [SELECT Id, Name, ContactId, Contact.Name, Contact.Email,Contact_Email__c,SAAS_Start_Date__c,Change_Request__c FROM Quote where Id =:recordId];
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
}
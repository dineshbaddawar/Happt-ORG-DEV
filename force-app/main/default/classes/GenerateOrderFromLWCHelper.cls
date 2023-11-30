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

                if(orderformName == 'OF With Card Deals'){
                    PageReference pdfPage = Page.OrderForm_OfWithCardDeals;   
                    pdfPage.getParameters().put('id',recordId);
                    pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('For Test Class content'));
                    filename = 'With__Card__Deal';
                }
                if(orderformName == 'Only Subscription With Cards'){
                    PageReference pdfPage = Page.OrderForm_OnlySubscriptionWithCards;   
                    pdfPage.getParameters().put('id',recordId);
                    pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('For Test Class Fake content'));
                    filename = 'Only_Subscription_With_Cards';
                }
                if(orderformName == 'Subscription & Implementation OF'){
                    PageReference pdfPage = Page.OrderSubscription_Implementation_OF;   
                    pdfPage.getParameters().put('id',recordId);
                    pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('For Test Class Fake content'));
                    filename = 'Subscription_Implementation_OF';
                }
                if(orderformName == 'Only Subscription OF'){
                    PageReference pdfPage = Page.Order_Only_Subscription_OF;   
                    pdfPage.getParameters().put('id',recordId);
                    pdfBody = (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('For Test Class Fake content'));
                    filename = 'Only_Subscription_Of';
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
}
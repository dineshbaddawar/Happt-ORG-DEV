/**
* @author [Dinesh B]
* @email dinesh.b@utilitarianLab.com
* @create date 2023-12-04 11:48:38
* @modify date 2023-12-04 11:48:38
* @desc [description]
*/

public class SendOrderEmailAttachementHelper {
    
    // Method for Sending Order Form As Attachment using Future Method
    public static string SendOrderFormWithAttachmentEmail(Map<Id,Quote> newQuoteMap,Map<Id,Quote> oldQuoteMap){
        try{
            Set<Id> QuoteIdSet = new Set<Id>();
            for(Quote quoteRec : newQuoteMap.values()){
                if(quoteRec.Status !=null && quoteRec.Status == 'Presented' && quoteRec.Status !=oldQuoteMap.get(quoteRec.id).Status){
                    QuoteIdSet.add(quoteRec.id);
                }
            }
            if(QuoteIdSet.size()>0){
                SendQuoteEmailAttachment(QuoteIdSet);
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
    // ============================================================================================================================
    // Method for Sending Email Attachment from Above Class
    @future(callout=true)
    public static void SendQuoteEmailAttachment(Set<Id> quoteRecIdSet){
        try{
            if(quoteRecIdSet.size()>0){
                List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                EmailTemplate temp = [SELECT Id,Subject,Body,HTMLValue FROM EmailTemplate WHERE Name ='Send Order Form Mail'];
                Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                String htmlBody = temp.HTMLValue;
                String subject = temp.Subject;
                String plainTextBody = temp.body;
                 String emailAddressesString = System.Label.SendApproaveEmailPresentedStage	;
                 List<String> emailAddressesList = emailAddressesString.split(',');      
                
               // String emailtoSend = 'sakshi.baranwal@happay.com';
                for(Quote quoteRec : [SELECT Id,Name FROM Quote WHERE Id IN:quoteRecIdSet]){
                    PageReference pdfPage = page.HappyOrderFormVF;
                    pdfPage.getParameters().put('id',quoteRec.id);
                    Blob Blobbody;
                    Blobbody =  (!Test.isRunningTest() ? pdfPage.getContent() : Blob.valueOf('For Test Class'));
                    attach.setContentType('application/pdf');
                    attach.setInline(false);
                    attach.Body = Blobbody;
                    attach.setFileName('Order Form_'+String.valueOf(System.now())+'_.Pdf');
                    Messaging.SingleEmailMessage mailTemp = new Messaging.SingleEmailMessage();
                    mailTemp.setHtmlBody(htmlBody);
                    mailTemp.setSubject(temp.subject);
                    mailTemp.setPlainTextBody(plainTextBody);
                    mailTemp.setToAddresses(emailAddressesList);
                        mailTemp.setFileAttachments(new Messaging.EmailFileAttachment[] { attach });
                    mailList.add(mailTemp);
                }
                if(!mailList.isEmpty()){
                    Messaging.sendEmail(mailList);
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
    }
    
    // ============================================================================================================================
    // Method to send Approved Email When Quote Status is Changed to Presented
    
    public static string sendOrderApprovedEmail(Map<Id,Quote> newQuoteMap,Map<Id,Quote> oldQuoteMap){
        try{
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            EmailTemplate temp = [SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body FROM EmailTemplate WHERE name = 'New Quote Approved Email'];
            String emailAddressesString = System.Label.SendApproaveEmailPresentedStage	;
            List<String> emailAddressesList = emailAddressesString.split(',');            
            Set<Id> QuoteIdSet = new Set<Id>();
            for(Quote quoteRec : newQuoteMap.values()){
                if(quoteRec.Status !=null && quoteRec.Status == 'Presented' && quoteRec.Status !=oldQuoteMap.get(quoteRec.id).Status){
                    QuoteIdSet.add(quoteRec.id);
                }
            }
            System.debug('QuoteIdSet New == >'+QuoteIdSet);
            if(QuoteIdSet.size()>0){
                for(Quote quoteRec : [SELECT Name,opportunity.name,owner.name,Travel_ARR_Discount__c,Travel_OTI_Discount__c,Expense_ARR_Discount__c,Expense_OTI_Discount__c,Approver_Authority_Level1__r.Name,Approver_Authority_Level2__r.Name,Approval_Authority_Level2B__r.Name FROM Quote WHERE ID IN:QuoteIdSet]){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(UserInfo.getUserId());
                    message.setSenderDisplayName('Happy Team');
                    message.setUseSignature(false);
                    message.setBccSender(false);
                    message.setSaveAsActivity(false);
                    message.setTemplateID(temp.Id);
                    message.setWhatId(quoteRec.Id);  
                    message.setToAddresses(emailAddressesList);
                    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results =  Messaging.sendEmail(messages);
                    if (results[0].success){
                        System.debug('The email was sent successfully.');
                    }else{
                        System.debug('Something went wrong !.');
                    }
                }
            }
        }catch(Exception e){
            System.debug('The Error ::'+e.getMessage() +' AND Error Line No :'+e.getLineNumber());
        }
        return null;
    }
    
}
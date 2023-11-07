@isTest
public class EmailToLeadHandlerTest {
    @isTest
    public static void inboundEmail()
    {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        email.subject = 'TestForContact';
        email.plainTextBody = 'Test';
        env.fromAddress = 'TestContact@gmail.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        EmailToLeadHandler emailService = new EmailToLeadHandler();
        emailService.handleInboundEmail(email,env);
    }
}
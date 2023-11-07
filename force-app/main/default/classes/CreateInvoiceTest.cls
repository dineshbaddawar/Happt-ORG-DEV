@isTest
public class CreateInvoiceTest {
	
    static testmethod void createInvoice() {
        Account ac = TestUtility.createAccount('Test Account');
        Opportunity op = TestUtility.createOpportunity(ac);
        
        contact con  = TestUtility.createContact(ac);
        system.debug('con-email'+con.Email);
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = con.Id;
        ocr.OpportunityId = op.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Other';
        insert ocr;
        
        op.StageName ='Stage 2 (Validated)';
        update op; 
        Quote q = TestUtility.createQuote(op, 'Draft');
        Quote createdQUote = [Select id, QuoteNumber from Quote where Id = :q.Id];
        String qNum = createdQUote.QuoteNumber;
        system.debug('qNum'+qNum);
        string today1 = system.today().format();
        //string dueDate = today.addDays(7);
        String jsonInput = '{"InvoiceList":[{"InvoiceNumber":"8212","Quote":"'+qNum+'","DueDate":"'+today1+'","InvoiceDate":"'+today1+'","startDate":"'+today1+'","endDate":"'+today1+'","InvoiceAmount":650,"bankingChannel":"temp","deltaRevenueARR":1500,"emailAddress":"a@b.com","implementationCharges":500,"invoiceAmoountForCardPurchase":150,"invoiceEmailId":"a@b.com","numberOfUsers":10,"paymentDetails":"temp","paymentMode":"temp","paymentRefInCaseOfSeparatePayment":"temp","revenueDetails":"temp","revenueRealization":"30/04/2021","salesManagerForThisCompany":"temp","salesManagerList":"temp","status":"Paid","submittedBy":"temp","totalAmount":1111,"upsellType":"temp","useCase":"temp","TotalPaidAmount":[{"name":"PAY-101","amount":222,"paymentNumber":251,"invoiceNumber":"temp","paymentType":"Credit","paymentMethod":"NEFT","paymentDescription":"temp","paymentDate":"30/04/2021"},{"name":"PAY-102","amount":333,"paymentNumber":252,"invoiceNumber":"temp","paymentType":"Credit","paymentMethod":"NEFT","paymentDescription":"temp","paymentDate":"30/04/2021"}]}]}';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/invoicecreation'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(jsonInput);
        RestContext.request = req;
        RestContext.response= res;

        
        CreateInvoice.createInvoiceMethod();
        
    }
}
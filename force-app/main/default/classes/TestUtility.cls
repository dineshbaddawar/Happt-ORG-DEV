/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 04-29-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   04-29-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class TestUtility {
    
    // SELECT Id, OpportunityId, Product2Id, PricebookEntryId, ProductCode, Name, Quantity, TotalPrice, UnitPrice, ListPrice FROM OpportunityLineItem where Opportunity.SyncedQuoteId = '0Q05D00000079JaSAI'
    
   public static void createSampleInvoiceForQuotation(String QuotationId)
    {
        //Invoice Create
        Quote q = [SELECT TotalPrice, Subtotal, Id,QuoteNumber, Name FROM Quote where Id=:QuotationId];
        System.debug('@Quote-->'+q);
        List<OpportunityLineItem> oppLineItem  = [SELECT Id, OpportunityId, Product2Id, PricebookEntryId, ProductCode, Name, Quantity,
                                                  TotalPrice, UnitPrice, ListPrice,Opportunity.AccountId FROM OpportunityLineItem where 
                                                  Opportunity.SyncedQuoteId =:QuotationId];
        System.debug('@oppLineItem-->'+oppLineItem);
        
        
        Invoice__c inv = new Invoice__c();
        inv.Invoice_Number__c = 'INV-456';
        inv.Invoice_Date__c = Date.parse('28/04/2021');
        inv.Due_Date__c = Date.parse('30/04/2021');
        inv.Account__c = oppLineItem[0].Opportunity.AccountId;
        inv.Quote__c = QuotationId;
        inv.Opportunity__c= oppLineItem[0].OpportunityId;
        
        insert inv;
        System.debug('@inv-->'+inv);  
        
        /*List<Invoice_Item__c> invoiceItemList = new List<Invoice_Item__c>();
for(OpportunityLineItem opli:oppLineItem){
Invoice_Item__c invItem = new Invoice_Item__c();

invItem.Invoice__c = inv.Id;
invItem.Product__c = opli.Product2Id;
invItem.Quantity__c = opli.Quantity;
//invItem.Unit_Price__c = opli.TotalPrice/opli.UnitPrice;
invItem.Unit_Price__c = opli.TotalPrice/opli.Quantity;

System.debug('@invItem-->'+invItem);  
invoiceItemList.add(invItem);
}
//Invoice Item

insert invoiceItemList;

//70 % Payment
Payment__c pay = new Payment__c();
pay.Invoice__c = inv.Id;
pay.Amount__c = (70*q.TotalPrice)/100;

System.debug('@pay-->'+pay);  
insert pay;
*/
    }
    
    public static OpportunityLineItem createLineItem(Opportunity opp)
    {
        //Create your product
        Product2 prod = new Product2(
            Name = 'Product X',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert prod;
        Id pricebookId = Test.getStandardPricebookId();
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
            Pricebook2Id = pricebookId,
            Product2Id = prod.Id,
            UnitPrice = 100.00,
            IsActive = true
        );
        insert pbEntry;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
            OpportunityId = opp.Id,
            Quantity = 5,
            PricebookEntryId = pbEntry.Id,
            TotalPrice =  5* pbEntry.UnitPrice
        );
        insert oli;
        return oli;
    }
    
    public static Account createAccount(String accName){
        Account acc = new Account();
        acc.Name = accName;
        acc.Phone = '15987466';
        acc.Auditor__c='NA';
        acc.HRMs__c='NA';
        acc.ERP_Accounting_Software__c='NA';
        acc.TMC__c ='NA';
        acc.CRM__c='NA';
        acc.Region__c ='West';
        insert acc;        
        return acc;
    }
    public static Contact createContact(Account ac){
        Contact c = new Contact();
        c.AccountId = ac.ID;
        c.FirstName = 'Test';
        c.LastName = 'Contact';
        c.email = 'test@test.com';
        c.Phone = '0985553269';
        c.MobilePhone ='9090909090';
        Insert c;
        return c;
    }
    /*public static Lead createLead(){
        Lead objLead = new Lead( FirstName = 'Test',
                                LastName = 'Sample',
                                Company = 'Testing Sample Co' ,
                                LeadSource ='Manual',
                                Status ='Qualified');  
        return objLead;
    } */
    public static Opportunity createOpportunity(Account ac){
        // Account ac = createAccount('TestAc');
        Opportunity o = new Opportunity();
        o.AccountId =ac.id;
        o.StageName = 'Stage 1 (Qualified)';
        o.Name = 'Test Opportunity';
        o.CloseDate =date.today();
        o.Email__c ='test.test@test.com';
        o.Mobile_Number__c ='9090909090';
        o.Phone_Number__c ='0202445566';
        Insert o;
        createTasksForOpp(o);
        return o;
    } 
    
    public static List<Task> createTasksForOpp(Opportunity op)
    {
       List<Task> tasks = new List<Task>{};
       for(Integer i = 0; i < 2; i++) 
       {
            Task t = new Task(Subject='Call'+i,Status='Completed',Priority='Normal',WhatId =op.Id);
            tasks.add(t);
       }
        insert tasks;
        return tasks;
    }
    /*public static Product2 createProduct2(){
        
        return null;
    }  
    public static Pricebook2 createPricebook2(){
        
        return null;
    }*/
    public static Quote createQuote(Opportunity op ,string status){
        Quote q = new Quote();
        q.Name = 'Test Quote';
        q.OpportunityId = op.id;
        q.Status = status;
        q.Subscription_Billing_Start_Date__c = system.Today().addDays(5);
        q.Delayed_Payment_Interest__c =2;
        q.Payment_Due_Date__c = 'Net 15';
        q.Advance_Billing_Cycle__c = 'Annual';
        q.Yearly_Price_Escalation__c = 3;
        q.Subscription_Term__c=5;
       
        Insert q;
        return q;
    } 
    /*public static Invoice__c createInvoice(){
        
        return null;
    }
    public static Payment__c createPayment(){
        
        return null;
    }
    public static Task createTask(){
        
        return null;
    }*/
    
    public static Opportunity__c createCustomOppo(Opportunity op)
    {
        Opportunity__c cop = new Opportunity__c();
        cop.Name ='Test cOpp';
        cOp.Standard_Opportunity__c = op.id;
        cop.Close_Date__c = op.CloseDate;
        cop.AccountId__c =op.AccountId;
        Insert cop;
        return cop;
    }
    
    public static  OpportunityLineItem__c createCustomOppLine(Opportunity__c custOp1 ,OpportunityLineItem oli )
    {
        OpportunityLineItem__c cOppLine = new OpportunityLineItem__c();
        cOppLine.Opportunity__c = custOp1.id;
        cOppLine.Standard_Opportunity_Product__c  = oli.id;
        cOppLine.Product__c = oli.Product2Id;
        cOppLine.Quantity__c = oli.Quantity;
        Insert cOppLine; 
        return cOppLine;
    }
    public static String utilityJSONMulitplier(Integer NumberofRecords, INteger StartingNumber)
    {
        String multipliedJSON  = '';
        Integer PaymentNumber = 0;
        String jSON = '{"InvoiceNumber":"[INVOICE__NUMBER]","Quote":"00000003","DueDate":"30/04/2021","InvoiceDate":"29/04/2021","InvoiceAmount":650,"bankingChannel":"temp","deltaRevenueARR":1500,"emailAddress":"a@b.com","implementationCharges":500,"invoiceAmoountForCardPurchase":150,"invoiceEmailId":"a@b.com","numberOfUsers":10,"paymentDetails":"temp","paymentMode":"temp","paymentRefInCaseOfSeparatePayment":"temp","revenueDetails":"temp","revenueRealization":"30/04/2021","salesManagerForThisCompany":"temp","salesManagerList":"temp","status":"Paid","submittedBy":"temp","totalAmount":1111,"upsellType":"temp","useCase":"temp","TotalPaidAmount":[[PAYMENT__STRING]]}';
        String PaymentString = '{"name":"PAY-101","amount":222,"paymentNumber":[PAYMENTNUMBER],"invoiceNumber":"[INVOICENUMBER]","paymentType":"Credit","paymentMethod":"NEFT","paymentDescription":"temp","paymentDate":"30/04/2021"}';
        String INVOICEString = '';
        for(Integer i=1;i<=NumberOfRecords;i++)
        {
            INVOICEString = json;
            INVOICEString = INVOICEString.replace('[INVOICE__NUMBER]', String.valueOf(StartingNumber+i));
            String PaymentStringToApend = '';
            for(Integer j=1;j<3;j++)
            {
                String TempPaymentString = PaymentString;
                TempPaymentString = TempPaymentString.replace('[PAYMENTNUMBER]', String.valueOf((StartingNumber+i)*10+j));
                TempPaymentString = TempPaymentString.replace('[INVOICENUMBER]', String.valueOf(StartingNumber+i));
                
                PaymentStringToApend = PaymentStringToApend + ','+TempPaymentString;
            }
            PaymentStringToApend =PaymentStringToApend.removeEnd(',');
            
            PaymentStringToApend =PaymentStringToApend.removeStart(',');
            INVOICEString = INVOICEString.replace('[PAYMENT__STRING]', PaymentStringToApend);
            multipliedJSON = multipliedJSON + ','+INVOICEString;
        }
        multipliedJSON =multipliedJSON.removeEnd(',');
        multipliedJSON =multipliedJSON.removeStart(',');
        System.debug(multipliedJSON);
        return multipliedJSON;
    }
}
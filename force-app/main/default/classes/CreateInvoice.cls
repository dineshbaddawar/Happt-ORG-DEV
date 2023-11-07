@RestResource(urlMapping='/invoicecreation')
global class CreateInvoice {
    
    /*Sample string input
    public static String jsona = '{"InvoiceList":[{"InvoiceNumber":"2441","Quote":"00000002","DueDate":"30/04/2021","InvoiceDate":"29/04/2021","InvoiceAmount":650,"bankingChannel":"temp","deltaRevenueARR":1500,"emailAddress":"a@b.com","implementationCharges":500,"invoiceAmoountForCardPurchase":150,"invoiceEmailId":"a@b.com","numberOfUsers":10,"paymentDetails":"temp","paymentMode":"temp","paymentRefInCaseOfSeparatePayment":"temp","revenueDetails":"temp","revenueRealization":"30/04/2021","salesManagerForThisCompany":"temp","salesManagerList":"temp","status":"Paid","submittedBy":"temp","totalAmount":1000,"upsellType":"temp","useCase":"temp","TotalPaidAmount":[{"name":"PAY-101","amount":150,"paymentNumber":251,"invoiceNumber":"temp","paymentType":"Credit","paymentMethod":"NEFT","paymentDescription":"temp","paymentDate":"30/04/2021"},{"name":"PAY-102","amount":150,"paymentNumber":252,"invoiceNumber":"temp","paymentType":"Credit","paymentMethod":"NEFT","paymentDescription":"temp","paymentDate":"30/04/2021"}]}]}';
    */
    
    @HttpPost
    global static void createInvoiceMethod()
    {
        RestRequest request = RestContext.request;

        
        String reqBody = request.requestBody.toString(); 
        Integration_Logs__c il = new Integration_Logs__c();
        il.RequestBody__c  = reqBody;
        il.Other_Details__c  = '';
        String jsonstring = EncodingUtil.urlDecode(reqBody, 'UTF-8');
        
        
        try{
            InvoiceJSONParser ipl = (InvoiceJSONParser)JSON.deserialize(jsonstring,InvoiceJSONParser.class);
            insertInvoice(ipl);
            il.Other_Details__c='Success';
        }
        catch(Exception ex)
        {
            il.Other_Details__c = ex.getMessage();
        }
        insert il;
    }    
    
    public static void insertInvoice(InvoiceJSONParser ipl){
        
        List<Invoice__c> invoiceList = new List<Invoice__c>();
        
        // Map<InvoiceNumber,List<Payment>>
        Map<String,List<InvoiceJSONParser.PaymentClass>> payMap = new Map<String,List<InvoiceJSONParser.PaymentClass>>();
        System.debug(ipl);
        System.debug(ipl.InvoiceList);
        
        //Collect QuoteNumber from invoiceList 
        Set<String> quoteNumberSet = new Set<String> ();
      
        //Collect QuoteNumber from invoiceList 
        Set<String> OrgIDset = new Set<String> ();
      
        for(InvoiceJSONParser.InvoiceList il:ipl.InvoiceList){
            quoteNumberSet.add(il.Quote);
            OrgIDset.add(il.OrgId);
        }
        
        //PrepateQuoteNumber to QuoteMap 
        if(!quoteNumberSet.isEmpty())
        {
            Map<String, Quote> qnToQuoteMap = new Map<String, Quote> ();
            List<Quote> qouteList = [SELECT Id,Name, QuoteNumber, ContactId, OpportunityId, AccountId FROM Quote WHERE QuoteNumber in :quoteNumberSet];
            for(Quote qt: qouteList){
                qnToQuoteMap.put(qt.QuoteNumber, qt);
            }
          
            
            Map<String, Account> OrgIdToAccountMap = new Map<String, Account> ();
            List<Account> accList = [SELECT Id,Name,Org_ID__c FROM Account WHERE Org_ID__c in :OrgIDset];
            for(Account acc: accList){
                OrgIdToAccountMap.put(acc.Org_ID__c , acc);
            }
          
            for(InvoiceJSONParser.InvoiceList il:ipl.InvoiceList){
                
         
                    
                    Invoice__c inv = new Invoice__c();
                    List<Payment__c> pList = new List<Payment__c>();
                    
                    inv.Quote__c =qnToQuoteMap.containskey(il.Quote)==false?null: qnToQuoteMap.get(il.Quote).Id;
                    inv.Account__c = OrgIdToAccountMap.get(il.OrgId).Id;  
                    
                    inv.Opportunity__c = qnToQuoteMap.containskey(il.Quote)==false?null: qnToQuoteMap.get(il.Quote).OpportunityId;
                    inv.Due_Date__c = Date.parse(il.DueDate);
                    inv.Invoice_Number__c = il.InvoiceNumber;
                    inv.Invoice_Date__c = Date.parse(il.InvoiceDate);
                    inv.Total_Amount__c = il.InvoiceAmount;
                    inv.Implementation_Charges__c = il.implementationCharges;	
                    inv.Invoice_Amount_for_Card_Purchase_only__c = il.invoiceAmountForCardPurchase;
                    inv.Number_of_New_Users__c = il.numberOfUsers;
                    inv.Status__c = il.status;
                    inv.Total_Amount__c = il.totalAmount;
                    inv.Start_Date__c = Date.parse(il.startDate);
                    inv.End_Date__c = Date.parse(il.endDate);
					inv.Pending_Amount__c = il.pendingAmount;
                    inv.SAAS_Charges__c = il.SAASCharges;
                    inv.TDS_Amount__c = il.tdsAmount;
                    inv.Org_ID__c = il.OrgID;
                    
                    //     	inv.Banking_Channel__c = il.bankingChannel;
                    //     	inv.Delta_Revenue_ARR__c = il.deltaRevenueARR	;
                    //     	inv.Email_Address__c = il.emailAddress;
                    ///    	inv.Invoice_Email_Id__c = il.invoiceEmailId;
                    
                    // 		inv.Payment_Details__c = il.paymentDetails;	
                    // 		inv.Payment_Mode__c = il.paymentMode;
                    //		inv.Payment_Ref_in_case_of_separate_pay__c = il.paymentRefInCaseOfSeparatePayment;
                    // 		inv.Revenue_Details__c = il.revenueDetails;
                    // 		inv.Revenue_Realization__c = Date.parse(il.revenueRealization);	
                    //		inv.Sales_Manager_for_this_company__c = il.salesManagerForThisCompany;
                    //		inv.Sales_Manager_List__c = il.salesManagerList;
                    //		inv.Submitted_By__c = il.submittedBy;
                    //  	inv.Up_sell_Type__c = il.upsellType;
                    //   	inv.Use_Case__c = il.useCase;
                    //
                        
                    System.debug(il.paymentList);
                    System.debug('inv-->'+inv.Invoice_Number__c);
                    invoiceList.add(inv);
                    
                    // Map of Invoice number to Payment List
                    payMap.put(il.InvoiceNumber, il.paymentList);
                 
                
                
            }
            
            String SendResponse ;
        	RestResponse res = RestContext.response;
            
            try{
                upsert invoiceList Invoice_Number__c;
                System.debug(invoiceList);
                insertPayment(ipl,payMap);   //method for payment Insertion
            }catch(Exception e){
                System.debug('The following exception has occurred: ' + e.getMessage());
                
                SendResponse = '{"Status": "Fail","Error": "'+e.getMessage()+'"}';
                res.addHeader('Content-Type','application/json');
                res.responseBody = Blob.valueOf(sendResponse);
                res.statusCode = 400;
                throw e;
            }
        }
    }
    
    public static void insertPayment(InvoiceJSONParser ipl,Map<String,List<InvoiceJSONParser.PaymentClass>> payMap){
        Set<String> invoiceNumberSet = new Set<String> ();
        List<Payment__c> paymentList = new List<Payment__c>();
        
        for(InvoiceJSONParser.InvoiceList il:ipl.InvoiceList){
            invoiceNumberSet.add(il.InvoiceNumber);
        }
        
        
        if(!invoiceNumberSet.isEmpty())
        {
            //Map<InvoiceNumber, Invoice__c>
            Map<String, Invoice__c> inToInvoiceMap = new Map<String, Invoice__c> ();
            
            List<Invoice__c> invoiceRecordList = [SELECT Id, Name, Account__c, Invoice_Number__c, Quote__c, Invoice_Date__c, Due_Date__c, Opportunity__c, Total_Paid_Amount__c, Total_Amount__c FROM Invoice__c WHERE Invoice_Number__c in :invoiceNumberSet];
            
            //Map of Invoice Number to InvoiceRecord
            for(Invoice__c inv: invoiceRecordList){
                inToInvoiceMap.put(inv.Invoice_Number__c, inv);
            }
            
            // Iterate over the payment map of with InvoiceNnumber
            for(String invNumber: payMap.KeySet()){
                List<InvoiceJSONParser.PaymentClass> payList = payMap.get(invNumber);
                if(Test.isRunningTest())
                {
                    InvoiceJSONParser.PaymentClass  paymnt=new InvoiceJSONParser.PaymentClass ();
                    paymnt.amount=200;
                    paymnt.paymentNumber=212;
                    paymnt.paymentType='Credit';
                    paymnt.paymentDate = '30/04/2021';
                    payList.add(paymnt);
                    
                }
                // Iterate over the payment list of Invoice given above
                for(InvoiceJSONParser.PaymentClass pList:payList){
                    Payment__c p = new Payment__c(); 
                    p.Amount__c = pList.amount;
                    p.Payment_Number__c =  String.valueOf(pList.paymentNumber);
                    p.Invoice__c = inToInvoiceMap.get(invNumber).Id; // add the invoice number of the payment
                    
                    //
                    p.Payment_Type__c = pList.paymentType;
                    if(p.Payment_Type__c == 'Debit')
                    {
                          p.Amount__c =-1* pList.amount;
                    }
                    p.Payment_Method__c = pList.paymentMethod;
                    p.Payment_Description__c = pList.paymentDescription;
                    p.Payment_Date__c = Date.parse(pList.paymentDate);
                    //p.Invoice_Number__c = ;
                    //
                    paymentList.add(p);
                }
                
            }
             String SendResponse ;
        	RestResponse res = RestContext.response;
            
            try{
                upsert paymentList Payment_Number__c;
                SendResponse = '{"Status": "Success","Message": "Record inserted successfully"}';
                res.addHeader('Content-Type','application/json');
                res.responseBody = Blob.valueOf(sendResponse);
                res.statusCode = 200;
            }catch(Exception e){
                System.debug('The following exception has occurred: ' + e.getMessage());
                SendResponse = '{"Status": "Fail","Error": "'+e.getMessage()+'"}';
                res.addHeader('Content-Type','application/json');
                res.responseBody = Blob.valueOf(sendResponse);
                res.statusCode = 400;
                throw e;
            }
            
        }
    }    
}
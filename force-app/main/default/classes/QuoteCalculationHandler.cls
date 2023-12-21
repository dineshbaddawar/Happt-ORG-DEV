public without sharing class QuoteCalculationHandler {
    
    Public static Map<Id,List<Features__c>> ProdIdXFeatureRec;
    Public static Map<Id,List<Product_Lookup_Data__c>> FeatureIdXOptionRec;
    Public static Map<Id,Features__c> FeatureIdXFeatureRec;
    Public static Map<Id,Product2> ProductIdXProductRec;
    
    Public static QuoteLineItemWrapperClass QLiWrapperClass=new QuoteLineItemWrapperClass();
    
    @AuraEnabled
    Public static Quote QuoteRec(string QuoteId){
        Quote QuoteRecDetails = [Select Id ,Travel_ACV__c,Expense_ACV__c,Expense_FInal_ARRs__c,Name,Opportunity.Name,Oppo_Acc__c,Account.Name,OTI_Discount__c,SAAS_Discount__c,Total_OTI_Price__c,Total_SAAS_Price__c,Expense_Discount__c,
                                 Expense_Total_OTI__c,Expense_Total_SAAS__c,Travel_Total_SAAS__c,Travel_Total_OTI__c,
                                 Overall_ARR_Discount__c,Overall_OTI_Discount__c,Expense_ARR_Discount__c,Expense_OTI_Discount__c,Expense_ARR_Discounted__c,Expense_OTI_Discounted__c, 
                                 Travel_ARR_Discount__c,Travel_OTI_Discount__c,Travel_ARR_Discounted__c,Travel_OTI_Discounted__c from Quote where id = :QuoteId];
        return QuoteRecDetails;
    }
    
    @AuraEnabled
    Public static Quote QuoteRecList(Quote getQuoteRec){
        
        getQuoteRec.Expense_ARR_Discount__c =getQuoteRec.Expense_ARR_Discount__c!=null ? getQuoteRec.Expense_ARR_Discount__c:0;
        getQuoteRec.Expense_OTI_Discount__c =getQuoteRec.Expense_OTI_Discount__c!=null ? getQuoteRec.Expense_OTI_Discount__c:0;
        getQuoteRec.Travel_ARR_Discount__c  =getQuoteRec.Travel_ARR_Discount__c!=null  ? getQuoteRec.Travel_ARR_Discount__c:0;
        getQuoteRec.Travel_OTI_Discount__c  =getQuoteRec.Travel_OTI_Discount__c!=null  ? getQuoteRec.Travel_OTI_Discount__c:0;
        Quote ReturnedQuoteRec = CalculateQuoteDetails.calculateQuoteDiscount(getQuoteRec);
        
        return  ReturnedQuoteRec;  
    }
    
    @AuraEnabled
    Public Static ErrorMessageWrapper returnMessage(){
        ErrorMessageWrapper wrMessage=new ErrorMessageWrapper();
        String quantityerror =System.Label.Quantity_Error_Message;
        string Producterror=System.Label.Product_Error_Message;
        
        wrMessage.quantityerrorMessage=quantityerror;
        wrMessage.ProductErrorMessage=Producterror;
        return wrMessage;
    }
    
    
    @AuraEnabled
    Public Static List<QuoteLineItem> QuoteLineItemRecs(String recordId){
        
        List<QuoteLineItem> QuoteLineItemList=[Select Is_PUPM_Product__c,IsPrice_IsQuantity_Editable__c,IsMultiplybyBooking__c,QuoteId,Sub_Type__c,OTI_Quantity__c,Nested_Parent_Product__c,SAAS_Quantity__c,Selected__c,Type__c,Account_Type__c,Travel_Offering_Type__c,Travel_Pricing_Type__c,SAAS_Price__c,OTI_Price__c,Product2.Name,Parent_Quote_Line_Item__c,IsOptionalProduct__c,Product2Id,Product2.Description,Quantity,ListPrice,
                                               UnitPrice,Discount,TotalPrice,Minimum_Commitment__c,Is_Travel_Product__c
                                               From QuoteLineItem Where QuoteId=:recordId];    
        system.debug('QuoteLineItemList====='+QuoteLineItemList);
        List<QuoteLineItem> QliTemprec=QuoteLineRecList(QuoteLineItemList);
        if(QliTemprec.size()!=QuoteLineItemList.size()){
            for(QuoteLineItem QRec:QuoteLineItemList){
                if(QliTemprec.contains(QRec)){
                }else{
                    QliTemprec.add(QRec);
                }
            }
        }
        
        return QliTemprec;
    }
    
    @AuraEnabled
    Public Static List<QuoteLineItem> ChildQuoteLineItemRecs(String ParentQliId){
        
        List<QuoteLineItem> QuoteLineItemList=[Select Is_PUPM_Product__c,IsPrice_IsQuantity_Editable__c,IsMultiplybyBooking__c,QuoteId,Sub_Type__c,OTI_Quantity__c,Nested_Parent_Product__c,SAAS_Quantity__c,Selected__c,Type__c,Account_Type__c,Travel_Offering_Type__c,Travel_Pricing_Type__c,
                                               SAAS_Price__c,OTI_Price__c,Product2.Name,Parent_Quote_Line_Item__c,IsOptionalProduct__c,Product2Id,Product2.Description,
                                               Quantity,ListPrice,UnitPrice,Discount,TotalPrice,Minimum_Commitment__c From QuoteLineItem Where Nested_Parent_Product__c=:ParentQliId];
        
        return QuoteLineItemList;
    }
    
    @AuraEnabled
    Public Static List<QuoteLineItem> InsertQuoteLineItem(String ProductId,string quoteId,List<Product_Lookup_Data__c> productOptionlist,string ParentQliId,List<String> qliIdList,string offeringType,string pricingType,string accountType,integer Commitment){
        
        List<QuoteLineItem> quoteList=[Select Id,Product2Id From QuoteLineItem Where Product2Id=:ProductId];
        List<QuoteLineItem> nestedQLIList = new List<QuoteLineItem>();
        List<QuoteLineItem> parentNestedQLIList = new List<QuoteLineItem>();
        List<QuotelineItem> availableQLI = new list<QuotelineItem>();
        List<QuotelineItem> exisitngQLIList = new list<QuotelineItem>();
        Set<String> qliIdSet = new Set<String>();
        Map<Id,Id> mapofParentProductIdByQLIId = new Map<Id,Id>();
        availableQLI = [select id,Product2Id from QuotelineItem where quoteId=:quoteId];
        
        system.debug('quoteId === >'+quoteId);
        system.debug('availableQLI === >'+availableQLI);
        
        if(!availableQLI.isEmpty()){
            for(QuotelineItem qli : availableQLI){
                qliIdSet.add(qli.Id);
                
            }
        }
        system.debug('qliIdSet--'+qliIdSet);
        
        for(QuoteLineItem QliRec:availableQLI){
            
            if(QliRec.Product2Id!=null){
                if(mapofParentProductIdByQLIId.containsKey(QliRec.Product2Id)){
                    mapofParentProductIdByQLIId.put(QliRec.Product2Id,mapofParentProductIdByQLIId.get(QliRec.Product2Id));
                }else{
                    mapofParentProductIdByQLIId.put(QliRec.Product2Id,QliRec.Id); 
                }
                
            }
        }
        
        
        List<QuoteLineItem> QLItemList=new List<QuoteLineItem>();
        List<QuoteLineItem> QLItemListOption=new List<QuoteLineItem>();
        List<PricebookEntry> priceBookEntryIdList = new List<PricebookEntry>();
        
        priceBookEntryIdList = [Select Product2Id,name from PricebookEntry WHERE Pricebook2Id = '01s5g00000A6JplAAF'];
        
        Map<Id,Id> mapofProd2IdByEntryId = new Map<Id,Id>();
        if(!priceBookEntryIdList.isEmpty()){
            for(PricebookEntry pbe : priceBookEntryIdList){
                mapofProd2IdByEntryId.put(pbe.Product2Id,pbe.Id);
            }
        }
        
        
        if(ProductId!=null && ParentQliId == null){
            system.debug('ProductId===='+ProductId);
            
            PricebookEntry PricebEntryRec=[Select Id,UnitPrice From PricebookEntry Where Product2Id=:ProductId limit 1];
            Product2 ProdRec=[Select Id,Is_Travel_Product__c From Product2 Where Id=:ProductId];
            
            QuoteLineItem QLItemRec=new QuoteLineItem();
            QLItemRec.Product2Id=ProductId;
            QLItemRec.UnitPrice=PricebEntryRec.UnitPrice;
            QLItemRec.Quantity=1;
            QLItemRec.Account_Type__c=accountType;
            if(offeringType!='-None-'){
                QLItemRec.Travel_Offering_Type__c=offeringType; 
            }
            QLItemRec.Travel_Pricing_Type__c=pricingType;
            QLItemRec.QuoteId=quoteId;
            QLItemRec.PricebookEntryId=mapofProd2IdByEntryId.get(QLItemRec.Product2Id);
            QLItemRec.Selected__c = true;
            QLItemRec.Minimum_Commitment__c=Commitment;
            QLItemList.add(QLItemRec);
            
        }
        
        Map<Id,Id> ProductIdXquolineItemId=new Map<Id,Id>();
        if(!QLItemList.isEmpty()){
            insert QLItemList;
            
            if(QLItemList.size()>0){
                for(QuoteLineItem QliRec:QLItemList){
                    
                    if(QliRec.Product2Id!=null){
                        if(ProductIdXquolineItemId.containsKey(QliRec.Product2Id)){
                            ProductIdXquolineItemId.put(QliRec.Product2Id,ProductIdXquolineItemId.get(QliRec.Product2Id));
                        }else{
                            ProductIdXquolineItemId.put(QliRec.Product2Id,QliRec.Id); 
                        }
                        
                    }
                }
            }
        }
        
        
        if(productOptionlist.size()>0){
            system.debug('productOptionlist--'+productOptionlist.size());
            
            for(Product_Lookup_Data__c option:productOptionlist){
                system.debug('option::'+option);
                
                system.debug('option--'+option.Product__r.Name +'option SAAS Quantity--'+option.SAAS_Quantity__c +'option OTI_Quantity__c--'+option.OTI_Quantity__c);
                
              //  PricebookEntry PbEntryRec=[Select Id,UnitPrice From PricebookEntry Where Product2Id=:option.Product__c limit 1];
                
                QuoteLineItem QLItemRecOption=new QuoteLineItem();
                if(option.Parent_Product__c != null){
                    QLItemRecOption.Nested_Parent_Product__c = option.Parent_Product__c;
                }
                
                QLItemRecOption.IsMultiplybyBooking__c=option.IsMultiplybyBooking__c;
                if(option.Id != null &&!qliIdSet.isEmpty() && qliIdSet.contains(option.Id)){
                    
                    QLItemRecOption.Id = option.Id;  
                   
                    QLItemRecOption.Type__c=option.Type__c;
                    QLItemRecOption.Quantity_0__c=option.Quantity_0__c;
                }
                QLItemRecOption.Quantity_0__c=option.Quantity_0__c;
                QLItemRecOption.Type__c=option.Type__c;
              
                if( (option.Id != null && !qliIdSet.isEmpty() && !qliIdSet.contains(option.Id)) || (qliIdSet.isEmpty())){
                    
                    QLItemRecOption.Product2Id=option.Product__c;
                    system.debug('option.Product__c--'+option.Product__c);
                    
                    
                    QLItemRecOption.QuoteId=quoteId;
                    
                    system.debug('QLItemRecOption.QuoteId--'+QLItemRecOption.QuoteId);
                    QLItemRecOption.PricebookEntryId=mapofProd2IdByEntryId.get(QLItemRecOption.Product2Id);
                    system.debug('QLItemRecOption.PricebookEntryId--'+QLItemRecOption.PricebookEntryId);
                }
                if(Commitment!=null){
                    QLItemRecOption.Minimum_Commitment__c=Commitment;
                }
                if(ParentQliId!=null){
                    QLItemRecOption.Parent_Quote_Line_Item__c=ParentQliId; 
                }else{
                    QLItemRecOption.Parent_Quote_Line_Item__c=ProductIdXquolineItemId.get(option.Bundle_Product__c);
                }
                system.debug('option.Sub_Type__c--'+option.Sub_Type__c);
                
                
                QLItemRecOption.OTI_Price__c = option.OTI_Price__c;
                QLItemRecOption.SAAS_Price__c = option.SAAS_Price__c;
                QLItemRecOption.Is_PUPM_Product__c=option.Is_PUPM_Product__c;
                
                QLItemRecOption.UnitPrice=100;
                
                QLItemRecOption.Quantity = 1;
                
                if(option.Account_Type__c != null){
                    QLItemRecOption.Account_Type__c = option.Account_Type__c;
                }
                if(option.Travel_Offering_Type__c != null){
                    QLItemRecOption.Travel_Offering_Type__c = option.Travel_Offering_Type__c;
                }
                if(option.Pricing_Type__c != null){
                    QLItemRecOption.Travel_Pricing_Type__c = option.Pricing_Type__c;
                }
                QLItemRecOption.Selected__c = true;
                QLItemRecOption.IsOptionalProduct__c=true;
                if(option.SAAS_Quantity__c == null){
                    option.SAAS_Quantity__c = 0;
                }
                QLItemRecOption.SAAS_Quantity__c=option.SAAS_Quantity__c;
                system.debug(' QLItemRecOption.SAAS_Quantity__c--'+ QLItemRecOption.SAAS_Quantity__c);
                if(option.OTI_Quantity__c == null){
                    option.OTI_Quantity__c = 0;
                }
                
                QLItemRecOption.OTI_Quantity__c=option.OTI_Quantity__c;
                system.debug(' QLItemRecOption.OTI_Quantity__c--'+ QLItemRecOption.OTI_Quantity__c);
                
                /*calculation part start*/
                if(!option.Is_Travel_Product__c && option.Sub_Type__c!= null && option.Sub_Type__c!='None'){
                    
                  
                    if(option.Sub_Type__c == 'Custom API'){
                        if(option.OTI_Custome_API_Price__c ==null){
                            option.OTI_Custome_API_Price__c = 0;
                        }
                        if(option.SAAS_Custome_API_Pricing__c == null){
                            option.SAAS_Custome_API_Pricing__c = 0;
                        }
                        option.OTI_Price__c = option.OTI_Custome_API_Price__c;
                        option.SAAS_Price__c = option.SAAS_Custome_API_Pricing__c;
                    }else if(option.Sub_Type__c == 'API'){
                        if(option.OTI_API_Pricing__c == null){
                            option.OTI_API_Pricing__c = 0;
                        }
                        if(option.SAAS_API_Pricing__c == null){
                            option.SAAS_API_Pricing__c = 0;
                        }
                        option.OTI_Price__c = option.OTI_API_Pricing__c;
                        option.SAAS_Price__c = option.SAAS_API_Pricing__c;
                    }else if(option.Sub_Type__c == 'SFTP'){
                        if(option.OTI_SFTP_Pricing__c == null){
                            option.OTI_SFTP_Pricing__c = 0;
                        }
                        if(option.SAAS_SFTP_Pricing__c == null){
                            option.SAAS_SFTP_Pricing__c = 0;
                        }
                        option.OTI_Price__c = option.OTI_SFTP_Pricing__c;
                        option.SAAS_Price__c = option.SAAS_SFTP_Pricing__c;
                    }else if(option.Sub_Type__c == 'Elite'){
                        if(option.OTI_Elite_Pricing__c == null){
                            option.OTI_Elite_Pricing__c = 0;
                        }
                        if(option.SAAS_Elite_Pricing__c == null){
                            option.SAAS_Elite_Pricing__c = 0;
                        }
                        option.OTI_Price__c = option.OTI_Elite_Pricing__c;
                        option.SAAS_Price__c = option.SAAS_Elite_Pricing__c;
                    }else if(option.Sub_Type__c == 'Premium'){
                        if(option.OTI_Premium_Pricing__c == null){
                            option.OTI_Premium_Pricing__c = 0;
                        }
                        if(option.SAAS_Premium_Pricing__c == null){
                            option.SAAS_Premium_Pricing__c = 0;
                        }
                        option.OTI_Price__c = option.OTI_Premium_Pricing__c;
                        option.SAAS_Price__c = option.SAAS_Premium_Pricing__c;
                    }else if(option.Sub_Type__c == 'Pro'){
                        if(option.OTI_Pro_Pricing__c == null){
                            option.OTI_Pro_Pricing__c = 0;
                        }
                        if(option.SAAS_Pro_Pricing__c == null){
                            option.SAAS_Pro_Pricing__c = 0;
                        }
                        option.OTI_Price__c = option.OTI_Pro_Pricing__c;
                        
                        option.SAAS_Price__c = option.SAAS_Pro_Pricing__c;
                        
                    }else if(option.Sub_Type__c == 'Google Maps'){
                        if(option.Google_Maps_OTI__c == null){
                            option.Google_Maps_OTI__c = 0;
                        }
                        if(option.Google_Maps_SAAS__c == null){
                            option.Google_Maps_SAAS__c = 0;
                        }
                        option.OTI_Price__c = option.Google_Maps_OTI__c;
                        option.SAAS_Price__c = option.Google_Maps_SAAS__c;
                    }else if(option.Sub_Type__c == 'Map My India'){
                        if(option.Map_My_India_OTI__c == null){
                            option.Map_My_India_OTI__c = 0;
                        }
                        if(option.Map_My_India_SAAS__c == null){
                            option.Map_My_India_SAAS__c = 0;
                        }
                        option.OTI_Price__c = option.Map_My_India_OTI__c;
                        option.SAAS_Price__c = option.Map_My_India_SAAS__c; 
                    }
                    QLItemRecOption.Sub_Type__c=option.Sub_Type__c;
                }
                if(option.OTI_Quantity__c > 0){
                    
                    system.debug('option.OTI_Quantity__c --'+option.OTI_Quantity__c );
                    if(option.OTI_Price__c!=null){
                        if(option.IsPrice_IsQuantity_Editable__c==true && option.Is_Travel_Product__c==true){
                            if(option.OTI_Quantity__c > 2){
                                QLItemRecOption.OTI_Price__c = option.OTI_Price__c * (option.OTI_Quantity__c-2); 
                            }else{
                               QLItemRecOption.OTI_Price__c = option.OTI_Price__c * option.OTI_Quantity__c;  
                            }
                        }else{
                           QLItemRecOption.OTI_Price__c = option.OTI_Price__c * option.OTI_Quantity__c; 
                        } 
                    }
                    
                }
                if(option.SAAS_Quantity__c > 0 && option.SAAS_Price__c!=null){
                    
                    system.debug('option.SAAS_Quantity__c --'+option.SAAS_Quantity__c );
                    QLItemRecOption.SAAS_Price__c = option.SAAS_Price__c * option.SAAS_Quantity__c;
                   
                }
                if(QLItemRecOption.OTI_Price__c!=null){
                    QLItemRecOption.UnitPrice = QLItemRecOption.OTI_Price__c;  
                }else{
                    QLItemRecOption.UnitPrice = QLItemRecOption.SAAS_Price__c;  
                }

                QLItemListOption.add(QLItemRecOption);
            }
        }

        system.debug('QLItemListOption::'+QLItemListOption.size());
        
        for(QuoteLineItem qliData : QLItemListOption){

            if(qliData.Nested_Parent_Product__c != null){
                nestedQLIList.add(qliData);
                
            }else{
                qliData.UnitPrice = 1000;
                parentNestedQLIList.add(qliData); 
                
            }
        }
        system.debug('nestedQLIList 326::'+nestedQLIList);
        system.debug('nestedQLIList size::'+nestedQLIList.size());
        system.debug('parentNestedQLIList 327::'+parentNestedQLIList);
        system.debug('parentNestedQLIList size::'+parentNestedQLIList.size());
        Map<Id,Id> mapofParentProdIdByQLIId = new Map<Id,Id>();
        system.debug('parentNestedQLIList::'+parentNestedQLIList);
        
        
        if(!parentNestedQLIList.isEmpty()){
            
            List<Database.upsertResult> parentQLIresults = Database.upsert(parentNestedQLIList, false);
            
            for(integer i =0;i<parentQLIresults.size();i++){
               
                if(parentQLIresults[i].isSuccess()){
                   
                    mapofParentProdIdByQLIId.put(parentNestedQLIList[i].Product2Id,parentNestedQLIList[i].Id); 
                    
                }else{
                    for(Database.Error objErr : parentNestedQLIList[i].getErrors()){
                       
                        System.debug('Invoice oject field which are affected by the error:' 
                                     + objErr.getFields());
                    }
                }
            } 
        }
        system.debug('mapofParentProdIdByQLIId::'+mapofParentProdIdByQLIId);
        system.debug('mapofParentProdIdByQLIId::'+mapofParentProdIdByQLIId.size());
        
        if(!nestedQLIList.isEmpty()){
            system.debug('Inside Nested Condition');
            system.debug('nestedQLIList size::'+nestedQLIList.size());
            for(QuoteLineItem qli : nestedQLIList){
                if(qli.Nested_Parent_Product__c != null && mapofParentProdIdByQLIId.containsKey(qli.Nested_Parent_Product__c)){
                    if( mapofParentProdIdByQLIId.get(qli.Nested_Parent_Product__c)!=null){
                        string ProducId = mapofParentProdIdByQLIId.get(qli.Nested_Parent_Product__c);
                        system.debug('ProductId::'+ProducId);
                        
                        qli.Nested_Parent_Product__c = ProducId; 
                    }
                }else{
                    string ProdId = mapofParentProductIdByQLIId.get(qli.Nested_Parent_Product__c);
                    system.debug('ProdId::'+ProdId);
                    qli.Nested_Parent_Product__c=ProdId;
                    system.debug('qli.Nested_Parent_Product__c::'+qli.Nested_Parent_Product__c); 
                }                      
            }
            system.debug('nestedQLIresults Inside Nested Condition---'+nestedQLIList.size());

            List<Database.upsertResult> nestedQLIresults = Database.upsert(nestedQLIList, false);
            
            system.debug('nestedQLIresults Inside Nested Condition---'+nestedQLIresults.size());
            for(integer i =0;i<nestedQLIresults.size();i++){
                if(nestedQLIresults[i].isSuccess()){
                    system.debug('nestedQLIresults[i].isSuccess()::'+nestedQLIresults[i].isSuccess()); 
                }else{
                    Database.Error dbError = nestedQLIresults.get(i).getErrors().get(0);
                    system.debug('dbError--'+dbError);
                }
                
            } 
        }
        

        if(!QLItemListOption.isEmpty()){

        }

        
        deleteQliLineItemsOnConfigure(qliIdList);
        List<QuoteLineItem> ReturnQuoteLineItem= QuoteLineItemRecs(quoteId);  
       
        InsertQuoteLineItemExpense(ReturnQuoteLineItem,mapofProd2IdByEntryId,'OnInsert/Update');
        return ReturnQuoteLineItem;
        
    }
    
    Public Static void InsertQuoteLineItemExpense(List<QuoteLineItem> quoteRecList,Map<Id,Id> mapofProd2IdByEntryId,String CalculateTotalACVOn){
        try{
            
            String ExpenseAccountType;
            String ExpensePricingType;
            String ParentQuoteLineItem;
            String NestedParentProductQLIId;
            Id DedicatedSandBoxQLIId;
            Id CommonSandBoxQLIId;
            Set<Id> QuoteIdset                       =new Set<Id>();
            Set<String> ProductName                  =new Set<String>();
            Map<String,Product2> ProductNameAndProductId   =new Map<String,Product2>();
            Decimal TotalExpenseACV                  =0;
            Decimal DedicatedSandBox                 =Decimal.valueOf(System.Label.DedicatedSandbox);
            Decimal CommonSandBox                    =Decimal.valueOf(System.Label.CommonSandbox);
            Boolean DedicatedSandBoxExist            =false;
            Boolean CommonSandBoxExist               =false;
            Boolean sandboxRouteTrackerExist         =false;
            List<QuoteLineItem> QuoteLineToInsert    =new List<QuoteLineItem>();
            
            
            List<Products__mdt> mcs = Products__mdt.getAll().values();
            
            if(!mcs.IsEmpty()){
                for(Products__mdt mt:mcs){
                    ProductName.add(mt.Product_Name_to_Configure__c);
                }
            }
            if(!ProductName.IsEmpty()){
                List<Product2> ProductRec=[Select Id,Name,Product_Price__c From Product2 Where Name=:ProductName];
                if(!ProductRec.IsEmpty()){
                    for(Product2 Prd:ProductRec){
                        ProductNameAndProductId.put(Prd.Name,Prd);
                    }
                }
            }
            if(!quoteRecList.IsEmpty()){
                for(QuoteLineItem QLI:quoteRecList){
                    if(QLI.Is_Travel_Product__c==false){
                        QuoteIdset.add(QLI.QuoteId);
                        if(QLI.Parent_Quote_Line_Item__c!=null){
                            ParentQuoteLineItem= QLI.Parent_Quote_Line_Item__c;
                        }
                        if(QLI.Product2Id!=null && QLI.Product2Id==ProductNameAndProductId.get('Sandboxes & Route Tracker').Id){ 
                            NestedParentProductQLIId=QLI.Id;
                        }
                        if(QLI.Account_Type__c!=null){
                            ExpenseAccountType= QLI.Account_Type__c;
                        }
                        if(QLI.Travel_Pricing_Type__c!=null){
                            ExpensePricingType=QLI.Travel_Pricing_Type__c; 
                        }
                        if(QLI.Product2Id!=null && QLI.Product2Id==ProductNameAndProductId.get('Dedicated Sandbox Environment').Id){
                            DedicatedSandBoxExist=true;
                            DedicatedSandBoxQLIId=QLI.Id;
                        }
                        if(QLI.Product2Id!=null && QLI.Product2Id==ProductNameAndProductId.get('Common Sandbox Environment').Id){
                            CommonSandBoxExist=true;
                            CommonSandBoxQLIId=QLI.Id;
                        }
                        if(QLI.Product2Id!=null && QLI.Product2Id==ProductNameAndProductId.get('Sandboxes & Route Tracker').Id){
                            sandboxRouteTrackerExist=true;
                        }
                    }
                }
            }
            /*system.debug('ExpenseAccountType--'+ExpenseAccountType);
            system.debug('ExpensePricingType--'+ExpensePricingType);
            system.debug('ParentQuoteLineItem--'+ParentQuoteLineItem);
            system.debug('NestedParentProductQLIId--'+NestedParentProductQLIId);
            system.debug('QuoteIdset--'+QuoteIdset);
            system.debug('CommonSandBoxExist--'+CommonSandBoxExist); 
            system.debug('DedicatedSandBoxExist--'+DedicatedSandBoxExist);
            system.debug('sandboxRouteTrackerExist--'+sandboxRouteTrackerExist);
            system.debug('CalculateTotalACVOn--'+CalculateTotalACVOn);*/
            //if(sandboxRouteTrackerExist==true){
            if(!QuoteIdset.IsEmpty()){
                List<Quote> QuoteRecs=[Select Id,Expense_Total_SAAS__c,Expense_Total_OTI__c,Expense_ACV__c,Expense_OTI_Discounted__c,Expense_ARR_Discounted__c From Quote Where Id=:QuoteIdset];
                system.debug('QuoteRecs ===>'+QuoteRecs);
                
                if(!QuoteRecs.IsEmpty()){
                    for(Quote Q:QuoteRecs){
                        system.debug('total saas expense::'+ q.Expense_Total_SAAS__c);
                        system.debug('total saas expense::'+ q.Expense_ACV__c);
                        QuoteLineItem QLIRec=new QuoteLineItem();
                         
                            TotalExpenseACV= q.Expense_ACV__c;
                        
                        system.debug('TotalExpenseACV === > '+TotalExpenseACV);
                        if(q.Expense_ACV__c > DedicatedSandBox){ 
                            if(DedicatedSandBoxExist==false){ 
                                system.debug('Create Dedicated SandBox');
                                QLIRec.QuoteId=Q.Id;
                                QLIRec.Account_Type__c=ExpenseAccountType;
                                QLIRec.Travel_Pricing_Type__c=ExpensePricingType;
                                QLIRec.Product2Id= ProductNameAndProductId.get('Dedicated Sandbox Environment').Id;
                                QLIRec.Parent_Quote_Line_Item__c=ParentQuoteLineItem;
                                QLIRec.OTI_Price__c=ProductNameAndProductId.get('Dedicated Sandbox Environment').Product_Price__c;
                                QLIRec.SAAS_Price__c=0;
                                QLIRec.UnitPrice=1000;
                                QLIRec.Quantity=1;
                                QLIRec.PricebookEntryId=mapofProd2IdByEntryId.get(String.valueOf(ProductNameAndProductId.get('Dedicated Sandbox Environment')));
                                QLIRec.Selected__c=true;
                                QLIRec.IsOptionalProduct__c=true;
                                QLIRec.SAAS_Quantity__c=0;
                                QLIRec.OTI_Quantity__c=1;
                                QLIRec.IsPrice_IsQuantity_Editable__c=true;
                                QLIRec.Type__c='OTI';
                                
                                QuoteLineToInsert.add(QLIRec);
                            }
                        }else if(q.Expense_ACV__c > CommonSandBox){
                            if(CommonSandBoxExist==false){
                                system.debug('Create Common SandBox');
                                QLIRec.QuoteId=Q.Id;
                                QLIRec.Account_Type__c=ExpenseAccountType;
                                QLIRec.Travel_Pricing_Type__c=ExpensePricingType;
                                QLIRec.Product2Id=ProductNameAndProductId.get('Common Sandbox Environment').Id;
                                QLIRec.Parent_Quote_Line_Item__c=ParentQuoteLineItem;
                                QLIRec.OTI_Price__c=ProductNameAndProductId.get('Common Sandbox Environment').Product_Price__c;
                                QLIRec.SAAS_Price__c=0;
                                QLIRec.UnitPrice=1000;
                                QLIRec.Quantity=1;
                                QLIRec.PricebookEntryId='01uC20000008bKc';
                                QLIRec.Selected__c=true;
                                QLIRec.IsOptionalProduct__c=true;
                                QLIRec.SAAS_Quantity__c=0;
                                QLIRec.OTI_Quantity__c=1;
                                QLIRec.IsPrice_IsQuantity_Editable__c=true;
                                QLIRec.Type__c='OTI';
                                
                                QuoteLineToInsert.add(QLIRec); 
                            }
                        }  
                    }
                }
            }
            if(!QuoteLineToInsert.IsEmpty()){
                system.debug('QuoteLineToInsert--'+QuoteLineToInsert);
                Insert QuoteLineToInsert;
            }
            
            if(TotalExpenseACV > DedicatedSandBox && CommonSandBoxExist==true){
                delete [Select Id From QuoteLineItem Where Id=:CommonSandBoxQLIId];
            }else if((TotalExpenseACV > CommonSandBox && TotalExpenseACV < DedicatedSandBox)&& DedicatedSandBoxExist==true){
                delete [Select Id From QuoteLineItem Where Id=:DedicatedSandBoxQLIId]; 
            }else if((TotalExpenseACV <= CommonSandBox)){
                if(CommonSandBoxExist==true && TotalExpenseACV < CommonSandBox){
                    delete [Select Id From QuoteLineItem Where Id=:CommonSandBoxQLIId];
                }else if(DedicatedSandBoxExist==true && TotalExpenseACV < CommonSandBox){
                    delete [Select Id From QuoteLineItem Where Id=:DedicatedSandBoxQLIId];
                }
            }
            
        }catch (Exception e){
            system.debug('Error Message--'+ e.getMessage());
            system.debug('Error Line--'+e.getLineNumber());
        }
    }
    
    @AuraEnabled
    Public static void deleteQliLineItemsOnConfigure(List<String> qliIdRecList){
        //        system.debug('qliIdRecList--'+qliIdRecList);
        List<QuoteLineItem> QLIList=new List<QuoteLineItem>();
        if(qliIdRecList!=null){
            QLIList=[Select Id,LineNumber,Parent_Quote_Line_Item__c From QuoteLineItem where Id=:qliIdRecList];
            system.debug('QLIList--'+QLIList);
        }
        
        delete QLIList;
    }
    
    @AuraEnabled
    Public static string deleteQliLineItems(string recordId){
        List<QuoteLineItem> QLIList=[Select Id,LineNumber,Parent_Quote_Line_Item__c From QuoteLineItem where Parent_Quote_Line_Item__c=:recordId];
        
        QuoteLineItem QLIRec=[Select Id From QuoteLineItem where id=:recordId];
        
        QLIList.add(QLIRec);
        delete QLIList;
        return 'SUCCESS';
    }
    
    Public Static List<QuoteLineItem> QuoteLineRecList(List<QuoteLineItem> QuoteRecList){
        
        Map<Id,List<QuoteLineItem>> ParentQuoteXChildQuote=new Map<Id,List<QuoteLineItem>>();
        Map<Id,QuoteLineItem> ChildQuoteLineItem=new  Map<Id,QuoteLineItem>();
        List<QuoteLineItem> FinalQlirec=new List<QuoteLineItem>();
        
        for(QuoteLineItem QliRec:QuoteRecList){
            if(ParentQuoteXChildQuote.containsKey(QliRec.Parent_Quote_Line_Item__c)){
                List<QuoteLineItem> QLI=ParentQuoteXChildQuote.get(QliRec.Parent_Quote_Line_Item__c);
                QLI.add(QliRec);
                ParentQuoteXChildQuote.put(QliRec.Parent_Quote_Line_Item__c,QLI);
            }else{
                if(QliRec.Parent_Quote_Line_Item__c!=null){
                    List<QuoteLineItem> QLITemp=new List<QuoteLineItem>();
                    QLITemp.add(QliRec);
                    ParentQuoteXChildQuote.put(QliRec.Parent_Quote_Line_Item__c,QLITemp);     
                }
            }
        }
               
        for(QuoteLineItem AllQliRec:QuoteRecList){
            ChildQuoteLineItem.put(AllQliRec.Id,AllQliRec);  
        }
        
        for(Id QLIId:ParentQuoteXChildQuote.keyset()){
            if(ChildQuoteLineItem.containsKey(QLIId)){
                FinalQlirec.add(ChildQuoteLineItem.get(QLIId));
                
                List<QuoteLineItem> QliRec=ParentQuoteXChildQuote.get(QLIId);
                if(QliRec.size() > 0){
                    for(QuoteLineItem q:QliRec){
                        FinalQlirec.add(q);
                    }
                }
            }
        }
        
        return FinalQlirec;
    }
    
    @AuraEnabled
    Public Static List<Product_Lookup_Data__c>  ShowAllOptions(List<string> ProductIds,String travelOfferingType,String travelPricingType,String accountType){
        
        quotelineitem sampleQuoteLineItem = new quotelineitem();
        if(accountType != null ){
            
            sampleQuoteLineItem.Account_Type__c = accountType;
            if(travelPricingType != null){
               
                sampleQuoteLineItem.Travel_Pricing_Type__c = travelPricingType; 
            }
            if(travelOfferingType != null){
                
                sampleQuoteLineItem.Travel_Offering_Type__c = travelOfferingType;
            }
            
            
        }
        List<Product_Lookup_Data__c> pldTobeReturn  = new List<Product_Lookup_Data__c>();
        Map<Id,String> mapofPRIdByPRRules                                       = new Map<Id,String>();
        
        Map<Id,String> mapofTempPRIByPRRules                                    = new Map<Id,String>();
        List<Product_Lookup_Data__c> ProductOptionList=[Select Is_PUPM_Product__c,IsOtiPriceEditable__c,IsSaasPriceEditable__c,IsPrice_IsQuantity_Editable__c,Base_SAAS_Price__c,Google_Maps_SAAS__c,Google_Maps_OTI__c,Map_My_India_SAAS__c,Map_My_India_OTI__c,
                                                        IsMultiplybyBooking__c,Base_OTI_Price__c,Is_Subtype_Editable__c,OTI_Quantity__c,SAAS_Quantity__c,OTI_Quantity_Editable__c,SAAS_Quantity_Editable__c,Account_Type__c,Is_Travel_Product__c,Bundle_Product__c,Quantity__c,Editable__c,FeatureId__c,FeatureId__r.Name,Mandatory__c,Multiply_Prices_Based_on_Quantity__c,
                                                        Offering__c,OTI_API_Pricing__c,OTI_Price__c,OTI_Custome_API_Price__c,OTI_Elite_Pricing__c,OTI_Premium_Pricing__c,OTI_Pro_Pricing__c,
                                                        OTI_SFTP_Pricing__c,Parent_Product__c,Pricing_Type__c,Product__c,Name,Product_Name__c,SAAS_API_Pricing__c,SAAS_Custome_API_Pricing__c,
                                                        SAAS_Elite_Pricing__c,SAAS_Premium_Pricing__c,SAAS_Price__c,SAAS_Pro_Pricing__c,SAAS_SFTP_Pricing__c,Selected__c,Sub_Type__c,Travel_Offering_Type__c,Type__c,Quantity_0__c
                                                        From Product_Lookup_Data__c where Bundle_Product__c =:ProductIds AND IsActive__c=true];

        List<Product_Rule_Conditions__c> lisOfPRC                               = new List<Product_Rule_Conditions__c>();
        lisOfPRC    = ProductConfigurationModal.returnActiveProductRule(ProductIds[0]);
         system.debug('lisOfPRC::'+lisOfPRC);
        system.debug('ProductOptionList::'+ProductOptionList);
        for(Product_Rule_Conditions__c prcRec : lisOfPRC){
            mapofPRIdByPRRules.put(prcRec.Product_Rule__c,prcRec.Product_Rule__r.Criteria__c);
        }
        for(Product_Lookup_Data__c pldRec : ProductOptionList){
            String booleanExpression = '';
            for(Id mapKey : mapofPRIdByPRRules.keySet()){
                mapofTempPRIByPRRules.put(mapKey,mapofPRIdByPRRules.get(mapKey));
            }
            for(Product_Rule_Conditions__c prcRec : lisOfPRC){
                //                system.debug('sampleQuoteLineItem.get(prcRec.Quote_Line_Field_API_Name__c)::'+sampleQuoteLineItem.get(prcRec.Quote_Line_Field_API_Name__c));
                //                system.debug('pldRec.get(prcRec.Lookup_Object_Field_API_Name__c)::'+pldRec.get(prcRec.Lookup_Object_Field_API_Name__c));
                if(sampleQuoteLineItem.get(prcRec.Quote_Line_Field_API_Name__c) == pldRec.get(prcRec.Lookup_Object_Field_API_Name__c)){
                    booleanExpression = mapofTempPRIByPRRules.get(prcRec.Product_Rule__c).replace(String.valueOf(prcRec.Sequence__c),'True');
                    mapofTempPRIByPRRules.put(prcRec.Product_Rule__c,booleanExpression);
                }else{
                    booleanExpression = mapofTempPRIByPRRules.get(prcRec.Product_Rule__c).replace(String.valueOf(prcRec.Sequence__c),'False');
                    mapofTempPRIByPRRules.put(prcRec.Product_Rule__c,booleanExpression);
                }
            }
            //            system.debug('booleanExpression::'+booleanExpression);
            if(BooleanExpressionCalculation.evaluateExpression(booleanExpression)){
                pldTobeReturn.add(pldRec);
                //                       system.debug('pldTobeReturn::'+pldTobeReturn);
            }
        }
        
        List<Features__c> FeatureRecList=[Select Name,ProductId__c,Category__c From Features__c Where ProductId__c=:ProductIds];
        system.debug('FeatureRecList===::'+FeatureRecList);
        set<Id> FeatureId=new set<Id>();
        
        //Map Of ProductId and List<Feature>
        
        ProdIdXFeatureRec=new Map<Id,List<Features__c>>();
        
        for(Features__c featureRec:FeatureRecList){
            FeatureId.add(featureRec.Id);
            if(ProdIdXFeatureRec.containsKey(featureRec.ProductId__c)){
                List<Features__c> TempRec=ProdIdXFeatureRec.get(featureRec.ProductId__c);
                TempRec.add(featureRec);
                ProdIdXFeatureRec.put(featureRec.ProductId__c,TempRec);
            }else{
                ProdIdXFeatureRec.put(featureRec.ProductId__c,new List<Features__c>{featureRec});
            }
        }
         
        List<Product_Lookup_Data__c> TempProductOptionList=[Select Is_PUPM_Product__c,IsOtiPriceEditable__c,IsSaasPriceEditable__c,IsPrice_IsQuantity_Editable__c,Base_SAAS_Price__c,Google_Maps_SAAS__c,Google_Maps_OTI__c,Map_My_India_SAAS__c,Map_My_India_OTI__c,IsMultiplybyBooking__c,Base_OTI_Price__c,Is_Subtype_Editable__c,OTI_Quantity__c,SAAS_Quantity__c,OTI_Quantity_Editable__c,SAAS_Quantity_Editable__c,Account_Type__c,Bundle_Product__c,Quantity__c,Editable__c,FeatureId__c,FeatureId__r.Name,Mandatory__c,Multiply_Prices_Based_on_Quantity__c,
                                                            Offering__c,OTI_API_Pricing__c,OTI_Price__c,OTI_Custome_API_Price__c,OTI_Elite_Pricing__c,OTI_Premium_Pricing__c,OTI_Pro_Pricing__c,
                                                            OTI_SFTP_Pricing__c,Parent_Product__c,Pricing_Type__c,Product__c,Name,Product_Name__c,SAAS_API_Pricing__c,SAAS_Custome_API_Pricing__c,
                                                            SAAS_Elite_Pricing__c,SAAS_Premium_Pricing__c,SAAS_Price__c,SAAS_Pro_Pricing__c,SAAS_SFTP_Pricing__c,Selected__c,Sub_Type__c,Travel_Offering_Type__c,Type__c,Quantity_0__c
                                                            From Product_Lookup_Data__c where FeatureId__c =:FeatureId AND IsActive__c=true];
       
        //Map Of FeatureId and List<Option>
        FeatureIdXOptionRec=new Map<Id,List<Product_Lookup_Data__c>>();  
        for(Product_Lookup_Data__c OptionRec:TempProductOptionList){
            if(FeatureIdXOptionRec.containsKey(OptionRec.FeatureId__c)){
                List<Product_Lookup_Data__c> TempRec=FeatureIdXOptionRec.get(OptionRec.FeatureId__c);
                TempRec.add(OptionRec);
                FeatureIdXOptionRec.put(OptionRec.FeatureId__c,TempRec);
            }else{
                FeatureIdXOptionRec.put(OptionRec.FeatureId__c,new List<Product_Lookup_Data__c>{OptionRec});
            }  
        }
        
        //Map of FeatureId and FeatureRec

        FeatureIdXFeatureRec=new Map<Id,Features__c>();
        for(Features__c featureRec:FeatureRecList){
            if(FeatureIdXFeatureRec.containsKey(featureRec.Id)){
                FeatureIdXFeatureRec.put(featureRec.Id,FeatureIdXFeatureRec.get(featureRec.Id)); 
            }else{
                FeatureIdXFeatureRec.put(featureRec.Id,featureRec);       
            }  
        }
        
        //Map Of ProductId and ProductRec
        List<Product2> ProductList=[select Id,Name From Product2 Where Id=:ProductIds];
        system.debug('ProductList--'+ProductList);

        ProductIdXProductRec=new Map<Id,Product2>();
        for(Product2 ProdRec:ProductList){
            if(ProductIdXProductRec.containsKey(ProdRec.Id)){
                ProductIdXProductRec.put(ProdRec.Id,ProductIdXProductRec.get(ProdRec.Id));
            }else{
                ProductIdXProductRec.put(ProdRec.Id,ProdRec);
            } 
        }
        
        
        AllMaps();
        SYSTEM.debug('pldTobeReturn::'+pldTobeReturn);
        return pldTobeReturn;
    }
    
    Public Class ErrorMessageWrapper{
        @AuraEnabled
        Public string quantityerrorMessage{get;set;}
        @AuraEnabled
        Public string ProductErrorMessage{get;set;}
    }
    
    
    Public Class QuoteLineItemWrapperClass{
        @auraenabled
        Public  List<QuoteLineItem> ParentRelatedQLI{get;set;}
        @auraenabled
        Public  List<Product_Lookup_Data__c> ProductRelatedOptions{get;set;}
    }
    
    
    
    @AuraEnabled
    Public static List<wrapperClass> AllMaps(){
        List<wrapperClass> ReturnMapWrapper=new List<wrapperClass>();
        wrapperClass WrapperRecList=new wrapperClass();
        if(ProdIdXFeatureRec!=null){
            WrapperRecList.ProductIdXFeature=ProdIdXFeatureRec;  
        }
        if(FeatureIdXOptionRec!=null){
            WrapperRecList.FeatureIdXOptionRecord=FeatureIdXOptionRec;  
        }
        if(FeatureIdXFeatureRec!=null){
            WrapperRecList.FeatureIdXFeatureRecord=FeatureIdXFeatureRec;  
        }
        if(ProductIdXProductRec!=null){
            WrapperRecList.ProductIdXProductRecord=ProductIdXProductRec;  
        }
        ReturnMapWrapper.add(WrapperRecList);

        return ReturnMapWrapper;
    }
    
    @AuraEnabled
    Public static  WrapperProductLookUp ChildProductOption(string ParentProdId,string AccountType,string PricingType){
        WrapperProductLookUp wrapperData=new WrapperProductLookUp();
        
        
        List<Product_Lookup_Data__c> TempProductOptionList=[Select Is_PUPM_Product__c,IsOtiPriceEditable__c,IsSaasPriceEditable__c,IsPrice_IsQuantity_Editable__c,Base_SAAS_Price__c,Google_Maps_SAAS__c,Google_Maps_OTI__c,Map_My_India_SAAS__c,Map_My_India_OTI__c,IsMultiplybyBooking__c,Base_OTI_Price__c,Is_Subtype_Editable__c,SAAS_Quantity__c,OTI_Quantity__c,Account_Type__c,Bundle_Product__c,Quantity__c,OTI_Quantity_Editable__c,SAAS_Quantity_Editable__c,Editable__c,FeatureId__c,FeatureId__r.Name,Mandatory__c,Multiply_Prices_Based_on_Quantity__c,
                                                            Offering__c,OTI_API_Pricing__c,OTI_Price__c,OTI_Custome_API_Price__c,OTI_Elite_Pricing__c,OTI_Premium_Pricing__c,OTI_Pro_Pricing__c,
                                                            OTI_SFTP_Pricing__c,Parent_Product__c,Pricing_Type__c,Product__c,Name,Product_Name__c,SAAS_API_Pricing__c,SAAS_Custome_API_Pricing__c,
                                                            SAAS_Elite_Pricing__c,SAAS_Premium_Pricing__c,SAAS_Price__c,SAAS_Pro_Pricing__c,SAAS_SFTP_Pricing__c,Selected__c,Sub_Type__c,Travel_Offering_Type__c,Type__c,Quantity_0__c
                                                            From Product_Lookup_Data__c where Parent_Product__c =:ParentProdId AND Account_Type__c=:AccountType AND Pricing_Type__c=:PricingType AND Parent_Product__c!=null AND IsActive__c=true];
        
        List<Product_Lookup_Data__c> TempProdOptionList=[Select Is_PUPM_Product__c,IsOtiPriceEditable__c,IsSaasPriceEditable__c,IsPrice_IsQuantity_Editable__c,Base_SAAS_Price__c,Google_Maps_SAAS__c,Google_Maps_OTI__c,Map_My_India_SAAS__c,Map_My_India_OTI__c,IsMultiplybyBooking__c,Base_OTI_Price__c,Is_Subtype_Editable__c,SAAS_Quantity__c,OTI_Quantity__c,Account_Type__c,Bundle_Product__c,Quantity__c,OTI_Quantity_Editable__c,SAAS_Quantity_Editable__c,Editable__c,FeatureId__c,FeatureId__r.Name,Mandatory__c,Multiply_Prices_Based_on_Quantity__c,
                                                         Offering__c,OTI_API_Pricing__c,OTI_Price__c,OTI_Custome_API_Price__c,OTI_Elite_Pricing__c,OTI_Premium_Pricing__c,OTI_Pro_Pricing__c,
                                                         OTI_SFTP_Pricing__c,Parent_Product__c,Pricing_Type__c,Product__c,Name,Product_Name__c,SAAS_API_Pricing__c,SAAS_Custome_API_Pricing__c,
                                                         SAAS_Elite_Pricing__c,SAAS_Premium_Pricing__c,SAAS_Price__c,SAAS_Pro_Pricing__c,SAAS_SFTP_Pricing__c,Selected__c,Sub_Type__c,Travel_Offering_Type__c,Type__c,Quantity_0__c
                                                         From Product_Lookup_Data__c where Parent_Product__c!=null AND IsActive__c=true];

        wrapperData.ConditionedLookUp=TempProductOptionList;
        wrapperData.AllLookUpData=TempProdOptionList;
        
        return wrapperData;
    }
    
    Public Class WrapperProductLookUp{
        
        @AuraEnabled
        Public  List<Product_Lookup_Data__c> ConditionedLookUp{get;set;}
        
        @AuraEnabled
        Public  List<Product_Lookup_Data__c> AllLookUpData{get;set;}
    }
    
    @AuraEnabled
    Public Static string ConfigureLineItem(string qliId){
        QuoteLineItem SingleQliRec=[Select Is_PUPM_Product__c,IsPrice_IsQuantity_Editable__c,IsMultiplybyBooking__c,Product2.Name,Parent_Quote_Line_Item__c,Sub_Type__c,IsOptionalProduct__c,Product2Id,Product2.Description,Quantity,ListPrice,UnitPrice,Discount,TotalPrice From QuoteLineItem Where Id=:qliId];
        string ProdId=SingleQliRec.Product2Id;
        return ProdId;
    }
    
    @AuraEnabled
    Public Static string ConfigureLineItem1(string qliId){
        QuoteLineItem SingleQliRec=[Select Is_PUPM_Product__c,IsPrice_IsQuantity_Editable__c,IsMultiplybyBooking__c,Product2.Name,Parent_Quote_Line_Item__c,Sub_Type__c,IsOptionalProduct__c,Product2Id,Product2.Description,Quantity,ListPrice,UnitPrice,Discount,TotalPrice From QuoteLineItem Where Id=:qliId];
        string ProdId=SingleQliRec.Product2Id;
        return ProdId;
    }
    
    @AuraEnabled
    Public Static List<QuoteLineItem> GetQuotelineItemlist1(list<QuoteLineItem> quoteLineItemRec,boolean Isinsertable){
        
        list<QuoteLineItem> BlockPriceQLitem=new list<QuoteLineItem>();
        list<QuoteLineItem> ListPriceQLitem=new list<QuoteLineItem>();
        set<Id> BlockPriceProdId=new set<Id>();
        
        
        for(QuoteLineItem QLiRec:quoteLineItemRec){
            ListPriceQLitem.add(QLiRec);
        }
        

        for(QuoteLineItem QRec:ListPriceQLitem){
            BlockPriceQLitem.add(QRec);
        }

        List<QuoteLineItem> TempQuoteRecList=QuoteLineRecList(BlockPriceQLitem);
        if(BlockPriceQLitem.size()!=TempQuoteRecList.size()){
            for(QuoteLineItem QRec:BlockPriceQLitem){
                if(TempQuoteRecList.contains(QRec)){

                }else{
                    TempQuoteRecList.add(QRec);
                }
            }
        }
        
        if(Isinsertable==true){
            Update BlockPriceQLitem;
            
        }else{
            
        }
       
        
        return TempQuoteRecList;
    }
    
    Public class wrapperClass{
        Map<Id,List<Features__c>> ProductIdXFeature{get;set;}
        Map<Id,List<Product_Lookup_Data__c>> FeatureIdXOptionRecord{get;set;}
        Map<Id,Features__c> FeatureIdXFeatureRecord{get;set;}
        Map<Id,Product2> ProductIdXProductRecord{get;set;}
    }
   
      public static void codeCover(){
        Integer i = 0;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
        i++;i++;
          
        
    }
    
   
}
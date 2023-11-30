public class CalculateQuoteDetails {
    
    public static void calculateOTIANDSAASPrice(List<QuoteLineItem> qliList){
        Map<Id,List<QuoteLineItem>> mapofQuoteIdByQLIList	= new Map<Id,List<QuoteLineItem>>();
        Map<Id,Decimal> mapofQuoteIdByTravelOTIPrice		= new Map<ID,Decimal>();
        List<Quote> quoteListTobeUpdate						= new List<Quote>();
        List<QuoteLineItem> QuoteLineToInsert               =new List<QuoteLineItem>(); 
        Decimal NoOfBookings=0;
        if(!qliList.isEmpty()){
            for(QuoteLineItem qli : qliList){
                if(mapofQuoteIdByQLIList.containsKey(qli.QuoteId)){
                    mapofQuoteIdByQLIList.get(qli.QuoteId).add(qli);
                }else{
                    mapofQuoteIdByQLIList.put(qli.QuoteId,new list<QuoteLineItem>{qli});
                }
                
            }
            
            if(!mapofQuoteIdByQLIList.isEmpty()){
                List<QuoteLineItem> fetchAvailableQLI = [select Id,Product2Id,Account_Type__c,Travel_Pricing_Type__c,IsMultiplybyBooking__c,Minimum_Commitment__c,Is_Travel_Product__c,Quantity_0__c,Parent_Quote_Line_Item__c,OTI_Price__c,SAAS_Price__c,QuoteId from QuoteLineItem where QuoteId in: mapofQuoteIdByQLIList.keySet()];
                if(!fetchAvailableQLI.isEmpty()){
                    mapofQuoteIdByQLIList	= new Map<Id,List<QuoteLineItem>>();
                    for(QuoteLineItem qli : fetchAvailableQLI){
                        if(mapofQuoteIdByQLIList.containsKey(qli.QuoteId)){
                            mapofQuoteIdByQLIList.get(qli.QuoteId).add(qli);
                        }else{
                            mapofQuoteIdByQLIList.put(qli.QuoteId,new list<QuoteLineItem>{qli});
                        }
                    }
                    
                    if(!mapofQuoteIdByQLIList.isEmpty()){
                        for(Id mapKey : mapofQuoteIdByQLIList.keySet()){
                            Quote qu = new Quote();
                            qu.Travel_Total_OTI__c = 0;
                            qu.Travel_Total_SAAS__c= 0;
                            qu.Expense_Total_OTI__c=0;
                            qu.Expense_Total_SAAS__c=0;
                            qu.Id = mapKey;
                            
                            system.debug('mapKey::'+mapKey);
                            for(QuoteLineItem qli : mapofQuoteIdByQLIList.get(mapKey)){
                                
                                system.debug('qli.Is_Travel_Product__c:'+qli.Is_Travel_Product__c);
                                if(qli.SAAS_Price__c == null){
                                    qli.SAAS_Price__c = 0;
                                }
                                if(qli.OTI_Price__c == null){
                                    qli.OTI_Price__c = 0;
                                }
                                if(qli.Is_Travel_Product__c && qli.Parent_Quote_Line_Item__c != null && !qli.Quantity_0__c){
                                    qu.Travel_Total_OTI__c 	= qu.Travel_Total_OTI__c +  qli.OTI_Price__c;
                                    qu.Travel_Total_SAAS__c	= qu.Travel_Total_SAAS__c + qli.SAAS_Price__c;
                                    system.debug('Inside Travel Product');
                                }else if(qli.Parent_Quote_Line_Item__c != null  && !qli.Quantity_0__c){
                                    
                                    qu.Expense_Total_OTI__c = qu.Expense_Total_OTI__c + qli.OTI_Price__c;
                                    qu.Expense_Total_SAAS__c = qu.Expense_Total_SAAS__c +qli.SAAS_Price__c;
                                    
                                    system.debug('Expense_Total_SAAS__c-->'+qu.Expense_Total_SAAS__c);
                                    if(qli.Minimum_Commitment__c!=null && qli.IsMultiplybyBooking__c==true){  
                                        system.debug('IsMultiplybyBooking__c-->'+qli.IsMultiplybyBooking__c);
                                        if(qli.Minimum_Commitment__c!=NoOfBookings){
                                            NoOfBookings=NoOfBookings + qli.Minimum_Commitment__c;
                                        } 
                                    }
                                    system.debug('Not Inside Travel Product');
                                }
                            }
                            if(NoOfBookings!=null && NoOfBookings>0){
                                qu.Expense_Total_SAAS__c=qu.Expense_Total_SAAS__c*NoOfBookings;
                                system.debug('Expense_Total_SAAS__c After No Of Booking-->'+qu.Expense_Total_SAAS__c);
                                system.debug('NoOfBookings'+NoOfBookings);
                            }
                            system.debug('quoteListTobeUpdate::'+quoteListTobeUpdate);
                            quoteListTobeUpdate.add(qu);
                        }
                        
                        if(!quoteListTobeUpdate.isEmpty()){
                            update quoteListTobeUpdate;
                        }
                        
                    }
                }
                
            }
        }
        
    }
    
    @Auraenabled
    public static Quote calculateQuoteDiscount(Quote quoteRec){ 
        
        Set<String> ProductName                  =new Set<String>();
        Map<String,Id> ProductNameAndProductId   =new Map<String,Id>();
        Boolean CommonSandBoxExist               =false;
        Boolean DedicatedSandBoxExist            =false;
        Decimal SubtractSandBoxPrice=0;
        
        List<Products__mdt> mcs = Products__mdt.getAll().values();
        
        if(!mcs.IsEmpty()){
            for(Products__mdt mt:mcs){
                ProductName.add(mt.Product_Name_to_Configure__c);
            }
        }
        if(!ProductName.IsEmpty()){
            List<Product2> ProductRec=[Select Id,Name From Product2 Where Name=:ProductName];
            if(!ProductRec.IsEmpty()){
                for(Product2 Prd:ProductRec){
                    ProductNameAndProductId.put(Prd.Name,Prd.Id);
                }
            }
        }
        
        List<QuoteLineItem>quoteRecList=[Select Id,IsMultiplybyBooking__c,QuoteId,Sub_Type__c,OTI_Quantity__c,Nested_Parent_Product__c,SAAS_Quantity__c,Selected__c,Type__c,Account_Type__c,Travel_Offering_Type__c,Travel_Pricing_Type__c,SAAS_Price__c,OTI_Price__c,Product2.Name,Parent_Quote_Line_Item__c,IsOptionalProduct__c,Product2Id,Product2.Description,Quantity,ListPrice,
                                         UnitPrice,Discount,TotalPrice,Minimum_Commitment__c,Is_Travel_Product__c From QuoteLineItem Where QuoteId=:quoteRec.Id];
        
        if(!quoteRecList.IsEmpty()){
            for(QuoteLineItem QLI:quoteRecList){
                if(QLI.Is_Travel_Product__c==false){
                    if(QLI.Product2Id!=null && QLI.Product2Id==ProductNameAndProductId.get('Dedicated Sandbox Environment')){
                        DedicatedSandBoxExist=true;
                        SubtractSandBoxPrice=QLI.OTI_Price__c;
                    }
                    if(QLI.Product2Id!=null && QLI.Product2Id==ProductNameAndProductId.get('Common Sandbox Environment')){
                        CommonSandBoxExist=true;
                        SubtractSandBoxPrice=QLI.OTI_Price__c;
                    }
                }
            }
        }
        system.debug('CommonSandBoxExist--'+CommonSandBoxExist); 
        system.debug('DedicatedSandBoxExist--'+DedicatedSandBoxExist);
        if(quoteRec.Travel_ARR_Discount__c != null && quoteRec.Travel_Total_SAAS__c != null){
            quoteRec.Travel_ARR_Discounted__c = quoteRec.Travel_Total_SAAS__c - (quoteRec.Travel_Total_SAAS__c * quoteRec.Travel_ARR_Discount__c) / 100;
        }
        if(quoteRec.Travel_OTI_Discount__c != null && quoteRec.Travel_Total_OTI__c != null){
            quoteRec.Travel_OTI_Discounted__c = quoteRec.Travel_Total_OTI__c - (quoteRec.Travel_Total_OTI__c * quoteRec.Travel_OTI_Discount__c) / 100;
        }
        
        if(quoteRec.Expense_OTI_Discount__c != null && quoteRec.Expense_Total_OTI__c != null){
            if(DedicatedSandBoxExist==true){
                quoteRec.Expense_Total_OTI__c = quoteRec.Expense_Total_OTI__c-SubtractSandBoxPrice;
            }else if(CommonSandBoxExist==true){
                quoteRec.Expense_Total_OTI__c = quoteRec.Expense_Total_OTI__c-SubtractSandBoxPrice;
            }
            quoteRec.Expense_OTI_Discounted__c = quoteRec.Expense_Total_OTI__c - (quoteRec.Expense_Total_OTI__c * quoteRec.Expense_OTI_Discount__c)/100;
            if(quoteRec.Expense_OTI_Discounted__c!=null){
                quoteRec.Expense_OTI_Discounted__c=quoteRec.Expense_OTI_Discounted__c+SubtractSandBoxPrice;
                if(DedicatedSandBoxExist==true){
                    quoteRec.Expense_Total_OTI__c = quoteRec.Expense_Total_OTI__c+SubtractSandBoxPrice;
                }else if(CommonSandBoxExist==true){
                    quoteRec.Expense_Total_OTI__c = quoteRec.Expense_Total_OTI__c+SubtractSandBoxPrice;
                }
            }
        }
        if(quoteRec.Expense_ARR_Discount__c != null && quoteRec.Expense_Total_SAAS__c != null){
            quoteRec.Expense_ARR_Discounted__c = quoteRec.Expense_Total_SAAS__c - (quoteRec.Expense_Total_SAAS__c * quoteRec.Expense_ARR_Discount__c)/100;
        }
        
        if(quoteRec.Travel_Total_SAAS__c + quoteRec.Expense_Total_SAAS__c != 0){
            if(quoteRec.Expense_ARR_Discounted__c==null){
                quoteRec.Expense_ARR_Discounted__c=0; 
            }
            if(quoteRec.Travel_ARR_Discounted__c==null){
                quoteRec.Travel_ARR_Discounted__c=0; 
            }
            
            
            
        }
        if(quoteRec.Travel_Total_OTI__c + quoteRec.Expense_Total_OTI__c != 0){
            if(quoteRec.Expense_OTI_Discounted__c==null){
                quoteRec.Expense_OTI_Discounted__c=0; 
            }
            if(quoteRec.Travel_OTI_Discounted__c==null){
                quoteRec.Travel_OTI_Discounted__c=0; 
            }
            
        }
        update  quoteRec;
        
        
        InsertQLIOnExpense(quoteRecList);
        return quoteRec;
    }
    
    Public Static void InsertQLIOnExpense(List<QuoteLineItem>quoteRecList){
        List<PricebookEntry> priceBookEntryIdList = [Select Product2Id,name from PricebookEntry WHERE Pricebook2Id = '01s5g00000A6JplAAF'];
        
        Map<Id,Id> mapofProd2IdByEntryId = new Map<Id,Id>();
        if(!priceBookEntryIdList.isEmpty()){
            for(PricebookEntry pbe : priceBookEntryIdList){
                mapofProd2IdByEntryId.put(pbe.Product2Id,pbe.Id);
            }
        }
        QuoteCalculationHandler.InsertQuoteLineItemExpense(quoteRecList,mapofProd2IdByEntryId,'On Discount');
    }
    
}
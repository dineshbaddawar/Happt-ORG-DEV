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
            
            /*if(!quoteListTobeUpdate.isEmpty()){
                
                String ParentQuoteLineItem;
                String NestedParentProductQLIId;
                String ExpenseAccountType;
                String ExpensePricingType;
                Decimal TotalExpenseACV=0;
                
                for(Quote qc:quoteListTobeUpdate){
                    
                    List<QuoteLineItem> QliRecList=mapofQuoteIdByQLIList.get(qc.Id);
                    
                    if(!QliRecList.IsEmpty()){
                        QuoteLineItem QLIRec=new QuoteLineItem();
                        for(QuoteLineItem QLI:QliRecList){
                            
                            if(QLI.Is_Travel_Product__c==false){
                                
                                if(QLI.Parent_Quote_Line_Item__c!=null){
                                    ParentQuoteLineItem= QLI.Parent_Quote_Line_Item__c;
                                }
                                if(QLI.Product2Id!=null && QLI.Product2Id=='01tC2000000src2IAA'){//Sandboxes & Route Tracker
                                    NestedParentProductQLIId=QLI.Id;
                                } 
                                if(QLI.Account_Type__c!=null){
                                    ExpenseAccountType=QLI.Account_Type__c;
                                }
                                if(QLI.Travel_Pricing_Type__c!=null){
                                    ExpensePricingType=QLI.Travel_Pricing_Type__c;
                                }
                            }
                        }
                        if((qc.Expense_Total_SAAS__c != 0 &&  qc.Expense_Total_SAAS__c > 0)|| (qc.Expense_Total_OTI__c != 0 && qc.Expense_Total_SAAS__c > 0)){
                            TotalExpenseACV=qc.Expense_Total_SAAS__c + qc.Expense_Total_OTI__c;
                        }
                        system.debug('TotalExpenseACV--'+TotalExpenseACV); 
                        if(Integer.valueOf(TotalExpenseACV) > 7000000){
                            QLIRec.QuoteId=qc.Id;
                            QLIRec.Account_Type__c=ExpenseAccountType;
                            QLIRec.Travel_Pricing_Type__c=ExpensePricingType;
                            QLIRec.Product2Id='01tC20000008dpTIAQ';//Dedicated Sandbox Environment
                            QLIRec.Parent_Quote_Line_Item__c=ParentQuoteLineItem;
                            QLIRec.Nested_Parent_Product__c=NestedParentProductQLIId;
                            QLIRec.OTI_Price__c=1500000;
                            QLIRec.SAAS_Price__c=0;
                            QLIRec.UnitPrice=1000;
                            QLIRec.Quantity=1;
                            QLIRec.PricebookEntryId='01uC20000009xIbIAI';
                            QuoteLineToInsert.add(QLIRec);
                        }else if(Integer.valueOf(TotalExpenseACV) > 2000000){
                            QLIRec.QuoteId=qc.Id;
                            QLIRec.Account_Type__c=ExpenseAccountType;
                            QLIRec.Travel_Pricing_Type__c=ExpensePricingType;
                            QLIRec.Product2Id='01tC20000008dpSIAQ';//Common Sandbox Environment
                            QLIRec.Parent_Quote_Line_Item__c=ParentQuoteLineItem;
                            QLIRec.Nested_Parent_Product__c=NestedParentProductQLIId;
                            QLIRec.OTI_Price__c=200000;
                            QLIRec.SAAS_Price__c=0;
                            QLIRec.UnitPrice=1000;
                            QLIRec.Quantity=1;
                            QLIRec.PricebookEntryId='01uC20000009xIbIAI';
                            QuoteLineToInsert.add(QLIRec);
                        }
                    }
                }
                if(!QuoteLineToInsert.IsEmpty()){
                    Insert QuoteLineToInsert;
                }
            }*/
        }
        
    }
    
    @Auraenabled
    public static Quote calculateQuoteDiscount(Quote quoteRec){
        if(quoteRec.Travel_ARR_Discount__c != null && quoteRec.Travel_Total_SAAS__c != null){
            quoteRec.Travel_ARR_Discounted__c = quoteRec.Travel_Total_SAAS__c - (quoteRec.Travel_Total_SAAS__c * quoteRec.Travel_ARR_Discount__c) / 100;
        }
        if(quoteRec.Travel_OTI_Discount__c != null && quoteRec.Travel_Total_OTI__c != null){
            quoteRec.Travel_OTI_Discounted__c = quoteRec.Travel_Total_OTI__c - (quoteRec.Travel_Total_OTI__c * quoteRec.Travel_OTI_Discount__c) / 100;
        }
        
        if(quoteRec.Expense_OTI_Discount__c != null && quoteRec.Expense_Total_OTI__c != null){
            quoteRec.Expense_OTI_Discounted__c = quoteRec.Expense_Total_OTI__c - (quoteRec.Expense_Total_OTI__c * quoteRec.Expense_OTI_Discount__c)/100;
        }
        if(quoteRec.Expense_ARR_Discount__c != null && quoteRec.Expense_Total_SAAS__c != null){
            quoteRec.Expense_ARR_Discounted__c = quoteRec.Expense_Total_SAAS__c - (quoteRec.Expense_Total_SAAS__c * quoteRec.Expense_ARR_Discount__c)/100;
        }
        
        if(quoteRec.Travel_Total_SAAS__c + quoteRec.Expense_Total_SAAS__c != 0){
            if(quoteRec.Expense_ARR_Discounted__c==null){
                quoteRec.Expense_ARR_Discounted__c=0; 
            }
            quoteRec.Overall_ARR_Discount__c = ((quoteRec.Travel_Total_SAAS__c + quoteRec.Expense_Total_SAAS__c) - (quoteRec.Travel_ARR_Discounted__c + quoteRec.Expense_ARR_Discounted__c))/(quoteRec.Travel_Total_SAAS__c + quoteRec.Expense_Total_SAAS__c) * 100;
        }
        if(quoteRec.Travel_Total_OTI__c + quoteRec.Expense_Total_OTI__c != 0){
            if(quoteRec.Expense_OTI_Discounted__c==null){
                quoteRec.Expense_OTI_Discounted__c=0; 
            }
            quoteRec.Overall_OTI_Discount__c = ((quoteRec.Travel_Total_OTI__c + quoteRec.Expense_Total_OTI__c) - (quoteRec.Travel_OTI_Discounted__c + quoteRec.Expense_OTI_Discounted__c))/(quoteRec.Travel_Total_OTI__c + quoteRec.Expense_Total_OTI__c) * 100;
        }
        update  quoteRec;
        
        List<QuoteLineItem>quoteRecList=[Select Id,IsMultiplybyBooking__c,QuoteId,Sub_Type__c,OTI_Quantity__c,Nested_Parent_Product__c,SAAS_Quantity__c,Selected__c,Type__c,Account_Type__c,Travel_Offering_Type__c,Travel_Pricing_Type__c,SAAS_Price__c,OTI_Price__c,Product2.Name,Parent_Quote_Line_Item__c,IsOptionalProduct__c,Product2Id,Product2.Description,Quantity,ListPrice,
                                               UnitPrice,Discount,TotalPrice,Minimum_Commitment__c,Is_Travel_Product__c From QuoteLineItem Where QuoteId=:quoteRec.Id];
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
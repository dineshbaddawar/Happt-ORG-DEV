public class QuoteLineItemTrigger {
    //To Insert
    Public static void TotalCalculationOnInsert(List<QuoteLineItem> quoteRecList){
        Set<Id> quoteIdset=new set<Id>();
        
        Map<Id,Decimal> mapofQuoteIdByOTIPrice = new Map<Id,Decimal>();
        Map<Id,Decimal> mapofQuoteIdBySAASPrice = new Map<Id,Decimal>();
        
        List<Quote> quoteListTobeUpdate = new List<Quote>();
        if(quoteRecList!=null){
            for(QuoteLineItem QuoteRec:quoteRecList){
                
                quoteIdset.add(QuoteRec.QuoteId);
                
                if(QuoteRec.OTI_Price__c!=null){
                    if(mapofQuoteIdByOTIPrice.containsKey(QuoteRec.QuoteId)){
                        mapofQuoteIdByOTIPrice.put(QuoteRec.QuoteId,mapofQuoteIdByOTIPrice.get(QuoteRec.QuoteId) + QuoteRec.OTI_Price__c);
                    }else{
                        mapofQuoteIdByOTIPrice.put(QuoteRec.QuoteId,QuoteRec.OTI_Price__c);
                    }
                }
                if(QuoteRec.SAAS_Price__c!=null){
                    if(mapofQuoteIdBySAASPrice.containsKey(QuoteRec.QuoteId)){
                        mapofQuoteIdBySAASPrice.put(QuoteRec.QuoteId,mapofQuoteIdBySAASPrice.get(QuoteRec.QuoteId) + QuoteRec.SAAS_Price__c);
                    }else{
                        mapofQuoteIdBySAASPrice.put(QuoteRec.QuoteId,QuoteRec.SAAS_Price__c);
                    }
                }
            }
            
            List<QuoteLineItem> QuoteList=[Select Id,OTI_Price__c,SAAS_Price__c,QuoteId From QuoteLineItem Where QuoteId IN:quoteIdset];
            
             Map<Id,Decimal> mapofQuoteByOTIPrice = new Map<Id,Decimal>();
             Map<Id,Decimal> mapofQuoteBySAASPrice = new Map<Id,Decimal>();
            if(QuoteList!=null){
                for(QuoteLineItem QuoteRecUpdate:QuoteList){
                    if(QuoteRecUpdate.OTI_Price__c!=null){
                        if(mapofQuoteByOTIPrice.containsKey(QuoteRecUpdate.QuoteId)){
                            mapofQuoteByOTIPrice.put(QuoteRecUpdate.QuoteId,mapofQuoteByOTIPrice.get(QuoteRecUpdate.QuoteId) + QuoteRecUpdate.OTI_Price__c);
                        }else{
                            mapofQuoteByOTIPrice.put(QuoteRecUpdate.QuoteId,QuoteRecUpdate.OTI_Price__c);
                        }
                    }
                    if(QuoteRecUpdate.SAAS_Price__c!=null){
                        if(mapofQuoteBySAASPrice.containsKey(QuoteRecUpdate.QuoteId)){
                            mapofQuoteBySAASPrice.put(QuoteRecUpdate.QuoteId,mapofQuoteBySAASPrice.get(QuoteRecUpdate.QuoteId) + QuoteRecUpdate.SAAS_Price__c);
                        }else{
                            mapofQuoteBySAASPrice.put(QuoteRecUpdate.QuoteId,QuoteRecUpdate.SAAS_Price__c);
                        }
                    }
                } 
            }
            
            
            if(!mapofQuoteByOTIPrice.isEmpty()){
                for(Id mapKey : mapofQuoteByOTIPrice.keySet()){
                    Quote qu = new Quote();
                    qu.Id = mapKey;
                    qu.Total_OTI_Price__c = mapofQuoteByOTIPrice.get(mapKey);
                    if(mapofQuoteBySAASPrice.containsKey(mapKey)){
                        qu.Total_SAAS_Price__c = mapofQuoteBySAASPrice.get(mapKey);
                    }
                    quoteListTobeUpdate.add(qu);
                }
                
                if(!quoteListTobeUpdate.isEmpty()){
                    update quoteListTobeUpdate;
                }
            }
        }
    }
     //To Update
    Public static void TotalCalCulationOnUpdate(Map<Id,QuoteLineItem> newMap,Map<Id,QuoteLineItem>OldMap){
         Set<Id> quoteIdset=new set<Id>();
         Map<Id,Decimal> mapofQuoteIdByOTIPrice = new Map<Id,Decimal>();
        Map<Id,Decimal> mapofQuoteIdBySAASPrice = new Map<Id,Decimal>();
        List<Quote> quoteListTobeUpdate = new List<Quote>();
        for(QuoteLineItem QuoteRec:newMap.values()){
            if(OldMap!=null){
                if(OldMap.containsKey(QuoteRec.Id)){
                    quoteIdset.add(QuoteRec.QuoteId);
                    if(OldMap.get(QuoteRec.Id).OTI_Price__c!=null && OldMap.get(QuoteRec.Id).OTI_Price__c!=newMap.get(QuoteRec.Id).OTI_Price__c){
                         
                        if(newMap.get(QuoteRec.Id).OTI_Price__c!=null){
                            if(mapofQuoteIdByOTIPrice.containsKey(QuoteRec.QuoteId)){
                                mapofQuoteIdByOTIPrice.put(QuoteRec.QuoteId,mapofQuoteIdByOTIPrice.get(QuoteRec.QuoteId) + QuoteRec.OTI_Price__c);
                            }else{
                                mapofQuoteIdByOTIPrice.put(QuoteRec.QuoteId,newMap.get(QuoteRec.Id).OTI_Price__c);
                            }
                        }
                        
                        
                    }else if(OldMap.get(QuoteRec.Id).OTI_Price__c!=null && OldMap.get(QuoteRec.Id).OTI_Price__c==newMap.get(QuoteRec.Id).OTI_Price__c){
                        
                           if(OldMap.get(QuoteRec.Id).OTI_Price__c!=null){
                            if(mapofQuoteIdByOTIPrice.containsKey(QuoteRec.QuoteId)){
                                mapofQuoteIdByOTIPrice.put(QuoteRec.QuoteId,mapofQuoteIdByOTIPrice.get(QuoteRec.QuoteId) + QuoteRec.OTI_Price__c);
                            }else{
                                mapofQuoteIdByOTIPrice.put(QuoteRec.QuoteId,OldMap.get(QuoteRec.Id).OTI_Price__c);
                            }
                        }                        
                    }
                    
                    if(OldMap.get(QuoteRec.Id).SAAS_Price__c!=null && OldMap.get(QuoteRec.Id).SAAS_Price__c!=newMap.get(QuoteRec.Id).SAAS_Price__c){
                         
                        if(newMap.get(QuoteRec.Id).SAAS_Price__c!=null){
                            if(mapofQuoteIdBySAASPrice.containsKey(QuoteRec.QuoteId)){
                                mapofQuoteIdBySAASPrice.put(QuoteRec.QuoteId,mapofQuoteIdBySAASPrice.get(QuoteRec.QuoteId) + QuoteRec.SAAS_Price__c);
                            }else{
                                mapofQuoteIdBySAASPrice.put(QuoteRec.QuoteId,newMap.get(QuoteRec.Id).SAAS_Price__c);
                            }
                        }
                        
                        
                    }else if(OldMap.get(QuoteRec.Id).SAAS_Price__c!=null && OldMap.get(QuoteRec.Id).SAAS_Price__c==newMap.get(QuoteRec.Id).SAAS_Price__c){
                        
                           if(OldMap.get(QuoteRec.Id).SAAS_Price__c!=null){
                            if(mapofQuoteIdBySAASPrice.containsKey(QuoteRec.QuoteId)){
                                mapofQuoteIdBySAASPrice.put(QuoteRec.QuoteId,mapofQuoteIdBySAASPrice.get(QuoteRec.QuoteId) + QuoteRec.SAAS_Price__c);
                            }else{
                                mapofQuoteIdBySAASPrice.put(QuoteRec.QuoteId,OldMap.get(QuoteRec.Id).SAAS_Price__c);
                            }
                        }                        
                    }
                }
                        
            }
            
        }
        
        List<QuoteLineItem> QuoteList=[Select Id,OTI_Price__c,SAAS_Price__c,QuoteId,Product2.Is_Travel_Product__c From QuoteLineItem Where QuoteId IN:quoteIdset];
        
             Map<Id,Decimal> mapofQuoteByOTIPrice = new Map<Id,Decimal>();
             Map<Id,Decimal> mapofQuoteBySAASPrice = new Map<Id,Decimal>();
            if(QuoteList!=null){
                for(QuoteLineItem QuoteRecUpdate:QuoteList){
                    if(QuoteRecUpdate.OTI_Price__c!=null){
                        if(mapofQuoteByOTIPrice.containsKey(QuoteRecUpdate.QuoteId)){
                            mapofQuoteByOTIPrice.put(QuoteRecUpdate.QuoteId,mapofQuoteByOTIPrice.get(QuoteRecUpdate.QuoteId) + QuoteRecUpdate.OTI_Price__c);
                        }else{
                            mapofQuoteByOTIPrice.put(QuoteRecUpdate.QuoteId,QuoteRecUpdate.OTI_Price__c);
                        }
                    }
                    if(QuoteRecUpdate.SAAS_Price__c!=null){
                        if(mapofQuoteBySAASPrice.containsKey(QuoteRecUpdate.QuoteId)){
                            mapofQuoteBySAASPrice.put(QuoteRecUpdate.QuoteId,mapofQuoteBySAASPrice.get(QuoteRecUpdate.QuoteId) + QuoteRecUpdate.SAAS_Price__c);
                        }else{
                            mapofQuoteBySAASPrice.put(QuoteRecUpdate.QuoteId,QuoteRecUpdate.SAAS_Price__c);
                        }
                    }
                } 
            }
        
         if(!mapofQuoteByOTIPrice.isEmpty()){
                for(Id mapKey : mapofQuoteByOTIPrice.keySet()){
                    Quote qu = new Quote();
                    qu.Id = mapKey;
                    qu.Total_OTI_Price__c = mapofQuoteByOTIPrice.get(mapKey);
                    if(mapofQuoteBySAASPrice.containsKey(mapKey)){
                        qu.Total_SAAS_Price__c = mapofQuoteBySAASPrice.get(mapKey);
                    }
                    quoteListTobeUpdate.add(qu);
                }
                
                if(!quoteListTobeUpdate.isEmpty()){
                    update quoteListTobeUpdate;
                }
            }
        
        
    }
    //To Delete
    Public static void UpdatequoteAfterDelete(List<QuoteLineItem> quoteRecList){
        System.debug('Delete Trigger ===> '+quoteRecList);
        set<Id> quoteIdRec=new set<Id>();
        system.debug('q::'+quoteRecList);
        for(QuoteLineItem q:quoteRecList){
            quoteIdRec.add(q.QuoteId);
        }
        system.debug('quoteIdRec::'+quoteIdRec);
        List<QuoteLineItem> QuoteList	= new List<QuoteLineItem>();
            QuoteList = [Select Id,OTI_Price__c,SAAS_Price__c,Minimum_Commitment__c,IsMultiplybyBooking__c,QuoteId,Is_Travel_Product__c,Product2.Is_Travel_Product__c,Quantity_0__c From QuoteLineItem Where QuoteId IN:quoteIdRec];
        
        system.debug('QuoteList::'+QuoteList);
        system.debug('QuoteList Size::'+QuoteList.size());
        
        Map<Id,Decimal> mapofQuoteIdByTravelTotalOTIPrice = new Map<Id,Decimal>();
        Map<Id,Decimal> mapofQuoteIdByTravelTotalSAASPrice = new Map<Id,Decimal>();
        
        Map<Id,Decimal> mapofQuoteIdByExpenseTotalOTIPrice = new Map<Id,Decimal>();
        Map<Id,Decimal> mapofQuoteIdByExpenseTotalSAASPrice = new Map<Id,Decimal>();
        Map<Id,Decimal> mapofQuoteIdByNoOfBookings=new Map<Id,Decimal>();
        
        List<Quote> quoteListTobeUpdate = new List<Quote>();
        List<Quote> ExpensequoteListTobeUpdate = new List<Quote>();
        
        Decimal NoOfBookings;
        system.debug('QuoteList::'+QuoteList);
        
        if(!QuoteList.isEmpty()){
            
            system.debug('inside not null');
            
            for(QuoteLineItem QuoteRec:QuoteList){
                
                if(QuoteRec.IsMultiplybyBooking__c==true && QuoteRec.Minimum_Commitment__c!=null){ 
                    if(mapofQuoteIdByNoOfBookings.containsKey(QuoteRec.QuoteId)){
                        NoOfBookings=QuoteRec.Minimum_Commitment__c;
                        if(mapofQuoteIdByNoOfBookings.get(QuoteRec.QuoteId)!=NoOfBookings){
                            mapofQuoteIdByNoOfBookings.put(QuoteRec.QuoteId,mapofQuoteIdByNoOfBookings.get(QuoteRec.QuoteId)+NoOfBookings); 
                        }
                    }else{
                       mapofQuoteIdByNoOfBookings.put(QuoteRec.QuoteId,QuoteRec.Minimum_Commitment__c); 
                    } 
                }
                
                system.debug('QuoteRec.OTI_Price__c-->'+QuoteRec.OTI_Price__c);
                
                if(QuoteRec.OTI_Price__c!=null && (QuoteRec.Is_Travel_Product__c==true || QuoteRec.Product2.Is_Travel_Product__c==true) && QuoteRec.Quantity_0__c==false){
                    if(mapofQuoteIdByTravelTotalOTIPrice.containsKey(QuoteRec.QuoteId)){
                        mapofQuoteIdByTravelTotalOTIPrice.put(QuoteRec.QuoteId,mapofQuoteIdByTravelTotalOTIPrice.get(QuoteRec.QuoteId) + QuoteRec.OTI_Price__c);
                    }else{
                        mapofQuoteIdByTravelTotalOTIPrice.put(QuoteRec.QuoteId,QuoteRec.OTI_Price__c);
                    }
                }else if(QuoteRec.OTI_Price__c!=null && (QuoteRec.Is_Travel_Product__c==false || QuoteRec.Product2.Is_Travel_Product__c==false) && QuoteRec.Quantity_0__c==false){
                    
                    if(mapofQuoteIdByExpenseTotalOTIPrice.containsKey(QuoteRec.QuoteId)){
                        mapofQuoteIdByExpenseTotalOTIPrice.put(QuoteRec.QuoteId,mapofQuoteIdByExpenseTotalOTIPrice.get(QuoteRec.QuoteId) + QuoteRec.OTI_Price__c);
                    }else{
                        mapofQuoteIdByExpenseTotalOTIPrice.put(QuoteRec.QuoteId,QuoteRec.OTI_Price__c);
                    }
                    
                }
                
                system.debug('QuoteRec.SAAS_Price__c-->'+QuoteRec.SAAS_Price__c);
                if(QuoteRec.SAAS_Price__c!=null && (QuoteRec.Is_Travel_Product__c==true || QuoteRec.Product2.Is_Travel_Product__c==true) && QuoteRec.Quantity_0__c==false){
                    if(mapofQuoteIdByTravelTotalSAASPrice.containsKey(QuoteRec.QuoteId)){
                        mapofQuoteIdByTravelTotalSAASPrice.put(QuoteRec.QuoteId,mapofQuoteIdByTravelTotalSAASPrice.get(QuoteRec.QuoteId) + QuoteRec.SAAS_Price__c);
                    }else{
                        mapofQuoteIdByTravelTotalSAASPrice.put(QuoteRec.QuoteId,QuoteRec.SAAS_Price__c);
                    }
                }else if(QuoteRec.SAAS_Price__c!=null && (QuoteRec.Is_Travel_Product__c==false || QuoteRec.Product2.Is_Travel_Product__c==false) && QuoteRec.Quantity_0__c==false){
                    
                    if(mapofQuoteIdByExpenseTotalSAASPrice.containsKey(QuoteRec.QuoteId)){
                        
                        mapofQuoteIdByExpenseTotalSAASPrice.put(QuoteRec.QuoteId,mapofQuoteIdByExpenseTotalSAASPrice.get(QuoteRec.QuoteId) + QuoteRec.SAAS_Price__c);
                        
                    }else{
                        mapofQuoteIdByExpenseTotalSAASPrice.put(QuoteRec.QuoteId,QuoteRec.SAAS_Price__c);
                    }
                }
            }
            system.debug('mapofQuoteIdByTravelTotalOTIPrice--->'+mapofQuoteIdByTravelTotalOTIPrice);
             system.debug('mapofQuoteIdByTravelTotalSAASPrice--->'+mapofQuoteIdByTravelTotalSAASPrice);
            
            system.debug('mapofQuoteIdByExpenseTotalOTIPrice--->'+mapofQuoteIdByExpenseTotalOTIPrice);
             system.debug('mapofQuoteIdByExpenseTotalSAASPrice--->'+mapofQuoteIdByExpenseTotalSAASPrice);
            
            set<Id> QuoteIdTosetZero=new set<Id>();
            List<QuoteLineItem> ExpenseProd=new List<QuoteLineItem>();
            List<QuoteLineItem> TravelProd=new List<QuoteLineItem>();
            
            for(QuoteLineItem QuoteItemRec:QuoteList){
                if(QuoteItemRec.Is_Travel_Product__c==false){
                    if(QuoteItemRec.Product2.Is_Travel_Product__c==false){
                        ExpenseProd.add(QuoteItemRec);  
                    } 
                }else if(QuoteItemRec.Is_Travel_Product__c==true || QuoteItemRec.Product2.Is_Travel_Product__c==true){
                    TravelProd.add(QuoteItemRec);
                }
            }
            List<Quote> QuotesToUpadteAfterTravelXExpendeDelete=new List<Quote>(); 
            if(!ExpenseProd.isEmpty()){
                system.debug('No need To Make Zero');
            }else{
                for(string qid:quoteIdRec){
                    Quote quToUpdate = new Quote();
                    quToUpdate.Id=qid;
                    quToUpdate.Expense_ARR_Discount__c 		= 0;
                    quToUpdate.Expense_OTI_Discount__c 		= 0;
                    quToUpdate.Expense_ARR_Discounted__c    = 0;
                    quToUpdate.Expense_OTI_Discounted__c    = 0;
                    quToUpdate.Expense_Total_OTI__c         = 0;
                    quToUpdate.Expense_Total_SAAS__c        = 0;
                    QuotesToUpadteAfterTravelXExpendeDelete.add(quToUpdate);
                }
               Update QuotesToUpadteAfterTravelXExpendeDelete;
            }
            
             if(!TravelProd.isEmpty()){
                system.debug('No need To Make Zero'); 
            }else{
                for(string qid:quoteIdRec){
                    Quote quToUpdate = new Quote();
                    quToUpdate.Id=qid;
                    quToUpdate.Total_OTI_Price__c			= 0;
                    quToUpdate.Total_SAAS_Price__c			= 0;
                    quToUpdate.Travel_Total_OTI__c			= 0;
                    quToUpdate.Travel_Total_SAAS__c			= 0;
                    quToUpdate.Travel_ARR_Discounted__c 	= 0;
                    quToUpdate.Travel_OTI_Discounted__c 	= 0;
                    quToUpdate.Travel_ARR_Discount__c 		= 0;
                    quToUpdate.Travel_OTI_Discount__c 		= 0;
                    QuotesToUpadteAfterTravelXExpendeDelete.add(quToUpdate);
                }
               Update QuotesToUpadteAfterTravelXExpendeDelete;
            } 
            
            //For Travel OTI AND SAAS
            if(!mapofQuoteIdByTravelTotalOTIPrice.isEmpty()){
                
                for(Id mapKey : mapofQuoteIdByTravelTotalOTIPrice.keySet()){
                    Quote qu = new Quote();
                    qu.Id = mapKey;
                    qu.Travel_Total_OTI__c = mapofQuoteIdByTravelTotalOTIPrice.get(mapKey);
                    system.debug('qu.Total_OTI_Price__c--->'+qu.Total_OTI_Price__c);
                    if(mapofQuoteIdByTravelTotalSAASPrice.containsKey(mapKey)){
                        qu.Travel_Total_SAAS__c = mapofQuoteIdByTravelTotalSAASPrice.get(mapKey);
                        system.debug('qu.Total_SAAS_Price__c--->'+qu.Total_SAAS_Price__c);
                    }
                    quoteListTobeUpdate.add(qu);
                }
                
                if(!quoteListTobeUpdate.isEmpty()){
                    update quoteListTobeUpdate;
                }
            }
            
            
            //For Expense OTI AND SAAS
            if(!mapofQuoteIdByExpenseTotalOTIPrice.isEmpty()){
                
                for(Id mapKey : mapofQuoteIdByExpenseTotalOTIPrice.keySet()){
                    Quote qu = new Quote();
                    qu.Id = mapKey;
                    qu.Expense_Total_OTI__c = mapofQuoteIdByExpenseTotalOTIPrice.get(mapKey);
                    system.debug('qu.Expense_Total_OTI__c--->'+qu.Expense_Total_OTI__c);
                    if(mapofQuoteIdByExpenseTotalSAASPrice.containsKey(mapKey)){
                        qu.Expense_Total_SAAS__c = mapofQuoteIdByExpenseTotalSAASPrice.get(mapKey);
                        if(qu.Expense_Total_SAAS__c!=null && mapofQuoteIdByNoOfBookings.get(mapKey)!=null){
                            qu.Expense_Total_SAAS__c=qu.Expense_Total_SAAS__c*mapofQuoteIdByNoOfBookings.get(mapKey);
                        }
                        system.debug('qu.Expense_Total_SAAS__c--->'+qu.Expense_Total_SAAS__c); 
                    }
                    ExpensequoteListTobeUpdate.add(qu);
                }
                
                if(!ExpensequoteListTobeUpdate.isEmpty()){
                    update ExpensequoteListTobeUpdate;
                }
            }
            
        }else{
            system.debug('inisde null::');
            for(string qid:quoteIdRec){
                Quote quToUpdate = new Quote();
                quToUpdate.id=qid;
                quToUpdate.Total_OTI_Price__c			= 0;
                quToUpdate.Total_SAAS_Price__c			= 0;
                quToUpdate.Travel_Total_OTI__c			= 0;
                quToUpdate.Travel_Total_SAAS__c			= 0;
                quToUpdate.Travel_ARR_Discounted__c 	= 0;
                quToUpdate.Travel_OTI_Discounted__c 	= 0;
                quToUpdate.Expense_ARR_Discount__c 		= 0;
                quToUpdate.Expense_OTI_Discount__c 		= 0;
                quToUpdate.Travel_ARR_Discount__c 		= 0;
                quToUpdate.Travel_OTI_Discount__c 		= 0;
                quToUpdate.Expense_ARR_Discounted__c    = 0;
                quToUpdate.Expense_OTI_Discounted__c    = 0;
                quToUpdate.Expense_Total_OTI__c         = 0;
                quToUpdate.Expense_Total_SAAS__c        = 0;       
                quoteListTobeUpdate.add(quToUpdate);
            } 
        }
        update quoteListTobeUpdate;
        UpdateOpportunity.Quote_Related_OpportunityUpdate(quoteIdRec);
    }   
}
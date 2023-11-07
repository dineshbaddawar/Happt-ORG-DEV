public class ProductConfiguration {
    public Static childWrapper wrapperTobeReturn = new childWrapper();
    
    @AuraEnabled 
    public static List<QuoteLineItem> getChildqli(Id qliId){
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        qliList = [Select Id,Quantity,discount,SAAS_Price__c,Product_Name__c,OTI_Price__c,Travel_Offering_Type__c,Sub_Type__c,Type__c,Option_Product__c,Parent_Quote_Line_Item__c     from QuoteLineItem where Parent_Quote_Line_Item__c  = :qliId];
        return qliList;
    }
    
    @AuraEnabled
    public static childWrapper editLineItems(QuoteLineItem bundleQLI){
        return ProductQuoteCalculator.editQLI(bundleQLI);
    }
    
    @AuraEnabled
    public static List<QuoteLineItem> getBundleProducts(Id quoteId){
        return [select id,Product_Name__c,Travel_Offering_Type__c,Travel_Pricing_Type__c,Account_Type__c from QuoteLineItem where quoteId =: quoteId and bundle_product__c = true];
    }
    
    @AuraEnabled    
    public static childWrapper fetchQuoteDetailsAndQLIs(Id QuoteId){
        quoteDetailWrapper qdtw = new quoteDetailWrapper();
        Map<Id,List<QuoteLineItem>> mapofProdIdByParentLoop = new Map<Id,List<QuoteLineItem>>();
         Map<Id,List<QuoteLineItem>> mapofProdIdByChildLoop = new Map<Id,List<QuoteLineItem>>();
        wrapperTobeReturn.mapOfNestedProdIdByListOfPLDTobeReturn 	= new Map<Id,List<quotelineItem>>();
        wrapperTobeReturn.availableQuoteLineList = new list<QuoteLineItem>();
        wrapperTobeReturn.bundleQLIList = new list<QuoteLineItem>();
        wrapperTobeReturn.bundleQLIList = [select id,Product_Name__c,Travel_Offering_Type__c,Travel_Pricing_Type__c,Account_Type__c,Product2Id from QuoteLineItem where quoteId =: quoteId and bundle_product__c = true];
            List<QuoteLineItem> QLIItems = [Select Id,Quantity,discount,SAAS_Price__c,Product_Name__c,OTI_Price__c,Travel_Offering_Type__c,Sub_Type__c,Type__c,Option_Product__c,Parent_Quote_Line_Item__c,product2.Name,Parent_Quote_Line_Item__r.Bundle_Product__c     from QuoteLineItem where QuoteId  = :QuoteId and Bundle_Product__c = false];
        
        Quote oppDetails = [Select Id ,Name ,Opportunity.Name,Oppo_Acc__c,Account.Name,OTI_Discount__c,SAAS_Discount__c,Total_OTI__c,Total_SAAS__c from Quote where id = :QuoteId];
        
        qdtw.QuoteLineItemList = QLIItems;
        wrapperTobeReturn.quoteRecDetails = oppDetails;
        
        for(QuoteLineItem qli : QLIItems){
            
            if(qli.Parent_Quote_Line_Item__c != null && qli.Parent_Quote_Line_Item__r.Bundle_Product__c == false){
                if(mapofProdIdByChildLoop.containsKey(qli.Parent_Quote_Line_Item__c)){
                    mapofProdIdByChildLoop.get(qli.Parent_Quote_Line_Item__c).add(qli);
                }else{
                    mapofProdIdByChildLoop.put(qli.Parent_Quote_Line_Item__c,new list<QuoteLineItem>{qli});
                }
            }else{
                wrapperTobeReturn.availableQuoteLineList.add(qli);
            }
        }
        
        wrapperTobeReturn.mapOfNestedProdIdByListOfPLDTobeReturn = mapofProdIdByChildLoop;
        
        return wrapperTobeReturn;
    }
    
    
    @AuraEnabled    
    public static childWrapper fetchProductAndProductBundle(Id productId,QuoteLineItem sampleQuoteLineItem){
        system.debug('productId'+productId);
        system.debug('sampleQuoteLineItem'+sampleQuoteLineItem);
        //quotelineitem bundleQLI = new quotelineitem();
        wrapperTobeReturn.bundleQLI = new quotelineitem();
        wrapperTobeReturn.bundleQLI.Quantity = 1;
        wrapperTobeReturn.bundleQLI.Account_Type__c = sampleQuoteLineItem.Account_Type__c;
        wrapperTobeReturn.bundleQLI.UnitPrice		 	= 50;
        wrapperTobeReturn.bundleQLI.Is_Editable__c	= false;
        wrapperTobeReturn.bundleQLI.Product2Id		= productId;
        wrapperTobeReturn.bundleQLI.Product_Name__c	= 'New Expense Product';
        wrapperTobeReturn.bundleQLI.QuoteId			= '0Q0C20000001iILKAY';
        if(sampleQuoteLineItem.Travel_Offering_Type__c != null){
            wrapperTobeReturn.bundleQLI.Travel_Offering_Type__c = sampleQuoteLineItem.Travel_Offering_Type__c;
        }
        if(sampleQuoteLineItem.Travel_Pricing_Type__c != null){
            wrapperTobeReturn.bundleQLI.Travel_Pricing_Type__c = sampleQuoteLineItem.Travel_Pricing_Type__c;
        }
        
        
        List<Product_Lookup_Data__c> listOfPLD 									= new List<Product_Lookup_Data__c>();
        List<Product_Rule_Conditions__c> lisOfPRC								= new List<Product_Rule_Conditions__c>();
        Map<Id,List<Product_Lookup_Data__c>> mapOfProdIdbyListOfPLD 			= new Map<Id,List<Product_Lookup_Data__c>>();
        Map<Id,List<Product_Lookup_Data__c>> mapOfNestedProdIdByListOfPLD		= new Map<Id,List<Product_Lookup_Data__c>>();
        
        lisOfPRC 	= ProductConfigurationModal.returnActiveProductRule(productId);
        listOfPLD 	= ProductConfigurationModal.fetchProductLookupData(productId);
        
        if(!listOfPLD.isEmpty()){
            for(Product_Lookup_Data__c pldData : listOfPLD){
                if(mapOfProdIdbyListOfPLD.containsKey(pldData.Bundle_Product__c) && pldData.Parent_Product__c == null){
                    mapOfProdIdbyListOfPLD.get(pldData.Bundle_Product__c).add(pldData);
                }else if(pldData.Parent_Product__c == null){
                    mapOfProdIdbyListOfPLD.put(pldData.Bundle_Product__c,new list<Product_Lookup_Data__c>{pldData});
                }
                
                if(pldData.Parent_Product__c != null){
                    if(mapOfNestedProdIdByListOfPLD.containsKey(pldData.Parent_Product__c)){
                        mapOfNestedProdIdByListOfPLD.get(pldData.Parent_Product__c).add(pldData);
                    }else{
                        mapOfNestedProdIdByListOfPLD.put(pldData.Parent_Product__c,new List<Product_Lookup_Data__c>{pldData});
                    }
                }
            }
            if(lisOfPRC.isEmpty()){
                mappingQuotelineItemRecords(mapOfProdIdbyListOfPLD,mapOfNestedProdIdByListOfPLD,productId);
            }else if(!lisOfPRC.isEmpty()){
                mappingQuotelineItemRecords(finalisedBundleProductsAfterExecutionCriteria(mapOfProdIdbyListOfPLD,lisOfPRC,sampleQuoteLineItem),mapOfNestedProdIdByListOfPLD,productId);
            }
        }
        system.debug('wrapperTobeReturn.mapOfProdIdbyListOfPLDTobeReturn::'+wrapperTobeReturn.mapOfProdIdbyListOfPLDTobeReturn);
        system.debug('wrapperTobeReturn.mapOfNestedProdIdByListOfPLDTobeReturn::'+wrapperTobeReturn.mapOfNestedProdIdByListOfPLDTobeReturn);
        return wrapperTobeReturn;
    }
    
    public static Map<Id,List<Product_Lookup_Data__c>> finalisedBundleProductsAfterExecutionCriteria(Map<Id,List<Product_Lookup_Data__c>> mapOfProdIdbyListOfPLD,List<Product_Rule_Conditions__c> lisOfPRC, QuoteLineItem sampleQuoteLineItem){
        Map<Id,List<Product_Rule_Conditions__c>> mapOfproductIdByListOfPRC 		= new Map<Id,List<Product_Rule_Conditions__c>>();
        Map<Id,List<Product_Lookup_Data__c>> mapofProdIdByPLDList				= new Map<Id,List<Product_Lookup_Data__c>>();
        Map<Id,String> mapofPRIdByPRRules									 	= new Map<Id,String>();
        Map<Id,String> mapofTempPRIByPRRules									= new Map<Id,String>();
        
        if(!lisOfPRC.isEmpty()){
            for(Product_Rule_Conditions__c prcRec : lisOfPRC){
                mapofPRIdByPRRules.put(prcRec.Product_Rule__c,prcRec.Product_Rule__r.Criteria__c);
                if(mapOfproductIdByListOfPRC.containsKey(prcRec.Product_Rule__r.Product__c)){
                    mapOfproductIdByListOfPRC.get(prcRec.Product_Rule__r.Product__c).add(prcRec);
                }else{
                    mapOfproductIdByListOfPRC.put(prcRec.Product_Rule__r.Product__c, new List<Product_Rule_Conditions__c>{prcRec});
                }
            }
            for(Id pldMapKey : mapOfProdIdbyListOfPLD.keySet()){
                system.debug('mapOfProdIdbyListOfPLD.get(pldMapKey)::'+mapOfProdIdbyListOfPLD.get(pldMapKey).size());
                for(Product_Lookup_Data__c pldRec : mapOfProdIdbyListOfPLD.get(pldMapKey)){
                    String booleanExpression = '';
                    system.debug('mapofPRIdByPRRules::'+mapofPRIdByPRRules);
                    for(Id mapKey : mapofPRIdByPRRules.keySet()){
                        mapofTempPRIByPRRules.put(mapKey,mapofPRIdByPRRules.get(mapKey));
                    }
                    //mapofTempPRIByPRRules = mapofPRIdByPRRules;
                    system.debug('mapofTempPRIByPRRules::'+mapofTempPRIByPRRules);
                    
                    for(Product_Rule_Conditions__c prcRec : mapOfproductIdByListOfPRC.get(pldMapKey)){
                        system.debug('sampleQuoteLineItem.get(prcRec.Quote_Line_Field_API_Name__c)::'+sampleQuoteLineItem.get(prcRec.Quote_Line_Field_API_Name__c));
                        system.debug('pldRec.get(prcRec.Lookup_Object_Field_API_Name__c)::'+pldRec.get(prcRec.Lookup_Object_Field_API_Name__c));
                        if(sampleQuoteLineItem.get(prcRec.Quote_Line_Field_API_Name__c) == pldRec.get(prcRec.Lookup_Object_Field_API_Name__c)){
                            system.debug('mapofPRIdByPRRules.get(prcRec.Product_Rule__c)::'+mapofTempPRIByPRRules.get(prcRec.Product_Rule__c));
                            system.debug('prcRec.Sequence__c::'+prcRec.Sequence__c);
                            booleanExpression = mapofTempPRIByPRRules.get(prcRec.Product_Rule__c).replace(String.valueOf(prcRec.Sequence__c),'True');
                            mapofTempPRIByPRRules.put(prcRec.Product_Rule__c,booleanExpression);
                        }else{
                            booleanExpression = mapofTempPRIByPRRules.get(prcRec.Product_Rule__c).replace(String.valueOf(prcRec.Sequence__c),'False');
                            mapofTempPRIByPRRules.put(prcRec.Product_Rule__c,booleanExpression);
                        }
                    }
                    system.debug('booleanExpression::'+booleanExpression);
                    if(BooleanExpressionCalculation.evaluateExpression(booleanExpression)){
                        if(mapofProdIdByPLDList.containsKey(pldRec.Bundle_Product__c)){
                            mapofProdIdByPLDList.get(pldRec.Bundle_Product__c).add(pldRec);
                        }else{
                            mapofProdIdByPLDList.put(pldRec.Bundle_Product__c,new List<Product_Lookup_Data__c>{pldRec});
                        }
                    }
                }
            }
        }
        return mapofProdIdByPLDList;
    }
    
    public static void mappingQuotelineItemRecords(Map<Id,List<Product_Lookup_Data__c>> mapofProdIdByPLDList,Map<Id,List<Product_Lookup_Data__c>> mapOfNestedProdIdByListOfPLD,Id bundleProdId){
        
        wrapperTobeReturn.mapOfNestedProdIdByListOfPLDTobeReturn 	= new Map<Id,List<quotelineItem>>();
        wrapperTobeReturn.mapOfProdIdbyListOfPLDTobeReturn 			= new Map<Id,List<quotelineItem>>();
        Map<Id,List<quotelineItem>> mapofProdIdByQLI 				= new Map<Id,List<quotelineItem>>();
        Map<Id,List<quotelineItem>> mapofProdIdByQLINestedMap 		= new Map<Id,List<quotelineItem>>();
        for(Id mapKey : mapofProdIdByPLDList.keySet()){
            for(Product_Lookup_Data__c pldRec : mapofProdIdByPLDList.get(mapKey)){
                quotelineItem qli = new quotelineItem();
                qli.Product2Id	= pldRec.Product__c;
                qli.Travel_Offering_Type__c	= pldRec.Travel_Offering_Type__c;
                qli.Selected__c				= pldRec.Selected__c;
                qli.Type__c					= pldRec.Type__c;
                qli.Product_Name__c         = pldRec.Product__r.Name;
                qli.Account_Type__c			= pldRec.Account_Type__c;
                qli.Is_Editable__c          = false;
                qli.Quantity			= 1; 
                qli.Parent_Quote_Line_Item__c = bundleProdId;
                if(pldRec.SAAS_Price__c == null){
                    pldRec.SAAS_Price__c = 0;
                }
                qli.SAAS_Price__c				= pldRec.SAAS_Price__c;
                
                if(pldRec.OTI_Price__c == null){
                    pldRec.OTI_Price__c = 0;
                }
                qli.OTI_Price__c				= pldRec.OTI_Price__c;
                if(pldRec.OTI_API_Pricing__c == null){
                    pldRec.OTI_API_Pricing__c = 0;
                }
                qli.OTI_API_Pricing__c			= pldRec.OTI_API_Pricing__c;
                if(pldRec.OTI_Custome_API_Price__c == null){
                    pldRec.OTI_Custome_API_Price__c = 0;
                }
                qli.OTI_Custom_API_Price__c		= pldRec.OTI_Custome_API_Price__c;
                if(pldRec.OTI_Elite_Pricing__c == null){
                    pldRec.OTI_Elite_Pricing__c = 0;
                }
                qli.OTI_Elite_Pricing__c		= pldRec.OTI_Elite_Pricing__c;
                if(pldRec.OTI_Elite_Pricing__c == null){
                    pldRec.OTI_Elite_Pricing__c = 0;
                }
                qli.OTI_Premium_Pricing__c		= pldRec.OTI_Premium_Pricing__c;
                if(pldRec.OTI_Pro_Pricing__c == null){
                    pldRec.OTI_Pro_Pricing__c = 0;
                }
                qli.OTI_Pro_Pricing__c			= pldRec.OTI_Pro_Pricing__c;
                if(pldRec.OTI_SFTP_Pricing__c == null){
                    pldRec.OTI_SFTP_Pricing__c = 0;
                }
                qli.OTI_SFTP_Pricing__c			= pldRec.OTI_SFTP_Pricing__c;
                if(pldRec.SAAS_API_Pricing__c == null){
                    pldRec.SAAS_API_Pricing__c = 0;
                }
                qli.SAAS_API_Pricing__c			= pldRec.SAAS_API_Pricing__c;
                if(pldRec.SAAS_Custome_API_Pricing__c == null){
                    pldRec.SAAS_Custome_API_Pricing__c = 0;
                }
                qli.SAAS_Custom_API_Pricing__c	= pldRec.SAAS_Custome_API_Pricing__c;
                if(pldRec.SAAS_Elite_Pricing__c == null){
                    pldRec.SAAS_Elite_Pricing__c = 0;
                }
                qli.SAAS_Elite_Pricing__c		= pldRec.SAAS_Elite_Pricing__c;
                if(pldRec.SAAS_Premium_Pricing__c == null){
                    pldRec.SAAS_Premium_Pricing__c = 0;
                }
                qli.SAAS_Premium_Pricing__c		= pldRec.SAAS_Premium_Pricing__c;
                if(pldRec.SAAS_Pro_Pricing__c == null){
                    pldRec.SAAS_Pro_Pricing__c = 0;
                }
                qli.SAAS_Pro_Pricing__c			= pldRec.SAAS_Pro_Pricing__c;
                if(pldRec.SAAS_SFTP_Pricing__c == null){
                    pldRec.SAAS_SFTP_Pricing__c = 0;
                }
                qli.SAAS_SFTP_Pricing__c		= pldRec.SAAS_SFTP_Pricing__c;
                qli.Discount					= 0;
                qli.UnitPrice					= qli.OTI_Price__c;
                if(mapofProdIdByQLI.containsKey(mapKey)){
                    mapofProdIdByQLI.get(mapKey).add(qli);
                }else{
                    mapofProdIdByQLI.put(mapKey,new List<quotelineItem> {qli});
                }
            }
        }
        wrapperTobeReturn.mapOfProdIdbyListOfPLDTobeReturn = mapofProdIdByQLI;
        for(Id mapKey : mapOfNestedProdIdByListOfPLD.keySet()){
            for(Product_Lookup_Data__c pldRec : mapOfNestedProdIdByListOfPLD.get(mapKey)){
                system.debug('pldRec::'+pldRec);
                quotelineItem qli = new quotelineItem();
                qli.Product2Id	= pldRec.Product__c;
                qli.Travel_Offering_Type__c	  = pldRec.Travel_Offering_Type__c;
                qli.Selected__c				  = pldRec.Selected__c;
                qli.Type__c					  = pldRec.Type__c;
                qli.Product_Name__c           = pldRec.Product__r.Name;
                qli.Parent_Quote_Line_Item__c = mapKey;
                qli.Is_Editable__c            = false;
                qli.Quantity			= 1;  
                
                if(pldRec.SAAS_Price__c == null){
                    pldRec.SAAS_Price__c = 0;
                }
                qli.SAAS_Price__c				= pldRec.SAAS_Price__c;
                
                if(pldRec.OTI_Price__c == null){
                    pldRec.OTI_Price__c = 0;
                }
                qli.OTI_Price__c				= pldRec.OTI_Price__c;
                if(pldRec.OTI_API_Pricing__c == null){
                    pldRec.OTI_API_Pricing__c = 0;
                }
                qli.OTI_API_Pricing__c			= pldRec.OTI_API_Pricing__c;
                if(pldRec.OTI_Custome_API_Price__c == null){
                    pldRec.OTI_Custome_API_Price__c = 0;
                }
                qli.OTI_Custom_API_Price__c		= pldRec.OTI_Custome_API_Price__c;
                if(pldRec.OTI_Elite_Pricing__c == null){
                    pldRec.OTI_Elite_Pricing__c = 0;
                }
                qli.OTI_Elite_Pricing__c		= pldRec.OTI_Elite_Pricing__c;
                if(pldRec.OTI_Elite_Pricing__c == null){
                    pldRec.OTI_Elite_Pricing__c = 0;
                }
                qli.OTI_Premium_Pricing__c		= pldRec.OTI_Premium_Pricing__c;
                if(pldRec.OTI_Pro_Pricing__c == null){
                    pldRec.OTI_Pro_Pricing__c = 0;
                }
                qli.OTI_Pro_Pricing__c			= pldRec.OTI_Pro_Pricing__c;
                if(pldRec.OTI_SFTP_Pricing__c == null){
                    pldRec.OTI_SFTP_Pricing__c = 0;
                }
                qli.OTI_SFTP_Pricing__c			= pldRec.OTI_SFTP_Pricing__c;
                if(pldRec.SAAS_API_Pricing__c == null){
                    pldRec.SAAS_API_Pricing__c = 0;
                }
                qli.SAAS_API_Pricing__c			= pldRec.SAAS_API_Pricing__c;
                if(pldRec.SAAS_Custome_API_Pricing__c == null){
                    pldRec.SAAS_Custome_API_Pricing__c = 0;
                }
                qli.SAAS_Custom_API_Pricing__c	= pldRec.SAAS_Custome_API_Pricing__c;
                if(pldRec.SAAS_Elite_Pricing__c == null){
                    pldRec.SAAS_Elite_Pricing__c = 0;
                }
                qli.SAAS_Elite_Pricing__c		= pldRec.SAAS_Elite_Pricing__c;
                if(pldRec.SAAS_Premium_Pricing__c == null){
                    pldRec.SAAS_Premium_Pricing__c = 0;
                }
                qli.SAAS_Premium_Pricing__c		= pldRec.SAAS_Premium_Pricing__c;
                if(pldRec.SAAS_Pro_Pricing__c == null){
                    pldRec.SAAS_Pro_Pricing__c = 0;
                }
                qli.SAAS_Pro_Pricing__c			= pldRec.SAAS_Pro_Pricing__c;
                if(pldRec.SAAS_SFTP_Pricing__c == null){
                    pldRec.SAAS_SFTP_Pricing__c = 0;
                }
                qli.SAAS_SFTP_Pricing__c		= pldRec.SAAS_SFTP_Pricing__c;
                qli.Discount					= 0;
                qli.UnitPrice					= qli.OTI_Price__c;
                if(mapofProdIdByQLINestedMap.containsKey(mapKey)){
                    mapofProdIdByQLINestedMap.get(mapKey).add(qli);
                }else{
                    mapofProdIdByQLINestedMap.put(mapKey,new List<quotelineItem> {qli});
                }
            }
        }
        wrapperTobeReturn.mapOfNestedProdIdByListOfPLDTobeReturn = mapofProdIdByQLINestedMap;
        
        system.debug('wrapperTobeReturn.mapOfProdIdbyListOfPLDTobeReturn::'+wrapperTobeReturn.mapOfProdIdbyListOfPLDTobeReturn);
        system.debug('wrapperTobeReturn.mapOfNestedProdIdByListOfPLDTobeReturn::'+wrapperTobeReturn.mapOfNestedProdIdByListOfPLDTobeReturn);
    }
    
    @AuraEnabled    
    public static List<QuoteLineItem> calculateTravelQuoteLineItems(List<QuoteLineItem> quoteLineItemList,Boolean saveFunction,List<QuoteLineItem> bundleQLI){
        system.debug('quoteLineItemList::'+quoteLineItemList);
        system.debug('Size::'+quoteLineItemList.size());
        system.debug('bundleQLI::'+bundleQLI);
        system.debug('size::'+bundleQLI.size());
        List<PricebookEntry> priceBookEntryIdList = new List<PricebookEntry>();
        priceBookEntryIdList = [Select Product2Id,name,Id from PricebookEntry WHERE Pricebook2Id = '01s5g00000A6JplAAF'];
        Map<Id,Id> mapofProd2IdByEntryId = new Map<Id,Id>();
        Map<Id,String> mapofProductIdByName = new Map<Id,String>();
        if(!priceBookEntryIdList.isEmpty()){
            for(PricebookEntry pbe : priceBookEntryIdList){
                mapofProd2IdByEntryId.put(pbe.Product2Id,pbe.Id);
                mapofProductIdByName.put(pbe.Product2Id,pbe.Name);
            }
        }
        List<QuoteLineItem>	bundleQLITobeInsert				= new List<QuoteLineItem>();
        List<QuoteLineItem> parentQuoteLineItemTobeInsert 	= new List<QuoteLineItem>();
        List<QuoteLineItem> childQuoteLineItemTobeInsert	= new List<QuoteLineItem>();
        for(QuoteLineItem qli : bundleQLI){
            qli.PricebookEntryId =    mapofProd2IdByEntryId.get(qli.Product2Id);
        qli.Product_Name__c = mapofProductIdByName.get(qli.Product2Id);
        qli.Quantity = 1;
        qli.UnitPrice = 120;
            qli.Bundle_Product__c = true;
            bundleQLITobeInsert.add(qli);
        }
        Map<Id,Id> mapofProduct2IdByBundleQLIId = new Map<Id,Id>();
        if(bundleQLITobeInsert.size() > 0){
            List<Database.SaveResult> bundleResults = Database.insert(bundleQLITobeInsert, false);
            for(integer k =0;k<bundleResults.size();k++){
                if(bundleResults[k].isSuccess()){
                    mapofProduct2IdByBundleQLIId.put(bundleQLITobeInsert[k].Product2Id,bundleQLITobeInsert[k].Id);
                }
            }
        }
		  
        for(QuoteLineItem qli : quoteLineItemList){
            system.debug('qli.Parent_Quote_Line_Item__c::'+qli.Parent_Quote_Line_Item__c);
            system.debug('qli.Selected__c::'+qli.Selected__c);
            if(qli.Parent_Quote_Line_Item__c != null && qli.Selected__c && !mapofProduct2IdByBundleQLIId.containsKey(qli.Parent_Quote_Line_Item__c)){
                QuoteLineItem childQLI = new QuoteLineItem();
                childQLI = qli;
                childQLI.PricebookEntryId = mapofProd2IdByEntryId.get(childQLI.Product2Id);
                childQLI.Product_Name__c = mapofProductIdByName.get(childQLI.Product2Id);
                if(qli.Sub_Type__c	!= null){
                        if(qli.Sub_Type__c == 'Customer API'){
                            if(qli.OTI_Custom_API_Price__c ==null){
                                qli.OTI_Custom_API_Price__c = 0;
                            }
                            if(qli.SAAS_Custom_API_Pricing__c == null){
                                qli.SAAS_Custom_API_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_Custom_API_Price__c;
                            qli.SAAS_Price__c = qli.SAAS_Custom_API_Pricing__c;
                        }else if(qli.Sub_Type__c == 'API'){
                            if(qli.OTI_API_Pricing__c == null){
                                qli.OTI_API_Pricing__c = 0;
                            }
                            if(qli.SAAS_API_Pricing__c == null){
                                qli.SAAS_API_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_API_Pricing__c;
                            qli.SAAS_Price__c = qli.SAAS_API_Pricing__c;
                        }else if(qli.Sub_Type__c == 'SFTP'){
                            if(qli.OTI_SFTP_Pricing__c == null){
                                qli.OTI_SFTP_Pricing__c = 0;
                            }
                            if(qli.SAAS_SFTP_Pricing__c == null){
                                qli.SAAS_SFTP_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_SFTP_Pricing__c;
                            qli.SAAS_Price__c = qli.SAAS_SFTP_Pricing__c;
                        }else if(qli.Sub_Type__c == 'Elite'){
                            if(qli.OTI_Elite_Pricing__c == null){
                                qli.OTI_Elite_Pricing__c = 0;
                            }
                            if(qli.SAAS_Elite_Pricing__c == null){
                                qli.SAAS_Elite_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_Elite_Pricing__c;
                            qli.SAAS_Price__c = qli.SAAS_Elite_Pricing__c;
                        }else if(qli.Sub_Type__c == 'Premium'){
                            if(qli.OTI_Premium_Pricing__c == null){
                                qli.OTI_Premium_Pricing__c = 0;
                            }
                            if(qli.SAAS_Premium_Pricing__c == null){
                                qli.SAAS_Premium_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_Premium_Pricing__c;
                            qli.SAAS_Price__c = qli.SAAS_Premium_Pricing__c;
                        }else if(qli.Sub_Type__c == 'Pro'){
                            if(qli.OTI_Pro_Pricing__c == null){
                                qli.OTI_Pro_Pricing__c = 0;
                            }
                            if(qli.SAAS_Pro_Pricing__c == null){
                                qli.SAAS_Pro_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_Pro_Pricing__c;
                            qli.SAAS_Price__c = qli.SAAS_Pro_Pricing__c;
                        }
                    }
                    if(qli.Type__c != null && qli.Type__c == Constant.OTI_TYPE){
                        if(qli.Quantity > 1){
                            childQLI.OTI_Price__c = qli.OTI_Price__c * qli.Quantity;
                        }
                        if(qli.Discount!= null){
                            childQLI.OTI_Price__c = qli.OTI_Price__c - ((qli.OTI_Price__c * qli.Discount)/100);
                        }
                    }else if(qli.Type__c != null && qli.Type__c == Constant.SAAS_TYPE){
                        if(qli.Quantity > 1){
                            childQLI.SAAS_Price__c = qli.SAAS_Price__c * qli.Quantity;
                        }
                        if(qli.Discount!= null){
                            childQLI.SAAS_Price__c = qli.SAAS_Price__c - ((qli.SAAS_Price__c * qli.Discount)/100);
                        }
                    }else if(qli.Type__c != null && qli.Type__c == Constant.SAAS_OTI_TYPE){
                        if(qli.Multiply_Prices_Based_on_Quantity__c == Constant.OTI_TYPE){
                            childQLI.OTI_Price__c = qli.Quantity * qli.OTI_Price__c;
                            if(qli.Discount != null){
                                childQLI.OTI_Price__c = qli.OTI_Price__c - ((qli.OTI_Price__c * qli.Discount)/100);
                            }
                        }else if(qli.Multiply_Prices_Based_on_Quantity__c == Constant.SAAS_TYPE){
                            childQLI.SAAS_Price__c = qli.Quantity * qli.SAAS_Price__c;
                            if(qli.Discount != null){
                                childQLI.SAAS_Price__c = qli.SAAS_Price__c - ((qli.SAAS_Price__c * qli.Discount)/100);
                            }
                        }else if (qli.Multiply_Prices_Based_on_Quantity__c == Constant.SAAS_OTI_TYPE){
                            childQLI.SAAS_Price__c = qli.Quantity * qli.SAAS_Price__c;
                            childQLI.OTI_Price__c  = qli.Quantity  * qli.OTI_Price__c;
                            if(qli.Discount != null ){
                                childQLI.OTI_Price__c = qli.OTI_Price__c - ((qli.OTI_Price__c * qli.Discount)/100);
                                childQLI.SAAS_Price__c = qli.SAAS_Price__c - ((qli.SAAS_Price__c * qli.Discount)/100);
                            }
                        }
                    }
                childQLI.UnitPrice = childQLI.OTI_Price__c;
                childQuoteLineItemTobeInsert.add(childQLI);
                system.debug('childQLI::'+childQLI);
                system.debug('childQuoteLineItemTobeInsert:::'+childQuoteLineItemTobeInsert);
            }else if(qli.Selected__c){
                QuoteLineItem parentQLI = new QuoteLineItem();
                parentQLI = qli;
                parentQLI.PricebookEntryId = mapofProd2IdByEntryId.get(parentQLI.Product2Id);
                parentQLI.Parent_Quote_Line_Item__c = mapofProduct2IdByBundleQLIId.get(parentQLI.Parent_Quote_Line_Item__c);
                if(qli.Sub_Type__c	!= null){
                        if(qli.Sub_Type__c == 'Customer API'){
                            if(qli.OTI_Custom_API_Price__c ==null){
                                qli.OTI_Custom_API_Price__c = 0;
                            }
                            if(qli.SAAS_Custom_API_Pricing__c == null){
                                qli.SAAS_Custom_API_Pricing__c = 0;
                            }
                            parentQLI.OTI_Price__c = qli.OTI_Custom_API_Price__c;
                            qli.SAAS_Price__c = qli.SAAS_Custom_API_Pricing__c;
                        }else if(qli.Sub_Type__c == 'API'){
                            if(qli.OTI_API_Pricing__c == null){
                                qli.OTI_API_Pricing__c = 0;
                            }
                            if(qli.SAAS_API_Pricing__c == null){
                                qli.SAAS_API_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_API_Pricing__c;
                            qli.SAAS_Price__c = qli.SAAS_API_Pricing__c;
                        }else if(qli.Sub_Type__c == 'SFTP'){
                            if(qli.OTI_SFTP_Pricing__c == null){
                                qli.OTI_SFTP_Pricing__c = 0;
                            }
                            if(qli.SAAS_SFTP_Pricing__c == null){
                                qli.SAAS_SFTP_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_SFTP_Pricing__c;
                            qli.SAAS_Price__c = qli.SAAS_SFTP_Pricing__c;
                        }else if(qli.Sub_Type__c == 'Elite'){
                            if(qli.OTI_Elite_Pricing__c == null){
                                qli.OTI_Elite_Pricing__c = 0;
                            }
                            if(qli.SAAS_Elite_Pricing__c == null){
                                qli.SAAS_Elite_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_Elite_Pricing__c;
                            qli.SAAS_Price__c = qli.SAAS_Elite_Pricing__c;
                        }else if(qli.Sub_Type__c == 'Premium'){
                            if(qli.OTI_Premium_Pricing__c == null){
                                qli.OTI_Premium_Pricing__c = 0;
                            }
                            if(qli.SAAS_Premium_Pricing__c == null){
                                qli.SAAS_Premium_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_Premium_Pricing__c;
                            qli.SAAS_Price__c = qli.SAAS_Premium_Pricing__c;
                        }else if(qli.Sub_Type__c == 'Pro'){
                            if(qli.OTI_Pro_Pricing__c == null){
                                qli.OTI_Pro_Pricing__c = 0;
                            }
                            if(qli.SAAS_Pro_Pricing__c == null){
                                qli.SAAS_Pro_Pricing__c = 0;
                            }
                            qli.OTI_Price__c = qli.OTI_Pro_Pricing__c;
                            qli.SAAS_Price__c = qli.SAAS_Pro_Pricing__c;
                        }
                    }
                    if(qli.Type__c != null && qli.Type__c == Constant.OTI_TYPE){
                        if(qli.Quantity > 1){
                            parentQLI.OTI_Price__c = qli.OTI_Price__c * qli.Quantity;
                        }
                        if(qli.Discount!= null){
                            parentQLI.OTI_Price__c = qli.OTI_Price__c - ((qli.OTI_Price__c * qli.Discount)/100);
                        }
                    }else if(qli.Type__c != null && qli.Type__c == Constant.SAAS_TYPE){
                        if(qli.Quantity > 1){
                            parentQLI.SAAS_Price__c = qli.SAAS_Price__c * qli.Quantity;
                        }
                        if(qli.Discount!= null){
                            parentQLI.SAAS_Price__c = qli.SAAS_Price__c - ((qli.SAAS_Price__c * qli.Discount)/100);
                        }
                    }else if(qli.Type__c != null && qli.Type__c == Constant.SAAS_OTI_TYPE){
                        if(qli.Multiply_Prices_Based_on_Quantity__c == Constant.OTI_TYPE){
                            parentQLI.OTI_Price__c = qli.Quantity * qli.OTI_Price__c;
                            if(qli.Discount != null){
                                parentQLI.OTI_Price__c = qli.OTI_Price__c - ((qli.OTI_Price__c * qli.Discount)/100);
                            }
                        }else if(qli.Multiply_Prices_Based_on_Quantity__c == Constant.SAAS_TYPE){
                            parentQLI.SAAS_Price__c = qli.Quantity * qli.SAAS_Price__c;
                            if(qli.Discount != null){
                                parentQLI.SAAS_Price__c = qli.SAAS_Price__c - ((qli.SAAS_Price__c * qli.Discount)/100);
                            }
                        }else if (qli.Multiply_Prices_Based_on_Quantity__c == Constant.SAAS_OTI_TYPE){
                            parentQLI.SAAS_Price__c = qli.Quantity * qli.SAAS_Price__c;
                            parentQLI.OTI_Price__c  = qli.Quantity  * qli.OTI_Price__c;
                            if(qli.Discount != null ){
                                parentQLI.OTI_Price__c = qli.OTI_Price__c - ((qli.OTI_Price__c * qli.Discount)/100);
                                parentQLI.SAAS_Price__c = qli.SAAS_Price__c - ((qli.SAAS_Price__c * qli.Discount)/100);
                            }
                        }
                    }
                parentQuoteLineItemTobeInsert.add(parentQLI);
            }
        }
        List<QuoteLineItem> qliListTobeInsert 	= new List<QuoteLineItem>();
        
        system.debug('parentQuoteLineItemTobeInsert::'+parentQuoteLineItemTobeInsert);
        system.debug('childQuoteLineItemTobeInsert::'+childQuoteLineItemTobeInsert);
        Map<Id,Id> mapOfParentProdIdByQuoteId = new Map<Id,Id>();
        List<Database.SaveResult> results = Database.insert(parentQuoteLineItemTobeInsert, false);
        for(integer i =0;i<results.size();i++){
            if(results[i].isSuccess()){
                mapOfParentProdIdByQuoteId.put(parentQuoteLineItemTobeInsert[i].Product2Id,parentQuoteLineItemTobeInsert[i].Id);
            }else{
                for(Database.Error objErr : parentQuoteLineItemTobeInsert[i].getErrors()){
                    System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                    System.debug('Invoice oject field which are affected by the error:' 
                                 + objErr.getFields());
                }
            }
        }
        system.debug('mapOfParentProdIdByQuoteId::'+mapOfParentProdIdByQuoteId);
        if(!mapOfParentProdIdByQuoteId.isEmpty()){
            for(quoteLineItem qli : childQuoteLineItemTobeInsert){
                if(mapOfParentProdIdByQuoteId.containsKey(qli.Product2Id)){
                    qli.Parent_Quote_Line_Item__c = mapOfParentProdIdByQuoteId.get(qli.Product2Id);
                }
            }
        }
        system.debug('childQuoteLineItemTobeInsert::'+childQuoteLineItemTobeInsert);
       // insert childQuoteLineItemTobeInsert;
        List<Database.SaveResult> childresults = Database.insert(childQuoteLineItemTobeInsert, false);
        for(integer i =0;i<childresults.size();i++){
            if(childresults[i].isSuccess()){
                system.debug('childresults'+childresults[i].getId());
               // mapOfParentProdIdByQuoteId.put(childQuoteLineItemTobeInsert[i].Product2Id,childQuoteLineItemTobeInsert[i].Id);
            }else{
                for(Database.Error objErr : childQuoteLineItemTobeInsert[i].getErrors()){
                    System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                    System.debug('Invoice oject field which are affected by the error:' 
                                 + objErr.getFields());
                }
            }
        }
        
        return qliListTobeInsert;
    }
    
    public class quoteDetailWrapper{
        @AuraEnabled
        public List<QuoteLineItem> QuoteLineItemList;
       @AuraEnabled 
        public list<QuoteLineItem> bundleQLI;
       
    }
    public class childWrapper{
        @AuraEnabled
        public Map<Id,List<quotelineItem>> mapOfNestedProdIdByListOfPLDTobeReturn;
        @AuraEnabled
        public Map<Id,List<quotelineItem>> mapOfProdIdbyListOfPLDTobeReturn;
        @AuraEnabled
        public  list<quotelineItem> availableQuoteLineList;
         @AuraEnabled
        public Quote quoteRecDetails;
        @AUraEnabled
        public quotelineitem bundleQLI;
        @AuraEnabled 
        public list<QuoteLineItem> bundleQLIList;
    }
}
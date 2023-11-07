public class ProductQuoteCalculator {
    public Static ProductConfiguration.childWrapper wrapperTobeReturn = new ProductConfiguration.childWrapper();
    @AuraEnabled    
    public static List<QuoteLineItem> calculateTravelQuoteLineItems(List<QuoteLineItem> quoteLineItemList,Boolean saveFunction){
        List<QuoteLineItem> qliListTobeInsert 	= new List<QuoteLineItem>();
        if(!quoteLineItemList.isEmpty()){
            for(QuoteLineItem qli : quoteLineItemList){
                if(qli.Selected__c){
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
                            qli.OTI_Price__c = qli.OTI_Price__c * qli.Quantity;
                        }
                        if(qli.Discount!= null){
                            qli.OTI_Price__c = qli.OTI_Price__c - ((qli.OTI_Price__c * qli.Discount)/100);
                        }
                    }else if(qli.Type__c != null && qli.Type__c == Constant.SAAS_TYPE){
                        if(qli.Quantity > 1){
                            qli.SAAS_Price__c = qli.SAAS_Price__c * qli.Quantity;
                        }
                        if(qli.Discount!= null){
                            qli.SAAS_Price__c = qli.SAAS_Price__c - ((qli.SAAS_Price__c * qli.Discount)/100);
                        }
                    }else if(qli.Type__c != null && qli.Type__c == Constant.SAAS_OTI_TYPE){
                        if(qli.Multiply_Prices_Based_on_Quantity__c == Constant.OTI_TYPE){
                            qli.OTI_Price__c = qli.Quantity * qli.OTI_Price__c;
                            if(qli.Discount != null){
                                qli.OTI_Price__c = qli.OTI_Price__c - ((qli.OTI_Price__c * qli.Discount)/100);
                            }
                        }else if(qli.Multiply_Prices_Based_on_Quantity__c == Constant.SAAS_TYPE){
                            qli.SAAS_Price__c = qli.Quantity * qli.SAAS_Price__c;
                            if(qli.Discount != null){
                                qli.SAAS_Price__c = qli.SAAS_Price__c - ((qli.SAAS_Price__c * qli.Discount)/100);
                            }
                        }else if (qli.Multiply_Prices_Based_on_Quantity__c == Constant.SAAS_OTI_TYPE){
                            qli.SAAS_Price__c = qli.Quantity * qli.SAAS_Price__c;
                            qli.OTI_Price__c  = qli.Quantity  * qli.OTI_Price__c;
                            if(qli.Discount != null ){
                                qli.OTI_Price__c = qli.OTI_Price__c - ((qli.OTI_Price__c * qli.Discount)/100);
                                qli.SAAS_Price__c = qli.SAAS_Price__c - ((qli.SAAS_Price__c * qli.Discount)/100);
                            }
                        }
                    }
                    
                    qliListTobeInsert.add(qli);
                }
                continue;
            }
            
            if(saveFunction && qliListTobeInsert.size() > 0){
                insert qliListTobeInsert;
            }
        }
        return qliListTobeInsert;
    }
    
    
    @AuraEnabled
    public static ProductConfiguration.childWrapper editQLI(QuoteLineItem bundleQLI){
        wrapperTobeReturn = ProductConfiguration.fetchProductAndProductBundle(bundleQLI.Product2Id,bundleQLI);
        wrapperTobeReturn.availableQuoteLineList =new List<QuoteLineItem>();
        
        
        if(wrapperTobeReturn.mapOfProdIdbyListOfPLDTobeReturn != null){
            system.debug('wrapperTobeReturn.mapOfProdIdbyListOfPLDTobeReturn::'+wrapperTobeReturn.mapOfProdIdbyListOfPLDTobeReturn.size());
            for(List<QuoteLineItem> parentqliList : wrapperTobeReturn.mapOfProdIdbyListOfPLDTobeReturn.values()){
                system.debug('parentqliList::'+parentqliList.size());
                for(QuoteLineItem parentqli : parentqliList){
                    system.debug('parentqli::'+parentqli);
                    wrapperTobeReturn.availableQuoteLineList.add(parentqli);
                    
                }
            }
        }
        system.debug('wrapperTobeReturn::'+wrapperTobeReturn);
        return wrapperTobeReturn;
    }
}
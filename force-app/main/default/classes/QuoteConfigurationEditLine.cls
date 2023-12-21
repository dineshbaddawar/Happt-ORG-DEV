public class QuoteConfigurationEditLine {
    Public static Map<Id,List<Features__c>> ProdIdXFeatureRec;
    Public static Map<Id,List<Product_Lookup_Data__c>> FeatureIdXOptionRec;
    Public static Map<Id,Features__c> FeatureIdXFeatureRec;
    Public static Map<Id,Product2> ProductIdXProductRec;
@AuraEnabled
    public static List<Features__c> getAllFeaturesFromProduct(List<String> ProductIdsList){
        List<Features__c> featureList = [select id,Name,Category__c  from Features__c where ProductId__c =:ProductIdsList];
        
        return featureList;
    }
    
    @AuraEnabled
    Public Static List<Product_Lookup_Data__c> PldOptions(){
        List<Product_Lookup_Data__c> Plds=[Select Is_PUPM_Product__c,IsOtiPriceEditable__c,IsSaasPriceEditable__c,IsPrice_IsQuantity_Editable__c,Base_SAAS_Price__c,Google_Maps_SAAS__c,Google_Maps_OTI__c,Map_My_India_SAAS__c,Map_My_India_OTI__c,Base_OTI_Price__c,Is_Subtype_Editable__c,Account_Type__c,OTI_Quantity__c,SAAS_Quantity__c,OTI_Quantity_Editable__c,SAAS_Quantity_Editable__c,Bundle_Product__c,Is_Travel_Product__c,Quantity__c,Editable__c,FeatureId__c,FeatureId__r.Name,Mandatory__c,Multiply_Prices_Based_on_Quantity__c,
                                                        Offering__c,OTI_API_Pricing__c,OTI_Price__c,OTI_Custome_API_Price__c,OTI_Elite_Pricing__c,OTI_Premium_Pricing__c,OTI_Pro_Pricing__c,
                                                        OTI_SFTP_Pricing__c,Parent_Product__c,Pricing_Type__c,Product__c,Name,Product_Name__c,SAAS_API_Pricing__c,SAAS_Custome_API_Pricing__c,
                                                        SAAS_Elite_Pricing__c,SAAS_Premium_Pricing__c,SAAS_Price__c,SAAS_Pro_Pricing__c,SAAS_SFTP_Pricing__c,Selected__c,Sub_Type__c,Travel_Offering_Type__c,Type__c,Quantity_0__c
                                                        From Product_Lookup_Data__c where  Parent_Product__c != null AND IsActive__c=true];
        return Plds;
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
        
        system.debug('WrapperRecList prodFeature--'+WrapperRecList.ProductIdXFeature);
        system.debug('WrapperRecList FeatureOption--'+WrapperRecList.FeatureIdXOptionRecord);
        system.debug('WrapperRecList featureIdFeatureRecord--'+WrapperRecList.FeatureIdXFeatureRecord);
        system.debug('WrapperRecList ProdIdProdRecord--'+WrapperRecList.ProductIdXProductRecord);
        system.debug('ReturnMapWrapper--'+ReturnMapWrapper);
        return ReturnMapWrapper;
    }
    @AuraEnabled
    Public Static List<Product_Lookup_Data__c>  ShowAllOptions(List<string> ProductIds,String travelOfferingType,String travelPricingType,String accountType){
        system.debug('ProductIds === >'+ProductIds);
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
        List<Product_Lookup_Data__c> ProductOptionList=[Select Is_PUPM_Product__c,IsOtiPriceEditable__c,IsSaasPriceEditable__c,IsPrice_IsQuantity_Editable__c,Base_SAAS_Price__c,Google_Maps_SAAS__c,Google_Maps_OTI__c,Map_My_India_SAAS__c,Map_My_India_OTI__c,IsMultiplybyBooking__c,Base_OTI_Price__c,Is_Subtype_Editable__c,OTI_Quantity__c,SAAS_Quantity__c,OTI_Quantity_Editable__c,SAAS_Quantity_Editable__c,Account_Type__c,Is_Travel_Product__c,Bundle_Product__c,Quantity__c,Editable__c,FeatureId__c,FeatureId__r.Name,Mandatory__c,Multiply_Prices_Based_on_Quantity__c,
                                                        Offering__c,OTI_API_Pricing__c,OTI_Price__c,OTI_Custome_API_Price__c,OTI_Elite_Pricing__c,OTI_Premium_Pricing__c,OTI_Pro_Pricing__c,
                                                        OTI_SFTP_Pricing__c,Parent_Product__c,Pricing_Type__c,Product__c,Name,Product_Name__c,SAAS_API_Pricing__c,SAAS_Custome_API_Pricing__c,
                                                        SAAS_Elite_Pricing__c,SAAS_Premium_Pricing__c,SAAS_Price__c,SAAS_Pro_Pricing__c,SAAS_SFTP_Pricing__c,Selected__c,Sub_Type__c,Travel_Offering_Type__c,Type__c,Quantity_0__c
                                                        From Product_Lookup_Data__c where Bundle_Product__c =:ProductIds AND IsActive__c=true];
        
          system.debug('ProductOptionList Size ==== >'+ProductOptionList.size());
        List<Product_Rule_Conditions__c> lisOfPRC                               = new List<Product_Rule_Conditions__c>();
        lisOfPRC    = ProductConfigurationModal.returnActiveProductRule(ProductIds[0]);
        
        for(Product_Rule_Conditions__c prcRec : lisOfPRC){
            mapofPRIdByPRRules.put(prcRec.Product_Rule__c,prcRec.Product_Rule__r.Criteria__c);
        }
        for(Product_Lookup_Data__c pldRec : ProductOptionList){
            String booleanExpression = '';
            for(Id mapKey : mapofPRIdByPRRules.keySet()){
                        mapofTempPRIByPRRules.put(mapKey,mapofPRIdByPRRules.get(mapKey));
                    }
            for(Product_Rule_Conditions__c prcRec : lisOfPRC){
                if(sampleQuoteLineItem.get(prcRec.Quote_Line_Field_API_Name__c) == pldRec.get(prcRec.Lookup_Object_Field_API_Name__c)){
                    booleanExpression = mapofTempPRIByPRRules.get(prcRec.Product_Rule__c).replace(String.valueOf(prcRec.Sequence__c),'True');
                    mapofTempPRIByPRRules.put(prcRec.Product_Rule__c,booleanExpression);
                }else{
                    booleanExpression = mapofTempPRIByPRRules.get(prcRec.Product_Rule__c).replace(String.valueOf(prcRec.Sequence__c),'False');
                    mapofTempPRIByPRRules.put(prcRec.Product_Rule__c,booleanExpression);
                }
            }
                    if(BooleanExpressionCalculation.evaluateExpression(booleanExpression)){
                        pldTobeReturn.add(pldRec);
                    }
        }
                
        List<Features__c> FeatureRecList=[Select Name,ProductId__c,Category__c From Features__c Where ProductId__c=:ProductIds];
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
    Public class wrapperClass{
        Map<Id,List<Features__c>> ProductIdXFeature{get;set;}
        Map<Id,List<Product_Lookup_Data__c>> FeatureIdXOptionRecord{get;set;}
        Map<Id,Features__c> FeatureIdXFeatureRecord{get;set;}
        Map<Id,Product2> ProductIdXProductRecord{get;set;}
    }
}
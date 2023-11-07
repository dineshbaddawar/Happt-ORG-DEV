/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 06-11-2021
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   06-09-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class ManageProductHandler {
    
    @AuraEnabled(cacheable=true)
    public static List<wrapperClass> getChildProducts(String parentId)
    {
        List<wrapperClass> wrapperList = new List<wrapperClass>();
        List<Product_Bundle__c> proList = [select Product__c,Product__r.Name,
                                           Product__r.Family,Product__r.Category__c,Is_Pricing_Dependent__c,Product__r.Is_Generic__c,Product__r.Type_of_Product__c,
                                           Product__r.Product_Pricing_Type__c,Sort_Order__c
                                           from Product_Bundle__c 
                                           where Parent_Product_Bundle__c =: parentId OR id =:parentId 
                                           ORDER BY Sort_Order__c ASC];
        system.debug(proList);
        for(Product_Bundle__c pro : proList)
        {
            wrapperClass wp = new wrapperClass();
            if(pro.Id == parentId)
            {
                wp.Is_Independent=true;
            }
            else{
                wp.Is_Independent=FALSE;
            }
            wp.Product2Id = pro.Product__c;
            wp.ProName =pro.Product__r.Name;
            wp.family = pro.Product__r.Family;
            wp.category = pro.Product__r.Category__c;
            wp.Is_Generic = pro.Product__r.Is_Generic__c;
            wp.pricingType = pro.Product__r.Product_Pricing_Type__c;
            wp.sortOrder=pro.Sort_Order__c;
            wp.Is_Pricing_Dependent = pro.Is_Pricing_Dependent__c;
            wp.Product_Type = pro.Product__r.Type_of_Product__c;
            wrapperList.add(wp);
        }
        return wrapperList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product_Price__c> getPricingTypeDetails(string proId)
    {
        List<Product_Price__c> pricingList = [select id ,Name,Pricing_Type__c, List_Price__c from Product_Price__c where Product__c =:proId ];
        return pricingList;
    }
    
    @AuraEnabled
    public static void upsertProducts(List<wrapperClass> wrapperList, String sObjectId , String sObjectName,Decimal SAAS_Discount,Decimal OTI_Discount)
    {
        //List<string> fields = new List<String>();
        List<OpportunityLineItem> oliToUpsert = new List<OpportunityLineItem>();
        List<QuoteLineItem> qliToUpsert = new List<QuoteLineItem>();
        Set<String> productIdSet = new Set<String> ();	
        for(wrapperClass wc : wrapperList)
        {
            productIdSet.add(wc.Product2Id);
        }
        List<Pricebook2> pblist = [SELECT Id, Name, IsActive, IsStandard FROM Pricebook2 where isActive = true and isStandard =true];
        String Pricebook2Id = pblist[0].Id;
        List<PricebookEntry> pbeList = [Select id, Product2Id from PricebookEntry where Pricebook2Id = :Pricebook2Id ];
        Map<String, String> pbEntryMap = new Map<String, String>();
        for(PricebookEntry pbe: pbeList)
        {
            pbEntryMap.put( pbe.Product2Id,pbe.Id);
        }
        for(wrapperClass wc : wrapperList)
        {
            if(sObjectName =='Opportunity')
            {
                OpportunityLineItem oli = new  OpportunityLineItem();
                oli.Product2Id = wc.Product2Id;
                oli.OpportunityId = sObjectId;
                oli.Id = wc.RecordId;
                oli.Quantity = wc.Quantity;
                oli.Discount = wc.Discount;
                oli.Product_Pricing__c = wc.Product_Pricing;
                oli.Sales_Type__c = wc.Sales_Type;
                oli.UnitPrice = wc.UnitPrice;
                oli.Other_Details__c = wc.Other_Details;
                oli.Sort_Order__c = wc.SortOrderforRecords;
                oli.Is_Independent__c = wc.Is_Independent;
                oli.Is_Pricing_Dependent__c=wc.Is_Pricing_Dependent ;
                oliToUpsert.add(oli);
                
            }
            else
            {
                QuoteLineItem qli = new QuoteLineItem();
                qli.Product2Id = wc.Product2Id;
                qli.PricebookEntryId = pbEntryMap.get(wc.Product2Id);
                System.debug(qli.PricebookEntryId);
                qli.QuoteId = sObjectId;
                qli.Id = wc.RecordId;
                qli.Quantity = wc.Quantity;
                qli.Discount = wc.Discount;
                qli.Other_Details__c = wc.Other_Details;
                qli.Product_Pricing__c = wc.Product_Pricing;
                qli.Sales_Type__c = wc.Sales_Type;
                qli.UnitPrice = wc.UnitPrice;
                qli.Sort_Order__c = wc.SortOrderforRecords;
                qli.Is_Independent__c = wc.Is_Independent;
                qli.Is_Pricing_Dependent__c=wc.Is_Pricing_Dependent ;
                qliToUpsert.add(qli); 
            }
            
            
        }
        Boolean olicheck = !oliToUpsert.isEmpty() && sObjectName == 'Opportunity';
        Boolean qlicheck = !qliToUpsert.isEmpty() && sObjectName == 'Quote';
        if(olicheck)
        {
            Database.upsert(oliToUpsert, OpportunityLineItem.Id, false);
            System.debug(oliToUpsert);
            Opportunity opp = New Opportunity();
            opp.Id = sObjectId;
            opp.SAAS_Discount__c = SAAS_Discount;
            opp.OTI_Discount__c = OTI_Discount;
            update opp;
        }
        else if(qlicheck)
        {
            
            database.upsert(qliToUpsert, QuoteLineItem.Id, false);
            Quote qt = New Quote();
            qt.Id = sObjectId;
            qt.SAAS_Discount__c = SAAS_Discount;
            qt.OTI_Discount__c = OTI_Discount;
            update qt;
        }
    }
    
    @AuraEnabled
    public static void deleteProducts(String recordId )
    { 
        String sObjectName = getObjName(recordId);
        boolean oliCheck = recordId != null && sObjectName =='OpportunityLineItem';
        boolean qliCheck = recordId != null && sObjectName =='QuoteLineItem';
        if(oliCheck) 
        {
            OpportunityLineItem oli = [SELECT id FROM OpportunityLineItem where id =:recordId ];
            DELETE oli;
        }
        else if(qliCheck)
        {
            QuoteLineItem qli =[SELECT id FROM QuoteLineItem where id =:recordId];
            DELETE qli;
        }
    }
    
    @AuraEnabled(cacheable = false)
    public static initWrapper fetchLineItems(String recordId)
    {
        List<wrapperClass> wrapperList = new List<wrapperClass>();
        initWrapper mainWrapper = new initWrapper();
        String objName = getObjName(recordId);
        Opportunity opp;
        Quote qt ;
        Boolean hasAccess=false;
        if(objName == 'Opportunity')
        {
            List<OpportunityLineItem> olis = [SELECT Id, OpportunityId, PricebookEntryId, Product2Id, Quantity,
                                              TotalPrice, UnitPrice, ListPrice, Product_Pricing__c,Is_Pricing_Dependent__c,Product2.Is_Generic__c,Other_Details__c,
                                              Product_Type__c,Sales_Type__c,Subtotal,Discount,Sort_Order__c,Is_Independent__c,
                                              Product2.Name,Product2.family,Product2.Category__c,SortOrder
                                              FROM OpportunityLineItem where OpportunityId =: recordId ORDER BY Sort_Order__c asc];
            
            for(OpportunityLineItem  oli : olis)
            {
                wrapperClass wp = new  wrapperClass();
                wp.RecordId =oli.id;
                wp.Product2Id = oli.Product2Id;
                wp.proName =oli.Product2.Name;
                wp.family = oli.Product2.family;
                wp.category = oli.Product2.Category__c;
                //wp.pricingType = oli.Product_Type__c;
                wp.PricebookEntryId = oli.PricebookEntryId;
                wp.ListPrice = oli.ListPrice;
                wp.Quantity = oli.Quantity;
                wp.TotalPrice =oli.TotalPrice;
                wp.Is_Generic = oli.Product2.Is_Generic__c;
                wp.Other_Details = oli.Other_Details__c;
                wp.UnitPrice = oli.UnitPrice;
                wp.Discount = oli.Discount;
                wp.Product_Pricing = oli.Product_Pricing__c;
                
                wp.Sales_Type = oli.Sales_Type__c;
                wp.SortOrderforRecords = oli.Sort_Order__c;
                wp.Is_Independent = oli.Is_Independent__c;
                wp.Product_Type= oli.Product_Type__c;
                wp.Is_Pricing_Dependent = oli.Is_Pricing_Dependent__c;
                wrapperList.add(wp);
                //wp.Subtotal = oli.s
            }
            /*
opp = [Select id, OTI_Discount__c, SAAS_Discount__c from Opportunity where Id=:recordId];
mainWrapper.SAAS_Discount = opp.SAAS_Discount__c;
mainWrapper.OTI_Discount = opp.OTI_Discount__c;

*/
            
            
        }
        else if(objName =='Quote')
        {
            List<QuoteLineItem> qlis = [SELECT Id, Subtotal, ListPrice, Product2Id, UnitPrice,
                                        Quantity, PricebookEntryId, Is_Independent__c,Sort_order__c,Is_Pricing_Dependent__c,Product2.Is_Generic__c,Other_Details__c,
                                        QuoteId, SortOrder, Discount, OpportunityLineItemId,TotalPrice,Sales_Type__c,Product_Pricing__c,Product_Type__c,
                                        Product2.Name, Product2.family, Product2.Category__c                      
                                        FROM QuoteLineItem where QuoteId =:recordId ORDER BY Sort_Order__c asc];
            
            
            for(QuoteLineItem  qli : qlis)
            {
                wrapperClass wp = new  wrapperClass();
                wp.RecordId =qli.id;
                wp.Product2Id = qli.Product2Id;
                wp.proName =qli.Product2.Name;
                wp.family = qli.Product2.family;
                wp.category = qli.Product2.Category__c;
                // wp.pricingType = qli.Product_Type__c;
                wp.PricebookEntryId = qli.PricebookEntryId;
                wp.ListPrice = qli.ListPrice;
                wp.Quantity = qli.Quantity;
                wp.TotalPrice =qli.TotalPrice;
                wp.UnitPrice = qli.UnitPrice;
                wp.Discount = qli.Discount;
                wp.Product_Pricing = qli.Product_Pricing__c;
                wp.Product_Type= qli.Product_Type__c;
                wp.Is_Generic = qli.Product2.Is_Generic__c;
                wp.Other_Details = qli.Other_Details__c;
                wp.Sales_Type = qli.Sales_Type__c;   
                wp.SortOrderforRecords = qli.Sort_Order__c;
                wp.Is_Independent = qli.Is_Independent__c;
                wp.Is_Pricing_Dependent = qli.Is_Pricing_Dependent__c;
                wrapperList.add(wp);
                //wp.Subtotal = oli.s
            }
            qt = [Select id, OTI_Discount__c, SAAS_Discount__c from Quote where Id=:recordId];
            mainWrapper.SAAS_Discount = qt.SAAS_Discount__c;
            mainWrapper.OTI_Discount = qt.OTI_Discount__c;
            
        }
        
        
        mainWrapper.allRecords = wrapperList;
        hasAccess= [SELECT RecordId, HasEditAccess FROM UserRecordAccess  where RecordId = :recordId and UserId = :UserInfo.getUserId()].HasEditAccess;
        
        mainWrapper.hasAccess = hasAccess; 
        
        return mainWrapper;
        
    }
    
    public static string getObjName(string recordId)
    {
        string objName;
        String keyCode  = recordId.subString(0,3);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType objectInstance : gd.values())
        {
            if(objectInstance.getDescribe().getKeyPrefix() == keyCode)
            {
                objName = objectInstance.getDescribe().getName();
            }
        }
        return objName;
    }
    
    public class initWrapper{
        @AuraEnabled public List<wrapperClass> allRecords{get;set;}
        @AuraEnabled public Boolean hasAccess{get;set;}
        @AuraEnabled public Decimal OTI_Discount {get;set;}
        @AuraEnabled public Decimal SAAS_Discount {get;set;}
    }
    
    public class wrapperClass{
        @AuraEnabled public String Product2Id{get;set;}
        @AuraEnabled public String proName{get;set;}
        @AuraEnabled public String family{get;set;}
        @AuraEnabled public String category{get;set;}
        @AuraEnabled public String pricingType{get;set;}
        @AuraEnabled public String Other_Details{get;set;}
        @AuraEnabled public Decimal sortOrder{get;set;}
        @AuraEnabled public String OpportunityLineItemId{get;set;}	
        @AuraEnabled public String QuoteItemId{get;set;}
        @AuraEnabled public String PricebookEntryId{get;set;}
        @AuraEnabled public String PricingTypeId{get;set;}
        @AuraEnabled public Boolean Is_Independent{get;set;}
        @AuraEnabled public Boolean Is_Generic{get;set;}	
        @AuraEnabled public Boolean Is_Pricing_Dependent{get;set;}	
        @AuraEnabled public Decimal SortOrderforRecords{get;set;}	
        @AuraEnabled public Decimal ListPrice{get;set;}
        @AuraEnabled public Decimal Quantity{get;set;}
        @auraEnabled public Decimal TotalPrice{get;set;}
        @auraEnabled public Decimal UnitPrice{get;set;}
        @auraEnabled public String RecordId{get;set;}
        @auraEnabled public Decimal Discount{get;set;}
        @auraEnabled public String Product_Pricing{get;set;}
        @auraEnabled public String Sales_Type{get;set;}
        @auraEnabled public String Product_Type{get;set;}
        @auraEnabled public Decimal Subtotal{get;set;}
        
    }
    
}
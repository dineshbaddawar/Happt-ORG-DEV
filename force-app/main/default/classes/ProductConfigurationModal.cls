public class ProductConfigurationModal {
    
    public static List<Product_Lookup_Data__c> fetchProductLookupData(Id productId){
        return [select Id,Account_Type__c,Bundle_Product__c,Bundle_Product__r.Name,Editable__c,Mandatory__c,Multiply_Prices_Based_on_Quantity__c,Offering__c,
                OTI_Price__c,Parent_Product__c,Parent_Product__r.Name,Product_Name__c,Pricing_Type__c,Product__c,Product__r.Name,Name,Quantity_0__c,SAAS_Price__c,Selected__c,Travel_Offering_Type__c,
                Type__c,Sub_Type__c,OTI_API_Pricing__c,OTI_Custome_API_Price__c,OTI_Elite_Pricing__c,OTI_Premium_Pricing__c,OTI_Pro_Pricing__c,OTI_SFTP_Pricing__c,
                SAAS_API_Pricing__c,SAAS_Custome_API_Pricing__c,SAAS_Elite_Pricing__c,SAAS_Premium_Pricing__c,SAAS_Pro_Pricing__c,SAAS_SFTP_Pricing__c
                from Product_Lookup_Data__c where Bundle_Product__c =: productId];
    }
    
    public static List<Product_Rule_Conditions__c> returnActiveProductRule(Id productId){
        return [select Id,Lookup_Object_Field_API_Name__c,Product_Rule__c,Name,Quote_Line_Field_API_Name__c,Sequence__c,
                Product_Rule__r.Active__c,Product_Rule__r.Criteria__c,Product_Rule__r.Lookup_Object__c,Product_Rule__r.Product__c,Product_Rule__r.Name
                from Product_Rule_Conditions__c 
                where Product_Rule__r.Active__c = true AND Product_Rule__r.Product__c =: productId order by Sequence__c];
    }
}
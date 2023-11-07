public class ConfigurePorductController {
	
    @auraEnabled
    public static quote getQuoteDetails(Id quoteId){
        return [select id,Name,Account.Name,AccountId,Opportunity.Name,OpportunityId from quote where id =: quoteId];
    }
    
    @auraEnabled
    public static List<quoteLineItem> getQuoteLineItems(Id QuoteId){
        return [select id,Product2Id,QuoteId,OTI_Price__c,SAAS_Price__c from quoteLineItem where quoteId = : QuoteId];
    }
}
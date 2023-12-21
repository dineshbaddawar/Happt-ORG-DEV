public class GetChild {
    
    private final List<Quote> quoteRecord;
    public Quote quoteList{get;set;}
    public GetChild() {
        quoteList = [SELECT Name,opportunity.name,owner.name,Travel_ARR_Discount__c	,Travel_OTI_Discount__c,Expense_ARR_Discount__c,Expense_OTI_Discount__c,Authority_1__r.Name,Authority_2__r.Name,Authority_3__r.Name,
                     (SELECT Id,Term_Attribute_Line_Item__r.Name,Billing_Type__c,Term_Section_Line_Item_Name__c FROM Terms_and_conditions__r) FROM Quote where id ='0Q09C00000008IzSAI'];
    }
    
    
    
}
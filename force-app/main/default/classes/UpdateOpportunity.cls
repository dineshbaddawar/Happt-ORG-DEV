public class UpdateOpportunity {
    @future
    Public Static void Quote_Related_OpportunityUpdate(set<Id> QuoteId){
        List<Opportunity> OpportunityToUpdate=new List<Opportunity>();
        If(!QuoteId.isEmpty()){
            List<Quote> QuoteRecList=[Select Id,OpportunityId,IsSyncing,TotalTravelCount__c,Travel_Account_Type__c,Travel_Pricing_Type__c,Travel_Offering_Type__c,Travel_Minimum_Commitment__c,
                                      TotalExpenseCount__c,Expense_Account_Type__c,Expense_Pricing_Type__c,Expense_Minimum_Commitment__c FROM quote Where Id=:QuoteId AND IsSyncing=TRUE];
            if(!QuoteRecList.IsEmpty()){
                for(Quote qr:QuoteRecList){
                    Opportunity OppRec=new Opportunity();
                    OppRec.Id=qr.OpportunityId;
                    //if(qr.TotalTravelCount__c!=null)
                        OppRec.No_of_Modules_sold_in_Travel__c= qr.TotalTravelCount__c!=null ? qr.TotalTravelCount__c : null;
                    if(qr.TotalExpenseCount__c!=null)
                        OppRec.No_of_Modules_sold_in_Expense__c=qr.TotalExpenseCount__c;
                    if(qr.Travel_Minimum_Commitment__c!=null)
                        OppRec.No_of_User_for_Travel__c=qr.Travel_Minimum_Commitment__c;
                    if(qr.Expense_Minimum_Commitment__c!=null)
                        OppRec.No_of_User_for_Expense__c=qr.Expense_Minimum_Commitment__c;
                    if(qr.Expense_Pricing_Type__c!=null)
                        OppRec.Expense_Type_Report_User__c=qr.Expense_Pricing_Type__c.substringAfter('Per ');   
                    if(qr.Travel_Pricing_Type__c!=null)
                        OppRec.Travel_Type_Report_User__c=qr.Travel_Pricing_Type__c.substringAfter('Per ');
                    OpportunityToUpdate.add(OppRec);
                }
                
                if(!OpportunityToUpdate.IsEmpty()){
                    Update OpportunityToUpdate;
                }
            }
            
        }
    }
    
}
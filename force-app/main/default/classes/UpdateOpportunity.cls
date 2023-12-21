public class UpdateOpportunity {
    @future
    Public Static void Quote_Related_OpportunityUpdate(set<Id> QuoteId){
        List<Opportunity> OpportunityToUpdate=new List<Opportunity>();
        If(!QuoteId.isEmpty()){
            List<Quote> QuoteRecList=[Select PUPM_Quantity_Count__c,Id,OpportunityId,IsSyncing,TotalTravelCount__c,Travel_Account_Type__c,Travel_Pricing_Type__c,Travel_Offering_Type__c,Travel_Minimum_Commitment__c,
                                      TotalExpenseCount__c,Expense_Account_Type__c,Expense_Pricing_Type__c,Expense_Minimum_Commitment__c FROM quote Where Id=:QuoteId AND IsSyncing=TRUE];
            if(!QuoteRecList.IsEmpty()){
                for(Quote qr:QuoteRecList){
                    Opportunity OppRec=new Opportunity();
                    OppRec.Id=qr.OpportunityId;
                    OppRec.No_of_Modules_sold_in_Travel__c  = qr.TotalTravelCount__c!=null ? qr.TotalTravelCount__c : null;
                    OppRec.No_of_Modules_sold_in_Expense__c = qr.TotalExpenseCount__c!=null ? qr.TotalExpenseCount__c : null;
                    OppRec.No_of_User_for_Travel__c         = qr.Travel_Minimum_Commitment__c !=null ? qr.Travel_Minimum_Commitment__c:null;
                    OppRec.No_of_User_for_Expense__c        = qr.Expense_Minimum_Commitment__c!=null? qr.Expense_Minimum_Commitment__c:null;
                    OppRec.Expense_Type_Report_User__c      = qr.Expense_Pricing_Type__c!=null ?qr.Expense_Pricing_Type__c.substringAfter('Per '):null;
                    OppRec.Travel_Type_Report_User__c       = qr.Travel_Pricing_Type__c!=null ? qr.Travel_Pricing_Type__c.substringAfter('Per '):null;
                    OppRec.Account_Type_Travel__c           = qr.Travel_Account_Type__c!=null ?  qr.Travel_Account_Type__c:null;
                    OppRec.Account_Type_Expense__c          = qr.Expense_Account_Type__c!=null ?  qr.Expense_Account_Type__c:null;
                    OppRec.PUPM_Quantity_Count__c           = qr.PUPM_Quantity_Count__c!=null ? qr.PUPM_Quantity_Count__c:null;
                    OpportunityToUpdate.add(OppRec);
                }
                
                if(!OpportunityToUpdate.IsEmpty()){
                    //Update OpportunityToUpdate;
                    Database.SaveResult[] srList = Database.update(OpportunityToUpdate, false);
                    
                    
                    for (Database.SaveResult sr : srList) {
                        if (sr.isSuccess()) {
                           
                            System.debug('Successfully updated Invoice. Invoice ID is : ' + sr.getId());
                        } else {
                           
                            for(Database.Error objErr : sr.getErrors()) {
                                System.debug('The following error has occurred.');
                               
                                System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                                System.debug('Invoice oject field which are affected by the error:' 
                                             + objErr.getFields());
                            }
                        }
                    }
                }
            }
            
        }
    }
    
}
public class TestUtility1 {

    public static Account createAccount(string Accountname){
        
        Account acc                         = new Account(Name = Accountname);
        insert acc;
        return acc;
    }
    public static Opportunity CreateOpp(String oppname ,string accid ,date clsdate,string stgname ){
        
        Opportunity oppRec                  = new Opportunity();
        oppRec.Name                         = oppname;
        oppRec.AccountId                    = accid;
        oppRec.CloseDate                    = clsdate;
        oppRec.StageName                    = stgname;
        insert oppRec;
        return oppRec;
    }


    public static Quote CreateQuote (string oppId,string name,Integer TtotalSaas,Integer EtotalSaas,Decimal TFAmount,Decimal EFAmount){

        Quote quotRec                       = new Quote();
        quotRec.OpportunityId               = oppId;
        quotRec.Name                        = name;
        quotRec.Travel_Total_SAAS__c        = TtotalSaas;
        quotRec.Expense_Total_SAAS__c       = EtotalSaas;
        quotRec.Travel_Final_ARR__c         = TFAmount;
        quotRec.Expense_FInal_ARR__c        = EFAmount;
        quotRec.Travel_Total_OTI__c         = 797464;
        quotRec.Expense_Total_OTI__c        = 5464676;
        quotRec.Expense_OTI_Discount__c     = 7000000; 
        quotRec.Travel_ARR_Discounted__c    = 7000000; 
        quotRec.Expense_ARR_Discounted__c   = 8000000;
        quotRec.Travel_OTI_Discounted__c    = 10000;
        quotRec.Expense_OTI_Discounted__c   = 7000000; 
        quotRec.Billing_Type_Multiplier__c  = 3;
         
        insert quotRec;
      
        return quotRec;
    }

    public static Product2 CreateProduct2(string name,boolean isactivevalue){

        Product2 ProRec                    = new Product2();
        ProRec.Name                        = name;
        ProRec.IsActive                    = isactivevalue;
        insert ProRec;
        return ProRec;

    }

    public static QuoteLineItem createQuateLineItem(string quoteId,string Pro2Id ,string PriceType,boolean bookingvalue,boolean quantityValue,decimal otiAmount, decimal saasAmount){
        QuoteLineItem qliRec               = new QuoteLineItem();
        qliRec.QuoteId                     = quoteId;
        qliRec.Product2Id                  = Pro2Id;
        qliRec.Account_Type__c             = 'SMALL';
        qliRec.Travel_Pricing_Type__c      = PriceType;
        qliRec.IsMultiplybyBooking__c      = bookingvalue;
        qliRec.Quantity_0__c               = quantityValue;
       // qliRec.Parent_Quote_Line_Item__c =  
        qliRec.OTI_Price__c                = otiAmount;
        qliRec.SAAS_Price__c               = saasAmount;
        qliRec.Travel_Offering_Type__c     = 'SBT';
        qliRec.Quantity                    = 2;
       // qliRec.Is_Travel_Product__c        = False;
        qliRec.Type__c                     = 'SAAS';
        
        insert qliRec;
        return qliRec;
     }
    
    public static Term_Section_Line_Item__c CreateTermSection  (string name){
        Term_Section_Line_Item__c tsLRec   = new Term_Section_Line_Item__c();
        tsLRec.Name                        = name;
        insert tsLRec;
        return tsLRec;
    }
        
    public static Term_Attribute_Line_Item__c CreateTermAttributeLI (String name,string tsliID,boolean booleanvalue,boolean approveValue,string userid ){
        Term_Attribute_Line_Item__c talRec = new Term_Attribute_Line_Item__c();
        talRec.Name                        = name;
        talRec.Term_Section_Line_Item__c   = tsliID;
        talRec.Approval_Required__c        = booleanvalue;
        talRec.Approved_By_Team_Lead__c    = approveValue;
        talRec.Approval_Authority__c       = userid;
        talRec.Approval_Required__c        = True;
       
        insert talRec;
        return talRec;
    }   
        
    public static Approval_Matrix__c CreateApprovalMatrix(string name,Boolean appReqValue,string userid,string TALIRecid ,string profileId,Boolean TleadApprValue){
        Approval_Matrix__c AMRec           = new Approval_Matrix__c();
        AMRec.Approval_Required__c         = appReqValue;
        AMRec.Approving_Authority__c       = userid;
        AMRec.Term_Attribute_Line_Item__c  = TALIRecid;
        AMRec.Profiles__c                  = profileId;
        AMRec.Team_Lead_Approver__c        = TleadApprValue;
        AMRec.Profiles__c                  = 'Enterprise';
       // AMRec.Higher_Authority__c          = False;
        insert AMRec;
        return AMRec;
   }      
    
    public static Terms_and_condition__c CreateTermAndCondition( string AppMatId,string TALIRecid,String TSLIRecID,string userid,string quoteId){
        Terms_and_condition__c TACRec     = new Terms_and_condition__c();
        TACRec.Approval_Matrix__c     = AppMatId;
        TACRec.Term_Attribute_Line_Item__c= TALIRecid;
        TACRec.Term_Section_Line_Item__c  = TSLIRecID;
        TACRec.Approval_Authority__c      = userid;
        TACRec.Quote__c                   = quoteId;
        TACRec.Change_Request__c = 1000;
        insert TACRec;
        return TACRec;
    }
    
}
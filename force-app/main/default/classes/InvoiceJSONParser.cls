public class InvoiceJSONParser {

	public List<InvoiceList> InvoiceList;

	public class PaymentClass {

		public Decimal amount;
        public String invoiceNumber;
        public Decimal paymentNumber;
        public String paymentType;
        public String paymentMethod;
        public String paymentDescription;//Remove
        public String paymentDate;
        
	}

	public class InvoiceList {
		public String InvoiceNumber;
        public String Quote;
		public String DueDate;
		public String InvoiceDate;
        public Decimal InvoiceAmount;
		public List<PaymentClass> paymentList; 
        public String bankingChannel;//Remove
        public Decimal deltaRevenueARR;//Remove
        public String emailAddress;//Remove
        public Decimal implementationCharges;
        
		public Decimal invoiceAmountForCardPurchase;//Rename
        public String invoiceEmailId;//Remove
        public Decimal numberOfUsers;
        public String paymentDetails;//Remove
        
		public String paymentMode;//Remove
		public String paymentRefInCaseOfSeparatePayment;//Remove
        public String revenueDetails;//Remove
		public String revenueRealization;//Remove

		public String salesManagerForThisCompany;//Remove
		public String salesManagerList;//Remove
		public String status;
		public String submittedBy;//Remove

		public Decimal totalAmount;
		public String upsellType;//Remove
		public String useCase;//Remove
		
        
        //New Elements
		
        public String OrgID; 
        public Decimal SAASCharges;
        public Decimal pendingAmount;
        
		public String startDate;
        public String endDate;
        public Decimal tdsAmount;
        
	}

	
	public static InvoiceJSONParser parse(String json) {
		return (InvoiceJSONParser) System.JSON.deserialize(json, InvoiceJSONParser.class);
	}
}
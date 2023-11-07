global class EmailToLeadHandler implements Messaging.InboundEmailHandler {
	  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		  Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          
          //String subToCompare = 'Create lead/ Demo Lead/'; // we can specify the Subject and add condition like this
          /*
            if(email.subject.equalsIgnoreCase(subToCompare))
			{
				...create Lead
			}
		  */
          
          List <Lead> leadsTolnsert = new List<Lead>(); 
          
          try{
              Lead instanceLead = new Lead();
              System.debug('@email-->'+email);
              
              
             // instanceLead.FirstName = email.fromName.substring(0, email.fromName.indexOf(' ')); 
             // instanceLead.LastName = email.fromName.substringAfter(' ');
            //  instanceLead.Company = instanceLead.FirstName +' '+ instanceLead.LastName; 
              System.debug(email.subject);
              instanceLead.Email = email.subject; 
              instanceLead.LeadSource = 'Email';
              instanceLead.Description = email.plainTextBody;
              
              
              String EmailString =  email.subject;
              
              String LastName = EmailString.substringBefore('@');
              String CompanyName = EmailString.substringAfter('@').substringBefore('.');
              
              System.debug(LastName);
              System.debug(CompanyName);
              
              instanceLead.Company = CompanyName;
              instanceLead.LastName = LastName;
              //System.debug('@15 myPlainText-->'+email.plainTextBody);  // this can be used to store as description 
              
              leadsTolnsert.add(instanceLead); 
              insert leadsTolnsert;
              
              result.success = true;
                 
          } 
          catch (Exception e) {
              result.success = false;
              System.debug('Message'+e.getMessage());
              result.message = 'Due to Technical Reasons,Your data cannot be Inserted.';              
              
              ErrorLogger.createLogError('EmailToLeadHandler', 'Apex Class',e.getTypeName(),
                                         e.getMessage(), String.valueOf(e.getLineNumber()),
                                         'handleInboundEmail', 
                                         e.getStackTraceString()+' Email:  '+email.plainTextBody+' Subject: '+email.subject);
              
          }
        return result;   
      }
  }
global class Batch_NoStageChangedReminder implements  Schedulable ,Database.Batchable<sObject>,Database.Stateful {
    global void execute(SchedulableContext sc) {
        Batch_NoStageChangedReminder b = new Batch_NoStageChangedReminder(); 
        database.executebatch(b);
    }
    Map<String, List<Reminder_Metadata__mdt>> reminderMap = new Map<String,List<Reminder_Metadata__mdt>>();
    Map<Id, User> userMap = new Map<Id, User>();
    
    global Batch_NoStageChangedReminder()
    {
        
        Map<String, List<Reminder_Metadata__mdt>> reminderMap = new Map<String,List<Reminder_Metadata__mdt>>();
        List<Reminder_Metadata__mdt> reminderMetadataList = [SELECT sObject__c, Type_of_Reminder__c,SendDaily__c, Remind_After_Days__c, Value__c, Id, Label, Include_Reporting_Manager__c 
                                                             FROM Reminder_Metadata__mdt where sObject__c = 'Opportunity' and 
                                                             Type_of_Reminder__c = 'Stage Not Changed'];
        for(Reminder_Metadata__mdt reminder : reminderMetadataList)
        {
            String StageName = reminder.Value__c;
            List<Reminder_Metadata__mdt> tempList = new  List<Reminder_Metadata__mdt>();
            
            if(reminderMap.containsKey(StageName))
            {
                tempList = reminderMap.get(StageName);
            }
            tempList.add(reminder);
            reminderMap.put(reminder.Value__c,tempList);
        }
        this.reminderMap = reminderMap;
        
        this.UserMap = new Map<Id,User>([Select id,Name, Email, ManagerId from User where isActive=true]);
        System.debug(this.userMap);
    }
    
    global Database.QueryLocator start( Database.BatchableContext BC ) {
        String query = 'Select id, Name,StageName, CreatedDate,LastStageChangeDate__c,OwnerId  from Opportunity';
        return Database.getQueryLocator(query);
    }
    
    global void execute( Database.BatchableContext BC, List< Opportunity > scope ) {
        
        Map<String, List<Reminder_Metadata__mdt>> reminderMap = new Map<String,List<Reminder_Metadata__mdt>>();
        reminderMap = this.reminderMap;
        
        List<Messaging.SingleEmailMessage> mails =  new List<Messaging.SingleEmailMessage>();
        for(Opportunity opp: scope)
        {
            
            if(reminderMap.containsKey(opp.StageName))
            {
                List<Reminder_Metadata__mdt> reminderList = reminderMap.get(opp.StageName);
                
                for(Reminder_Metadata__mdt reminder: reminderList)
                {
                    Date LastStageChangeDate;
                    LastStageChangeDate = opp.LastStageChangeDate__c==null?Date.valueOf(opp.CreatedDate):Date.valueOf(opp.LastStageChangeDate__c);
                    System.debug(LastStageChangeDate.daysBetween(system.Today()));
                    System.debug(reminder.Remind_After_Days__c);
                    if(reminder.SendDaily__c){
                        if(LastStageChangeDate.daysBetween(system.Today()) >= reminder.Remind_After_Days__c||Test.isRunningTest())
                        {
                            mails.add(prepareEmail(opp,reminder,userMap,LastStageChangeDate.daysBetween(system.Today())));
                        }
                    }
                    else{
                        if(LastStageChangeDate.daysBetween(system.Today()) == reminder.Remind_After_Days__c||Test.isRunningTest())
                        {
                            mails.add(prepareEmail(opp,reminder,userMap,LastStageChangeDate.daysBetween(system.Today())));
                        }
                    }
                }
            }
            
        }
        System.debug(mails);
        Messaging.sendEmail(mails);
      
        
    }
    global void finish( Database.BatchableContext BC ) {
        

    }
    
    public  static Messaging.SingleEmailMessage prepareEmail(Opportunity opp,Reminder_Metadata__mdt reminder,Map<Id, User> userMap,Decimal NumberofDays)
    {
        String BaseURL = URL.getSalesforceBaseURL().toExternalForm();
        System.debug(BaseURL);
        
        String OppLink = BaseURL + '/'+opp.Id;
        String EmailBody='<h1>Opportunity Stage Not Changed</h1>'
            +'<p>The below marked opportunity stage has not been moved in last '+NumberofDays+' days</p><p></p>'
            +'<p>Opportunity : <a href="'+OppLink+'" >'+opp.Name+'</a></p>'
            +'<p>Current Stage : '+opp.StageName+'</p>'
            +'<p></p><p>Necessary action is required on this Opportunity on an urgent basis. </p><p></p>';
        
        
        Messaging.SingleEmailMessage mailforInternal =  new Messaging.SingleEmailMessage();
     	 List<String> sendTo = new List<String>();
        if( (System.label.Reminder_SendToAdminsOnly).toLowerCase() == 'yes')
        {
        	sendTo.add(System.label.Reminder_AdminEmailId );//Internal Email Template
        }else{
            String OwnerEmail = userMap.containskey(opp.OwnerId) ? userMap.get(opp.OwnerId).Email : '';            
            sendTo.add(OwnerEmail);
        }
        
		if((System.label.Reminder_SendToAdminsOnly).toLowerCase() != 'yes'&&reminder.Include_Reporting_Manager__c)
        {
			String ManagerId  = userMap.get(opp.OwnerId).ManagerId;
            String ManagerEmailId  = userMap.get(ManagerId).Email;
            sendTo.add(ManagerEmailId);
        }
        String addtionalEmails = System.Label.Reminder_AdditionalEmails;
        if(addtionalEmails!='NA'){
            sendTo.addAll(addtionalEmails.split(','));
        }
        mailforInternal.setToAddresses(sendTo);        
        mailforInternal.setSubject('Opportunity '+opp.Name+' Stage Not Changed Notification');

        
        mailforInternal.setHtmlBody(EmailBody);
        
        return  mailforInternal;
    }
}
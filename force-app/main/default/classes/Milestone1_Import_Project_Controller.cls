/**
 * @description       : 
 * @author            : RISHAB GOYAL
 * @group             : 
 * @last modified on  : 07-07-2021
 * @last modified by  : RISHAB GOYAL
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   07-07-2021   RISHAB GOYAL   Initial Version
**/
global without sharing class Milestone1_Import_Project_Controller {
    global Milestone1_Project__c project {get; set;}
    global List<Document> docs {get;set;}
    global List<SelectOption> docOptions {get;set;}
    global String contentType {get;set;}
    global String docId{get;set;}

    global String OppId{get;set;}
    global string fileName{get;set;}
    global String UsePredefinedTemplate{get;set;}
    global Blob fileBody{get;set;} 
    global Integer docsSize {get;set;} 
    global Integer maxFileSize {get; set;}
    global static Integer MAX_FILE_SIZE = 500000;
    
    private static String CONTENT_ERROR = system.label.Milestone1_ContentIsNotAllowedInProlog;
    
    global Milestone1_Import_Project_Controller(ApexPages.StandardSetController ssc)
    {
        docOptions = new List<SelectOption>();
        
        if (Schema.sObjectType.Document.isAccessible()) {
        	docs = [Select Id, Name from Document where Name like: 'EXPORT %' ];
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: User is unauthorized to act on this object/field.'));
		}
        
        if (Schema.sObjectType.Document.isCreateable()) {
        	for (Document doc : docs) {
            	docOptions.add(new SelectOption(doc.Id,doc.Name));
        	}
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: User is unauthorized to act on this object/field.'));
        }    
        UsePredefinedTemplate='n';
        UsePredefinedTemplate='n';
        UsePredefinedTemplate='n';
        
        UsePredefinedTemplate = apexpages.currentpage().getparameters().get('UsePredefinedTemplate');
        if(UsePredefinedTemplate=='y')
        {
            docId=System.Label.Project_Tempalte_Id ; OppId = apexpages.currentpage().getparameters().get('OppId');
        }
        
      
        
        docsSize = docs.size();
    }
    
    global PageReference importTemplateXML() {
        
        try {

        	if( this.maxFileSize < 1 ){
        		throw new Milestone1_Import_Exception( Milestone1_Import_Exception.ERROR_EMPTY_XML );
        	}
            Milestone1_XML_Import_Utility importUtility = new Milestone1_XML_Import_Utility();
            String xml = '';
            if( fileBody != null && fileName != null ) {
                system.debug('The Import XML Size == ' + fileBody.size());
                if(fileBody.size() > MAX_FILE_SIZE) {
                    fileBody = null; // Null out the large filesize to prevent ViewState Max Size errors.
                    throw new Milestone1_Import_Exception(Milestone1_Import_Exception.ERROR_FILESIZE_TOO_LARGE + ' The number of characters must be less than ' + MAX_FILE_SIZE +'.');
                }
                xml = fileBody.toString();  
            }
            else {
                xml = getDocumentXMLString();
            }
            if(xml == null || xml.length() < 1) {
                return ApexPages.currentPage();
            }

            project = importUtility.importProject(xml);
            system.debug(OppId);
           if(UsePredefinedTemplate=='y')
           {
               system.debug(OppId);
               OppId = OppId.substring(0,18);
             List<Opportunity__c> salesOppList = Database.query('SELECT Id, Name, AccountId__c FROM Opportunity__c where Standard_Opportunity__c = :OppId'); Opportunity__c salesOpp=salesOppList[0];
               	String SalesOppName = salesOpp.Name; integer SNLength = SalesOppName.length(); Integer PNLength  = (Project.Name).length(); if(SNLength + PNLength + 1>=80){SalesOppName = SalesOppName.left(78 - PNLength);}  
                project.Name=SalesOppName+' '+Project.Name; project.Project_Opportunity__c = OppId; project.Project_Account__c =salesOpp!=null?salesOpp.AccountId__c:null;project.Sales_Opportunity__c =salesOpp!=null?salesOpp.Id:null;
            update project;
            
           }
        }
        catch( Exception e ) {
            ApexPages.Message errorMsg = new ApexPages.Message( ApexPages.Severity.FATAL, e.getMessage() );
            System.debug(e.getMessage());
            if(e.getMessage() != null && e.getMessage().contains(CONTENT_ERROR)) {
                errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL,Milestone1_Import_Exception.ERROR_INVALID_XML);
            }
            ApexPages.addMessage( errorMsg );
            return ApexPages.currentPage();
        }
        return new ApexPages.StandardController(project).view();
    }
   
    
    global String getDocumentXMLString() {
        
        List<Document> docs = new List<Document>();
        
        if (Schema.sObjectType.Document.isCreateable()) {
        	docs = [Select Id, Body, ContentType From Document Where Id = :docId limit 1];
        } else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: User is unauthorized to act on this object/field.'));
		}    
            
        if(docs.size() != 0)
        {
            String xml = docs.get(0).body.toString();
            return xml;
        }else
        {
            throw new Milestone1_Import_Exception(Milestone1_Import_Exception.ERROR_NO_FILE_SELECTED);
        }
    }
 
}
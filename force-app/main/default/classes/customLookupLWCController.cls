/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-09-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-09-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class customLookupLWCController {


    // Method to fetch lookup search result   
     @AuraEnabled(cacheable=false)
     public static list<sObject> fetchLookupData(string searchKey ,String displayField, String fieldstoquery, string sObjectApiName ,string whereClause) {    
         System.debug(searchKey);
         System.debug(whereClause);

         System.debug(displayField);
         List < sObject > returnList = new List < sObject > ();
 
         string sWildCardText = '%' + searchKey + '%';
         string extraField = displayField=='Name'?'':','+displayField;
         
         string sQuery = 'Select Id,Name '+extraField+fieldstoquery+' From ' + sObjectApiName + ' Where '+displayField+' Like : sWildCardText '+whereClause+ ' order by createdDate DESC LIMIT 5';
         System.debug(sQuery);
         for (sObject obj: database.query(sQuery)) {
             returnList.add(obj);
         }
         return returnList;
     }
     
     // Method to fetch lookup default value 
     @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , String displayField,string sObjectApiName ,string whereClause) {
         string sRecId = recordId;    

         string extraField = displayField=='Name'?'':','+displayField;
         string sQuery = 'Select Id,Name '+extraField+' From ' + sObjectApiName + ' Where  Id = : sRecId LIMIT 1';
         for (sObject obj: database.query(sQuery)) {
             return obj;
         }
         return null;
     }
     
 
}
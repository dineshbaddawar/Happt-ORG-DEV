/**
 * @description       : 
 * @author            : Dhanush Babu
 * @group             : 
 * @last modified on  : 03-02-2023
 * @last modified by  : Dhanush Babu
**/
public with sharing class FetchObjectsFields {
    
        @AuraEnabled//Method to get the List of All Objects
        public static Map<String, String> getAllObject(){
            
            Map<String,String> returnObjectMap = new Map<String,String>();
            
            //Schema.getGlobalDescribe() => return a Map of type Map<String, Schema.SObjectType>
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            
            //get List of all sObject
            List<Schema.SObjectType> objectMapValues = objectMap.Values();
            System.debug('All Objects '+ objectMapValues);
            
            //prepare a Map to send Data from Server to Client Side
            
            for(Schema.SObjectType objType : objectMapValues){
         
              
                if(objType.getDescribe().isAccessible() && objType.getDescribe().isSearchable()){
                String key = objType.getDescribe().getName();
                String value = objType.getDescribe().getLabel();
                returnObjectMap.put(key,value);
                }
            }
            System.debug(returnObjectMap.size());
            if(returnObjectMap != null && returnObjectMap.size() > 0){
                return returnObjectMap;
            }else{
                return null;
            }
        }
        
        @AuraEnabled //Method to get all the fields of a particular Object
        public static Map<String,string> getAllfields(String objectName){
            List<String> allFields = new List<String>();
            
            Map<String, Schema.SObjectType> objectMap = Schema.getGlobalDescribe();
            SObjectType objType = objectMap.get(objectName);
            
            // Map of fields with api name and Api name as value
            Map<String,Schema.SObjectField> objTypeFields = objType.getDescribe().fields.getMap();
            
            Map<String,String> MapTobereturn = new Map<String,String>();
            
            
            if(!objTypeFields.isEmpty()){
                
                for (String fieldName: objTypeFields.keySet()) {
                    system.debug('');
                    
                    //getting labels and Name of the fields as used in Apex
                    String fieldLabel = objTypeFields.get(fieldName).getDescribe().getLabel();
                    string ApiName = objTypeFields.get(fieldName).getDescribe().getName();
                    
                    system.debug('@@@@@@' + ApiName);
                    
                    //allFields.add(fieldLabel);
                    MapTobereturn.put(ApiName, fieldLabel);
                }
                
                
            }
            
            System.debug(MapTobereturn);
            System.debug(objTypeFields);
            return MapTobereturn;
        }
    }
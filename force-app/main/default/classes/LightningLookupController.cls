/* 	
*/
public with sharing class LightningLookupController 
{


	// Description	: executes the SOQL query and return records.
	// @param 		: sObjectName - name of SObject 
	// @param 		: valueFieldName - name of field from object to use as the value of the pick list 
	// @param 		: displayedFieldName - name of field from object to display in pick list 
	// @param 		: whereClause - optional where clause to add to the SOQL query 
	// @param		: filteredFieldName - optional field name for filter value
	// @param		: filterValue - filter value for filter field
	@AuraEnabled
	public static LookupRecords getRecords(String sObjectName, String valueFieldName, 
											String displayedFieldName, String otherFields, String whereClause,
                                          	String filteredFieldName, String filterFieldValue)
	{
		try
		{
			
            Boolean checkIfanyBlank  = valueFieldName == null || displayedFieldName == null || valueFieldName == '' || displayedFieldName == '';
            if(checkIfanyBlank)
            {
                return null;
            }
            sObjectName = String.escapeSingleQuotes(sObjectName); 
            if(valueFieldName != null) {valueFieldName = String.escapeSingleQuotes(valueFieldName); }
            if(displayedFieldName != null){ displayedFieldName = String.escapeSingleQuotes(displayedFieldName); }
            if(otherFields != null) {otherFields = String.escapeSingleQuotes(otherFields); }
            if(filteredFieldName != null) { filteredFieldName = String.escapeSingleQuotes(filteredFieldName); }
            if(filterFieldValue != null) { filterFieldValue = String.escapeSingleQuotes(filterFieldValue); }
           
            LookupRecords retVal = new LookupRecords();

			
          
		
            retVal = queryRecords(sObjectName,valueFieldName,displayedFieldName,otherFields,whereClause,filteredFieldName,filterFieldValue);
         /*   SObject[] lstRec = Database.query(soql);
			if(lstRec.isEmpty()){
				retVal.add(Schema.getGlobalDescribe().get(sObjectName).newSObject(),'','No records found!');
			}
			for( SObject obj : lstRec)
			{
				retVal.add( obj,
							String.valueOf(obj.get(valueFieldName)), 
							String.valueOf(obj.get(displayedFieldName)));
			}*/

			return retVal;
		}
		catch (Exception ex)
		{
			throw new AuraHandledException('Exception occured:\r\n' + ex.getMessage() + '\r\n' + ex.getStackTraceString() + '\r\n');
		}
	}
	
    public static LookupRecords queryRecords (String sObjectName, String valueFieldName, 
											String displayedFieldName,String otherFields,String whereClause,
                                              String filteredFieldName, String filterFieldValue)
    {
        Boolean isOtherFieldsBlank  = otherFields == null || otherFields == '';
        String soql = 'Select ' + valueFieldName + ',' + displayedFieldName;
        soql += isOtherFieldsBlank ? '' : ',' + otherFields ;
        soql += ' FROM ' + sObjectName;
        Boolean isWhere = (whereClause != null && whereClause != '');
        Boolean isFilter = (filterFieldValue != null && filterFieldValue != '' && filteredFieldName != null && filteredFieldName != '');
        
        Boolean isWhereandFilter = isWhere && isFilter;
        Boolean isWhereORFilter = isWhere || isFilter;
        if(isWhereORFilter)
        {
            soql += ' WHERE ';
        }
        if(isWhere)
        {
            soql += whereClause;
        }
        if(isWhereandFilter)
        {
            soql += ' AND ';
        }
        if (isFilter)
        {
            soql += filteredFieldName + '=\'' + filterFieldValue + '\'';
        }
        
        soql += ' ORDER BY ' + displayedFieldName + ' Limit 100';
        system.debug('========> soql = ' + soql);
        LookupRecords retVal = new LookupRecords();
        SObject[] lstRec = Database.query(soql);
			if(lstRec.isEmpty()){
				retVal.add(Schema.getGlobalDescribe().get(sObjectName).newSObject(),'','No records found!');
			}
			for( SObject obj : lstRec)
			{
				retVal.add( obj,
							String.valueOf(obj.get(valueFieldName)), 
							String.valueOf(obj.get(displayedFieldName)));
			}

			return retVal;
    }
    
    
	/**
	 * gets the help text from the field
	 * @param  field [Full Name of the field to describe]
	 * @return       [Help text of given field]
	 */
	@AuraEnabled
	public static String getHelpText(String field){
		try{
			String[] data = field.split('\\.');
			return Schema.getGlobalDescribe().get(data[0]).getDescribe().fields.getMap().get(data[1]).getDescribe().getInlineHelpText();
		}
		catch(Exception ex){
			throw new AuraHandledException('Exception occured:\r\n' + ex.getMessage() + '\r\n' + ex.getStackTraceString() + '\r\n');
		}
	}

	/**
	 * gets the object that the given field is a lookup for
	 * NOTE: does not support polymorphic fields
	 * @param  field [Full Name of the field to describe]
	 * @return       [SObject Name of the lookup reference]
	 */
	@AuraEnabled
	public static String getReference(String field){
		try{
			String[] data = field.split('\\.');
			Schema.DescribeFieldResult f = Schema.getGlobalDescribe().get(data[0]).getDescribe().fields.getMap().get(data[1]).getDescribe();
			return f.getReferenceTo()[0].getDescribe().getName();
		}
		catch(Exception ex){
			throw new AuraHandledException('Exception occured:\r\n' + ex.getMessage() + '\r\n' + ex.getStackTraceString() + '\r\n');
		}
	}

	/**
	 * gets the data needed for lookup component based on id provided to the component on init
	 * @param  obj   [SObject API]
	 * @param  objId [Record Id]
	 * @param  label [Search label]
	 * @return       [LookupRecords wrapper]
	 */
	@AuraEnabled
	public static LookupRecords getFieldValue(String obj, String objId, String label){
		try{
			String q = 'Select Id, ' + label + ' from ' + obj + ' where Id = \'' + objId + '\'';
			LookupRecords retVal = new LookupRecords();
			for(SObject so :Database.query(q)){
				retVal.add(so,(String)so.get('Id'),(String)so.get(label));
			}
			return retVal;
		}
		catch(Exception ex){
			throw new AuraHandledException('Exception occured:\r\n' + ex.getMessage() + '\r\n' + ex.getStackTraceString() + '\r\n');
		}
	}

	// Description : Class for return value of getRecords method
	public Class LookupRecords
	{
		@AuraEnabled public List<SObject> lstRecords;
		@AuraEnabled public List<String> lstValue; // list of values corresponding to the display values
		@AuraEnabled public List<String> lstDisplay; // list of display values

		public void add(SObject obj, String value, String display)
		{
			if(lstValue == null)
			{
				lstValue = new List<String>();
			}
			if(lstDisplay == null)
			{
				lstDisplay = new List<String>();
			}
			if(lstRecords == null)
			{
				lstRecords = new List<SObject>();
			}

			lstValue.add(value);	
			lstDisplay.add(display);
			lstRecords.add(obj);
		}
	}

}
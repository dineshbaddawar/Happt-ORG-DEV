@isTest
public class TestUpdateStageOnLeadController {
    
    @isTest
    static void testGetPickListValuesIntoList() {
        // Create a test lead record with EPIC record type
        String epicRecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead' AND Name = 'EPIC' LIMIT 1].Id;
        String teRecordTypeId = [SELECT Id, Name FROM RecordType WHERE SObjectType = 'Lead' AND Name = 'Travel & Expense' LIMIT 1].Id;
        Lead testLeadEPIC = new Lead(
            RecordTypeId = epicRecordTypeId,
            Status = 'Contacted',
            Company = 'Test',
            FirstName = 'Te33st',
            LastName = 'N33ame',
            Email = 'te33st@gmail.com',
            Phone = '3876543456'     
        );
        insert testLeadEPIC;

        // Call the method and verify picklist values
        List<String> picklistValuesEPIC = UpdateStageOnLeadController.getPickListValuesIntoList(testLeadEPIC.Id);
       
        // Create a test lead record with Travel & Expense record type
        Lead testLeadTravelExpense = new Lead(
            RecordTypeId = teRecordTypeId,
            Status = 'Open',
            Company = 'Testww1',
            FirstName = 'Testww1',
            LastName = 'Nawwwme'
        );
        insert testLeadTravelExpense;

        // Call the method and verify picklist values
        List<String> picklistValuesTravelExpense = UpdateStageOnLeadController.getPickListValuesIntoList(testLeadTravelExpense.Id);
        
    }

    @isTest
    static void testUpdateLeadStatus() {
        // Create a test lead record
        Lead testLead = new Lead(Status = 'Open', Company = 'Test2', FirstName = 'Test2', LastName = 'Name');
        insert testLead;

        // Test the updateLeadStatus method for a lead with 'Open' status
        String resultOpenStatus = UpdateStageOnLeadController.updateLeadStatus(testLead, testLead.Id);
        

        // Test the updateLeadStatus method for a lead with 'Converted' status
        testLead.Status = 'Converted';
        String resultConvertedStatus = UpdateStageOnLeadController.updateLeadStatus(testLead, testLead.Id);
      

        // Simulate a DML exception by setting an invalid status
        testLead.Status = 'InvalidStatus';
        String resultInvalidStatus = UpdateStageOnLeadController.updateLeadStatus(testLead, testLead.Id);
      
    }
}
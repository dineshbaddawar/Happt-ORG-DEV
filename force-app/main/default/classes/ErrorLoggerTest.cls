@isTest
private class ErrorLoggerTest {
    @isTest static void myTest() {
        
		ErrorLogger.createLogError('Anon Window', 'Test Apex Code','Limit Exception',
                     'Hey this is a description Dump Exverything here', 'API Error code 500',
                     'RecordID', 
                                   'Put the JSON Here');
        
        ErrorLogger.LogError('Anon Window', 'Test Apex Code','Limit Exception',
                                   'Hey this is a description Dump Exverything here', 'API Error code 500',
                                   'RecordID', 
                                   'Put the JSON Here');

    }
}
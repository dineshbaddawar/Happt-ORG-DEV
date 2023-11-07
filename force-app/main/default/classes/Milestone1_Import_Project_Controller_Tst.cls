/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
@isTest
private class Milestone1_Import_Project_Controller_Tst {
    
    static testMethod void testImportController() {
        
        Document testDoc = new Document();
        testDoc.Name = 'EXPORT UNIT TEST XYZABC' + System.now();
        String body = '<?xml version="1.0"?><export><meta><exportPackage>Milestone1_Project_Export</exportPackage><exportAuthor>Admin+User</exportAuthor><exportOrganization>Force.com+Labs+PM</exportOrganization><exportCreateDate>2010-07-28+21%3A39%3A39</exportCreateDate><exportVersion>1.0</exportVersion></meta><Milestone1_Project__c><Id>a03A0000001PchPIAS</Id><Total_Expense_Estimate__c>1.00</Total_Expense_Estimate__c><Total_Expense_Budget__c>null</Total_Expense_Budget__c><Status__c>null</Status__c><Description__c>abc</Description__c><Description__c>null</Description__c><Milestone1_Milestone__c><Id>a02A0000002UR8YIAW</Id><Deadline__c>2010-07-29+00%3A00%3A00</Deadline__c><Description__c>Description+for+UNIT+TEST+MILESTONE+NAME+ACB123XYZ+UNIQUE2010-07-28+21%3A39%3A39</Description__c><Expense_Budget__c>15665.37</Expense_Budget__c><Hour_Budget__c>null</Hour_Budget__c><Hours_Budget__c>246.59</Hours_Budget__c><Milestone1_Milestone__c><Id>a02A0000002UR8aIAG</Id><Deadline__c>2010-07-25+00%3A00%3A00</Deadline__c><Description__c>Description+for+UNIT+TEST+MILESTONE+NAME3+ACB123XYZ+UNIQUE2010-07-28+21%3A39%3A39</Description__c><Expense_Budget__c>32904.61</Expense_Budget__c><Hour_Budget__c>null</Hour_Budget__c><Hours_Budget__c>454.30</Hours_Budget__c><Name>UNIT+TEST+MILESTONE+NAME3+ACB123XYZ+UNIQUE2010-07-28+21%3A39%3A39</Name></Milestone1_Milestone__c><Name>UNIT+TEST+MILESTONE+NAME+ACB123XYZ+UNIQUE2010-07-28+21%3A39%3A39</Name></Milestone1_Milestone__c><Milestone1_Milestone__c><Id>a02A0000002UR8ZIAW</Id><Deadline__c>2010-08-03+00%3A00%3A00</Deadline__c><Description__c>Description+for+UNIT+TEST+MILESTONE+NAME2+ACB123XYZ+UNIQUE2010-07-28+21%3A39%3A39</Description__c><Expense_Budget__c>823.57</Expense_Budget__c><Hour_Budget__c>null</Hour_Budget__c><Hours_Budget__c>352.72</Hours_Budget__c><Name>UNIT+TEST+MILESTONE+NAME2+ACB123XYZ+UNIQUE2010-07-28+21%3A39%3A39</Name></Milestone1_Milestone__c><Name>UNIT_TEST_NAME_XYZABC</Name></Milestone1_Project__c></export>';
        testDoc.body = Blob.valueOf(body);
        
        List<Document> docs = new List<Document>{testDoc};
        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new List<Milestone1_Project__c>());
        Milestone1_Import_Project_Controller testController = new Milestone1_Import_Project_Controller(ssc);
        testController.fileBody = testDoc.body;
        testController.fileName = 'UNIT TEST.XML';
        testController.docId = testDoc.Id;
        testController.importTemplateXML();
        
       // System.assert(testController.project != null);
        //System.assert(testController.project.Name == 'UNIT_TEST_NAME_XYZABC');
        //System.assert(testController.project.Id != null);
        
    }
    
    static testMethod void testImportControllerNoFileException() {
        
        //List<Document> docs = [Select Id from Document];
        //delete docs;
        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new List<Milestone1_Project__c>());
        Milestone1_Import_Project_Controller testController = new Milestone1_Import_Project_Controller(ssc);
        testController.fileBody = null;
        testController.fileName = null;
        testController.docId = null;
        try
        {
            testController.importTemplateXML();
        }catch(Exception e)
        {
            System.assert(testController.project == null);
            Boolean expectedExceptionThrown =  e.getMessage().contains(Milestone1_Import_Exception.ERROR_NO_FILE_SELECTED) ? true : false;
            System.assertEquals(expectedExceptionThrown,true);
        }   
    }
    
    static testMethod void testImportControllerInvalidXML() {
        
        Document testDoc = new Document();
        testDoc.Name = 'EXPORT UNIT TEST XYZABC' + System.now();
        String body = 'This is not an XML file';
        testDoc.body = Blob.valueOf(body);
        testDoc.FolderId = UserInfo.getUserId();
        insert testDoc;
        
        List<Document> docs = new List<Document>{testDoc};
        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new List<Milestone1_Project__c>());
        Milestone1_Import_Project_Controller testController = new Milestone1_Import_Project_Controller(ssc);
        testController.fileBody = testDoc.body;
        testController.fileName = 'UNIT TEST.XML';
        testController.docId = testDoc.Id;
        testController.importTemplateXML();
        
        System.assert(testController.project == null);
    }
    
    static testMethod void testImportControllerValidFromDocsFolder() {
        
        Document testDoc = new Document();
        testDoc.Name = 'EXPORT UNIT TEST XYZABC' + System.now();
        String body = '<?xml version="1.0"?><export><meta><exportPackage>Milestone1_Project_Export</exportPackage><exportAuthor>Vijay+Gupta</exportAuthor><exportOrganization>Happay</exportOrganization><exportCreateDate>2021-07-06+16%3A43%3A07</exportCreateDate><exportVersion>1.0</exportVersion></meta><Milestone1_Project__c><Id>a055g000000gEgcAAE</Id><Total_Hours_Budget__c>0.00</Total_Hours_Budget__c><Total_Expense_Budget__c>0.00</Total_Expense_Budget__c><Name>TT+Project</Name><Milestone1_Milestone__c><Id>a035g000002mjTKAAY</Id><Expense_Budget__c>0.00</Expense_Budget__c><Hours_Budget__c>0.00</Hours_Budget__c><Name>Go+Live</Name><Kickoff__c>2021-08-24+00%3A00%3A00</Kickoff__c><Deadline__c>2021-09-06+00%3A00%3A00</Deadline__c></Milestone1_Milestone__c><Milestone1_Milestone__c><Id>a035g000002mjTLAAY</Id><Expense_Budget__c>0.00</Expense_Budget__c><Hours_Budget__c>189.00</Hours_Budget__c><Name>BluePrint+Sign+off</Name><Kickoff__c>2021-07-06+00%3A00%3A00</Kickoff__c><Deadline__c>2021-07-27+00%3A00%3A00</Deadline__c><Milestone1_Task__c><Id>a075g000002flgjAAA</Id><Name>Config+Handover</Name><Estimated_Hours__c>45.00</Estimated_Hours__c><Start_Date__c>2021-07-06+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-12+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTLAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgkAAA</Id><Name>Scope+Validation+and+Sign+off+by+IM</Name><Estimated_Hours__c>18.00</Estimated_Hours__c><Start_Date__c>2021-07-27+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-27+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTLAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flglAAA</Id><Name>Final+Project+Plan+with+dates+upto+Go+Live</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-07-13+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-15+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTLAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgmAAA</Id><Name>Project+Updates</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-07-16+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-20+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTLAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgnAAA</Id><Name>Internal+Handover+to+IM+by+Config%2FTesting+Manager</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-07-27+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-27+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTLAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgoAAA</Id><Name>Internal+Testing</Name><Estimated_Hours__c>18.00</Estimated_Hours__c><Start_Date__c>2021-07-26+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-27+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTLAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgpAAA</Id><Name>Integrations</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-07-21+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-23+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTLAAY</Project_Milestone__c></Milestone1_Task__c></Milestone1_Milestone__c><Milestone1_Milestone__c><Id>a035g000002mjTMAAY</Id><Expense_Budget__c>0.00</Expense_Budget__c><Hours_Budget__c>90.00</Hours_Budget__c><Name>UAT+Handover</Name><Kickoff__c>2021-07-28+00%3A00%3A00</Kickoff__c><Deadline__c>2021-08-10+00%3A00%3A00</Deadline__c><Milestone1_Task__c><Id>a075g000002flgqAAA</Id><Name>UAT+Documents+%28Test+Users+Data%2C+Test+Scenarios%2C+Observation+Tracker%29+along+with</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-08-02+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-08-04+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTMAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgrAAA</Id><Name>UAT+Sign+Off</Name><Estimated_Hours__c>18.00</Estimated_Hours__c><Start_Date__c>2021-08-06+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-08-10+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTMAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgsAAA</Id><Name>Change+Request</Name><Estimated_Hours__c>18.00</Estimated_Hours__c><Start_Date__c>2021-08-05+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-08-06+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTMAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgtAAA</Id><Name>Customer+UAT+handover+demo</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-07-28+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-30+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTMAAY</Project_Milestone__c></Milestone1_Task__c></Milestone1_Milestone__c><Milestone1_Milestone__c><Id>a035g000002mjTNAAY</Id><Expense_Budget__c>0.00</Expense_Budget__c><Hours_Budget__c>45.00</Hours_Budget__c><Name>Customer+Readiness</Name><Kickoff__c>2021-06-15+00%3A00%3A00</Kickoff__c><Deadline__c>2021-06-20+00%3A00%3A00</Deadline__c><Milestone1_Task__c><Id>a075g000002flguAAA</Id><Name>Deals+Team+compliance+checklist</Name><Estimated_Hours__c>9.00</Estimated_Hours__c><Start_Date__c>2021-06-15+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-06-15+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTNAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgvAAA</Id><Name>Deals+Team+introduction</Name><Estimated_Hours__c>9.00</Estimated_Hours__c><Start_Date__c>2021-06-16+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-06-16+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTNAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgwAAA</Id><Name>Customer+Readiness+Confirmation</Name><Estimated_Hours__c>9.00</Estimated_Hours__c><Start_Date__c>2021-06-16+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-06-16+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTNAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgxAAA</Id><Name>Kick+off+meeting+to+be+scheduled</Name><Estimated_Hours__c>18.00</Estimated_Hours__c><Start_Date__c>2021-06-17+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-06-18+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTNAAY</Project_Milestone__c></Milestone1_Task__c></Milestone1_Milestone__c><Milestone1_Milestone__c><Id>a035g000002mjTOAAY</Id><Expense_Budget__c>0.00</Expense_Budget__c><Hours_Budget__c>135.00</Hours_Budget__c><Name>Project+Kickoff</Name><Kickoff__c>2021-06-21+00%3A00%3A00</Kickoff__c><Deadline__c>2021-07-05+00%3A00%3A00</Deadline__c><Milestone1_Task__c><Id>a075g000002flgyAAA</Id><Name>Deals+Team+Support+for+internal+and+external+issues</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-07-02+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-05+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTOAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flgzAAA</Id><Name>Scope+Sign+off</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-07-05+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-05+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTOAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flh0AAA</Id><Name>Kick+Off+Meeting</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-06-21+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-06-23+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTOAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flh1AAA</Id><Name>Project+Updates+and+Review+Calls</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-06-29+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-07-01+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTOAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flh2AAA</Id><Name>Implementation+Workshops</Name><Estimated_Hours__c>27.00</Estimated_Hours__c><Start_Date__c>2021-06-24+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-06-28+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTOAAY</Project_Milestone__c></Milestone1_Task__c></Milestone1_Milestone__c><Milestone1_Milestone__c><Id>a035g000002mjTPAAY</Id><Expense_Budget__c>0.00</Expense_Budget__c><Hours_Budget__c>45.00</Hours_Budget__c><Name>UAT+Sign+off</Name><Kickoff__c>2021-08-11+00%3A00%3A00</Kickoff__c><Deadline__c>2021-08-24+00%3A00%3A00</Deadline__c><Milestone1_Task__c><Id>a075g000002flh3AAA</Id><Name>Go+Live+Checklist+and+Activity+Tracker</Name><Estimated_Hours__c>9.00</Estimated_Hours__c><Start_Date__c>2021-08-13+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-08-13+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTPAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flh4AAA</Id><Name>Change+Management+%26+Training</Name><Estimated_Hours__c>9.00</Estimated_Hours__c><Start_Date__c>2021-08-16+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-08-16+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTPAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flh5AAA</Id><Name>Go+Live</Name><Estimated_Hours__c>9.00</Estimated_Hours__c><Start_Date__c>2021-08-17+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-08-17+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTPAAY</Project_Milestone__c></Milestone1_Task__c><Milestone1_Task__c><Id>a075g000002flh6AAA</Id><Name>AM+Assignment</Name><Estimated_Hours__c>18.00</Estimated_Hours__c><Start_Date__c>2021-08-11+00%3A00%3A00</Start_Date__c><Due_Date__c>2021-08-12+00%3A00%3A00</Due_Date__c><Project_Milestone__c>a035g000002mjTPAAY</Project_Milestone__c></Milestone1_Task__c></Milestone1_Milestone__c></Milestone1_Project__c></export>';
        testDoc.body = Blob.valueOf(body);
        testDoc.FolderId = UserInfo.getUserId();
        insert testDoc;
        
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(new List<Milestone1_Project__c>());
        Milestone1_Import_Project_Controller testController = new Milestone1_Import_Project_Controller(ssc);
        testController.docId = testDoc.Id;
        testController.importTemplateXML();
        
       // System.assert(testController.project != null);
        //System.assert(testController.project.Name == 'UNIT_TEST_NAME_XYZABC');
        //System.assert(testController.project.Id != null);
        
    }
}
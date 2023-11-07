@isTest
public class PlaybookAIWebhookApexTriggerInsertTest {

    static SObject mock(String sobjectName) {
        SObjectType t = Schema.getGlobalDescribe().get(sobjectName);

        SObject o = t.newSobject();

        Map<String, Schema.SObjectField> m = t.getDescribe().fields.getMap();

        for (String fieldName : m.keySet()) {
            DescribeFieldResult f = m.get(fieldName).getDescribe();
            if (!f.isNillable() && f.isCreateable() && !f.isDefaultedOnCreate()) {
                if (f.getType() == DisplayType.Boolean) {
                    o.put(f.getName(), false);
                }
                else if (f.getType() == DisplayType.Currency) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Date) {
                    o.put(f.getName(), Date.today());
                }
                else if (f.getType() == DisplayType.DateTime) {
                    o.put(f.getName(), System.now());
                }
                else if (f.getType() == DisplayType.Double) {
                    o.put(f.getName(), 0.0);
                }
                else if (f.getType() == DisplayType.Email) {
                    o.put(f.getName(), 'foo@foo.com');
                }
                else if (f.getType() == DisplayType.Integer) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Percent) {
                    o.put(f.getName(), 0);
                }
                else if (f.getType() == DisplayType.Phone) {
                    o.put(f.getName(), '555-555-1212');
                }
                else if (f.getType() == DisplayType.String) {
                    o.put(f.getName(), 'TEST');
                }
                else if (f.getType() == DisplayType.TextArea) {
                    o.put(f.getName(), 'TEST');
                }
                else if (f.getType() == DisplayType.Time) {
                    o.put(f.getName(), System.now().time());
                }
                else if (f.getType() == DisplayType.URL) {
                    o.put(f.getName(), 'http://foo.com');
                }
                else if (f.getType() == DisplayType.PickList) {
                    o.put(f.getName(), f.getPicklistValues()[0].getValue());
                }
            }
        }
        return o;
    }

    @isTest static void testTrigger() {
        SObject o = mock('Lead');

        Test.startTest();
        insert o;
        Test.stopTest();


        if (PlaybookAIWebhookApex.request != null) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(PlaybookAIWebhookApex.request.getBody());
            System.assertNotEquals(null, jsonResponse.get('userId'));
        }
    }
    
    @isTest static void testEmptyJsonContent() {
        String userId = JSON.serialize(UserInfo.getUserId());
        String content = '{"new": [], "old": [], "userId": ' + userId + '}';
        System.assertEquals(content , PlaybookAIWebhookApex.jsonContent(null,null));
    }
    
    @isTest static void testJsonContentNew() {
        String newObjects = '[]';
        List<Lead> newLeadList = new List<Lead>();
        List<Lead> oldLeadList = new List<Lead>();
        Lead objLead = new Lead (LastName = 'Test', Email = 'test@gmail.com', Company = 'Test company');
        newLeadList.add(objLead);
        String userId = JSON.serialize(UserInfo.getUserId());
        newObjects = JSON.serialize(newLeadList);
        String content = '{"new": '+newObjects+', "old": [], "userId": ' + userId + '}';
        System.assertEquals(content , PlaybookAIWebhookApex.jsonContent(newLeadList,null));
    }
    
    @isTest static void testJsonContentOld() {
        String oldObjects = '[]';
        List<Lead> newLeadList = new List<Lead>();
        List<Lead> oldLeadList = new List<Lead>();
        Lead objLead = new Lead (LastName = 'Test', Email = 'test@gmail.com', Company = 'Test company');
        oldLeadList.add(objLead);
        String userId = JSON.serialize(UserInfo.getUserId());
        oldObjects = JSON.serialize(oldLeadList);
        String content = '{"new": [], "old": '+oldObjects+', "userId": ' + userId + '}';
        System.assertEquals(content , PlaybookAIWebhookApex.jsonContent(null,oldLeadList));
    }
    
    @isTest static void testCalloutData() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new PlaybookAIWebhookApex());
        test.startTest();

        PlaybookAIWebhookApex.callout('https://integrator.playbook.ai/api/salesforce/notified?user_id=111&event_type=insert','{"new":[{"id":"001"}]}');

        test.stopTest();

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse res= PlaybookAIWebhookApex.response;
        
        // Verify response received contains fake values
        
        String actualValue = res.getBody();
        String expectedValue = '';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }
    
    
    @isTest static void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new PlaybookAIWebhookApex());
        test.startTest();

        PlaybookAIWebhookApex.callout('https://integrator.playbook.ai/api/salesforce/notified?user_id=111&event_type=insert','{}');

        test.stopTest();

        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        HttpResponse res= PlaybookAIWebhookApex.response;
        
        // Verify response received contains fake values
        
 
        String actualValue = res.getBody();
        String expectedValue = '';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }

}
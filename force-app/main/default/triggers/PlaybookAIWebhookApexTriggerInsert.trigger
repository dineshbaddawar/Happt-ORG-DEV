trigger PlaybookAIWebhookApexTriggerInsert on Lead (after insert) {

    String url = 'https://integrator.playbook.ai/api/salesforce/notified?AID=3&event_type=insert';

    String content = PlaybookAIWebhookApex.jsonContent(Trigger.new, Trigger.old);

    PlaybookAIWebhookApex.callout(url, content);

}
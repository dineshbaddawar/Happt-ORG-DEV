trigger PlaybookAIWebhookApexTriggerUpdate on Lead (after update) {

    String url = 'https://integrator.playbook.ai/api/salesforce/notified?AID=3&event_type=update';

    String content = PlaybookAIWebhookApex.jsonContent(Trigger.new, Trigger.old);

    PlaybookAIWebhookApex.callout(url, content);

}
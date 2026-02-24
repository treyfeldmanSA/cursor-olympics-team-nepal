public class InboundEmailHandler_NEPAL implements Messaging.InboundEmailHandler {

    public Messaging.InboundEmailResult handleInboundEmail(
        Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope
    ) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();

        try {
            Inbound_Request_NEPAL__c request = new Inbound_Request_NEPAL__c();
            request.Subject__c = email.subject;
            request.From_Email__c = email.fromAddress;
            request.Body__c = email.plainTextBody;
            request.Message_Id__c = email.messageId;
            request.Status__c = 'New';
            request.Email_Time__c = DateTime.now();

            insert request;

            result.success = true;
        } catch (Exception e) {
            result.success = false;
            result.message = e.getMessage();
        }

        return result;
    }
}

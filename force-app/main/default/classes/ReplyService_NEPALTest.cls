@isTest
private class ReplyService_NEPALTest {

    @TestSetup
    static void setupTestData() {
        Inbound_Request_NEPAL__c request = new Inbound_Request_NEPAL__c(
            Subject__c = 'Test Subject',
            From_Email__c = 'sender@example.com',
            Body__c = 'Test email body content',
            Message_Id__c = 'MSG-TEST-001',
            Status__c = 'New',
            Email_Time__c = DateTime.now()
        );
        insert request;
    }

    @isTest
    static void testSendReply() {
        Inbound_Request_NEPAL__c request = [
            SELECT Id, Status__c, Last_Reply_At__c
            FROM Inbound_Request_NEPAL__c
            LIMIT 1
        ];

        System.assertEquals('New', request.Status__c, 'Initial status should be New');
        System.assertEquals(null, request.Last_Reply_At__c, 'Last_Reply_At__c should be null initially');

        Test.startTest();
        ReplyService_NEPAL.sendReply(
            request.Id,
            'Thank you for your message.',
            null,
            null
        );
        Test.stopTest();

        Inbound_Request_NEPAL__c updated = [
            SELECT Id, Status__c, Last_Reply_At__c
            FROM Inbound_Request_NEPAL__c
            WHERE Id = :request.Id
        ];

        System.assertEquals('Replied', updated.Status__c, 'Status should be Replied after sending reply');
        System.assertNotEquals(null, updated.Last_Reply_At__c, 'Last_Reply_At__c should be populated after reply');
    }

    @isTest
    static void testSendReplyWithCcBcc() {
        Inbound_Request_NEPAL__c request = [
            SELECT Id FROM Inbound_Request_NEPAL__c LIMIT 1
        ];

        Test.startTest();
        ReplyService_NEPAL.sendReply(
            request.Id,
            'Reply with CC and BCC',
            'cc@example.com',
            'bcc@example.com'
        );
        Test.stopTest();

        Inbound_Request_NEPAL__c updated = [
            SELECT Id, Status__c, Last_Reply_At__c
            FROM Inbound_Request_NEPAL__c
            WHERE Id = :request.Id
        ];

        System.assertEquals('Replied', updated.Status__c, 'Status should be Replied');
        System.assertNotEquals(null, updated.Last_Reply_At__c, 'Last_Reply_At__c should be populated');
    }

    @isTest
    static void testInboundEmailHandler() {
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Inbound Test Subject';
        email.fromAddress = 'inbound@example.com';
        email.plainTextBody = 'Inbound test body';
        email.messageId = 'MSG-INBOUND-001';

        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();

        Test.startTest();
        InboundEmailHandler_NEPAL handler = new InboundEmailHandler_NEPAL();
        Messaging.InboundEmailResult result = handler.handleInboundEmail(email, envelope);
        Test.stopTest();

        System.assertEquals(true, result.success, 'Inbound email handling should succeed');

        Inbound_Request_NEPAL__c created = [
            SELECT Subject__c, From_Email__c, Body__c, Message_Id__c, Status__c, Email_Time__c
            FROM Inbound_Request_NEPAL__c
            WHERE Message_Id__c = 'MSG-INBOUND-001'
            LIMIT 1
        ];

        System.assertEquals('Inbound Test Subject', created.Subject__c);
        System.assertEquals('inbound@example.com', created.From_Email__c);
        System.assertEquals('Inbound test body', created.Body__c);
        System.assertEquals('New', created.Status__c);
        System.assertNotEquals(null, created.Email_Time__c);
    }
}

public with sharing class ReplyService_NEPAL {

    @AuraEnabled(cacheable=true)
    public static List<Inbound_Request_NEPAL__c> getInboundRequests() {
        return [
            SELECT Id, Name, Subject__c, From_Email__c, Body__c, Message_Id__c,
                   Status__c, Email_Time__c, Last_Reply_At__c
            FROM Inbound_Request_NEPAL__c
            ORDER BY Email_Time__c DESC
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static void sendReply(Id recordId, String replyBody, String ccAddresses, String bccAddresses) {
        Inbound_Request_NEPAL__c request = [
            SELECT Id, Subject__c, From_Email__c, Body__c
            FROM Inbound_Request_NEPAL__c
            WHERE Id = :recordId
            LIMIT 1
        ];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ request.From_Email__c });
        mail.setSubject('[NEPAL] Re: ' + request.Subject__c);
        mail.setPlainTextBody(replyBody);

        if (String.isNotBlank(ccAddresses)) {
            mail.setCcAddresses(ccAddresses.split(','));
        }
        if (String.isNotBlank(bccAddresses)) {
            mail.setBccAddresses(bccAddresses.split(','));
        }

        if (!Test.isRunningTest()) {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ mail });
        }

        request.Status__c = 'Replied';
        request.Last_Reply_At__c = DateTime.now();
        update request;
    }
}

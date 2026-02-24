Inbound_Request_NEPAL__c req = new Inbound_Request_NEPAL__c();
req.put('Subject__c', 'Help with account access');
req.put('From_Email__c', 'testuser@example.com');
req.put('Body__c', 'Hi, I am unable to access my account. Can you help me reset my password? Thanks.');
req.put('Message_Id__c', 'MSG-DEMO-001');
req.put('Status__c', 'New');
req.put('Email_Time__c', DateTime.now());
insert req;
System.debug('Inserted record: ' + req.Id);

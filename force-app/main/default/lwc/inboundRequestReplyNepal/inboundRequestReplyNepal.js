import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import sendReply from '@salesforce/apex/ReplyService_NEPAL.sendReply';
import getInboundRequests from '@salesforce/apex/ReplyService_NEPAL.getInboundRequests';

import SUBJECT_FIELD from '@salesforce/schema/Inbound_Request_NEPAL__c.Subject__c';
import FROM_EMAIL_FIELD from '@salesforce/schema/Inbound_Request_NEPAL__c.From_Email__c';
import BODY_FIELD from '@salesforce/schema/Inbound_Request_NEPAL__c.Body__c';
import STATUS_FIELD from '@salesforce/schema/Inbound_Request_NEPAL__c.Status__c';

const FIELDS = [SUBJECT_FIELD, FROM_EMAIL_FIELD, BODY_FIELD, STATUS_FIELD];

const LIST_COLUMNS = [
    { label: 'Request #', fieldName: 'Name', type: 'text' },
    { label: 'Subject', fieldName: 'Subject__c', type: 'text' },
    { label: 'From', fieldName: 'From_Email__c', type: 'email' },
    { label: 'Status', fieldName: 'Status__c', type: 'text' },
    {
        label: 'Received',
        fieldName: 'Email_Time__c',
        type: 'date',
        typeAttributes: { month: 'short', day: '2-digit', hour: '2-digit', minute: '2-digit' }
    }
];

export default class InboundRequestReplyNepal extends LightningElement {
    @api recordId;

    replyBody = '';
    ccAddresses = '';
    bccAddresses = '';
    isSending = false;

    selectedRecord = null;
    listColumns = LIST_COLUMNS;
    wiredRequestsResult;

    get isRecordPage() {
        return !!this.recordId;
    }

    // --- Record-page wiring ---
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    record;

    // --- Home-page wiring ---
    @wire(getInboundRequests)
    wiredRequests(result) {
        this.wiredRequestsResult = result;
    }

    get requests() {
        return this.wiredRequestsResult?.data || [];
    }

    get hasRequests() {
        return this.requests.length > 0;
    }

    get hasSelectedRecord() {
        return this.selectedRecord !== null;
    }

    // --- Field getters (work for both modes) ---
    get subject() {
        if (this.isRecordPage) {
            return getFieldValue(this.record.data, SUBJECT_FIELD) || '';
        }
        return this.selectedRecord?.Subject__c || '';
    }

    get fromEmail() {
        if (this.isRecordPage) {
            return getFieldValue(this.record.data, FROM_EMAIL_FIELD) || '';
        }
        return this.selectedRecord?.From_Email__c || '';
    }

    get body() {
        if (this.isRecordPage) {
            return getFieldValue(this.record.data, BODY_FIELD) || '';
        }
        return this.selectedRecord?.Body__c || '';
    }

    get status() {
        if (this.isRecordPage) {
            return getFieldValue(this.record.data, STATUS_FIELD) || '';
        }
        return this.selectedRecord?.Status__c || '';
    }

    get replySubject() {
        return '[NEPAL] Re: ' + this.subject;
    }

    get isSendDisabled() {
        return this.isSending || !this.replyBody;
    }

    get sendButtonLabel() {
        return this.isSending ? 'Sending...' : 'Send Reply';
    }

    get showReplyForm() {
        if (this.isRecordPage) {
            return !!this.record?.data;
        }
        return this.hasSelectedRecord;
    }

    get activeRecordId() {
        return this.isRecordPage ? this.recordId : this.selectedRecord?.Id;
    }

    // --- Handlers ---
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRecord = selectedRows.length > 0 ? selectedRows[0] : null;
        this.replyBody = '';
        this.ccAddresses = '';
        this.bccAddresses = '';
    }

    handleReplyChange(event) {
        this.replyBody = event.target.value;
    }

    handleCcChange(event) {
        this.ccAddresses = event.target.value;
    }

    handleBccChange(event) {
        this.bccAddresses = event.target.value;
    }

    handleBack() {
        this.selectedRecord = null;
        this.replyBody = '';
        this.ccAddresses = '';
        this.bccAddresses = '';
    }

    async handleSendReply() {
        this.isSending = true;
        try {
            await sendReply({
                recordId: this.activeRecordId,
                replyBody: this.replyBody,
                ccAddresses: this.ccAddresses || null,
                bccAddresses: this.bccAddresses || null
            });
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Reply sent successfully!',
                    variant: 'success'
                })
            );
            this.replyBody = '';
            this.ccAddresses = '';
            this.bccAddresses = '';

            if (!this.isRecordPage) {
                this.selectedRecord = null;
                await refreshApex(this.wiredRequestsResult);
            }
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error.body ? error.body.message : error.message,
                    variant: 'error'
                })
            );
        } finally {
            this.isSending = false;
        }
    }
}

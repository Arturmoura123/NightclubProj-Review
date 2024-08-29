import { LightningElement, api, wire } from 'lwc';
import QR_CODE_URL_FIELD from '@salesforce/schema/Contact.QR_Code_URL__c';
import { getRecord } from 'lightning/uiRecordApi';

export default class QrCodeDisplay extends LightningElement {
    @api recordId;
    qrCodeUrl;

    @wire(getRecord, { recordId: "$recordId", fields: [QR_CODE_URL_FIELD] })
    wiredContact({ error, data }) {
        if (data) {
            this.qrCodeUrl = data.fields.QR_Code_URL__c.value;
        } else if (error) {
            console.error('Error fetching QR code URL:', error);
        }
    }

    
}

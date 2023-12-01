// resendInvoiceButton.js
import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import sendInvoice from '@salesforce/apex/ResendInvoice.sendInvoice';

export default class ResendInvoiceButton extends LightningElement {
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields: ['Invoice__c.InvoiceNo__c'] })
    invoice;

    resendInvoice() {
        try {
            // Check if the invoice data is available
            if (this.invoice.data) {
                const invoiceNo = this.invoice.data.fields.InvoiceNo__c.value;

                // Call the Apex method to send the invoice
                sendInvoice({ publicKey: 'yourPublicKey', invoiceNo: invoiceNo })
                    .then(result => {
                        // Handle the response from the Apex method
                        console.log('Invoice sent successfully. Result: ', result);
                        // You can add more logic here based on the result
                    })
                    .catch(error => {
                        console.error('Error sending invoice: ', error);
                    });
            } else {
                console.error('Invoice data is not available.');
            }
        } catch (error) {
            console.error('Error: ' + error.message);
        }
    }
}

import { LightningElement } from 'lwc';
import { getBarcodeScanner } from 'lightning/mobileCapabilities';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateContactAsScanned from '@salesforce/apex/updateContactQRCode.markContactAsScanned';

export default class BarcodeScannerLwcComp extends LightningElement {
    scannedBarcode = '';
    scanButtonDisabled = false;

    connectedCallback() {
        this.myScanner = getBarcodeScanner(); 
        if (this.myScanner == null || !this.myScanner.isAvailable()) {
            this.scanButtonDisabled = true;
        }
    }

    handleBarcodeClick(event){ 
        this.scannedBarcode = '';
        if(this.myScanner.isAvailable() || this.myScanner != null) {
            const scanningOptions = {
                barcodeTypes: [this.myScanner.barcodeTypes.QR],
                instructionText: 'Scan a QR code',
                successText: 'Scanning complete.'
            }; 
            this.myScanner.beginCapture(scanningOptions)
            .then((result) => { 
                this.scannedBarcode = result.value;  
                console.log('Scanned QR Code Data:', this.scannedBarcode); // Debug statement
                this.updateContactAsScanned(this.scannedBarcode);  // Pass the scanned barcode data
            })
            .catch((error) => { 
                this.showError('Error during scanning', error.message);
                console.error('Error during scanning:', error); // Debug statement
            })
            .finally(() => {
                this.myScanner.endCapture();
            }); 
        } else {
            this.showError('Error', 'This device does not support a scanner.');
        }
    }

    updateContactAsScanned(scannedData) {
        console.log('Sending data to Apex:', scannedData); // Debug statement
        updateContactAsScanned({ data: scannedData })  // Pass the scanned data to Apex
            .then(() => {
                this.showSuccess('Contact marked as scanned.');
            })
            .catch((error) => {
                let errorMessage = 'An error occurred while updating the contact';
                // Check if the error is coming from AuraHandledException and display the specific message
                if (error.body && error.body.message) {
                    errorMessage = error.body.message;
                }
                this.showError('Error updating contact', errorMessage);
                console.error('Error updating contact in Apex:', error); // Debug statement
            });
    }

    showError(title, message) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: 'error'
        });
        this.dispatchEvent(event);
    }

    showSuccess(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success'
        });
        this.dispatchEvent(event);
    }
}

import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import QR_CODE_LIB from '@salesforce/resourceUrl/QRCodeLib';
import { loadScript } from 'lightning/platformResourceLoader';

export default class successPage extends LightningElement {
    firstName;
    lastName;
    email;
    phone;
    nightclub;
    nightclubName;
    qrCodeGenerated = false;

    renderedCallback() {
        if (this.qrCodeGenerated) {
            return;
        }

        loadScript(this, QR_CODE_LIB)
            .then(() => {
                this.qrCodeGenerated = true;
                this.generateQRCodeIfReady();
            })
            .catch(error => {
                console.error('Error loading QR Code library', error);
            });
    }

    @wire(getRecord, { recordId: '$nightclub', fields: 'Account.Name' })
    loadNightclub({ error, data }) {
        if (data) {
            this.nightclubName = data.fields.Name.value;
        } else if (error) {
            this.nightclubName = 'Unknown Nightclub';
        }
        this.generateQRCodeIfReady();
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.firstName = currentPageReference.state.c__firstName;
            this.lastName = currentPageReference.state.c__lastName;
            this.email = currentPageReference.state.c__email;
            this.phone = currentPageReference.state.c__phone;
            this.nightclub = currentPageReference.state.c__nightclub;
        }
        this.generateQRCodeIfReady();
    }

    generateQRCodeIfReady() {
        if (this.qrCodeGenerated && this.firstName && this.lastName && this.email && this.phone && this.nightclubName) {
            this.generateQRCode();
        }
    }

    generateQRCode() {
        const qrData = `Name: ${this.firstName} ${this.lastName}, Email: ${this.email}, Phone: ${this.phone}, Nightclub: ${this.nightclubName}`;
        const qrCodeContainer = this.template.querySelector('.qrcode');

        if (qrCodeContainer && QRCode) {
            qrCodeContainer.innerHTML = ''; // Clear any previous QR code
            new QRCode(qrCodeContainer, {
                text: qrData,
                width: 128,
                height: 128
            });
        }
    }
}

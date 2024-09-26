import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';

export default class successPage extends LightningElement {
    firstName;
    lastName;
    email;
    phone;
    nightclub;
    nightclubName;

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.firstName = currentPageReference.state.c__firstName;
            this.lastName = currentPageReference.state.c__lastName;
            this.email = currentPageReference.state.c__email;
            this.phone = currentPageReference.state.c__phone;
            this.nightclub = currentPageReference.state.c__nightclub;
        }
    }

    // Criei esta função porque quero ter acesso ao nome da discoteca (this.nightclub é apenas o Id)
    // o getRecord permite acedermos aos fields do objeto desde que tenhamos acesso ao Id do mesmo
    @wire(getRecord, { recordId: '$nightclub', fields: 'Account.Name' })
    loadNightclub({ error, data }) {
        if (data) {
            this.nightclubName = data.fields.Name.value;
        } else if (error) {
            this.nightclubName = 'Unknown Nightclub';
        }
    }
}

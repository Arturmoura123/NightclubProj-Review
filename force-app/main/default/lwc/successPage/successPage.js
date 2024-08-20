import { LightningElement, wire, api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';

export default class successPage extends LightningElement {
    firstName;
    lastName;
    email;
    phone;
    nightclub;
    nightclubName;

    @wire(getRecord, { recordId: '$nightclub', fields: 'Account.Name' })
    loadNightclub({ error, data }) {
        if (data) {
            // Extract the nightclub's name from the retrieved data
            this.nightclubName = data.fields.Name.value;
        } else if (error) {
            // Handle error case
            this.nightclubName = 'Unknown Nightclub';
        }
    }

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.firstName = currentPageReference.state.c__firstName;
            this.lastName = currentPageReference.state.c__lastName;
            this.email = currentPageReference.state.c__email;
            this.phone = currentPageReference.state.phone;
            this.nightclub = currentPageReference.state.c__nightclub;
        }
    }
}

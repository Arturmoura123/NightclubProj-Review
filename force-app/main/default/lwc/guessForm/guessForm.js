import { LightningElement, wire } from 'lwc';
import createContact from '@salesforce/apex/ContactController.createContact';
import getNightclubAccounts from '@salesforce/apex/AccountController.getNightclubAccounts';
import { NavigationMixin } from 'lightning/navigation';
import night from '@salesforce/resourceUrl/night'; 


export default class GuessForm extends NavigationMixin(LightningElement) {
    formData = {
        firstName: '',
        lastName: '',
        email: '',
        cellphoneNumber: '',
        nightclub: ''
    };

    nightclubOptions = [];

    @wire(getNightclubAccounts)
    wiredAccounts({data, error}) {
        if (data) {
            this.nightclubOptions = data.map(account => {
                return {label: account.label, value: account.value}});
        }
        else if (error) {
            console.error('Error fetching nightclubs:', error);
        }
    }

    handleInputChange(event) {
        const inputName = event.target.name;
        const inputValue = event.target.value;

        console.log(`Input Changed: ${inputName} = ${inputValue}`); 
        this.formData[inputName] = inputValue;
    }

    
    async handleSubmit(event) {
        event.preventDefault(); 
        console.log('Form Submitted:', this.formData); 

        // Detection of errors in the Form
        const phone = this.formData.cellphoneNumber;
        const phoneDigits = phone.replace(/\D/g, ''); 
        if (phoneDigits.length != 9) {
            alert('Contact creation failed: Contact Number must contain 9 digits.');
            console.warn('Phone number validation failed'); 
            return;
        }

        try {
            const contactId = await createContact({
                firstName: this.formData.firstName,
                lastName: this.formData.lastName,
                email: this.formData.email,
                phone: this.formData.cellphoneNumber,
                nightclub: this.formData.nightclub
            });
            
            
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__SuccessPageWrapper'
                },
                state: {
                    c__firstName: this.formData.firstName,
                    c__lastName: this.formData.lastName,
                    c__email: this.formData.email,
                    c__phone: this.formData.cellphoneNumber,
                    c__nightclub: this.formData.nightclub
                }
            });

        } catch (error) {
            console.error('Error occurred during contact creation:', error); 

            if (error.body && error.body.message.includes('A Contact with this email or phone number already exists.')) {
                alert('Failed to create contact: A Contact with this email or phone number already exists.');
            } else {
                alert('Failed to create contact. Please try again.');
            }
        }
    }
}

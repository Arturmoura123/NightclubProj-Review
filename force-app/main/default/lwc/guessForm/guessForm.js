import { LightningElement, wire } from 'lwc';
import createContact from '@salesforce/apex/ContactController.createContact';
import getNightclubAccounts from '@salesforce/apex/AccountController.getNightclubAccounts';



export default class GuessForm extends LightningElement {
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

            console.log('New Contact Created with Id:', contactId); 
            alert('Contact created successfully!');

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

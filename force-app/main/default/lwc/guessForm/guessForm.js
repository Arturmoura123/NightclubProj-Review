import { LightningElement, wire } from 'lwc';
import createContact from '@salesforce/apex/createContactAndEmail.createContactAndSendEmail';
import getNightclubAccounts from '@salesforce/apex/AccountController.getNightclubAccounts';
import { NavigationMixin } from 'lightning/navigation';
import night from '@salesforce/resourceUrl/night';
import urban_night from '@salesforce/resourceUrl/urban_night';
import urban_night2 from '@salesforce/resourceUrl/urban_night2';
urban1 = night;
urban2 = urban_night;
urban3 = urban_night2;

export default class GuessForm extends NavigationMixin(LightningElement) {
    formData = {
        firstName: '',
        lastName: '',
        email: '',
        cellphoneNumber: '',
        nightclub: ''
    };

    
    // Esta função vai buscar as discotecas que foram fetched pela class AccountController
    // Iteneramos sobre cada discoteca para que esta fique com os parametros requeridos pelo lightning-combobox
    nightclubOptions = [];
    @wire(getNightclubAccounts)
    wiredAccounts({data, error}) {
        if (data) {
            this.nightclubOptions = data.map(account => {
                return { label: account.label, value: account.value };
            });
        } else if (error) {
            console.error('Error fetching nightclubs:', error);
        }
    }


    // Usamos o onchange no HTML de forma a que qualquer mudança no forms seja correspondida no JS
    handleInputChange(event) {
        const inputName = event.target.name;
        const inputValue = event.target.value;

        console.log(`Input Changed: ${inputName} = ${inputValue}`);
        this.formData[inputName] = inputValue;
    }

    async handleSubmit(event) {
        event.preventDefault();

        // Algumas validações do Form
        const phone = this.formData.cellphoneNumber;
        const phoneDigits = phone.replace(/\D/g, '');
        if (phoneDigits.length !== 9) {
            alert('Contact creation failed: Contact Number must contain 9 digits.');
            console.warn('Phone number validation failed');
            return;
        }

        //Passamos os dados recolhidos no Forms para a class Apex createContactAndEmail
        try {
            const contactId = await createContact({
                firstName: this.formData.firstName,
                lastName: this.formData.lastName,
                email: this.formData.email,
                phone: this.formData.cellphoneNumber,
                nightclub: this.formData.nightclub
            });


            // Meti a sucess page dentro de um aura (SucessPageWrapper) porque só assim consegui com que a sucess page fosse visualizada pelo user 
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
            } else if (error.body && error.body.message.includes('full capacity')) {
                alert('The selected nightclub is at full capacity. Please choose another.');
            } else {
                alert('Failed to create contact. Please try again.');
            }
        }
    }
}
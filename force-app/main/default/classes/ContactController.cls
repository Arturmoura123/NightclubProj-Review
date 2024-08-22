public with sharing class ContactController {
    @AuraEnabled
    public static Id createContact(String firstName, String lastName, String email, String phone, String nightclub) {
        List<Contact> existingContacts = [
            SELECT Id FROM Contact WHERE Email = :email OR Phone = :phone
        ];

        if (!existingContacts.isEmpty()) {
            throw new AuraHandledException('A Contact with this email or phone number already exists.');
        }

        // If no conflicts, create the new Contact
        Contact newContact = new Contact();
        newContact.FirstName = firstName;
        newContact.LastName = lastName;
        newContact.Email = email;
        newContact.Phone = phone;
        newContact.AccountId = nightclub;

        insert newContact;
        return newContact.Id;
    }
}

public with sharing class ContactController {
    @AuraEnabled
    public static Id createContact(String firstName, String lastName, String email, String phone, String nightclub) {
        // Check if a Contact with the same email or phone number already exists
        List<Contact> existingContacts = [
            SELECT Id FROM Contact WHERE Email = :email OR Phone = :phone LIMIT 1
        ];

        if (!existingContacts.isEmpty()) {
            // Throw an exception with a generic message indicating a duplicate issue
            throw new AuraHandledException('A Contact with this email or phone number already exists.');
        }

        // If no conflicts, create the new Contact
        Contact newContact = new Contact();
        newContact.FirstName = firstName;
        newContact.LastName = lastName;
        newContact.Email = email;
        newContact.Phone = phone;
        newContact.AccountId = nightclub;

        // Insert the new Contact record
        insert newContact;

        // Return the Id of the newly created Contact
        return newContact.Id;
    }
}

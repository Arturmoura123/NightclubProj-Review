public class Registered_guesses {

    public static void updateRegisteredGuesses(List<Contact> contactos, Boolean isDelete) {
        // Create a map to store the account Id and the number of related contacts
        Map<Id, Integer> accountContactCount = new Map<Id, Integer>();

        // Loop through the contacts and update the map
        for (Contact cont : contactos) {
            if (cont.AccountId != null) {
                if (!accountContactCount.containsKey(cont.AccountId)) {
                    accountContactCount.put(cont.AccountId, 1);
                } else {
                    accountContactCount.put(cont.AccountId, accountContactCount.get(cont.AccountId) + 1);
                }
            }
        }

        // Query the accounts that need to be updated
        List<Account> accountsToUpdate = [SELECT Id, Registered_guesses__c FROM Account WHERE Id IN :accountContactCount.keySet()];

        // Update the count on each account
        for (Account acc : accountsToUpdate) {
            Integer existingCount = acc.Registered_guesses__c != null ? Integer.valueOf(acc.Registered_guesses__c) : 0;
            if (isDelete) {
                // Decrease count when a contact is deleted
                acc.Registered_guesses__c = existingCount - accountContactCount.get(acc.Id);
            } else {
                // Increase count when a contact is inserted or updated
                acc.Registered_guesses__c = existingCount + accountContactCount.get(acc.Id);
            }
        }

        // Perform the DML update
        update accountsToUpdate;
    }
}


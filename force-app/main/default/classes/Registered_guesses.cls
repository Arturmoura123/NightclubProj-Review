// Esta class regista o numero de guests de cada discoteca 
// É ativada cada vez que um Contacto é criado ou deleted (ver o trigger ContactCountTrigger)
public class Registered_guesses {

    public static void updateRegisteredGuesses(List<Contact> contactos, Boolean isDelete) {
        Map<Id, Integer> accountContactCount = new Map<Id, Integer>();

        for (Contact cont : contactos) {
            if (cont.AccountId != null) {
                if (!accountContactCount.containsKey(cont.AccountId)) {
                    accountContactCount.put(cont.AccountId, 1);
                } else {
                    accountContactCount.put(cont.AccountId, accountContactCount.get(cont.AccountId) + 1);
                }
            }
        }

        List<Account> accountsToUpdate = [SELECT Id, Registered_guesses__c FROM Account WHERE Id IN :accountContactCount.keySet()];

        
        for (Account acc : accountsToUpdate) {
            Integer existingCount = acc.Registered_guesses__c != null ? Integer.valueOf(acc.Registered_guesses__c) : 0;
            if (isDelete) {
                // Diminuir o count quando o contacto é deleted
                acc.Registered_guesses__c = existingCount - accountContactCount.get(acc.Id);
            } else {
                // Aumentar o count quando o contacto é inserido
                acc.Registered_guesses__c = existingCount + accountContactCount.get(acc.Id);
            }
        }

        update accountsToUpdate;
    }
    
}


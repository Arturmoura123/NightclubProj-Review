public with sharing class AccountController {
    @AuraEnabled(cacheable=true)
    public static List<AccountOption> getNightclubAccounts() {
        List<AccountOption> options = new List<AccountOption>();
        
        for (Account acc : [SELECT Id, Name FROM Account WHERE Business_Type__c = 'Nightclub']) {
            options.add(new AccountOption(acc.Id, acc.Name));
        }
        
        return options;
    }
    
    public class AccountOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        
        public AccountOption(String id, String name) {
            this.value = id;
            this.label = name;
        }
    }
}



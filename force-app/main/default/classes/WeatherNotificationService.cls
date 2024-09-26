// No metodo checkWeatherAndNotify fazemos a call à API 
// Se estiver a chuver, o metodo boleano isRainy (que está dentro da class WeatherService) será verdadeiro e irá despontar o método sendRainNotification presente nesta class
// O trigger para esta class é um Scheduled Job que criei dentro da Salesforce Org

public with sharing class WeatherNotificationService {
    public static void sendWeatherAlerts() {

        List<String> cities = new List<String>{'Porto', 'Lisbon'}; // Só tenho 4 discotecas, 2 no Porto e 2 em Lisboa, pelo que só estas duas cidades precisam de estar na lista
        
        for (String city : cities) {
            checkWeatherAndNotify(city);
        }
    }

    @future(callout=true)
    private static void checkWeatherAndNotify(String city) {
        // Fazer o callout
        String weatherData = WeatherService.getWeather(city);
        
        if (WeatherService.isRainy(weatherData)) {
            sendRainNotification(city);
        }
    }

    private static void sendRainNotification(String city) {
        // Aqui vou dar query das discotecas (Accounts) que pertencem a essa cidade
        List<Account> accounts = [
            SELECT Id, Name
            FROM Account 
            WHERE City__c = :city
        ];

        Set<Id> accountIds = new Set<Id>(); 
        Map<Id, String> accountNames = new Map<Id, String>(); // Criei esta variavel para ter acesso ao nome da discoteca quando escrever o email

        
        for (Account acct : accounts) {
            accountIds.add(acct.Id);
            accountNames.put(acct.Id, acct.Name); 
        }

        // Neste query vamos buscar todos os contactos que estão dentro da discoteca/accounts
        List<Contact> contacts = [
            SELECT Email, AccountId, Name
            FROM Contact 
            WHERE AccountId IN :accountIds 
        ];

        for (Contact contact : contacts) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { contact.Email });
            String accountName = accountNames.get(contact.AccountId);
            email.setSubject('Weather Update: Rain Expected in ' + city);
            
            
            String emailBody = '<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px; background-color: #f9f9f9;">' +
                '<div style="text-align: center;">' +
                '<h1 style="color: #333; font-size: 24px;">Important Weather Update</h1>' +
                '</div>' +
                '<p style="color: #555; font-size: 16px; line-height: 1.5;">Dear ' + contact.Name + ',</p>' +
                '<p style="color: #555; font-size: 16px; line-height: 1.5;">We wanted to inform you that due to the expected weather conditions in ' + city + 
                ', the outdoor nightclub, <strong>' + accountName + '</strong>, will be closed today.</p>' +
                '<p style="color: #555; font-size: 16px; line-height: 1.5;">We apologize for any inconvenience this may cause.</p>' +
                '<p style="color: #555; font-size: 16px; line-height: 1.5;">For more updates, please check our website or contact us directly.</p>' +
                '<p style="color: #555; font-size: 16px; line-height: 1.5;">Thank you for your understanding.</p>' +
                '<div style="text-align: center; margin-top: 20px;">' +
                '<p style="color: #999; font-size: 14px;">&copy; 2024 ' + accountName + '. All rights reserved.</p>' +
                '</div>' +
            '</div>';

            email.setHtmlBody(emailBody);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }
    }
}

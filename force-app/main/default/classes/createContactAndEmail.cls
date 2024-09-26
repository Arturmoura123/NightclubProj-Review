public with sharing class createContactAndEmail {

    // Com este metodo criamos o contacto sendo que este fica automaticamente associado à discoteca que escolheu pelo AccountID
    @AuraEnabled
    public static Id createContactAndSendEmail(String firstName, String lastName, String email, String phone, String nightclub) {

        // Ver se o nightclub está cheio
        Account getNightclub = [SELECT Id, Registered_guesses__c, Max_capacity__c 
                                FROM Account 
                                WHERE Id = :nightclub];

        // A lógica que garante o limitar de convidados está na Apex class Registered_guesses
        if (getNightclub.Registered_guesses__c >= getNightclub.Max_capacity__c) {
            throw new AuraHandledException('The selected nightclub is at full capacity.');
        }

        List<Contact> existingContacts = [
            SELECT Id FROM Contact WHERE Email = :email OR Phone = :phone
        ];

        if (!existingContacts.isEmpty()) {
            throw new AuraHandledException('A Contact with this email or phone number already exists.');
        }

        String qrData = 'Name: ' + firstName + ' ' + lastName + ', Nightclub: ' + nightclub + ' Email: ' + email;
        String qrCodeURL = generateQRCodeURL(qrData);

        Contact newContact = new Contact();
        newContact.FirstName = firstName;
        newContact.LastName = lastName;
        newContact.Email = email;
        newContact.Phone = phone;
        newContact.AccountId = nightclub;
        newContact.QR_Code_URL__c = qrCodeURL; // Meti o QR code dentro do contact para ter logo acesso e poder fazer debugging sem ter de estar a mandar mail
        insert newContact;

        sendEmailWithQRCode(newContact.Id, firstName, lastName, email, nightclub);

        return newContact.Id;
    }

    // Este metodo cria e manda um email ao user contendo o respetivo QrCode
    // Tem uma função privada que converte o QR code para blob de forma a poder ser anexado ao email
    @future(callout=true)
    public static void sendEmailWithQRCode(Id contactId, String firstName, String lastName, String email, String nightclub) {
        String qrData = 'Name: ' + firstName + ' ' + lastName + ', Nightclub: ' + nightclub + ' Email: ' + email;
        Blob qrCodeBlob = generateQRCodeBlob(qrData);

        String emailBody = '<div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px; background-color: #f9f9f9;">' +
            '<div style="text-align: center;">' +
            '<h1 style="color: #333; font-size: 24px;">Welcome to Club K!</h1>' +
            '</div>' +
            '<p style="color: #555; font-size: 16px; line-height: 1.5;">Dear ' + firstName + ',</p>' +
            '<p style="color: #555; font-size: 16px; line-height: 1.5;">Thank you for registering with Club K Guest Management. We are excited to have you as our guest! Please find your QR code attached in this email. Show it to the bouncer at the entrance of the nightclub.</p>' +
            '<p style="color: #555; font-size: 16px; line-height: 1.5;">For any inquiries or assistance, feel free to reach out to us at support@clubk.com.</p>' +
            '<p style="color: #555; font-size: 16px; line-height: 1.5;">We look forward to seeing you soon!</p>' +
            '<div style="text-align: center; margin-top: 20px;">' +
            '<p style="color: #999; font-size: 14px;">&copy; 2024 Club K Guest Management. All rights reserved.</p>' +
            '</div>' +
        '</div>';

        // Criar o email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { email });
        mail.setSubject('Your Nightclub Entry QR Code');
        mail.setHtmlBody(emailBody);  // Changed to HTML body

        // Dar attached to QR code
        Messaging.EmailFileAttachment qrCodeAttachment = new Messaging.EmailFileAttachment();
        qrCodeAttachment.setFileName('qrcode.png');
        qrCodeAttachment.setBody(qrCodeBlob);
        qrCodeAttachment.setContentType('image/png');
        mail.setFileAttachments(new List<Messaging.EmailFileAttachment>{qrCodeAttachment});

        // Mandar o email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    
    private static String generateQRCodeURL(String qrData) {
        return 'https://api.qrserver.com/v1/create-qr-code/?data=' + EncodingUtil.urlEncode(qrData, 'UTF-8') + '&size=300x300';
    }

    
    private static Blob generateQRCodeBlob(String qrData) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.qrserver.com/v1/create-qr-code/?data=' + EncodingUtil.urlEncode(qrData, 'UTF-8') + '&size=300x300');
        req.setMethod('GET');
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            return res.getBodyAsBlob();
        } else {
            throw new AuraHandledException('Failed to generate QR code');
        }
    }
}

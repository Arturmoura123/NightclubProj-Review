// O objetivo desta classe é registar no Salesforce a data e hora em que o user validou o seu QR Code com sucesso

public with sharing class updateContactQRCode {

    
    // O valor do parametro string data vem do barcodeScanner, mais concretamente da função handleBarcodeClick(event)
    // Na função privada extractEmailFromQrCode extrai o email do contacto
    // Na query contactToUpdate usei esse email para extrair o contacto pretendido
    // Depois de algumas validações, dei update do field Scanned e da hora/dia

    @AuraEnabled
    public static void markContactAsScanned(String data) {

        if (data == null || String.isBlank(data)) {
            throw new AuraHandledException('No data received from the QR code scanner.');
        }

        try {
            String email = extractEmailFromQRData(data);
            System.debug('Extracted Email: ' + email);

            if (email == null || String.isBlank(data)) {
                throw new AuraHandledException('Failed to extract email from the QR code data.');
            }
            
            
            Contact contactToUpdate = [
                SELECT Id, Scanned__c, Scanned_Time__c 
                FROM Contact 
                WHERE Email = :email 
                LIMIT 1
            ];

            
            if (contactToUpdate == null) {
                throw new AuraHandledException('No contact found for the provided email.');
            }

            if (contactToUpdate.Scanned__c == true) {
                throw new AuraHandledException('This contact was already scanned');
            }

            // Marcar o contacto como scanned
            contactToUpdate.Scanned__c = true;
            contactToUpdate.Scanned_Time__c = System.now();
            
            update contactToUpdate;

        } catch (QueryException e) {
            throw new AuraHandledException('No contact found for the provided email: ' + e.getMessage());
        } catch (Exception e) {
            System.debug('Error occurred while updating the contact: ' + e.getMessage());
            throw new AuraHandledException('An error occurred while updating the contact: ' + e.getMessage());
        }
    }

    private static String extractEmailFromQRData(String data) {
        System.debug('Extracting email from QR data: ' + data);
        Pattern emailPattern = Pattern.compile('Email:\\s*(\\S+)');
        Matcher matcher = emailPattern.matcher(data);
        if (matcher.find()) {
            return matcher.group(1);  // Extracted email address
        } else {
            return null;
        }
    }
}



public with sharing class updateContactQRCode {

    @AuraEnabled
    public static void markContactAsScanned(String data) {
        System.debug('QR Code Data: ' + data);

        // Check if data is null or empty
        if (data == null || String.isBlank(data)) {
            throw new AuraHandledException('No data received from the QR code scanner.');
        }

        try {
            String email = extractEmailFromQRData(data);
            System.debug('Extracted Email: ' + email);

            // Check if email was successfully extracted
            if (email == null || String.isBlank(data)) {
                throw new AuraHandledException('Failed to extract email from the QR code data.');
            }
            
            // Query the Contact based on the Email address
            Contact contactToUpdate = [
                SELECT Id, Scanned__c, Scanned_Time__c 
                FROM Contact 
                WHERE Email = :email 
                LIMIT 1
            ];

            // Check if the contact was found
            if (contactToUpdate == null) {
                throw new AuraHandledException('No contact found for the provided email.');
            }

            if (contactToUpdate.Scanned__c == true) {
                throw new AuraHandledException('This contact was already scanned');
            }

            // Mark the contact as scanned
            contactToUpdate.Scanned__c = true;
            contactToUpdate.Scanned_Time__c = System.now();
            
            // Update the contact in the database
            update contactToUpdate;

        } catch (QueryException e) {
            // Handle case where no contact is found for the provided email
            throw new AuraHandledException('No contact found for the provided email: ' + e.getMessage());
        } catch (Exception e) {
            // Log and handle any other exceptions
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



public with sharing class ApplicationController {

    @AuraEnabled(cacheable=true)
    public static List<Application__c> getApplications(Id positionId) {
        return [
            SELECT Id, Name, Status__c, Expected_Salary__c, Candidate__c, Candidate__r.Name
            FROM Application__c
            WHERE Position__c = :positionId
            WITH USER_MODE
            ORDER BY CreatedDate DESC
            LIMIT 200
        ];
    }

    @AuraEnabled
    public static void updateStatus(Id applicationId, String newStatus) {
        try {
            Application__c app = new Application__c(Id = applicationId, Status__c = newStatus);
            update as user app;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }

    // Datatable inline edit sathi
    @AuraEnabled
    public static void updateApplications(List<Application__c> apps) {
        try {
            update as user apps;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }

    @AuraEnabled
    public static Id createApplication(
        Id positionId, String candidateName, String email,
        String phone, Decimal experience, Decimal expectedSalary
    ) {
        try {
            // Email var Candidate shodha, nasel tar navin banva
            List<Candidate__c> existing = [
                SELECT Id FROM Candidate__c WHERE Email__c = :email LIMIT 1
            ];
            Candidate__c cand;
            if (existing.isEmpty()) {
                cand = new Candidate__c(
                    Name = candidateName, Email__c = email,
                    Phone__c = phone, Experience__c = experience
                );
                insert as user cand;
            } else {
                cand = existing[0];
            }

            Application__c app = new Application__c(
                Position__c = positionId,
                Candidate__c = cand.Id,
                Expected_Salary__c = expectedSalary,
                Status__c = 'Applied'
            );
            insert as user app;
            return app.Id;
        } catch (DmlException e) {
            // Trigger cha addError message ithe yeil
            throw new AuraHandledException(e.getDmlMessage(0));
        }
    }
}
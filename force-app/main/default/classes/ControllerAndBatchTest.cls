@IsTest
private class ControllerAndBatchTest {

    @IsTest
    static void testPositionSearch() {
        TestDataFactory.createPosition('Apex Developer', 2, true);
        TestDataFactory.createPosition('Tester', 1, true);

        Test.startTest();
        List<Position__c> all = PositionController.getOpenPositions('');
        List<Position__c> filtered = PositionController.getOpenPositions('Apex');
        Test.stopTest();

        System.assertEquals(2, all.size());
        System.assertEquals(1, filtered.size());
    }

    @IsTest
    static void testCreateApplicationAndUpdate() {
        Position__c pos = TestDataFactory.createPosition('Dev', 3, true);

        Test.startTest();
        Id appId = ApplicationController.createApplication(
            pos.Id, 'Rahul Patil', 'rahul@test.com', '9999999999', 3, 500000
        );
        ApplicationController.updateStatus(appId, 'Screening');
        List<Application__c> apps = ApplicationController.getApplications(pos.Id);
        Test.stopTest();

        System.assertEquals(1, apps.size());
        System.assertEquals('Screening', apps[0].Status__c);
    }

    @IsTest
    static void testDuplicateThrowsAuraException() {
        Position__c pos = TestDataFactory.createPosition('Dev', 3, true);
        ApplicationController.createApplication(pos.Id, 'A', 'a@test.com', '1', 1, 100);

        try {
            ApplicationController.createApplication(pos.Id, 'A', 'a@test.com', '1', 1, 100);
            System.assert(false, 'Exception yayla pahije hota');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }

    @IsTest
    static void testBatchClosesExpiredPositions() {
        Position__c expired = TestDataFactory.createPosition('Old', 1, false);
        expired.Closing_Date__c = Date.today().addDays(-5);
        insert expired;
        Position__c active = TestDataFactory.createPosition('New', 1, true);

        Test.startTest();
        Database.executeBatch(new PositionAutoCloseBatch());
        Test.stopTest();

        System.assertEquals('Closed', [SELECT Status__c FROM Position__c WHERE Id = :expired.Id].Status__c);
        System.assertEquals('Open', [SELECT Status__c FROM Position__c WHERE Id = :active.Id].Status__c);
    }

    @IsTest
    static void testSchedulable() {
        Test.startTest();
        String jobId = System.schedule('Test Job', '0 0 1 * * ?', new PositionAutoCloseBatch());
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
}
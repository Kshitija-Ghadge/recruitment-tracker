@IsTest
private class ApplicationTriggerHandlerTest {

    @IsTest
    static void testDuplicateBlocked() {
        Position__c pos = TestDataFactory.createPosition('Dev', 5, true);
        Candidate__c cand = TestDataFactory.createCandidates(1)[0];

        insert new Application__c(Position__c = pos.Id, Candidate__c = cand.Id);

        Test.startTest();
        Database.SaveResult sr = Database.insert(
            new Application__c(Position__c = pos.Id, Candidate__c = cand.Id), false
        );
        Test.stopTest();

        System.assert(!sr.isSuccess(), 'Duplicate block vhayla pahije hota');
        System.assert(sr.getErrors()[0].getMessage().contains('already'));
    }

    @IsTest
    static void testClosedPositionBlocked() {
        Position__c pos = TestDataFactory.createPosition('QA', 1, false);
        pos.Status__c = 'Closed';
        insert pos;
        Candidate__c cand = TestDataFactory.createCandidates(1)[0];

        Test.startTest();
        Database.SaveResult sr = Database.insert(
            new Application__c(Position__c = pos.Id, Candidate__c = cand.Id), false
        );
        Test.stopTest();

        System.assert(!sr.isSuccess());
    }

    @IsTest
    static void testPositionAutoClosesWhenFilled() {
        Position__c pos = TestDataFactory.createPosition('Admin', 1, true);
        Candidate__c cand = TestDataFactory.createCandidates(1)[0];
        Application__c app = new Application__c(Position__c = pos.Id, Candidate__c = cand.Id);
        insert app;

        Test.startTest();
        app.Status__c = 'Hired';
        update app;
        Test.stopTest();

        System.assertEquals('Closed', [SELECT Status__c FROM Position__c WHERE Id = :pos.Id].Status__c);
    }

    @IsTest
    static void testPositionStaysOpenIfNotFilled() {
        Position__c pos = TestDataFactory.createPosition('Sales', 2, true);
        Candidate__c cand = TestDataFactory.createCandidates(1)[0];
        Application__c app = new Application__c(Position__c = pos.Id, Candidate__c = cand.Id);
        insert app;

        app.Status__c = 'Hired';
        update app;

        System.assertEquals('Open', [SELECT Status__c FROM Position__c WHERE Id = :pos.Id].Status__c);
    }

    @IsTest
    static void testBulk200() {
        Position__c pos = TestDataFactory.createPosition('Bulk Role', 500, true);
        List<Candidate__c> cands = TestDataFactory.createCandidates(200);

        List<Application__c> apps = new List<Application__c>();
        for (Candidate__c c : cands) {
            apps.add(new Application__c(Position__c = pos.Id, Candidate__c = c.Id));
        }

        Test.startTest();
        insert apps;
        for (Application__c a : apps) a.Status__c = 'Hired';
        update apps;
        Test.stopTest();

        System.assertEquals(200, [SELECT COUNT() FROM Application__c WHERE Status__c = 'Hired']);
        System.assertEquals('Open', [SELECT Status__c FROM Position__c WHERE Id = :pos.Id].Status__c);
    }
}
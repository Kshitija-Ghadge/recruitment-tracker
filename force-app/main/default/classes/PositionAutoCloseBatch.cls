public with sharing class PositionAutoCloseBatch implements Database.Batchable<SObject>, Schedulable {

    // Batch
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, Status__c FROM Position__c
            WHERE Status__c = 'Open' AND Closing_Date__c < TODAY
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Position__c> scope) {
        for (Position__c p : scope) {
            p.Status__c = 'Closed';
        }
        update scope;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('PositionAutoCloseBatch complete.');
    }

    // Schedulable
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new PositionAutoCloseBatch(), 200);
    }
}
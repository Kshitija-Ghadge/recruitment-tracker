public with sharing class ApplicationTriggerHandler {

    public static void beforeInsert(List<Application__c> newList) {
        blockClosedPositions(newList);
        checkDuplicates(newList);
    }

    public static void afterUpdate(List<Application__c> newList, Map<Id, Application__c> oldMap) {
        closeFilledPositions(newList, oldMap);
    }

    // 1) Closed position var application nako
    private static void blockClosedPositions(List<Application__c> newList) {
        Set<Id> positionIds = new Set<Id>();
        for (Application__c app : newList) {
            if (app.Position__c != null) {
                positionIds.add(app.Position__c);
            }
        }
        if (positionIds.isEmpty()) return;

        Map<Id, Position__c> positions = new Map<Id, Position__c>(
            [SELECT Id, Status__c FROM Position__c WHERE Id IN :positionIds]
        );

        for (Application__c app : newList) {
            Position__c pos = positions.get(app.Position__c);
            if (pos != null && pos.Status__c == 'Closed') {
                app.addError('Hi Position Closed aahe, tyamule application karta yenar nahi.');
            }
        }
    }

    // 2) Same candidate + same position = duplicate
    private static void checkDuplicates(List<Application__c> newList) {
        Set<Id> candidateIds = new Set<Id>();
        Set<Id> positionIds = new Set<Id>();
        for (Application__c app : newList) {
            if (app.Candidate__c != null && app.Position__c != null) {
                candidateIds.add(app.Candidate__c);
                positionIds.add(app.Position__c);
            }
        }
        if (candidateIds.isEmpty()) return;

        Set<String> existingKeys = new Set<String>();
        for (Application__c ex : [
            SELECT Candidate__c, Position__c
            FROM Application__c
            WHERE Candidate__c IN :candidateIds AND Position__c IN :positionIds
        ]) {
            existingKeys.add(buildKey(ex.Candidate__c, ex.Position__c));
        }

        // Same batch madhe pn duplicate asu shakto, mhanun seenKeys
        Set<String> seenKeys = new Set<String>();
        for (Application__c app : newList) {
            if (app.Candidate__c == null || app.Position__c == null) continue;
            String key = buildKey(app.Candidate__c, app.Position__c);
            if (existingKeys.contains(key) || seenKeys.contains(key)) {
                app.addError('Hya Candidate ne already hya Position sathi apply kele aahe.');
            } else {
                seenKeys.add(key);
            }
        }
    }

    // 3) Hired count >= Openings zala ki Position Closed
    private static void closeFilledPositions(List<Application__c> newList, Map<Id, Application__c> oldMap) {
        Set<Id> positionIds = new Set<Id>();
        for (Application__c app : newList) {
            Application__c oldApp = oldMap.get(app.Id);
            if (app.Status__c == 'Hired' && oldApp.Status__c != 'Hired') {
                positionIds.add(app.Position__c);
            }
        }
        if (positionIds.isEmpty()) return;

        // Roll-up field itthe stale asto (roll-up after-trigger nantar calculate hoto),
        // mhanun direct COUNT query vaparli.
        Map<Id, Integer> hiredCounts = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Position__c pos, COUNT(Id) cnt
            FROM Application__c
            WHERE Position__c IN :positionIds AND Status__c = 'Hired'
            GROUP BY Position__c
        ]) {
            hiredCounts.put((Id) ar.get('pos'), (Integer) ar.get('cnt'));
        }

        List<Position__c> toUpdate = new List<Position__c>();
        for (Position__c pos : [
            SELECT Id, Openings__c, Status__c FROM Position__c WHERE Id IN :positionIds
        ]) {
            Integer hired = hiredCounts.get(pos.Id);
            if (hired != null && pos.Openings__c != null
                && hired >= pos.Openings__c && pos.Status__c != 'Closed') {
                pos.Status__c = 'Closed';
                toUpdate.add(pos);
            }
        }
        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    private static String buildKey(Id candidateId, Id positionId) {
        return String.valueOf(candidateId) + '-' + String.valueOf(positionId);
    }
}
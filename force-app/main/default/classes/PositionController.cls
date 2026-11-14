public with sharing class PositionController {

    @AuraEnabled(cacheable=true)
    public static List<Position__c> getOpenPositions(String searchKey) {
        String key = '%' + (String.isBlank(searchKey) ? '' : searchKey.trim()) + '%';
        return [
            SELECT Id, Name, Department__c, Openings__c, Filled_Count__c, Closing_Date__c
            FROM Position__c
            WHERE Status__c = 'Open' AND Name LIKE :key
            WITH USER_MODE
            ORDER BY Closing_Date__c ASC NULLS LAST
            LIMIT 50
        ];
    }
}
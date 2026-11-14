@IsTest
public class TestDataFactory {

    public static Position__c createPosition(String name, Integer openings, Boolean doInsert) {
        Position__c p = new Position__c(
            Name = name, Status__c = 'Open',
            Openings__c = openings, Department__c = 'IT',
            Closing_Date__c = Date.today().addDays(30)
        );
        if (doInsert) insert p;
        return p;
    }

    public static List<Candidate__c> createCandidates(Integer count) {
        List<Candidate__c> list1 = new List<Candidate__c>();
        for (Integer i = 0; i < count; i++) {
            list1.add(new Candidate__c(
                Name = 'Candidate ' + i,
                Email__c = 'cand' + i + '@test.com',
                Experience__c = 2
            ));
        }
        insert list1;
        return list1;
    }
}
public with sharing class ObjectiveController {
    @AuraEnabled(cacheable=true)
    public static List<ObjectiveWrapper> getObjectivesByUserAndYear(Id userId, String year) {
        List<ObjectiveWrapper> objectiveWrappers = new List<ObjectiveWrapper>();
        for (Objective__c objective : [
            SELECT Id, Name, Objective_year__c, User__c, User__r.Name 
            FROM Objective__c 
            WHERE User__c = :userId AND Objective_year__c = :year
        ]) {
            ObjectiveWrapper wrapper = new ObjectiveWrapper();
            wrapper.id = objective.Id;
            wrapper.name = objective.Name;
            wrapper.year = objective.Objective_year__c;
            wrapper.userId = objective.User__c;
            wrapper.userName = objective.User__r.Name;
            List<KeyResultWrapper> keyResults = new List<KeyResultWrapper>();
            for (Key_Result__c keyResult : [
                SELECT Id, Name 
                FROM Key_Result__c 
                WHERE Objective__c = :objective.Id
            ]) {
                keyResults.add(new KeyResultWrapper(keyResult));
            }
            wrapper.keyResults = keyResults;
            objectiveWrappers.add(wrapper);
        }
        return objectiveWrappers;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getNearest10Years() {
        Integer currentYear = Date.today().year();
        List<String> years = new List<String>();
        for (Integer i = 0; i < 10; i++) {
            years.add(String.valueOf(currentYear + i));
        }
        return years;
    }

    public class ObjectiveWrapper {
        @AuraEnabled
        public Id id { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String year { get; set; }
        @AuraEnabled
        public Id userId { get; set; }
        @AuraEnabled
        public String userName { get; set; }
        @AuraEnabled
        public List<KeyResultWrapper> keyResults { get; set; }
    }

    public class KeyResultWrapper {
        @AuraEnabled
        public Id id { get; set; }
        @AuraEnabled
        public String name { get; set; }

        public KeyResultWrapper(Key_Result__c keyResult) {
            this.id = keyResult.Id;
            this.name = keyResult.Name;
        }
    }
    
    @AuraEnabled
    public static void createObjective(String name, String year, Id userId) {
        Objective__c newObjective = new Objective__c(
            Name = name,
            Objective_year__c = year,
            User__c = userId
        );
        insert newObjective;
    }
}
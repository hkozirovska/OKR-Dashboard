public with sharing class KeyResultController {

    @AuraEnabled(cacheable=true)
    public static List<KeyResultWrapper> getKeyResultsWithTargets(Id objectiveId) {
        List<KeyResultWrapper> keyResultWrappers = new List<KeyResultWrapper>();

        for (Key_Result__c keyResult : [SELECT Id, Name FROM Key_Result__c WHERE Objective__c = :objectiveId]) {
            KeyResultWrapper wrapper = new KeyResultWrapper();
            wrapper.id = keyResult.Id;
            wrapper.name = keyResult.Name;
            wrapper.targets = new List<TargetWrapper>();

            List<Target_Score__c> targetScores = [SELECT Target_Type__c, Current_Score__c, Target_Score__c, Subtype__c
                                                 FROM Target_Score__c
                                                 WHERE Key_Result__c = :keyResult.Id];

            for (Target_Score__c targetScore : targetScores) {
                TargetWrapper targetWrapper = new TargetWrapper();
                targetWrapper.objectType = targetScore.Target_Type__c;
                targetWrapper.currentScore = targetScore.Current_Score__c;
                targetWrapper.targetScore = targetScore.Target_Score__c;
                targetWrapper.additionalOption = targetScore.Subtype__c;
                wrapper.targets.add(targetWrapper);
            }
            keyResultWrappers.add(wrapper);
        }

        return keyResultWrappers;
    }

    @AuraEnabled
    public static void createKeyResult(String name, Id objectiveId) {
        Key_Result__c newKeyResult = new Key_Result__c(
            Name = name,
            Objective__c = objectiveId
        );
        insert newKeyResult;
    }

    @AuraEnabled
    public static void saveNewTarget(String keyResultId, List<String> targets, Integer targetScore, String additionalOption) {
        List<Target_Score__c> targetScores = new List<Target_Score__c>();

        for (String target : targets) {
            Target_Score__c targetScoreRecord = new Target_Score__c();
            targetScoreRecord.Key_Result__c = keyResultId;
            targetScoreRecord.Target_Type__c = target;
            targetScoreRecord.Target_Score__c = targetScore;
            targetScoreRecord.Current_Score__c = 0;
            targetScoreRecord.Name = 'Target for ' + target;
             if (additionalOption != null) {
                targetScoreRecord.Subtype__c = additionalOption;
            }
            targetScores.add(targetScoreRecord);
        }

        insert targetScores;
    }

    // Wrapper classes
    public class KeyResultWrapper {
        @AuraEnabled
        public Id id { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public List<TargetWrapper> targets { get; set; }
    }

    public class TargetWrapper {
        @AuraEnabled
        public String objectType { get; set; }
        @AuraEnabled
        public Decimal currentScore { get; set; }
        @AuraEnabled
        public Decimal targetScore { get; set; }
        @AuraEnabled
        public String additionalOption { get; set; }
    }
}
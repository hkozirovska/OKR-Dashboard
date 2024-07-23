public with sharing class TargetScoreUpdater {
    public static void incrementCurrentScore(String targetType, List<SObject> newRecords) {
        Map<Id, Integer> keyResultScoreMap = new Map<Id, Integer>();
		Map<Id, String> keyResultTypeMap = new Map<Id, String>();
        
        for (SObject record : newRecords) {
            Id keyResultId;
            String additionalOption = '';

            if (targetType == 'Calls') {
                Task taskRecord = (Task)record;
                Id whatId = taskRecord.WhatId;
                if (whatId != null) {
                    Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Id = :whatId LIMIT 1];
                    keyResultId = keyResult.Id;
                }
            } else if (targetType == 'Leads') {
                Lead lead = (Lead)record;
                keyResultId = lead.Key_Result__c;
            } else if (targetType == 'Events') {
				Event eventRecord = (Event)record;
                Id whatId = eventRecord.WhatId;
                if (whatId != null) {
                    Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Id = :whatId LIMIT 1];
                    keyResultId = keyResult.Id;
                    additionalOption = eventRecord.Type;
                }
            } else if (targetType == 'Opportunities') {
                keyResultId = ((Opportunity)record).Key_Result__c;
            } else if (targetType == 'Contracts') {
                Contract contractRecord = (Contract)record;
                keyResultId = contractRecord.Key_Result__c;
                additionalOption = contractRecord.Type__c;
            } else if (targetType == 'Surveys') {
                keyResultId = ((Survey__c)record).Key_Result__c;
            } else if (targetType == 'Reviews') {
                keyResultId = ((Review__c)record).Key_Result__c;
            } else if (targetType == 'Google Reviews') {
                keyResultId = ((Google_Review__c)record).Key_Result__c;
            } else if (targetType == 'Case Studies') {
                keyResultId = ((Case_Study__c)record).Key_Result__c;
            }

            if (keyResultId != null) {
                if (!keyResultScoreMap.containsKey(keyResultId)) {
                    keyResultScoreMap.put(keyResultId, 0);
                }
                keyResultScoreMap.put(keyResultId, keyResultScoreMap.get(keyResultId) + 1);
                keyResultTypeMap.put(keyResultId, additionalOption);
            }
        }

        List<Target_Score__c> targetScoresToUpdate = new List<Target_Score__c>();
        for (Id keyResultId : keyResultScoreMap.keySet()) {
            String type = keyResultTypeMap.get(keyResultId);
            List<Target_Score__c> targetScores;
                targetScores = [
                    SELECT Id, Current_Score__c 
                    FROM Target_Score__c 
                    WHERE Key_Result__c = :keyResultId 
                    AND Target_Type__c = :targetType
                    AND Subtype__c = :type
                ];
            
            for (Target_Score__c targetScore : targetScores) {
                targetScore.Current_Score__c += keyResultScoreMap.get(keyResultId);
                targetScoresToUpdate.add(targetScore);
            }
        }

        if (!targetScoresToUpdate.isEmpty()) {
            update targetScoresToUpdate;
        }
    }
    
    public static void decreaseCurrentScore(String targetType, List<SObject> oldRecords) {
        Map<Id, Integer> keyResultScoreMap = new Map<Id, Integer>();
        Map<Id, String> keyResultTypeMap = new Map<Id, String>();
        
        for (SObject record : oldRecords) {
            Id keyResultId;
            String additionalOption = '';
    
            if (targetType == 'Calls') {
                Task taskRecord = (Task)record;
                Id whatId = taskRecord.WhatId;
                if (whatId != null) {
                    Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Id = :whatId LIMIT 1];
                    keyResultId = keyResult.Id;
                }
            } else if (targetType == 'Leads') {
                Lead lead = (Lead)record;
                keyResultId = lead.Key_Result__c;
            } else if (targetType == 'Events') {
                Event eventRecord = (Event)record;
                Id whatId = eventRecord.WhatId;
                if (whatId != null) {
                    Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Id = :whatId LIMIT 1];
                    keyResultId = keyResult.Id;
                    additionalOption = eventRecord.Type;
                }
            } else if (targetType == 'Opportunities') {
                keyResultId = ((Opportunity)record).Key_Result__c;
            } else if (targetType == 'Contracts') {
                Contract contractRecord = (Contract)record;
                keyResultId = contractRecord.Key_Result__c;
                additionalOption = contractRecord.Type__c;
            } else if (targetType == 'Surveys') {
                keyResultId = ((Survey__c)record).Key_Result__c;
            } else if (targetType == 'Reviews') {
                keyResultId = ((Review__c)record).Key_Result__c;
            } else if (targetType == 'Google Reviews') {
                keyResultId = ((Google_Review__c)record).Key_Result__c;
            } else if (targetType == 'Case Studies') {
                keyResultId = ((Case_Study__c)record).Key_Result__c;
            }
    
            if (keyResultId != null) {
                if (!keyResultScoreMap.containsKey(keyResultId)) {
                    keyResultScoreMap.put(keyResultId, 0);
                }
                keyResultScoreMap.put(keyResultId, keyResultScoreMap.get(keyResultId) - 1);
                keyResultTypeMap.put(keyResultId, additionalOption);
            }
        }
    
        List<Target_Score__c> targetScoresToUpdate = new List<Target_Score__c>();
        for (Id keyResultId : keyResultScoreMap.keySet()) {
            String type = keyResultTypeMap.get(keyResultId);
            List<Target_Score__c> targetScores;
                targetScores = [
                    SELECT Id, Current_Score__c 
                    FROM Target_Score__c 
                    WHERE Key_Result__c = :keyResultId 
                    AND Target_Type__c = :targetType
                    AND Subtype__c = :type
                ];
            
            for (Target_Score__c targetScore : targetScores) {
                targetScore.Current_Score__c += keyResultScoreMap.get(keyResultId);
                targetScoresToUpdate.add(targetScore);
            }
        }
    
        if (!targetScoresToUpdate.isEmpty()) {
            update targetScoresToUpdate;
        }

    }


}
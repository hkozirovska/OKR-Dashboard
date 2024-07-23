trigger SurveyTrigger on Survey__c (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetScoreUpdater.incrementCurrentScore('Surveys', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetScoreUpdater.decreaseCurrentScore('Surveys', Trigger.old);
        }
    }
}
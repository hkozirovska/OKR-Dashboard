trigger CaseStudyTrigger on Case_Study__c (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetScoreUpdater.incrementCurrentScore('Case Studies', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetScoreUpdater.decreaseCurrentScore('Case Studies', Trigger.old);
        }
    }
}
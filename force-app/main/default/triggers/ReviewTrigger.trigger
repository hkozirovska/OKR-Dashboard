trigger ReviewTrigger on Review__c (after insert, after delete) {
    if (Trigger.isInsert) {
        TargetScoreUpdater.incrementCurrentScore('Reviews', Trigger.new);
    } else if (Trigger.isDelete) {
        TargetScoreUpdater.decreaseCurrentScore('Reviews', Trigger.old);
    }
}
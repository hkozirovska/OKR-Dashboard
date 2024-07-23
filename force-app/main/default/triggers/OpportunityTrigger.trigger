trigger OpportunityTrigger on Opportunity (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetScoreUpdater.incrementCurrentScore('Opportunities', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetScoreUpdater.decreaseCurrentScore('Opportunities', Trigger.old);
        }
    }
}
trigger EventTrigger on Event (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetScoreUpdater.incrementCurrentScore('Events', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetScoreUpdater.decreaseCurrentScore('Events', Trigger.old);
        }
    }
}
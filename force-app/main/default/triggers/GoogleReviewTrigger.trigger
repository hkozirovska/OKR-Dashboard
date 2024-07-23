trigger GoogleReviewTrigger on Google_Review__c (after insert, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            TargetScoreUpdater.incrementCurrentScore('Google Reviews', Trigger.new);
        } else if (Trigger.isDelete) {
            TargetScoreUpdater.decreaseCurrentScore('Google Reviews', Trigger.old);
        }
    }
}
trigger TaskTrigger on Task (after insert, after delete) {
    List<Task> callTasks = new List<Task>();

    if (Trigger.isInsert) {
        for (Task t : Trigger.new) {
            if (t.Type == 'Call') {
                callTasks.add(t);
            }
        }
        if (!callTasks.isEmpty()) {
            TargetScoreUpdater.incrementCurrentScore('Calls', callTasks);
        }
    }

    if (Trigger.isDelete) {
        List<Task> oldCallTasks = new List<Task>();
        for (Task t : Trigger.old) {
            if (t.Type == 'Call') {
                oldCallTasks.add(t);
            }
        }
        if (!oldCallTasks.isEmpty()) {
            TargetScoreUpdater.decreaseCurrentScore('Calls', oldCallTasks);
        }
    }
}
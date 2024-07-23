trigger LeadTrigger on Lead (after insert, after delete) {
    List<Lead> webLeads = new List<Lead>();

    if (Trigger.isInsert) {
        for (Lead l : Trigger.new) {
            if (l.LeadSource == 'Web') {
                webLeads.add(l);
            }
        }
        if (!webLeads.isEmpty()) {
            TargetScoreUpdater.incrementCurrentScore('Leads', webLeads);
        }
    }

    if (Trigger.isDelete) {
        List<Lead> oldWebLeads = new List<Lead>();
        for (Lead l : Trigger.old) {
            if (l.LeadSource == 'Web') {
                oldWebLeads.add(l);
            }
        }
        if (!oldWebLeads.isEmpty()) {
            TargetScoreUpdater.decreaseCurrentScore('Leads', oldWebLeads);
        }
    }
}
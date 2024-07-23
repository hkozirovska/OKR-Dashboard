public with sharing class RelatedRecordController {
    @AuraEnabled(cacheable=true)
    public static List<RelatedRecordWrapper> getRelatedRecords(Id keyResultId) {
        List<RelatedRecordWrapper> relatedRecords = new List<RelatedRecordWrapper>();
        
        //Surveys
        for (Survey__c survey : [SELECT Id, Name FROM Survey__c WHERE Key_Result__c = :keyResultId]) {
            relatedRecords.add(new RelatedRecordWrapper(survey.Id, survey.Name, 'Survey'));
        }
        
        //Reviews
        for (Review__c review : [SELECT Id, Name FROM Review__c WHERE Key_Result__c = :keyResultId]) {
            relatedRecords.add(new RelatedRecordWrapper(review.Id, review.Name, 'Review'));
        }
        
        //Google Reviews
        for (Google_Review__c googleReview : [SELECT Id, Name FROM Google_Review__c WHERE Key_Result__c = :keyResultId]) {
            relatedRecords.add(new RelatedRecordWrapper(googleReview.Id, googleReview.Name, 'Google Review'));
        }
        
        //Case Studies
        for (Case_Study__c caseStudy : [SELECT Id, Name FROM Case_Study__c WHERE Key_Result__c = :keyResultId]) {
            relatedRecords.add(new RelatedRecordWrapper(caseStudy.Id, caseStudy.Name, 'Case Study'));
        }
        
        return relatedRecords;
    }
    
    public class RelatedRecordWrapper {
        @AuraEnabled
        public Id recordId { get; set; }
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String recordType { get; set; }
        
        public RelatedRecordWrapper(Id recordId, String name, String recordType) {
            this.recordId = recordId;
            this.name = name;
            this.recordType = recordType;
        }
    }
    
@AuraEnabled
public static RelatedRecordWrapper createRelatedRecord(Id keyResultId, String recordName, String recordType) {
    RelatedRecordWrapper newRecordWrapper;

    if (recordType == 'Survey') {
        Survey__c newRecord = new Survey__c(Name = recordName, Key_Result__c = keyResultId);
        insert newRecord;
        newRecordWrapper = new RelatedRecordWrapper(newRecord.Id, newRecord.Name, 'Survey');
    } else if (recordType == 'Review') {
        Review__c newRecord = new Review__c(Name = recordName, Key_Result__c = keyResultId);
        insert newRecord;
        newRecordWrapper = new RelatedRecordWrapper(newRecord.Id, newRecord.Name, 'Review');
    } else if (recordType == 'Google Review') {
        Google_Review__c newRecord = new Google_Review__c(Name = recordName, Key_Result__c = keyResultId);
        insert newRecord;
        newRecordWrapper = new RelatedRecordWrapper(newRecord.Id, newRecord.Name, 'Google Review');
    } else if (recordType == 'Case Study') {
        Case_Study__c newRecord = new Case_Study__c(Name = recordName, Key_Result__c = keyResultId);
        insert newRecord;
        newRecordWrapper = new RelatedRecordWrapper(newRecord.Id, newRecord.Name, 'Case Study');
    }

    return newRecordWrapper;
	}
}
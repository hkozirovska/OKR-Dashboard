@isTest
public class RelatedRecordControllerTest {
    @testSetup
    static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String uniqueUsername = 'testuser' + DateTime.now().getTime() + '@example.com';
        User testUser = new User(
            Alias = 'testusr',
            Email = 'testuser@example.com',
            LastName = 'Testing',
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            LanguageLocaleKey='en_US',
            ProfileId = p.Id,
            UserName = uniqueUsername
        );
        insert testUser;

        Objective__c obj = new Objective__c(Name = 'Objective 1', Objective_year__c = '2024', User__c = testUser.Id);
        insert obj;

        Key_Result__c keyResult = new Key_Result__c(Name = 'Key Result 1', Objective__c = obj.Id);
        insert keyResult;

        Survey__c survey = new Survey__c(Name = 'Survey 1', Key_Result__c = keyResult.Id);
        Review__c review = new Review__c(Name = 'Review 1', Key_Result__c = keyResult.Id);
        Google_Review__c googleReview = new Google_Review__c(Name = 'Google Review 1', Key_Result__c = keyResult.Id);
        Case_Study__c caseStudy = new Case_Study__c(Name = 'Case Study 1', Key_Result__c = keyResult.Id);
        insert new List<SObject>{survey, review, googleReview, caseStudy};
    }

    @isTest
    static void testGetRelatedRecords() {
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 1' LIMIT 1];

        List<RelatedRecordController.RelatedRecordWrapper> result = RelatedRecordController.getRelatedRecords(keyResult.Id);
        
        System.assertEquals(4, result.size());

        Set<String> expectedTypes = new Set<String>{'Survey', 'Review', 'Google Review', 'Case Study'};
        Set<String> actualTypes = new Set<String>();
        
        for (RelatedRecordController.RelatedRecordWrapper record : result) {
            actualTypes.add(record.recordType);
        }

        System.assertEquals(expectedTypes, actualTypes);
    }

    @isTest
    static void testCreateRelatedRecord() {
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 1' LIMIT 1];
        
        Test.startTest();
        RelatedRecordController.RelatedRecordWrapper newSurvey = RelatedRecordController.createRelatedRecord(keyResult.Id, 'New Survey', 'Survey');
        RelatedRecordController.RelatedRecordWrapper newReview = RelatedRecordController.createRelatedRecord(keyResult.Id, 'New Review', 'Review');
        RelatedRecordController.RelatedRecordWrapper newGoogleReview = RelatedRecordController.createRelatedRecord(keyResult.Id, 'New Google Review', 'Google Review');
        RelatedRecordController.RelatedRecordWrapper newCaseStudy = RelatedRecordController.createRelatedRecord(keyResult.Id, 'New Case Study', 'Case Study');
        Test.stopTest();
        
        System.assertNotEquals(null, newSurvey);
        System.assertEquals('New Survey', newSurvey.name);
        System.assertEquals('Survey', newSurvey.recordType);

        System.assertNotEquals(null, newReview);
        System.assertEquals('New Review', newReview.name);
        System.assertEquals('Review', newReview.recordType);

        System.assertNotEquals(null, newGoogleReview);
        System.assertEquals('New Google Review', newGoogleReview.name);
        System.assertEquals('Google Review', newGoogleReview.recordType);

        System.assertNotEquals(null, newCaseStudy);
        System.assertEquals('New Case Study', newCaseStudy.name);
        System.assertEquals('Case Study', newCaseStudy.recordType);
    }
}

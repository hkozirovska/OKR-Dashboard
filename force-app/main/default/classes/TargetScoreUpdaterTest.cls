@isTest
public class TargetScoreUpdaterTest {
    
    @testSetup
    static void setupTestData() {
        Objective__c objective = new Objective__c(Name = 'Test Objective', Objective_year__c = '2024');
        insert objective;
        
        Key_Result__c keyResult1 = new Key_Result__c(Name = 'Key Result 1', Objective__c = objective.Id);
        Key_Result__c keyResult2 = new Key_Result__c(Name = 'Key Result 2', Objective__c = objective.Id);
        insert new List<Key_Result__c>{keyResult1, keyResult2};
        
        Target_Score__c targetScore1 = new Target_Score__c(Key_Result__c = keyResult1.Id, Target_Type__c = 'Events', Subtype__c = 'Meeting', Current_Score__c = 0, Target_Score__c = 10);
        Target_Score__c targetScore2 = new Target_Score__c(Key_Result__c = keyResult2.Id, Target_Type__c = 'Contracts', Subtype__c = 'FP', Current_Score__c = 0, Target_Score__c = 10);
        insert new List<Target_Score__c>{targetScore1, targetScore2};
        
        Target_Score__c targetScoreSurvey = new Target_Score__c(Key_Result__c = keyResult1.Id, Target_Type__c = 'Surveys', Subtype__c = null, Current_Score__c = 0, Target_Score__c = 10);
        insert targetScoreSurvey;
        
        Target_Score__c targetScoreReviews = new Target_Score__c(Key_Result__c = keyResult1.Id, Target_Type__c = 'Reviews', Subtype__c = null, Current_Score__c = 0, Target_Score__c = 10);
        insert targetScoreReviews;
        
        Target_Score__c targetScoreCaseStudies = new Target_Score__c(Key_Result__c = keyResult1.Id, Target_Type__c = 'Case studies', Subtype__c = null, Current_Score__c = 0, Target_Score__c = 10);
        insert targetScoreCaseStudies;
        
        Target_Score__c targetScoreGoogleReviews = new Target_Score__c(Key_Result__c = keyResult1.Id, Target_Type__c = 'Google reviews', Subtype__c = null, Current_Score__c = 0, Target_Score__c = 10);
        insert targetScoreGoogleReviews;
        
        Target_Score__c targetScoreOpportunities = new Target_Score__c(Key_Result__c = keyResult1.Id, Target_Type__c = 'Opportunities', Subtype__c = null, Current_Score__c = 0, Target_Score__c = 10);
        insert targetScoreOpportunities;
    }

    @isTest
    static void testIncrementCurrentScoreWithEvent() {
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 1' LIMIT 1];

        Event testEvent = new Event(WhatId = keyResult.Id, Type = 'Meeting', ActivityDate = Date.today(), DurationInMinutes = 3, ActivityDateTime = Date.today());
        insert testEvent;

        Target_Score__c updatedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Events' AND Subtype__c = 'Meeting'];
        System.assertEquals(1, updatedTargetScore.Current_Score__c, 'The current score should have been increased by 1.');
        
        delete testEvent;

        Target_Score__c decreasedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Events' AND Subtype__c = 'Meeting'];
        System.assertEquals(0, decreasedTargetScore.Current_Score__c, 'The current score should have been decreased by 1.');
    }

    @isTest
    static void testIncrementCurrentScoreWithContract() {
        
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 2' LIMIT 1];
        
        Account testAccount = new Account(Name = 'Test Account');
    	insert testAccount;
        
        Contract testContract = new Contract(Key_Result__c = keyResult.Id, Type__c = 'FP', AccountId = testAccount.Id);
        insert testContract;

        Target_Score__c updatedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Contracts' AND Subtype__c = 'FP'];
        System.assertEquals(1, updatedTargetScore.Current_Score__c, 'The current score should have been increased by 1.');
        
        delete testContract;

        Target_Score__c decreasedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Contracts' AND Subtype__c = 'FP'];
        System.assertEquals(0, decreasedTargetScore.Current_Score__c, 'The current score should have been decreased by 1.');
    }

    @isTest
    static void testIncrementCurrentScoreForCalls() {
        Objective__c objective = new Objective__c(Name = 'Test Objective for Calls', Objective_year__c = '2024');
        insert objective;
    
        Key_Result__c keyResult = new Key_Result__c(Name = 'Key Result for Calls', Objective__c = objective.Id);
        insert keyResult;
    
        Target_Score__c targetScore = new Target_Score__c(Key_Result__c = keyResult.Id, Target_Type__c = 'Calls', Current_Score__c = 0, Target_Score__c = 5);
        insert targetScore;
    
        Task testTask = new Task(WhatId = keyResult.Id, Subject = 'Call Task', ActivityDate = Date.today(), Type = 'Call');
        insert testTask;
    
        Target_Score__c updatedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Id = :targetScore.Id];
        System.assertEquals(1, updatedTargetScore.Current_Score__c, 'The current score should be incremented by 1');
        
        delete testTask;

        Target_Score__c decreasedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Id = :targetScore.Id];
        System.assertEquals(0, decreasedTargetScore.Current_Score__c, 'The current score should have been decreased by 1.');
    }
    
    @isTest
    static void testIncrementCurrentScoreForLeads() {
        Objective__c objective = new Objective__c(Name = 'Test Objective for Leads', Objective_year__c = '2024');
        insert objective;
    
        Key_Result__c keyResult = new Key_Result__c(Name = 'Key Result for Leads', Objective__c = objective.Id);
        insert keyResult;
    
        Target_Score__c targetScore = new Target_Score__c(Key_Result__c = keyResult.Id, Target_Type__c = 'Leads', Current_Score__c = 0, Target_Score__c = 5);
        insert targetScore;
    
        Lead testLead = new Lead(Key_Result__c = keyResult.Id, LastName = 'Test Lead', Company = 'Test Company', LeadSource = 'Web');
        insert testLead;
    
        Target_Score__c updatedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Id = :targetScore.Id];
        System.assertEquals(1, updatedTargetScore.Current_Score__c, 'The current score should be incremented by 1');
        
        delete testLead;

        Target_Score__c decreasedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Id = :targetScore.Id];
        System.assertEquals(0, decreasedTargetScore.Current_Score__c, 'The current score should have been decreased by 1.');
    }


    @isTest
    static void testIncrementCurrentScoreWithNoMatchingType() {
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 1' LIMIT 1];

        Event testEvent = new Event(WhatId = keyResult.Id, Type = 'NonMatchingType', ActivityDate = Date.today(), DurationInMinutes = 3, ActivityDateTime = Date.today());
        insert testEvent;

        Target_Score__c targetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Events' AND Subtype__c = 'Meeting'];
        System.assertEquals(0, targetScore.Current_Score__c, 'The current score should remain 0');
        
        delete testEvent;

        Target_Score__c decreasedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Events' AND Subtype__c = 'Meeting'];
        System.assertEquals(0, decreasedTargetScore.Current_Score__c, 'The current score should remain 0');
    }
    
    @isTest
    static void testIncrementCurrentScoreWithSurvey() {
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 1' LIMIT 1];
    
        Survey__c testSurvey = new Survey__c(Key_Result__c = keyResult.Id);
        insert testSurvey;
    
        Target_Score__c updatedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Surveys' LIMIT 1];
        System.assertEquals(1, updatedTargetScore.Current_Score__c, 'The current score should have been increased by 1.');
        
        delete testSurvey;

        Target_Score__c decreasedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Surveys' LIMIT 1];
        System.assertEquals(0, decreasedTargetScore.Current_Score__c, 'The current score should remain 0');
	}
    
    @isTest
    static void testIncrementCurrentScoreWithReviews() {
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 1' LIMIT 1];
    
        Review__c testReview = new Review__c(Key_Result__c = keyResult.Id);
        insert testReview;
    
        Target_Score__c updatedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Reviews' LIMIT 1];
        System.assertEquals(1, updatedTargetScore.Current_Score__c, 'The current score should have been increased by 1.');
        
        delete testReview;

        Target_Score__c decreasedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Reviews' LIMIT 1];
        System.assertEquals(0, decreasedTargetScore.Current_Score__c, 'The current score should have been decreased by 1.');
	}
    
    @isTest
    static void testIncrementCurrentScoreWithCaseStudies() {
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 1' LIMIT 1];
    
        Case_Study__c testCaseStudy = new Case_Study__c(Key_Result__c = keyResult.Id);
        insert testCaseStudy;
    
        Target_Score__c updatedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Case studies' LIMIT 1];
        System.assertEquals(1, updatedTargetScore.Current_Score__c, 'The current score should have been increased by 1.');
        
        delete testCaseStudy;

        Target_Score__c decreasedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Case studies' LIMIT 1];
        System.assertEquals(0, decreasedTargetScore.Current_Score__c, 'The current score should have been decreased by 1.');
	}
    
    @isTest
    static void testIncrementCurrentScoreWithGoogleReviews() {
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 1' LIMIT 1];
    
        Google_Review__c testGoogleReview = new Google_Review__c(Key_Result__c = keyResult.Id);
        insert testGoogleReview;
    
        Target_Score__c updatedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Google reviews' LIMIT 1];
        System.assertEquals(1, updatedTargetScore.Current_Score__c, 'The current score should have been increased by 1.');
        
        delete testGoogleReview;

        Target_Score__c decreasedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Google reviews' LIMIT 1];
        System.assertEquals(0, decreasedTargetScore.Current_Score__c, 'The current score should have been decreased by 1.');
	}
    
    @isTest
    static void testIncrementCurrentScoreWithOpportunities() {
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 1' LIMIT 1];
    
        Opportunity testOpportunity = new Opportunity(Key_Result__c = keyResult.Id, CloseDate = Date.today(), StageName = 'Prospecting', Name = 'Test');
        insert testOpportunity;
    
        Target_Score__c updatedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Opportunities' LIMIT 1];
        System.assertEquals(1, updatedTargetScore.Current_Score__c, 'The current score should have been increased by 1.');
        
        delete testOpportunity;

        Target_Score__c decreasedTargetScore = [SELECT Current_Score__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Target_Type__c = 'Opportunities' LIMIT 1];
        System.assertEquals(0, decreasedTargetScore.Current_Score__c, 'The current score should have been decreased by 1.');
	}

}
@isTest
public class KeyResultControllerTest {
    @testSetup
    static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String uniqueUsername = 'testuser' + DateTime.now().getTime() + '@example.com';
        User testUser1 = new User(
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
        insert testUser1;

        Objective__c obj = new Objective__c(Name = 'Objective 1', Objective_year__c = '2024', User__c = testUser1.Id);
        insert obj;

        Key_Result__c keyResult1 = new Key_Result__c(Name = 'Key Result 1', Objective__c = obj.Id);
        Key_Result__c keyResult2 = new Key_Result__c(Name = 'Key Result 2', Objective__c = obj.Id);
        insert new List<Key_Result__c>{keyResult1, keyResult2};

        Target_Score__c targetScore1 = new Target_Score__c(Key_Result__c = keyResult1.Id, Target_Type__c = 'Reviews', Current_Score__c = 10, Target_Score__c = 100);
        Target_Score__c targetScore2 = new Target_Score__c(Key_Result__c = keyResult2.Id, Target_Type__c = 'Contracts', Current_Score__c = 20, Target_Score__c = 200, Subtype__c = 'FP');
        insert new List<Target_Score__c>{targetScore1, targetScore2};
    }

    @isTest
    static void testGetKeyResultsWithTargets() {
        Objective__c obj = [SELECT Id FROM Objective__c WHERE Name = 'Objective 1' LIMIT 1];
        List<KeyResultController.KeyResultWrapper> result = KeyResultController.getKeyResultsWithTargets(obj.Id);
        
        System.assertEquals(2, result.size());
        System.assertEquals('Key Result 1', result[0].name);
        System.assertEquals('Key Result 2', result[1].name);
        System.assertEquals(1, result[0].targets.size());
        System.assertEquals(1, result[1].targets.size());
    }

    @isTest
    static void testCreateKeyResult() {
        Objective__c obj = [SELECT Id FROM Objective__c WHERE Name = 'Objective 1' LIMIT 1];
        String keyResultName = 'New Key Result';

        Test.startTest();
        KeyResultController.createKeyResult(keyResultName, obj.Id);
        Test.stopTest();

        Key_Result__c createdKeyResult = [SELECT Id, Name, Objective__c FROM Key_Result__c WHERE Name = :keyResultName AND Objective__c = :obj.Id LIMIT 1];
        System.assertNotEquals(null, createdKeyResult);
        System.assertEquals(keyResultName, createdKeyResult.Name);
        System.assertEquals(obj.Id, createdKeyResult.Objective__c);
    }

    @isTest
    static void testSaveNewTarget() {
        Key_Result__c keyResult = [SELECT Id FROM Key_Result__c WHERE Name = 'Key Result 1' LIMIT 1];
        List<String> targets = new List<String>{'Reviews', 'Contracts'};
        Integer targetScore = 50;
        String additionalOption = 'FP';

        Test.startTest();
        KeyResultController.saveNewTarget(keyResult.Id, targets, targetScore, additionalOption);
        Test.stopTest();

        List<Target_Score__c> targetScores = [SELECT Key_Result__c, Target_Type__c, Current_Score__c, Target_Score__c, Subtype__c FROM Target_Score__c WHERE Key_Result__c = :keyResult.Id AND Name IN ('Target for Reviews', 'Target for Contracts')];
        System.assertEquals(2, targetScores.size());
        System.assertEquals('Reviews', targetScores[0].Target_Type__c);
        System.assertEquals(0, targetScores[0].Current_Score__c);
        System.assertEquals(targetScore, targetScores[0].Target_Score__c);
        System.assertEquals(additionalOption, targetScores[0].Subtype__c);
    }
}

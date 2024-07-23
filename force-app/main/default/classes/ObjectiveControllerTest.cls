@isTest
public class ObjectiveControllerTest {
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

        Objective__c obj1 = new Objective__c(Name = 'Objective 1', Objective_year__c = '2024', User__c = testUser1.Id);
        Objective__c obj2 = new Objective__c(Name = 'Objective 2', Objective_year__c = '2024', User__c = testUser1.Id);
        insert new List<Objective__c>{obj1, obj2};

        Key_Result__c keyResult1 = new Key_Result__c(Name = 'Key Result 1', Objective__c = obj1.Id);
        Key_Result__c keyResult2 = new Key_Result__c(Name = 'Key Result 2', Objective__c = obj2.Id);
        insert new List<Key_Result__c>{keyResult1, keyResult2};
    }

    @isTest
    static void testGetObjectivesByUserAndYear() {
        User testUser1 = [SELECT Id FROM User WHERE Alias = 'testusr' LIMIT 1];
        List<ObjectiveController.ObjectiveWrapper> result = ObjectiveController.getObjectivesByUserAndYear(testUser1.Id, '2024');
        
        System.assertEquals(2, result.size());
        System.assertEquals('Objective 1', result[0].name);
        System.assertEquals('Objective 2', result[1].name);
        System.assertEquals(1, result[0].keyResults.size());
        System.assertEquals(1, result[1].keyResults.size());
    }

    @isTest
    static void testGetNearest10Years() {
        List<String> years = ObjectiveController.getNearest10Years();
        Integer currentYear = Date.today().year();
        
        System.assertEquals(10, years.size());
        System.assertEquals(String.valueOf(currentYear), years[0]);
        System.assertEquals(String.valueOf(currentYear + 9), years[9]);
    }

    @isTest
    static void testCreateObjective() {
        User testUser1 = [SELECT Id FROM User WHERE Alias = 'testusr' LIMIT 1];
        String objectiveName = 'New Objective';
        String year = '2025';

        Test.startTest();
        ObjectiveController.createObjective(objectiveName, year, testUser1.Id);
        Test.stopTest();

        Objective__c createdObjective = [SELECT Id, Name, Objective_year__c, User__c FROM Objective__c WHERE Name = :objectiveName AND Objective_year__c = :year LIMIT 1];
        System.assertNotEquals(null, createdObjective);
        System.assertEquals(objectiveName, createdObjective.Name);
        System.assertEquals(year, createdObjective.Objective_year__c);
        System.assertEquals(testUser1.Id, createdObjective.User__c);
    }
}

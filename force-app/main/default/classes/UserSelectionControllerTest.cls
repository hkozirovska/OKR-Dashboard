@IsTest(SeeAllData=false)
public class UserSelectionControllerTest {
    @testSetup
    static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        System.assertNotEquals(null, p, 'Standard User Profile not found');

        User activeUser1 = new User(
            Alias = 'actusr1',
            Email = 'activeuser1@example.com',
            LastName = 'Active1',
            ProfileId = p.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            LanguageLocaleKey='en_US',
            UserName = 'activeuser1' + DateTime.now().getTime() + '@example.com',
            IsActive = true
        );

        User activeUser2 = new User(
            Alias = 'actusr2',
            Email = 'activeuser2@example.com',
            LastName = 'Active2',
            ProfileId = p.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            LanguageLocaleKey='en_US',
            UserName = 'activeuser2' + DateTime.now().getTime() + '@example.com',
            IsActive = true
        );

        User inactiveUser = new User(
            Alias = 'inactusr',
            Email = 'inactiveuser@example.com',
            LastName = 'Inactive',
            ProfileId = p.Id,
            EmailEncodingKey='UTF-8',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Los_Angeles',
            LanguageLocaleKey='en_US',
            UserName = 'inactiveuser' + DateTime.now().getTime() + '@example.com',
            IsActive = false
        );

        // Insert users
        insert new List<User> { activeUser1, activeUser2, inactiveUser };
    }

    @isTest
    static void testGetUsers() {
        Test.startTest();
        List<User> users = UserSelectionController.getUsers();
        Test.stopTest();

        System.debug('Users retrieved: ' + users);
        
        System.assertEquals(9, users.size(), 'Number of active users returned is incorrect');
        
            Set<String> expectedUserNames = new Set<String>{ 
                'Active1', 
                'Active2', 
                'Chatter Expert', 
                'Data.com Clean', 
                'Kozirovska', 
                'Platform Integration User', 
                'Process', 
                'User'
            };
        Set<String> actualUserNames = new Set<String>();

        for (User user : users) {
            actualUserNames.add(user.LastName);
        }

        System.assertEquals(expectedUserNames, actualUserNames, 'The user names returned do not match expected values');
    }
}

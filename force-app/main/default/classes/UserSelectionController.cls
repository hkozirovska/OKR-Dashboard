public class UserSelectionController {
    @AuraEnabled(cacheable=true)
    public static List<User> getUsers() {
        return [SELECT Id, Name, LastName FROM User WHERE IsActive = true];
    }
}
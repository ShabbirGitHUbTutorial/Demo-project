@IsTest(SeeAllData=true)
public class SPEN_GS6FormControllerTest {
    @isTest
    static void testGetDistrict() {
        Test.startTest();

        // Create test data, such as User and ServiceTerritoryMember records
        User testUser = new User(
            Username = 'TestGS6@test.com',
            LastName = 'Test Last Name',
            Email = 'testUser@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = UserInfo.getProfileId(),
            LanguageLocaleKey = 'en_US',
            IsActive = true);
        
        insert testUser;

        OperatingHours testOperatingHours = new OperatingHours(
            Name = 'Test Hours',
        	TimeZone = 'Europe/London'
            
        );
        
        insert testOperatingHours;
        
         ServiceTerritory testTerritory = new ServiceTerritory(
            Name = 'Test Territory',
        	OperatingHoursId = testOperatingHours.Id,
            isActive = true
        );
        
        insert testTerritory;
        
        ServiceResource testServiceResource = new ServiceResource(
            Name = 'Test Service Resource',
            RelatedRecordId = testUser.Id,
            isActive = true
        );
        
        insert testServiceResource;

        ServiceTerritoryMember testMember = new ServiceTerritoryMember(
            ServiceResourceId = testServiceResource.id,
            ServiceTerritoryId = testTerritory.id,
            TerritoryType = 'P',
            EffectiveStartDate = DateTime.now()
            //EffectiveEndDate = Null
        );
        
        System.debug('testUser: ' + testUser);
        System.debug('testSR: ' + testServiceResource);
        System.debug('testTerritory: ' + testTerritory);
        System.debug('testMember: ' + testMember);
        
        insert testMember;
        

        // Call the method being tested
        ServiceTerritoryMember result = SPEN_GS6FormController.getDistrict(testUser.Id);

        // Assert that the result is as expected
        System.assertEquals(testTerritory.Name, result.ServiceTerritory.Name);
        System.assertEquals('P', result.TerritoryType);

        Test.stopTest();
    }
}
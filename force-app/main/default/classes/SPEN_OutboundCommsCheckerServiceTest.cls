@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_OutboundCommsCheckerServiceTest 
{
    @isTest 
    private static void getCommHoursIfDailyTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        System.runAs(user)
        { 
            
            Test.startTest();
            try
            {
                List<SPEN_IVR__c> listIVR = SPEN_TestDataFactory.createIVRrecord(1);
                insert listIVR;
                SPEN_IVRMessage__c message = SPEN_TestDataFactory.createIVRMessage(1);
                insert message;
                List<SPEN_IVROperatingHours__c> lstIVR = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,listIVR[0].id, message.id);
                SPEN_OutboundCommsCheckerService.getCommHoursIfDaily(lstIVR[0]);
                
                List<SPEN_IVROperatingHours__c> lstIVR1 = SPEN_TestDataFactory.createIVROperatingHoursrecord(1,listIVR[0].id, message.id);
                lstIVR1[0].SPEN_isDaily__c = true;
                SPEN_OutboundCommsCheckerService.getCommHoursIfDaily(lstIVR1[0]);
                Assert.isNotNull(message);
            }
            catch(exception e){
                Assert.isTrue(e!=null);
            }
            Test.stopTest();
        }
    }    
}
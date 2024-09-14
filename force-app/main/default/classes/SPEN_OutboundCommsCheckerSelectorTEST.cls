@IsTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_OutboundCommsCheckerSelectorTEST {
    @IsTest
    private static void testgetIfIn(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_VoiceAlertAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id); 
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_PSRAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ContactAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
        System.runAs(user)
        {
             	SPEN_IVRMessage__c ivrMessage = SPEN_TestDataFactory.createIVRMessage(1);
            	insert ivrMessage;
            	List<SPEN_IVR__c> ivrList=SPEN_TestDataFactory.createIVRrecord(SPEN_TestDataFactoryConstants.SINGLE_REC);
            	insert ivrList;
            	List<SPEN_IVROperatingHours__c> operatingList=SPEN_TestDataFactory.createIVROperatingHoursrecord(SPEN_TestDataFactoryConstants.SINGLE_REC,                                                                                                 ivrList[0].Id,ivrMessage.Id);
            	insert operatingList;
            
            	Test.startTest();
            	List<SPEN_IVROperatingHours__c> testList=SPEN_OutboundCommsCheckerSelector.getIfInRestricedDate(operatingList[0].Id);
            	List<SPEN_IVROperatingHours__c> testList2=SPEN_OutboundCommsCheckerSelector.getIfInRestricedDate(NULL);
            	List<SPEN_IVROperatingHours__c> testList1=SPEN_OutboundCommsCheckerSelector.getIfInStartEndTime(operatingList[0].Id);
            	Assert.isNotNull(testList);
            	Assert.isNotNull(testList1);
            	Test.stopTest();
        }
    }
        /*static void testThrowAnException() {
    	Exception capturedException;

    	try {
        	throwAnException();
    	} 	catch (Exception e) {
        	capturedException = e;
    	}

    	System.assertNotEquals(null, capturedException, 'Exception should be thrown');
    	System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
    	System.assertEquals('The message that you can get in a test', capturedException.getMessage(), 'Specific error message is expected');
		}*/
    }
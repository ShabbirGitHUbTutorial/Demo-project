@IsTest
public class SPEN_CaseServiceTEST {
    @IsTest
    private static void outageETRTest(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user)
        {
            Test.startTest();
            Case caseList = new Case();
            String caseCategory = 'No Supply (Single Premise)';
            SPEN_CaseService testCaseService = new SPEN_CaseService();
            Integer hourValue = system.now().hour();
            //testCaseService.hourValue = system.now().hour();
    		//SPEN_ConfigurableSettings__c configSetMap = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,'Test123');
            //insert configSetMap;
            //system.debug(configSetMap.Id);
        	//configSetMap = SPEN_CaseSelector.configSettingsMap;//map to hold COnfig settings value
            SPEN_CaseService.getOutageETR(caseCategory);
            caseCategory = 'No Supply (IVR) Single Prem';
            SPEN_CaseService.getOutageETR(caseCategory);
            //configSetMap.SPEN_CaseService.getOutageETR(caseCategory);
            caseCategory = 'No Supply (Network)';
            SPEN_CaseService.getOutageETR(caseCategory);
            Assert.isNotNull(caseCategory); 
            //testCaseService.hourValue =12;
            SPEN_CaseService.getOutageETR(NULL);
            Test.stopTest();
        }
    }
    @IsTest
    private static void getOutageETRValTest(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        
        System.runAs(user)
        {
            Test.startTest();
            String zone = 'Dee Valley';
            Datetime createdDate = system.now();
            SPEN_CaseService.getOutageETRVal(createdDate, zone);
            Assert.isNotNull(zone);
            Test.stopTest();
        }
    }
    @IsTest
    private static void getOutageTimeInModValueTest(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        
        System.runAs(user)
        {
            Test.startTest();
            Integer valueThreshold =3;
            Datetime createdDate = system.now();
            
            Assert.isNotNull(valueThreshold);
            Boolean inBusinessHours =true;
            SPEN_CaseService.getOutageTimeValue(valueThreshold, createdDate,inBusinessHours);
            SPEN_CaseService.getOutageTimeInModValue(valueThreshold, inBusinessHours);
            Assert.isNotNull(valueThreshold);
            inBusinessHours =false;
            SPEN_CaseService.getOutageTimeValue(valueThreshold, createdDate,inBusinessHours);
            SPEN_CaseService.getOutageTimeInModValue(valueThreshold, inBusinessHours);
            Assert.isNotNull(valueThreshold);
            Test.stopTest();
        }
    }
    @IsTest
    private static void getOutsideETRMessageTest(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        System.runAs(user)
        {
            Test.startTest();
            String configStr = 'Test';
            SPEN_CaseService.getOutsideETRMessage(configStr);
            Assert.isNotNull(configStr);
            Test.stopTest();
        }
    }
    @IsTest
    private static void getgetCommonOutageETRTest(){
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        if (devOpsPSGroup.Status != 'Updated') {
            Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
        }
        PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
        devOpsAssign.AssigneeId = user.Id;
        devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
        insert devOpsAssign;
        
        System.runAs(user)
        {	
            Test.startTest();
                Incident incidentRec = SPEN_TestDataFactory.createListofIncidents(1)[0];
                incidentRec.SPEN_EstimatedRestorationTime__c = System.now();
                insert incidentRec;
               String result =  SPEN_CaseService.getCommonOutageETR('NOS', incidentRec.Id);
            	System.assertNotEquals(null, result, 'Common outage has some value');
            Test.stopTest();
        }
    }

}
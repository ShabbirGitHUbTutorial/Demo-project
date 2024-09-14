/**********************************************************************************************
* @Author:      Smita Raikar
* @Date:        08/12/2022
* @Description: Test class for Configurable setting selector class
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SEL_ConfigurationSettingSelector_TEST {
    @isTest static void getconfigSettingTest() {
        
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
        PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_ConfigurableSettingsRU'];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
        System.runAs(user)
        {
            SPEN_ConfigurableSettings__c cs = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,SPEN_ConstantData.IncidentMessage);
            SPEN_ConfigurableSettings__c csetting = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,CasesConstants.NoSupplyNetworkWithinBusinessHours);
            insert cs;
            insert csetting;
            
            Test.startTest();
            SEL_ConfigurationSettingSelector.getconfigSetting();
            SEL_ConfigurationSettingSelector.getETRConfig('NS-SP within Business Hours');
            Test.stopTest(); 
            Assert.areEqual(cs.Name,SPEN_ConstantData.IncidentMessage );
            Assert.areEqual(csetting.Name,CasesConstants.NoSupplyNetworkWithinBusinessHours );
        }
    }
    
    @isTest
    public static void getMsgTaskTypeTest()
    {
        test.startTest();
        SPEN_ConfigurableSettings__c cS1 =SPEN_TestDataFactory.createConfigSetting(1,'MessagingTaskType');
        insert cS1;
        SEL_ConfigurationSettingSelector.getMsgTaskType();
        Assert.isTrue(cS1!=null);
        test.stopTest();
    }
    @isTest
    public static void getBatchDelayTest()
    {
        test.startTest();
        SPEN_ConfigurableSettings__c cS2 =SPEN_TestDataFactory.createConfigSetting(1,'CreationBatchDelay');
        insert cS2;
        SEL_ConfigurationSettingSelector.getBatchDelay();
        Assert.isTrue(cS2!=null);
        test.stopTest();
    }
    @isTest
    public static void getSMSConfigTest()
    {
        test.startTest();
        String  outcome1 = 'outcome1' +'%';
        SEL_ConfigurationSettingSelector.getSMSConfig(outcome1);
        Assert.isTrue(outcome1!=null);
        test.stopTest();
    }
}
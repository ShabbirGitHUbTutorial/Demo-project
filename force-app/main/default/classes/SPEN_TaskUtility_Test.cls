/*************************************************************************
@Author: Swaathi KR
@Date: 28/08/23
@User Story: CRMD-776
@purpose: Test Class with to cover SPEN_TaskUtility
*************************************************************************************/
@isTest
public class SPEN_TaskUtility_Test {
    @isTest 
    public static void insertTask()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        
        System.runAs(user)
        {
            Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
            Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
            List<Case> csList = new List<Case>();
            
            Case ThreePDCase =new Case();
            ThreePDCase.Status ='Created';
            ThreePDCase.Priority='Medium';
            ThreePDCase.RecordTypeId = recordTypeId3PD;
            insert ThreePDCase; 
            csList.add(ThreePDCase);
            SPEN_TaskUtility.InsertTask(csList,'Contact the field engineers onsite for missing Photo');
            Assert.isNotNull(csList);
        }   
    }
}
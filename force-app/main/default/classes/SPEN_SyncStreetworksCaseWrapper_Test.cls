/***************************************************************************
* @Author:      Swaathi
* @Date:        24/08/2023
* @UserStory:   CRMD-724
* @Description: Method to handle test class coverage for SPEN_SyncStreetworksCaseDetailsWrapper class
*****************************************************************************/
@isTest
public class SPEN_SyncStreetworksCaseWrapper_Test {
    
    @isTest
    public static void testwrapper()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            SPEN_SyncStreetworksCaseDetailsWrapper wrappertest = new SPEN_SyncStreetworksCaseDetailsWrapper();
            System.assertequals('test',wrappertest.test());
            Assert.isNull(wrappertest.Cases);
        }
    }
}
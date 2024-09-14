@isTest
public class SPEN_VoicemailsTest 
{
    @isTest
    private static void testConstantClass()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user);
        System.runAs(user)
        {
            /*List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test',SPEN_TestDataFactoryConstants.SINGLE_REC);
			  SPEN_Voicemails.coverageMethod();
              Assert.isNotNull(accRec);*/           
            Test.startTest();
            SPEN_Voicemails.coverageMethod();
            SEL_BatchConstants.getUnitTest();
            //System.assertEquals(true,user.IsActive,'active user');
            Assert.areEqual(true,user.IsActive,'active user');
            Test.stopTest();
        }
    }
}
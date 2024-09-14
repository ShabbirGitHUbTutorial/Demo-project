@isTest
public class SPEN_GetMeterDetailsWrapper_Test 
{
	@isTest 
    private static void test()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            String resbody = '{"Header":{"RequestDate":"20230203 08:06:26.AM","RequestId":17267658,"ResponseTime":"343.8054","VersionNumber":"1.0.0.0;Instance=UIT"},"Results":[{"Errors":[],"ParameterSet":{"Parameters":[{"Key":"MPAN","Value":"1800051691439"}]},"UtilityMatches":[{"UtilityDetails":[{"Key":"mpan_core","Value":"1800051691439"}],"UtilityKey":"1800051691439","UtilityType":"electricity","Meters":[{"MeterDetails":[{"Key":"mpancore","Value":"1800051691439"}]}]}]}]}';
            
            SPEN_GetMeterDetailsWrapper objWrapper = new SPEN_GetMeterDetailsWrapper();
            SPEN_GetMeterDetailsWrapper.Errors objError = new SPEN_GetMeterDetailsWrapper.Errors();
            objError.Code = '101';
            objError.Description = 'test';
            List<SPEN_GetMeterDetailsWrapper.Errors> lstErrors  = new List<SPEN_GetMeterDetailsWrapper.Errors>();
            lstErrors.add(objError);
            
            SPEN_GetMeterDetailsWrapper.Parameters objParameters = new SPEN_GetMeterDetailsWrapper.Parameters();
            objParameters.Key = '101';
            objParameters.Value = 'test';
            List<SPEN_GetMeterDetailsWrapper.Parameters> lstParameters  = new List<SPEN_GetMeterDetailsWrapper.Parameters>();
            lstParameters.add(objParameters);
            
            SPEN_GetMeterDetailsWrapper.UtilityMatches objUtilityMatches = new  SPEN_GetMeterDetailsWrapper.UtilityMatches();
            objUtilityMatches.UtilityDetails = lstParameters;
            objUtilityMatches.UtilityType = 'TestType';
            objUtilityMatches.UtilityKey = 'TestKey';
            List<SPEN_GetMeterDetailsWrapper.UtilityMatches> lstUtilityMatches  = new List<SPEN_GetMeterDetailsWrapper.UtilityMatches>();
            lstUtilityMatches.add(objUtilityMatches);
            
            SPEN_GetMeterDetailsWrapper.Results objResults = new SPEN_GetMeterDetailsWrapper.Results();
            objResults.Errors = lstErrors;
            objResults.UtilityMatches = lstUtilityMatches;
            List<SPEN_GetMeterDetailsWrapper.Results> lstUtilityResult = new List<SPEN_GetMeterDetailsWrapper.Results>();
            lstUtilityResult.add(objResults);
            objWrapper.results = lstUtilityResult;
            
            SPEN_GetMeterDetailsWrapper.test();
            Assert.isNotNull(objWrapper);
            Test.stopTest();
        }
    }
}
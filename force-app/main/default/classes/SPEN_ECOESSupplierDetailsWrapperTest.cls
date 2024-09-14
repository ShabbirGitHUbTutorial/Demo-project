@isTest
    public class SPEN_ECOESSupplierDetailsWrapperTest {
	@isTest 
    private static void test()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        { 
            Test.startTest();
            
            String json = '{"Errors": [],"ParameterSet":{"Parameters":[{"Key": "Postcode","Value": "G11 1GG"},]},"UtilityAddressMatches": [{"AddressDetails": [{"Key": "installing_supplier_mpid","Value": "BGAS"}],"UtilityType": null}]}';
           // SPEN_ECOESSupplierDetailsWrapper objWrapper =(SPEN_ECOESSupplierDetailsWrapper)System.JSON.deserialize(json,SPEN_ECOESSupplierDetailsWrapper.class);
            //SPEN_ECOESSupplierDetailsWrapper.reqBody = objWrapper.
            SPEN_ECOESSupplierDetailsWrapper objWrapper = new SPEN_ECOESSupplierDetailsWrapper();
            SPEN_ECOESSupplierDetailsWrapper.Errors objError = new SPEN_ECOESSupplierDetailsWrapper.Errors();
            objError.Code = '101';
            objError.Description = 'test';
            List<SPEN_ECOESSupplierDetailsWrapper.Errors> lstErrors  = new List<SPEN_ECOESSupplierDetailsWrapper.Errors>();
            lstErrors.add(objError);
            
            SPEN_ECOESSupplierDetailsWrapper.Parameters objParameters = new SPEN_ECOESSupplierDetailsWrapper.Parameters();
            objParameters.Key = '101';
            objParameters.Value = 'test';
            List<SPEN_ECOESSupplierDetailsWrapper.Parameters> lstParameters  = new List<SPEN_ECOESSupplierDetailsWrapper.Parameters>();
            lstParameters.add(objParameters);
            
            SPEN_ECOESSupplierDetailsWrapper.UtilityAddressMatches objUtilityAddressMatches = new  SPEN_ECOESSupplierDetailsWrapper.UtilityAddressMatches();
            objUtilityAddressMatches.AddressDetails = lstParameters;
            objUtilityAddressMatches.UtilityType = 'test';
            List<SPEN_ECOESSupplierDetailsWrapper.UtilityAddressMatches> lstUtilityAddressMatches  = new List<SPEN_ECOESSupplierDetailsWrapper.UtilityAddressMatches>();
            lstUtilityAddressMatches.add(objUtilityAddressMatches);
            
            SPEN_ECOESSupplierDetailsWrapper.RequestBody objRequestBody = new SPEN_ECOESSupplierDetailsWrapper.RequestBody();
            objRequestBody.Errors = lstErrors;
            //objRequestBody.ParameterSet.Parameters = lstParameters;
            objRequestBody.UtilityAddressMatches = lstUtilityAddressMatches;
            List<SPEN_ECOESSupplierDetailsWrapper.RequestBody> lstUtilityRequestBody  = new List<SPEN_ECOESSupplierDetailsWrapper.RequestBody>();
            lstUtilityRequestBody.add(objRequestBody);
            objWrapper.reqBody = lstUtilityRequestBody;
			SPEN_ECOESSupplierDetailsWrapper.test();
            Assert.isTrue(objWrapper.reqBody!=null);
            Test.stopTest();
        }
    }
}
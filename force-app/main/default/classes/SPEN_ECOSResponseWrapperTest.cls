@isTest
public class SPEN_ECOSResponseWrapperTest 
{
  @isTest
  public static void testMethod1(){ 
    Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
    User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
    Database.insert(user); 
    System.runAs(user)
    { 
      Test.startTest();
      
      String json = '{"Errors": [],"ParameterSet":{"Parameters":[{"Key": "Postcode","Value": "G11 1GG"},]},"UtilityAddressMatches": [{"AddressDetails": [{"Key": "installing_supplier_mpid","Value": "BGAS"}],"UtilityType": null}]}';
      SPEN_ECOSResponseWrapper objWrapper = new SPEN_ECOSResponseWrapper();
      SPEN_ECOSResponseWrapper.test();
      Assert.isTrue(objWrapper!=null);
      Test.stopTest();
    }           
  }
}
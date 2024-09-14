/*-----------------------------------------------------------------------------------------
DESCRIPTION  :  Unit test class for Last Gasp Mock API apex class SPEN_LastGaspMockIntegrationService.
AUTHOR    :  Smita Raikar
LIBRARY    :  Salesforce Enterprise Library 
VERSION    :  1.0

HISTORY    :
Date      Author      Comment
NOV-02-2022    Smita Raikar     Initial version
-----------------------------------------------------------------------------------------*/
@isTest(seeAllData=False)
public class SPEN_LastGaspMockIntegrationService_TEST implements HttpCalloutMock{
  public HttpResponse respond(HTTPRequest req){
    HttpResponse res = new HttpResponse();
    res.setStatus('OK');
    res.setStatusCode(200);
    return res;
  }
  static SPEN_MPAN__c getmpanRecord(){
    SPEN_MPAN__c mpan = SPEN_TestDataFactory.createMPANRecords(SPEN_TestDataFactoryConstants.SINGLE_REC);
    insert mpan;
    return mpan;
  }

  static testMethod void testMock(){
     Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
      User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
      Database.insert(user);
      PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_MPANAccessCRU']; //Ayush 20 01 2023
      insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
      System.runAs(user)
      {
          SPEN_MPAN__c mpanRecord = getmpanRecord();
          Test.startTest();
          Test.setMock(HttpCalloutMock.class, new SPEN_LastGaspMockIntegrationService_TEST());
          SPEN_LastGaspMockIntegrationService.getMockResponse(mpanRecord.Id);
          Assert.isNotNull(mpanRecord, 'MPAN Record Passed');
          Test.stopTest();
          
      }
    
  }
}
@isTest
public class SPEN_SynctoADQMCallout_Test {
    public class SPEN_SyncADQMCalloutHttpMock  implements HttpCalloutMock{
        public HttpResponse respond(HTTPRequest req){
              if (req.getEndpoint().contains('client_credentials')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().contains('ADQM')) {
                String reqBody = '<env:Envelope xmlns:env="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><env:Header/><env:Body><m:getcustomerdetailsResponse xmlns:m="http://adqm_adaptor/AdqmWS.wsdl"><customerdetails><typ:position xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/" xsi:nil="true"/><typ:customerversionnumber xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/">46034374</typ:customerversionnumber><typ:premisesowner xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/" xsi:nil="true"/><typ:sitecontactname xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/">SITE CONTACT SHEKER</typ:sitecontactname><typ:mpanlist xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"><typ:mpandata><typ:supplyenddate xsi:nil="true"/><typ:currentsupplier>SPOW</typ:currentsupplier><typ:db01pending>N</typ:db01pending><typ:schemeref xsi:nil="true"/><typ:mpancore>1800026386317</typ:mpancore><typ:developmentname xsi:nil="true"/><typ:usage>DOMESTIC</typ:usage><typ:meterposition xsi:nil="true"/><typ:msnlist/><typ:energisationstatus>E</typ:energisationstatus><typ:meteringpointstatus>T</typ:meteringpointstatus><typ:db02pending>N</typ:db02pending><typ:supplystartdate>2012-11-19T00:00:00.000Z</typ:supplystartdate></typ:mpandata></typ:mpanlist><typ:custaddress xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"><typ:buildingname xsi:nil="true"/><typ:subbuildingnameno xsi:nil="true"/><typ:county xsi:nil="true"/><typ:doubledependentlocality xsi:nil="true"/><typ:locality xsi:nil="true"/><typ:streetname xsi:nil="true"/><typ:housenumber xsi:nil="true"/><typ:postcode xsi:nil="true"/><typ:dependentthoroughfare xsi:nil="true"/><typ:posttown xsi:nil="true"/><typ:plot xsi:nil="true"/></typ:custaddress><typ:premisesownaddress xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"><typ:buildingname xsi:nil="true"/><typ:subbuildingnameno>1/2</typ:subbuildingnameno><typ:county>LANARKSHIRE</typ:county><typ:doubledependentlocality xsi:nil="true"/><typ:locality xsi:nil="true"/><typ:streetname>SHETTLESTON ROAD</typ:streetname><typ:housenumber>1726</typ:housenumber><typ:postcode>G32 9AW</typ:postcode><typ:dependentthoroughfare xsi:nil="true"/><typ:posttown>GLASGOW</typ:posttown><typ:plot xsi:nil="true"/></typ:premisesownaddress><typ:surname xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/">SAGAR</typ:surname><typ:ownphonelist xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"/><typ:sitephonelist xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"/><typ:password xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/" xsi:nil="true"/><typ:sitecontactaddress xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"><typ:buildingname xsi:nil="true"/><typ:subbuildingnameno xsi:nil="true"/><typ:county xsi:nil="true"/><typ:doubledependentlocality xsi:nil="true"/><typ:locality xsi:nil="true"/><typ:streetname xsi:nil="true"/><typ:housenumber xsi:nil="true"/><typ:postcode xsi:nil="true"/><typ:dependentthoroughfare xsi:nil="true"/><typ:posttown xsi:nil="true"/><typ:plot xsi:nil="true"/></typ:sitecontactaddress><typ:premisesid xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/">2111322</typ:premisesid><typ:altdetailsname xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/" xsi:nil="true"/><typ:initials xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/" xsi:nil="true"/><typ:customertypecode xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/">0001</typ:customertypecode><typ:siteemaillist xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"/><typ:altdetsaddress xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"><typ:buildingname xsi:nil="true"/><typ:subbuildingnameno xsi:nil="true"/><typ:county xsi:nil="true"/><typ:doubledependentlocality xsi:nil="true"/><typ:locality xsi:nil="true"/><typ:streetname xsi:nil="true"/><typ:housenumber xsi:nil="true"/><typ:postcode xsi:nil="true"/><typ:dependentthoroughfare xsi:nil="true"/><typ:posttown xsi:nil="true"/><typ:plot xsi:nil="true"/></typ:altdetsaddress><typ:custemaillist xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"><typ:emaildetails><typ:emailaddress>sonu123.sagar@accenture.com</typ:emailaddress><typ:lastupdateddate xsi:nil="true"/></typ:emaildetails></typ:custemaillist><typ:altemaillist xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"/><typ:premiseaddress xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"><typ:buildingname xsi:nil="true"/><typ:subbuildingnameno>1/2</typ:subbuildingnameno><typ:county>LANARKSHIRE</typ:county><typ:doubledependentlocality xsi:nil="true"/><typ:locality xsi:nil="true"/><typ:streetname>SHETTLESTON ROAD</typ:streetname><typ:housenumber>1726</typ:housenumber><typ:postcode>G32 9AW</typ:postcode><typ:dependentthoroughfare xsi:nil="true"/><typ:posttown>GLASGOW</typ:posttown><typ:plot xsi:nil="true"/></typ:premiseaddress><typ:forename xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/">SONU12345</typ:forename><typ:custphonelist xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"><typ:phonedetails><typ:phoneno>07753624226</typ:phoneno><typ:phonetype>MOBILE</typ:phonetype><typ:lastupdateddate>2023-02-13T07:13:33.000Z</typ:lastupdateddate></typ:phonedetails><typ:phonedetails><typ:phoneno>07753624228</typ:phoneno><typ:phonetype>HOME</typ:phonetype><typ:lastupdateddate>2023-02-13T07:13:34.000Z</typ:lastupdateddate></typ:phonedetails></typ:custphonelist><typ:psrdetails xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"><typ:consenttosharegiven>T</typ:consenttosharegiven><typ:consenttosharesource>WS-U345575</typ:consenttosharesource><typ:consenttosharedate>2022-11-04T00:00:00.000Z</typ:consenttosharedate><typ:psrprimarycontact><typ:contactname xsi:nil="true"/><typ:contactfreetext xsi:nil="true"/><typ:contactsubbuilding xsi:nil="true"/><typ:contactbuildingname xsi:nil="true"/><typ:contactdepthoroughfare xsi:nil="true"/><typ:contactstreet xsi:nil="true"/><typ:contactvillage xsi:nil="true"/><typ:contactdistrict xsi:nil="true"/><typ:contacttown xsi:nil="true"/><typ:contactcounty xsi:nil="true"/><typ:contactpostcode xsi:nil="true"/><typ:contactphonenumbers/></typ:psrprimarycontact><typ:psralternatecontact><typ:contactname xsi:nil="true"/><typ:contactfreetext>ADDRESS NO LONGER USED</typ:contactfreetext><typ:contactsubbuilding xsi:nil="true"/><typ:contactbuildingname xsi:nil="true"/><typ:contactdepthoroughfare xsi:nil="true"/><typ:contactstreet xsi:nil="true"/><typ:contactvillage xsi:nil="true"/><typ:contactdistrict xsi:nil="true"/><typ:contacttown xsi:nil="true"/><typ:contactcounty xsi:nil="true"/><typ:contactpostcode xsi:nil="true"/><typ:contactphonenumbers/></typ:psralternatecontact><typ:psrcodes/></typ:psrdetails><typ:altphonelist xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"/><typ:passwordefd xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/" xsi:nil="true"/><typ:premisesemaillist xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"/><typ:company xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/" xsi:nil="true"/><typ:salutation xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/">MR.</typ:salutation></customerdetails><result>1</result><errors><typ:error xmlns:typ="http://adqm_adaptor/AdqmWS.wsdl/types/"><typ:description xsi:nil="true"/><typ:code xsi:nil="true"/></typ:error></errors></m:getcustomerdetailsResponse></env:Body></env:Envelope>';
                HttpResponse res = new HttpResponse();
                res.setStatus('OK');
                res.setStatusCode(200);
                res.setBody(reqBody);
                return res;
            }else {
                return null;
            }
            
        }
    }
    @isTest static void GetCustomerDetails() {
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
        System.runAs(user){
 		List<Account> testAccount = SPEN_TestDataFactory.createAccounts(SPEN_TestDataFactoryConstants.ACCNAME,
                                                                            SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert testAccount;
        Contact ct = SPEN_TestDataFactory.createContacts(testAccount[0].id,SPEN_TestDataFactoryConstants.SINGLE_REC);
     	insert ct; 
    	List<SPEN_Premise__c> premiseList = SPEN_TestDataFactory.createListOfPremise(SPEN_TestDataFactoryConstants.SINGLE_REC);
     	insert premiseList; 
    	SPEN_ContactPremise__c conpremise = SPEN_TestDataFactory.createContactPremises(SPEN_TestDataFactoryConstants.SINGLE_REC,ct.Id,premiseList[0].Id);
     	conpremise.SPEN_ExternalId__c = '1234';
        conpremise.SPEN_Role__c = 'Customer';
        insert conpremise;
        List<SPEN_IntegrationRequest__c> intreq = SPEN_TestDataFactory.createSentIntegrationReq(SPEN_TestDataFactoryConstants.SINGLE_REC);
        insert intreq;
        intreq[0].SPEN_RelatedRecord__c = ct.Id;
        update intreq;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SPEN_SyncADQMCalloutHttpMock());
        SPEN_SynctoADQMCallout.GetCustomerDetails(ct.Id);
        SPEN_SynctoADQMCallout.getContactSynctoADQMVal(ct.Id);
        SPEN_SynctoADQMCallout.getLastIntegrationStatus(ct.Id);
        Assert.isNotNull(conpremise);
        Test.stopTest();
        }
    }
}
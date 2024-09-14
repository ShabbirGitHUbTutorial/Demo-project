@isTest
public class SPEN_VoiceCallServiceTest 
{    
    @IsTest
    private static void voiceCallTest()
    {
        Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
        User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
        Database.insert(user); 
        System.runAs(user)
        {   
            Test.startTest();
            List<Account> accRec = SPEN_TestDataFactory.createAccounts('Test', 1);
            insert accRec;
            List<Account> accRec1 = SPEN_TestDataFactory.createAccounts('Test1', 1);
            insert accRec1;
            List<SPEN_Premise__c> premiseRec = SPEN_TestDataFactory.createListOfPremise(2);
            insert premiseRec;
            
            CallCenter center=[select Id from CallCenter limit 1];
            
            List<Contact> conList = new List<Contact>();
            Contact conRec = SPEN_TestDataFactory.createContacts(accRec[0].Id, SPEN_TestDataFactoryConstants.SINGLE_REC);
            //conRec.SPEN_CustomerID__c='A1234';
            conRec.SPEN_Premise__c=premiseRec[0].Id;
            Contact conRec1 = SPEN_TestDataFactory.createContacts(accRec1[0].Id, SPEN_TestDataFactoryConstants.SINGLE_REC);
            conRec1.SPEN_CustomerID__c='SB__003';
            conRec1.MobilePhone = '07123456791';
            conRec1.Salutation = 'Ms.';
            conRec1.FirstName = 'Jessica';
            conRec1.LastName = 'Doe';
            conRec1.Phone = '01234567896';
            conRec1.Suffix = 'AK1';
            conRec1.SPEN_Premise__c=premiseRec[1].Id;
            conList.add(conRec);
            conList.add(conRec1);
            insert conList;
            
            VoiceCall voiceRec=SPEN_TestDataFactory.createVoiceCall(1);
            //voiceRec.SPEN_ContactId__c = conList[0].Id;
            voiceRec.CallCenterId =center.Id;
            voiceRec.SPEN_VoicecallPremise__c = premiseRec[0].Id;
            voiceRec.CallType ='OutBound';
            voiceRec.RelatedRecordId = conList[0].Id;
            insert voiceRec;
            
            //voiceRec.SPEN_ContactId__c = conList[1].Id;
            //update voiceRec;
            
            List<VoiceCall> voiceCallList = new List<VoiceCall>();
            voiceCallList.add(voiceRec);
            SPEN_VoiceCallService.updateCWizardDataToVoiceCall(voiceCallList);
            //system.assertEquals(voiceRec.SPEN_VoicecallPremise__c, conRec.SPEN_Premise__c,'voice call premise');
            Assert.areEqual(voiceRec.SPEN_VoicecallPremise__c, conRec.SPEN_Premise__c,'voice call premise');
            Test.stopTest();
            
        }
    }
    @IsTest
    private static void testException()
    {
        Test.startTest();
		SPEN_VoiceCallService voiceCallService = new SPEN_VoiceCallService();
        voiceCallService.isUpdatingPremiseOnVoiceCall(NULL, NULL);
        Assert.isNotNull(voiceCallService);
        Test.stopTest();
    }
}
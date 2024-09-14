/*------------------------------------------------------------------------------------
    DESCRIPTION	:	Test class of SPEN_IVRMessageSelector
    LIBRARY		:	SPEN
    VERSION		:	1.0
    
    HISTORY		:
    Date			Author				Comment
    
    ------------------------------------------------------------------------------------*/
    @IsTest
    public with sharing class SPEN_IVRMessageSelector_TEST
    {
        @testSetup static void setup(){
            //Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
            PermissionSetGroup devOpsPSGroup = SPEN_TestDataFactory.getPSGroup('SPEN_PersonaDevOpsUser');
            User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
            Database.insert(user); 
            if (devOpsPSGroup.Status != 'Updated') 
            {
                Test.calculatePermissionSetGroup(devOpsPSGroup.Id);
            }
            PermissionSetAssignment devOpsAssign = new PermissionSetAssignment();
            devOpsAssign.AssigneeId = user.Id;
            devOpsAssign.PermissionSetGroupId = devOpsPSGroup.Id;
            insert devOpsAssign;
            System.runAs(user){
                Test.startTest();
                SPEN_ConfigurableSettings__c cs = SPEN_TestDataFactory.createConfigSetting(SPEN_TestDataFactoryConstants.SINGLE_REC,SPEN_ConstantData.IncidentMessage);
                cs.Name = 'Zone broadcast message updated last one hour';
                cs.SPEN_Value__c = '10';
                insert cs;
                List<SPEN_iVRmessage__c> iVRmessageList=new List<SPEN_iVRmessage__c>();
                SPEN_iVRmessage__c iVRmessage1 = SPEN_TestDataFactory.createiVRmessage(2);
                iVRmessage1.SPEN_ExternalId__c='Case-Creation-2';
                iVRmessageList.add(iVRmessage1);
                insert iVRmessageList;
                Test.stopTest();
            }
        }
        
        @IsTest
        public static void testGetRelatedIVRmsg(){
            User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
            System.runAs(user){ 
            test.startTest();
            SPEN_IVRMessage__c ivrMsg = new SPEN_IVRMessage__c();
            ivrMsg.Name = 'TESTMessageRecord';
            ivrMsg.SPEN_IVRMessage__c = 'Thanks for Contacting SPEN';
            ivrMsg.SPEN_ExternalId__c = 'TESTMessageRecord';
            insert ivrMsg;
            SPEN_IVRMessageSelector obj = new SPEN_IVRMessageSelector();
            SPEN_IVRMessage__c msg2 = obj.selectByExternalId(ivrMsg.SPEN_ExternalId__c);
            //SPEN_IVRMessage__c msg3= SPEN_IVRMessageSelector.getIVRMsgRecord(ivrMsg.id);
            //List<SPEN_IVRMessage__c> msg4 = SPEN_IVRMessageSelector.getIVRMessage(ivrMsg.SPEN_ExternalId__c,recTypeIdIVR);
            
            //system.assertEquals('TESTMessageRecord', msg.Name);
            Assert.areEqual(ivrMsg.Name,'TESTMessageRecord');
            test.stoptest();
            }
        }
        @IsTest
        public static void getIVRMessageMapTest(){
            User user=SPEN_TestdataSelector.getuser(SPEN_TestDataFactoryConstants.FIRSTNAME);
            System.runAs(user){ 
            test.startTest();
            SPEN_iVRmessage__c iVRmessage =SPEN_TestdataSelector.getIVRMessage('Case-Creation-2');
            List<Id> ivrMsgIdList=new List<Id>{iVRmessage.id};
            Map<Id,SPEN_IVRMessage__c> ivrmap=SPEN_IVRMessageSelector.getIVRMessageMap(ivrMsgIdList);
            Assert.areEqual(ivrmap.size(),1);
            test.stoptest();
    }
        }
    }
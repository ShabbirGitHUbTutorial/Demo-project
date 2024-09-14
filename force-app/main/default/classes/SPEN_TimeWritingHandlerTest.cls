@isTest
    public class SPEN_TimeWritingHandlerTest
{
        
        @isTest
        Public static void testcalculateTimeWritingFee()
        {
            //Profile Creation
            Id profileId = SPEN_TestDataFactory.getProfile(SPEN_TestDataFactoryConstants.PROFILENAME);
            //User setup
            User user = SPEN_TestDataFactory.settestUser(SPEN_TestDataFactoryConstants.PROFILENAME);
            //insert User
            Database.insert(user);
            //Permissionset assignment
            PermissionSet ps1 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseAccessCRU'];
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps1.Id);
            
            PermissionSet ps2 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_IVROperatinghoursAccessCRU'];
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps2.Id);
            
            PermissionSet ps3 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_CaseTransmissionAccessCRU'];
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps3.Id);
            
            PermissionSet ps4 = [SELECT Id FROM PermissionSet WHERE Name = 'SPEN_TimeWritingAccessCRU'];
            insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps4.Id);       
            
            System.runAs(user)
            {
                Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
                
                //create records for SPEN_TransmissionApplicationFeeRules__c and insert 
                List<SPEN_TransmissionApplicationFeeRules__c> sptLst = new List<SPEN_TransmissionApplicationFeeRules__c>(); 
                Id sptRecTypeId=[select Id from RecordType where DeveloperName='SPEN_VariableApplicationFee'].Id;
                SPEN_TransmissionApplicationFeeRules__c spt1 = new SPEN_TransmissionApplicationFeeRules__c(SPEN_Team__c='System Design', SPEN_Role__c= 'Department manager', SPEN_DailyRate__c= 723 );
                spt1.RecordTypeId = sptRecTypeId;
                spt1.SPEN_isActive__c = true;
                // SPEN_TransmissionApplicationFeeRules__c spt2 = new SPEN_TransmissionApplicationFeeRules__c(SPEN_ApplicationStage__c='Initial', SPEN_ApplicationType__c='Direct', SPEN_ContractArea__c='In Area',SPEN_LocationType__c='Onshore',SPEN_MaxDemandCapacityMWs__c=1000000.00,SPEN_MaxSizeMWsExportCEC__c=1000000.00,SPEN_MinDemandCapacityMWs__c=0.00,SPEN_MinSizeMWsExportCEC__c=1800.01,SPEN_PrimaryTransmissionTechnologyType__c='Wind',SPEN_SecondaryTransmissionTechnologyType__c='Wind',SPEN_TertiaryTransmissionTechnologyType__c='Wind',SPEN_FixedCumulativeApplicationFee__c=91150.00,SPEN_IsActive__c=TRUE);
                sptLst.add(spt1);
                //sptLst.add(spt2);
                insert sptLst;
                
                //Create Case
                List<case> testCase = SPEN_TestDataFactory.createListOfCases(SPEN_TestDataFactoryConstants.SINGLE_REC);
                Id recTypeId=[select Id from RecordType where DeveloperName='SPEN_CaseTransmission'].Id;
                testCase[0].RecordTypeId =recTypeId;
                testCase[0].SPEN_ESOApplicationID__c='1111';
                testCase[0].SPEN_DNOApplicationID__c='2222';
                testCase[0].SPEN_LocationType__c='Onshore';
                testCase[0].SPEN_ApplicationType__c='Direct';
                testCase[0].Application_Stage__c='Initial'; 
                testCase[0].SPEN_PrimaryTransmissionTechnologyType__c='Wind';
                testCase[0].SPEN_SecondaryTransmissionTechnologyType__c='Wind';
                testCase[0].SPEN_TertiaryTransmissionTechnologyType__c	='Wind';
                testCase[0].SPEN_ContractArea__c ='In Area';
                testCase[0].SPEN_DemandCapacityMWs__c = 3.00;
                testCase[0].SPEN_SizeMWsExportCEC__c = 2.00 ;
                testCase[0].RecordTypeId=recTypeId;
                insert testCase;
                
                //Create Financial Record
                List<SPEN_FinancialInformation__c> finInfo = new List<SPEN_FinancialInformation__c>(); 
                SPEN_FinancialInformation__c finInfo1 = new SPEN_FinancialInformation__c(SPEN_TerminationAmount__c = 884.26);
                finInfo.add(finInfo1);
                insert finInfo;
                
                //create records for TimeWriting and insert
                List<SPEN_TimeWriting__c> tw = new List<SPEN_TimeWriting__c>(); 
                SPEN_TimeWriting__c tw1=new SPEN_TimeWriting__c();
                tw1.SPEN_Team__c = 'System Design';
                tw1.SPEN_Role__c = 'Department manager';
                tw1.SPEN_HoursSpent__c = 10;
                tw1.SPEN_FinancialInformation__c = finInfo[0].id;
                tw.add(tw1);
                insert tw;
                tw1.SPEN_HoursSpent__c = 20;
                update tw1;
                Test.startTest();
                if(sptLst.size()>0 && tw.size()>0)
                {
                    if(sptLst[0].SPEN_Team__c == tw[0].SPEN_Team__c  && sptLst[0].SPEN_Role__c == tw[0].SPEN_Role__c)
                    {
                        SPEN_TimeWritingTriggerHandler.calculateTimeWritingFee(tw);
                       
                    }           
                }
                 Test.stopTest();
                 Assert.areNotEqual(tw[0].SPEN_TotalCost__c,977.027027027027);
                
            }
            
        }
}
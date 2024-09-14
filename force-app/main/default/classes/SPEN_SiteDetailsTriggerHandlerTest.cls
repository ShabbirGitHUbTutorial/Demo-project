@isTest
@SuppressWarnings('PMD.SOQLSelectorPattern')
public class SPEN_SiteDetailsTriggerHandlerTest {
    Public static Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
    @isTest
    public static void siteDetailsTriggerHandlerTest(){
        Test.setMock(HttpCalloutMock.class, new SPEN_UtilityClass());
        Test.startTest();
        Case caseRecord = new Case();
        caseRecord.RecordTypeId = recordTypeIdQuery;
        caseRecord.SPEN_Type__c='NRSWA';
        caseRecord.Origin='PowerOn';
        caseRecord.SPEN_ConnectionDistrict__c='test';
        caseRecord.SPEN_SPDSPMIndicator__c='SPD';
        caseRecord.SPEN_QueryReason__c='Other';
        insert caseRecord;
        List<SPEN_SiteDetails__c> sdList = new List<SPEN_SiteDetails__c>();
        SPEN_SiteDetails__c sd = new SPEN_SiteDetails__c();
        sd.SPEN_PowerOn_Additional_Coordinates__c = true;
        sd.SPEN_SurfaceType__c ='Carriageway';
        sd.SPEN_Status__c = 'Open';
        sd.SPEN_Case__c =caseRecord.Id;
        insert sd;
        sdList.add(sd);
        SPEN_SiteDetails__c sd1 = new SPEN_SiteDetails__c();
        sd1.SPEN_PowerOn_Additional_Coordinates__c = true;
        sd1.SPEN_SurfaceType__c ='	Cycleway';
        sd1.SPEN_Status__c = 'Open';
        sd1.SPEN_Case__c =caseRecord.Id;
        insert sd1;
        sdList.add(sd1);
        
        SPEN_SiteDetailsTriggerHandler.createQueryCase(sdList);
        //SPEN_SiteDetailsTriggerInterface sti = new SPEN_SiteDetailsTriggerInterface();
        Assert.areEqual('Open',  sd.SPEN_Status__c, 'Site Details status');

        //Added to cover blocks in interface class
        sd1.SPEN_LocationOfWorks__c = 'Test';
        update sd1;
        SPEN_SiteDetailsTriggerInterface obj = new SPEN_SiteDetailsTriggerInterface(); 
        Map<Id, sObject> deleteMap = new Map<Id,sObject>();
        deleteMap.put(sd1.id,sd1);
        obj.beforeDelete(deleteMap);
        obj.afterDelete(deleteMap);
        obj.afterUndelete(deleteMap);
        Test.stopTest();
    }
}
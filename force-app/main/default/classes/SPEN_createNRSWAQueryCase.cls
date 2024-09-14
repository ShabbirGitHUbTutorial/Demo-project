/***************************************************************************
* @Author:      Shubhi 
* @Date:        25/09/2023
* @UserStory:   CRMD-7413	
* @Description: class for creating NRSWA query case for resource detail arrival on site 
*****************************************************************************/
public with sharing class SPEN_createNRSWAQueryCase {
    
   	@InvocableMethod(category='SPEN' label='SPEN NRSWA query case' description='Create NRSWA query case for resource detail')
    public static void createNRSWAQueryCase(List<SPEN_ResourceDetail__c> resourceDetail){
        if(resourceDetail!=null && resourceDetail[0]!=null){
			Incident inc=IncidentSelector.getIncRecordById(resourceDetail[0].SPEN_Incident__c);
            insertQueryCase(resourceDetail[0],inc);
        }
    }
    private static void insertQueryCase(SPEN_ResourceDetail__c resdetail,Incident inc){
        Case nRSWAcase=new Case();
        Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
        nRSWAcase.recordTypeId=recordTypeIdQuery;
        nRSWACase.SPEN_Type__c=CasesConstants.nrswaType;
        nRSWACase.status=CasesConstants.openStatus;//'Open';
        nRSWACase.Origin=CasesConstants.poweronOrigin;
        nrswaCase.Description ='Resource Name: '+ resdetail.SPEN_ResourceName__c +'\n'+ 'Event Date: '+  resdetail.SPEN_EventDate__c + '\n'+'Log Comment: '+resdetail.SPEN_Comment__c;
        //nRSWACase.Description=resdetail.SPEN_ResourceName__c+' '+resdetail.SPEN_Comment__c;
        nRSWACase.SPEN_QueryReason__c='Resource - '+resdetail.SPEN_Event__c;
        if(inc!=null){
          nRSWACase.SPEN_Incident__c=inc.id;
          nRSWACase.SPEN_SPDSPMIndicator__c=inc.SPEN_SPDSPM__c; 
          nRSWACase.SPEN_IncidentReference__c=inc.SPEN_IncidentReference__c; 
        }
        if(inc.SPEN_SPDSPM__c == 'SPM' && nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c == NULL){//9376
            nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c='2 Hr SLA South';
            
        }
         if(inc.SPEN_SPDSPM__c == 'SPM' && !nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c.containsIgnoreCase('High')){//9376
            nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c='2 Hr SLA South';
            
        }else if(inc.SPEN_SPDSPM__c == 'SPD' && nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c == NULL){//9376
            nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c='2 Hr SLA North';
            
        }
        else if(inc.SPEN_SPDSPM__c == 'SPD' && !nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c.containsIgnoreCase('High')){//9376
            nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c='2 Hr SLA North';
            
        }
        /*if(nRSWACase.SPEN_SPDSPMIndicator__c=='SPD'){
           //Group queueTobeAssigned = new SPEN_GroupsSelector().selectByQueueName('NRSWA_SPD');
           //nRSWACase.ownerId = queueTobeAssigned.id;
           /*BusinessHours bsHr=SPEN_BusinessHourSelector.getBusinessHrsByName(CasesConstants.NRSWA_SPD_BUSINESSHOUR);
           if(bsHr!=null){
              nRSWACase.BusinessHoursId=bsHr.id;
           }
        }else if(nRSWACase.SPEN_SPDSPMIndicator__c=='SPM'){
           //Group queueTobeAssigned = new SPEN_GroupsSelector().selectByQueueName('NRSWA_SPM');
           //nRSWACase.ownerId = queueTobeAssigned.id;
           /*BusinessHours bsHr=SPEN_BusinessHourSelector.getBusinessHrsByName(CasesConstants.NRSWA_SPM_BUSINESSHOUR);
           if(bsHr!=null){
               nRSWACase.BusinessHoursId=bsHr.id;
           }
        }*/
        insert nRSWACase;
        Set<Id> setCaseId = new Set<Id>();
        setCaseId.add(nrswaCase.id);
        System.enqueueJob(new SPEN_JourneySLAQueueable(setCaseId));
    }
}
@RestResource(urlMapping ='/ResourceDetails/*')
global with sharing class SPEN_IncidentResourceDetails {
    Public static Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
    @HttpPost
    global static void incidentRecordUpdate(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        List<String> strList = new List<String>();
        String incidentId;
        
        try{
            SPEN_IncidentResourceDetailsXMLNodes.SoapBodyNode soapNodeValues = new SPEN_IncidentResourceDetailsXMLNodes.SoapBodyNode();
            strList = req.requestBody.toString().split('<soap:Body>');
            String newStr = req.requestBody.toString().replace(strList[0],'').replace('</soap:Envelope>', '');
            String soapEnv = newStr.replaceAll('soap:', '');
            system.debug('----soapEnv--'+soapEnv);
            String finalRequest = soapEnv.replaceAll('xmlns:xsi=http://www.w3.org/2001/XMLSchema-instance  xsi:nil="true"', '');
            system.debug('----finalRequest--'+finalRequest);
            soapNodeValues.load(finalRequest);
            
            //BusinessHours spmHours = SPEN_BusinessHourSelector.getNRSWABusinessHrs();
            //BusinessHours spdHours = SPEN_BusinessHourSelector.getNRSWASpdHrs();
            //Entitlement queryEntitlement = SPEN_EntitlementSelector.getQueryEntitlement();
            Group queueSPMId = new SPEN_GroupsSelector().selectByQueueName('NRSWA_SPM');
            Group queueSPDId = new SPEN_GroupsSelector().selectByQueueName('NRSWA_SPD');
            SPEN_IncidentResourceDetailsWrapper.RequestBody createResourceWrapper = (SPEN_IncidentResourceDetailsWrapper.RequestBody) System.JSON.deserialize(JSON.serialize(soapNodeValues), SPEN_IncidentResourceDetailsWrapper.RequestBody.class);
            system.debug('------createResourceWrapper-------'+createResourceWrapper);
            if(createResourceWrapper.SDIFIncidentLabourLogCreated != null && !createResourceWrapper.SDIFIncidentLabourLogCreated.isEmpty() && System.Label.SPEN_PowerOnCheck =='Yes'){
                SPEN_IncidentResourceDetailsWrapper.SDIFIncidentLabourLogCreated incResourceRec= createResourceWrapper.SDIFIncidentLabourLogCreated[0];
                SPEN_IncidentResourceDetailsWrapper.IncidentLabourLogCreatedStc nextResourceLog =incResourceRec.IncidentLabourLogCreatedStc[0];
                system.debug('----nextResourceLog--'+nextResourceLog);
                Incident inc = IncidentSelector.getIncRecord(nextResourceLog.IncidentReference);
                Case caseRecord = SPEN_CaseSelector.getNRSWACase(inc.Id);
                system.debug('----caseRecord--'+caseRecord);
                SPEN_ResourceDetail__c rdRecord = new SPEN_ResourceDetail__c();
                rdRecord.SPEN_Company__c = nextResourceLog.Company;
                rdRecord.SPEN_Comment__c = nextResourceLog.LogComment;
                rdRecord.SPEN_ResourceName__c = nextResourceLog.ResourceName;
                rdRecord.SPEN_EventDate__c = DateTime.valueOfGmt((nextResourceLog.EventDate.replace('T', ' ')));
                system.debug('----SPEN_EventDate__c--'+rdRecord.SPEN_EventDate__c);
                system.debug('----nextResourceLog.EventDate--'+nextResourceLog.EventDate);
                rdRecord.SPEN_Incident__c = inc.Id;
                if(nextResourceLog.LogCategoryID == 2 && nextResourceLog.LogSubCategoryID == -1){
                    rdRecord.SPEN_Event__c = 'Arrival On Site';
                }
                else if(nextResourceLog.LogCategoryID == 2 && nextResourceLog.LogSubCategoryID == -11){
                    rdRecord.SPEN_Event__c = 'Cancelled';
                }
                if(rdRecord != null && Schema.sObjectType.SPEN_ResourceDetail__c.isCreateable()){
                    insert rdRecord;
                }
                if(caseRecord.Id != null && rdRecord.SPEN_Event__c== 'Cancelled' && rdRecord.SPEN_Event__c != null){
                    Case nrswaCase = new Case();
                    nrswaCase.RecordTypeId = recordTypeIdQuery;
                    nrswaCase.Origin = 'PowerOn';
                    nrswaCase.Status = 'Open';
                    nrswaCase.SPEN_Type__c = 'NRSWA';
                    nrswaCase.SPEN_QueryReason__c = 'Resource - Cancelled';
                    nrswaCase.SPEN_Incident__c = inc.Id;
                    nrswaCase.SPEN_IncidentReference__c = nextResourceLog.IncidentReference;
                    nrswaCase.Description ='Resource Name: '+ nextResourceLog.ResourceName +'\n'+ 'Event Date: '+  rdRecord.SPEN_EventDate__c + '\n'+'Log Comment: '+nextResourceLog.LogComment;
                    
                    nrswaCase.SPEN_SPDSPMIndicator__c = inc.SPEN_Zone__r.SPEN_SPD_SPM__c;
                    nrswaCase.ParentId = caseRecord.Id;
                    //nrswaCase.EntitlementId = queryEntitlement.Id;
                    if(inc.SPEN_Zone__r.SPEN_SPD_SPM__c == 'SPM'){
                        nrswaCase.OwnerId = queueSPMId.Id;
                        //9376
                        if(nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c == NULL)
                        {
                        nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c='2 Hr SLA South';
                        }
                        else if( !nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c.containsIgnoreCase('High')){//9376
                            nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c='2 Hr SLA South';
                        }

                        //nrswaCase.BusinessHoursId = spmHours.Id;
                    }else if(inc.SPEN_Zone__r.SPEN_SPD_SPM__c == 'SPD'){
                        nrswaCase.OwnerId = queueSPDId.Id;
                        if(nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c == NULL)//9376
                        {
                        nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c='2 Hr SLA North';
                        }
                         else if( !nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c.containsIgnoreCase('High')){//9376
                            nrswaCase.SPEN_Email_WI_Queue_Routing_Outcome__c='2 Hr SLA North';
                        }

                        //nrswaCase.BusinessHoursId = spdHours.Id;
                    }
                    if(nrswaCase != null && Schema.sObjectType.Case.isCreateable()){
                        insert nrswaCase;
                        system.debug('----nrswaCase--'+nrswaCase);
                        Set<Id> setCaseId = new Set<Id>();
                        setCaseId.add(nrswaCase.id);
                        System.enqueueJob(new SPEN_JourneySLAQueueable(setCaseId));
                    }
                }
            }
        }
        catch(Exception ex){
            SEL_LoggingService.log(ex);
        }
    }
}
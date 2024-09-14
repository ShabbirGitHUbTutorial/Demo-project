public with sharing class SPEN_IncidentQueueableClass implements Queueable
{
    public SPEN_SyncIncidentDetailsWrapper.sdifIncidentScopeChanged incidentWrapper;
    public List<Incident> incidentRecordsList = new List<Incident>(); 
    public Incident incidentObjScopeChanged;
    SPEN_MessagingTaskService msgTaskSrv=new SPEN_MessagingTaskService();
    Id recTypeId= Schema.SObjectType.SPEN_MessagingTask__c.getRecordTypeInfosByDeveloperName().get(SPEN_ImpactedPremisesConstants.INCIDENTNAME).getRecordTypeId();
    Set<Id> premSet=new Set<Id>();
    public List<String> callRef = new List<String>();
    public List<String> incStrLst = new List<String>();
    
    public SPEN_IncidentQueueableClass(SPEN_SyncIncidentDetailsWrapper.sdifIncidentScopeChanged incidentWrapper) 
    {
        this.incidentWrapper = incidentWrapper;
    }
    public void execute(QueueableContext context) 
    { 
        SPEN_SyncIncidentDetailsWrapper.sdifIncidentScopeChanged  incScopeCngd = incidentWrapper;
        incidentRecordsList = [SELECT Id,SPEN_IncidentID__c,SPEN_IncidentType__c,SPEN_IncidentStatus__c,SPEN_droppedsupply__c,(select id from SPEN_MessagingTasks__r where SPEN_Event__c = '3rd Call Received') FROM Incident WHERE SPEN_IncidentReference__c = :incScopeCngd.IncidentScopeChangedStc[0].incidentReference limit 1];
        if(!incidentRecordsList.isEmpty()){
            incidentObjScopeChanged = incidentRecordsList[0];
            List<Id> lstId = new List<Id>();
            for(Integer i=0; i<incScopeCngd.IncidentScopeChangedStc[0].calls.size() ; i++)
            {
                if(!incScopeCngd.IncidentScopeChangedStc[0].calls[i].callReference.contains(SPEN_ImpactedPremisesConstants.CALL)){
                    lstId.add(incScopeCngd.IncidentScopeChangedStc[0].calls[i].callReference);
                }
                
            }
            for(Case cCall : [Select id,SPEN_AddressPremise__c from Case where Id in :lstId])
            {
                premSet.add(cCall.SPEN_AddressPremise__c);
            }
            for(Case csObj: [Select id,SPEN_AddressPremise__c from Case where SPEN_Incident__r.SPEN_IncidentReference__c =:incScopeCngd.IncidentScopeChangedStc[0].incidentReference])
            {
                premSet.add(csObj.SPEN_AddressPremise__c);
            }
            if(!premSet.isEmpty()  && incidentObjScopeChanged != Null && premSet.size()>2 && !incidentObjScopeChanged.SPEN_droppedsupply__c && incidentObjScopeChanged.SPEN_MessagingTasks__r.isEmpty())
            {
                SPEN_ConfigurableSettings__c MessageINCType = [SELECT SPEN_Value__c FROM SPEN_ConfigurableSettings__c WHERE Name='MessagingTaskType3rdCall' Limit 1];
                List<String> MessageINCTypeList = MessageINCType.SPEN_Value__c.split(',');
                if(MessageINCTypeList.contains(String.ValueOf(incidentObjScopeChanged.SPEN_IncidentType__c))){
                    msgTaskSrv.createMessagingTask(SPEN_ImpactedPremisesConstants.THIRDCALL,incidentObjScopeChanged.id,recTypeId,Null,'New');
                }
            }
            for(SPEN_SyncIncidentDetailsWrapper.Calls callRefValues : incScopeCngd.IncidentScopeChangedStc[0].calls)
            {
                if(!(callRefValues.callReference.contains(SPEN_ImpactedPremisesConstants.CALL))){
                    callRef.add(callRefValues.callReference);
                }
            }
             /**Modified by : Rahul Kumar 
             * Description : If low volume case is there process immediately or send it to batch to process in async mode. This limit can be configured at any time in SPEN_BatchSettings custom metadata
             * 
             *  */ 
            Cases.isScopeChangedCase=true; //added by shubhi v :CRMD-9236

             Map<String,Integer> incCaseMap = new Map<String,Integer>();
            
             for(SPEN_BatchSettings__mdt mdtRec : [SELECT Id, DeveloperName, SPEN_BatchSize__c FROM SPEN_BatchSettings__mdt]){
                 incCaseMap.put(mdtRec.DeveloperName,Integer.valueOf(mdtRec.SPEN_BatchSize__c));
                 
             }
 
             if(!incCaseMap.isEmpty() && incCaseMap.containsKey(SPEN_ImpactedPremisesConstants.INCOMINGCASEVOLUMECOUNT) && callRef.size() <= incCaseMap.get(SPEN_ImpactedPremisesConstants.INCOMINGCASEVOLUMECOUNT)){
             
                 List<Case> caseList= [SELECT Id,Status,SPEN_IsMerge__c,SPEN_Incident__c,SPEN_Incident__r.ParentIncidentId,SPEN_Incident__r.SPEN_IncidentStatus__c,SPEN_Incident__r.SPEN_IncidentType__c 
                                       FROM Case WHERE Id =:callRef];
                 SPEN_SyncIncidentUtility.incidentReparentSyncCall(caseList,incidentObjScopeChanged);
             
             }
             else{
                 // process with Batch....
                 Database.executeBatch(new SPEN_IncidentScopeChangedProcessingBatch(incidentObjScopeChanged, callRef),200);
             }
             
         }
         
        
    }
}
/***************************************************************************
* @Author:      Kiranmayi Garimella
* @Date:        19/12/2023
* @UserStory:   
* @Description: To update Case and create CaseTracker Record on AgentWork Record Insertion
*****************************************************************************/

public class SPEN_AgentWorkTriggerHandler {
    Public static Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
    Public static Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
    Public static Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
    Public static Id recordTypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
    Public static Id recordTypeIdGE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GeneralEnquiries').getRecordTypeId();
     public static Set<Id> getCJrecordtypes(){
        Set<Id> setRecordTypeId = new Set<Id>();
        setRecordTypeId.add(recordTypeId3PD);
        setRecordTypeId.add(recordTypeIdQuery);
        setRecordTypeId.add(recordTypeIdSW);
        setRecordTypeId.add(recordTypeIdNRSWA);
        setRecordTypeId.add(recordTypeIdGE);
        return setRecordTypeId;
    }
    public static void createCaseTracker(List<AgentWork> newAgentWorkList)
        
    {
        Set<Id> setRecType = getCJrecordtypes();
        List<Case> casesToUpdate = new List<Case>();
        List<SPEN_Case_Tracker__c> caseTrackersToInsert = new List<SPEN_Case_Tracker__c>();
        Set<Id> setQueueId = new Set<Id>();
        Set<Id> setOwnerID = new Set<Id>();
        Set<Id> setCaseID = new Set<Id>();
        List<Case> listCase = new List<Case>();
        Map<ID, String> mapQueueId2Name = new Map<Id,String>();
        Map<ID, String> mapUserId2Name = new Map<Id,String>();
        Map<ID,Case> mapCaseId2Case = new Map<Id, Case>();
        List<Case> listCaseUpdate = new List<Case>();
        
        for(AgentWork aw : newAgentWorkList){
            setQueueId.add(aw.OriginalQueueId);
            setOwnerID.add(aw.OwnerId);
            setCaseID.add(aw.WorkItemId);
        }
        if(!setCaseID.isEmpty())
        {
            mapCaseId2Case = SPEN_CaseSelector.getCaseForAgentWork(setCaseID,setRecType);
        }
        if(!setQueueId.isEmpty())
        {
            mapQueueId2Name = SPEN_CaseSelector.getQueueName(setQueueId);
        }
        if(!setOwnerID.isEmpty())
        {
            mapUserId2Name = SPEN_CaseSelector.getUserName(setOwnerID);
        }
        try{
             // create Case Tracker
            for(AgentWork aw : newAgentWorkList){
                if(aw.status.equalsIgnoreCase('Opened')){
                    Case parentCase = mapCaseId2Case.get(aw.WorkItemId);
                    SPEN_Case_Tracker__c ctRec = new SPEN_Case_Tracker__c();
                    ctRec.SPEN_StartTime__c = parentCase.SPEN_CaseAssignmentTime__c;
                    ctRec.SPEN_ParentCase__c = aw.WorkItemId;
                    ctRec.SPEN_EndTime__c = system.now();
                    ctRec.Case_Tracker_Type__c = 'Case Owner Update';
                    ctRec.SPEN_NewValue__c = mapUserId2Name.get(aw.OwnerId);
                    ctRec.SPEN_PreviousValue__c = mapQueueId2Name.get(aw.OriginalQueueId);
                    ctRec.SPEN_CaseOwner__c = UserInfo.getUserId();
					ctRec.SPEN_OwnerAssignmentType__c = 'Automated';//CRMD-10516
                   
                    if(ctRec.SPEN_StartTime__c != null && ctRec.SPEN_EndTime__c != null)
                    {
                        ctRec.SPEN_AgentHandlingTimeInMinutes__c = SPEN_BusinessDaysCalculationUtil.getAgentHandlingTimeinMinutes(ctRec.SPEN_StartTime__c, ctRec.SPEN_EndTime__c);
                        ctRec.SPEN_AgentHandlingTime__c = SPEN_BusinessDaysCalculationUtil.calculateTimeDiffinString(ctRec.SPEN_StartTime__c, ctRec.SPEN_EndTime__c);
                    }
                    caseTrackersToInsert.add(ctRec); 
                    parentCase.SPEN_CaseAssignmentTime__c = system.now();
                    listCaseUpdate.add(parentCase);
                }
                
            }
            insert caseTrackersToInsert; 
            if(!listCaseUpdate.isEmpty())
                update listCaseUpdate;
        }catch(exception exc){
            system.debug('Exception occured in SPEN_AgentWorkTriggerHandler '+ exc.getMessage());
        }
       
    }
    public static void beforeInsertDummy(){
        system.debug('Test coverage');
    }
}
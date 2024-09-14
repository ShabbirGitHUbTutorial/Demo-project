public with sharing class SPEN_Tasks 
{
    public static void beforeTaskInsert(List<sObject> taskNewList)
    {
        List<Task> tskList = (List<Task>)taskNewList;
        List<Task> taskList = new List<Task>();
        List<Case> caseOwnerList = new List<Case>();
        Id recordTypeIdComplaints = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_Complaints).getRecordTypeId();       
         Id GSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GSCS').getRecordTypeId();
    	 Id NFRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NeutralFaults').getRecordTypeId();
    	 Id CNTRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CNT').getRecordTypeId();     
  		 Id recordTypeIdReferral = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_Referral).getRecordTypeId();
         Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();//CRMD-7117
         Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
		 Id recordTypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();
		 Id recordTypeIdGE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GeneralEnquiries').getRecordTypeId();
	
        Set<Id> setRecordTypeId = new Set<Id>();
        setRecordTypeId.add(recordTypeIdReferral);
        setRecordTypeId.add(recordTypeIdComplaints);
        setRecordTypeId.add(GSRecordTypeId);
        setRecordTypeId.add(NFRecordTypeId);
        setRecordTypeId.add(CNTRecordTypeId);
        setRecordTypeId.add(recordTypeId3PD);//CRMD-7117
        setRecordTypeId.add(recordTypeIdSW);
        setRecordTypeId.add(recordTypeIdNRSWA);
        setRecordTypeId.add(recordTypeIdGE);

        //SF-AMS628 Changes Start
        Id recordTypeIdBudget = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_BudgetConnectionEnquiry').getRecordTypeId();
        Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_FormalConnectionEnquiry').getRecordTypeId();
        Id recordTypeIdConnReadOnly = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ConnectionReadOnlyCase').getRecordTypeId();

        Set<Id> connectionsSetRecordTypeId = new Set<Id>();
        connectionsSetRecordTypeId.add(recordTypeIdBudget);
        connectionsSetRecordTypeId.add(recordTypeIdFormal);
        connectionsSetRecordTypeId.add(recordTypeIdConnReadOnly);        
        //SF-AMS628 Changes End

        Set<Id> caseIds = new Set<Id>();
        Map<Id, Case> cseMap = New Map<Id, Case>();
        
        for(Task tsk: tskList)
        {
            if (tsk.WhatId != null && tsk.WhatId.getSObjectType() == Case.SObjectType) 
            {
                caseIds.add(tsk.WhatId);
            }
        }
        if(!caseIds.isEmpty())
        {
            cseMap = SPEN_CaseSelector.getCaseOwner(caseIds);
        }
        for (Task task : tskList)
        {
            if(task.WhatId != null && cseMap.containsKey(task.WhatId) &&
               cseMap.get(task.WhatId).RecordTypeId == recordTypeIdGE && cseMap.get(task.WhatId).BusinessHoursId != null)
            {
                if(task.subject.equalsIgnoreCase(system.label.SPEN_GEAcknowledgementTaskSubject))
                {
                    Long range = 2 * 24 * 60 * 60 * 1000;
    				task.ActivityDate = System.BusinessHours.add( cseMap.get(task.WhatId).BusinessHoursId, cseMap.get(task.WhatId).SPEN_ReceivedDate__c, range).date();
                }
                if(task.subject.equalsIgnoreCase(system.label.SPEN_GEPlanofWorkTaskSubject))
                {
                    Long range = 6 * 24 * 60 * 60 * 1000;
    				task.ActivityDate = System.BusinessHours.add(cseMap.get(task.WhatId).BusinessHoursId, cseMap.get(task.WhatId).SPEN_ReceivedDate__c, range).date();
                }
                if(task.subject.equalsIgnoreCase(system.label.SPEN_CallDownTask))
                {
                    Long range = 1 * 24 * 60 * 60 * 1000;
    				task.SPEN_Due_DateTime__c = System.BusinessHours.add(cseMap.get(task.WhatId).BusinessHoursId,(System.Now()), range);
                }
		        if(task.subject.equalsIgnoreCase('GE Existing Enquiry Callback Request'))
                {
                    
    				task.IsReminderSet=true;
                    task.ReminderDateTime=System.Now();
                }
            }
            
            if (task.WhatId != null && cseMap.containsKey(task.WhatId) && setRecordTypeId.contains(cseMap.get(task.WhatId).RecordTypeId)) 
            {
                task.OwnerId = cseMap.get(task.WhatId).OwnerId;
            }
            if (task.WhatId != null && cseMap.containsKey(task.WhatId) && 
                ((cseMap.get(task.WhatId).RecordTypeId == recordTypeIdComplaints) || 
                 (cseMap.get(task.WhatId).RecordTypeId == recordTypeId3PD) || //CRMD-7117 
                 (cseMap.get(task.WhatId).RecordTypeId == recordTypeIdSW) ||
                 (cseMap.get(task.WhatId).RecordTypeId == recordTypeIdNRSWA) ||
                 (cseMap.get(task.WhatId).RecordTypeId == GSRecordTypeId) ||
                 (cseMap.get(task.WhatId).RecordTypeId == NFRecordTypeId) ||
                 (cseMap.get(task.WhatId).RecordTypeId == CNTRecordTypeId) ||
                 (cseMap.get(task.WhatId).RecordTypeId == recordTypeIdReferral)||//CRMD-7600
                (cseMap.get(task.WhatId).RecordTypeId == recordTypeIdGE)
                ))
            {
                if(cseMap.get(task.WhatId).SPEN_SPDSPMIndicator__c != null){
                    task.SPEN_SPD_SPM__c = cseMap.get(task.WhatId).SPEN_SPDSPMIndicator__c;
                }
                else{
                    task.SPEN_SPD_SPM__c = cseMap.get(task.WhatId).SPEN_SPD_SPM__c;
                }
            }
            if (task.WhatId != null && cseMap.containsKey(task.WhatId) && setRecordTypeId.contains(cseMap.get(task.WhatId).RecordTypeId)) 
            {
                task.SPEN_CaseRecordType__c = cseMap.get(task.WhatId).recordtype.Name;
            }
            //SF-AMS628 Changes Start
            if (task.WhatId != null && cseMap.containsKey(task.WhatId) && connectionsSetRecordTypeId.contains(cseMap.get(task.WhatId).RecordTypeId)) 
            {
                if(cseMap.get(task.WhatId).SPEN_CompanyID__c != null) {
                    task.SPEN_SPD_SPM__c = cseMap.get(task.WhatId).SPEN_CompanyID__c;
                }
                if(cseMap.get(task.WhatId).OwnerId != null) {
                    if((cseMap.get(task.WhatId).OwnerId.getsobjecttype() == User.SobjectType)) {
                        task.SPEN_CaseOwnerDetails__c = cseMap.get(task.WhatId).OwnerId;
                     }
                     task.SPEN_CaseOwnerWhenTaskCreated__c = cseMap.get(task.WhatId).Owner.Name;
                }
                if(cseMap.get(task.WhatId).SPEN_ConnectionDistrict__c !=null) {
                    task.SPEN_CaseConnectionDistrict__c = cseMap.get(task.WhatId).SPEN_ConnectionDistrict__c;
                }
            }
            //SF-AMS628 Changes End            
        }
    }
}
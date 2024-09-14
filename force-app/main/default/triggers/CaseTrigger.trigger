/**********************************************************************************************
 * @Author:      Dhara Desai
 * @Date:        04/10/2022
 * @Description: Case Trigger
 * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
 ***********************************************************************************************/
 trigger CaseTrigger on Case (before insert,before update, after insert, after update) 
 {
    
    
     
     //CRMD-10261
     Public static Id recordTypeIdReferral = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_Referral).getRecordTypeId();
     Public static Id complaintsRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Complaints').getRecordTypeId();
     Public static Id GSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GSCS').getRecordTypeId();
     Public static Id NFRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NeutralFaults').getRecordTypeId();
     Public static Id CNTRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CNT').getRecordTypeId();//430 for CNT case type    
     Public static Id recordTypeId3PD = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ThirdPartyDamage').getRecordTypeId();
     Public static Id recordTypeIdQuery = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Query').getRecordTypeId();
     Public static Id recordTypeIdSW = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_Streetworks').getRecordTypeId();
     Public static Id recordTypeIdGE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GeneralEnquiries').getRecordTypeId();
     public static Id recordTypeIdTransmission = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CaseTransmission').getRecordTypeId(); //CRMD-10261
     Public static Id recordTypeIdNRSWA = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_NRSWA').getRecordTypeId();//CRMD-10261
     Public static Id recordTypeIdBudget = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_BudgetConnectionEnquiry).getRecordTypeId();//CRMD-10261
     Public static Id recordTypeIdFormal = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(CasesConstants.Case_FormalConnectionEnquiry).getRecordTypeId();//CRMD-10261
     Public static Id CaseUnplannedBypassRecordId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned – Bypass').getRecordTypeId();//CRMD-10261
     Public static Id CaseRecordUnplannedFaultId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Unplanned - Fault').getRecordTypeId();//CRMD-10261
     Public static Id recordTypeIdConnectionReadOnly = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_ConnectionReadOnlyCase').getRecordTypeId();
     Public static Id recordTypeIdSI = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_SmartInterventions').getRecordTypeId();//CRMD-10627	
     Public static Id recordTypeIdLCT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_LCT').getRecordTypeId();//CRMD-10729
     
     Public static Id recordTypeIdCustomerSatisfaction = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_CustomerSatisfaction').getRecordTypeId();//CRMD-10877
     
    if(!FeatureManagement.checkPermission('SPEN_BypassTriggerCase')){
     if(!Cases.bypassCaseTrigger){
         
            if(Trigger.isInsert && Trigger.isBefore)
         {
                Cases cseHandler = new Cases();
             List<Case> cseList = Trigger.new;
             for(Case caseObj : cseList){
                 if(caseObj.RecordTypeId == complaintsRecordTypeId || caseObj.RecordTypeId == GSRecordTypeId || 
                    caseObj.RecordTypeId == recordTypeIdReferral || caseObj.RecordTypeId == NFRecordTypeId || 
                    caseObj.RecordTypeId == CNTRecordTypeId || caseObj.RecordTypeId == recordTypeIdGE )
                 {
                     Cases.caseInsertZoneValue(Trigger.new);
                 }
                  if(caseObj.RecordTypeId == complaintsRecordTypeId || caseObj.RecordTypeId == GSRecordTypeId || 
                    caseObj.RecordTypeId == recordTypeIdReferral || caseObj.RecordTypeId == NFRecordTypeId || 
                    caseObj.RecordTypeId == CNTRecordTypeId || caseObj.RecordTypeId == recordTypeIdGE ||
                     caseObj.RecordTypeId == recordTypeId3PD ||   caseObj.RecordTypeId == recordTypeIdQuery||
                    caseObj.RecordTypeId == recordTypeIdSW || caseObj.RecordTypeId == recordTypeIdNRSWA ||
                    caseObj.RecordTypeId == recordTypeIdBudget || caseObj.RecordTypeId == recordTypeIdFormal ||
                    caseObj.RecordTypeId == CaseUnplannedBypassRecordId || caseObj.RecordTypeId == CaseRecordUnplannedFaultId ||
                     caseObj.RecordTypeId == recordTypeIdConnectionReadOnly || caseObj.RecordTypeId == recordTypeIdTransmission ||caseObj.RecordTypeId == recordTypeIdSI || caseObj.RecordTypeId == recordTypeIdLCT)//CRMD-10627
                 {
                      cseHandler.beforeCaseInsert(Trigger.new);
                 }
                  if(caseObj.RecordTypeId == CaseUnplannedBypassRecordId || caseObj.RecordTypeId == CaseRecordUnplannedFaultId)
                 {
                     Cases.caseInsertETROutageValue(Trigger.new);
                 }
                 if(caseObj.recordTypeId == complaintsRecordTypeId || caseObj.recordTypeId == GSRecordTypeId || caseObj.recordTypeId == recordTypeIdGE)
                 {
                     new Cases().caseUpdateComplaintDates(Trigger.new,null);
                 }
                 if(caseObj.RecordTypeId == ComplaintsRecordTypeId || caseObj.RecordTypeId == GSRecordTypeId || caseObj.RecordTypeId == NFRecordTypeId || caseObj.RecordTypeId == CNTRecordTypeId||
                   caseObj.RecordTypeId == recordTypeIdNRSWA || caseObj.RecordTypeId == recordTypeIdGE)
                 {
                     Cases.updateEntitlement(Trigger.new);
                 }
                    if(caseObj.RecordTypeId == recordTypeIdReferral || caseObj.RecordTypeId == GSRecordTypeId){
                     Cases.checkRecordType(null, null, Trigger.new, null);
                 }
           
                 if(caseObj.RecordTypeId == recordTypeIdQuery)
                 {
                     Cases.populate3PDCaseOnQueryCase(Trigger.new);//CRMD-7071
                 }
                 if(caseObj.RecordTypeId == recordTypeIdCustomerSatisfaction)
                 {
                     System.debug('Inside trigger===>');
                     Cases.populateCaseDistrict(Trigger.new);//CRMD-10877
                 }
                 if(caseObj.RecordTypeId == recordTypeIdBudget ||  caseObj.RecordTypeId == recordTypeIdFormal)
                 {
                     Cases.caseUpdateDitrictFromPostCode(Trigger.new,null,null);//CRMD-6725
                 }
                 if(caseObj.RecordTypeId ==recordTypeIdSW || caseObj.RecordTypeId ==recordTypeId3PD || caseObj.RecordTypeId == recordTypeIdNRSWA)
                 {
                     Cases.chkDistrictForSW(Trigger.new);//CRMD-7284
                 }
                 if(caseObj.RecordTypeId == recordTypeIdBudget || caseObj.RecordTypeId == recordTypeIdFormal || caseObj.RecordTypeId == recordTypeIdConnectionReadOnly)
                 {
                     Cases.populateDatesOnCase(Trigger.new,null,null);//CRMD-6699 // connections related
                 }
                    if(caseObj.RecordTypeId ==recordTypeIdSW)
                 {
                     cases.updateRoutingOutcomeSW(Trigger.New);
                 }
                 if(caseObj.RecordTypeId == recordTypeIdTransmission){
                     Cases.populateCaseContractNumber(Trigger.new,null,null);//CRMD-9978
                 }
             }
             
         }
         
            if(Trigger.isUpdate && Trigger.isBefore)
         {
                Cases cseHandler = new Cases();
                //CRMD 9891
                Boolean transmissionCheck = Cases.checkTransmissionAccess();
             //if((!Cases.firstcall && !Cases.isIncidetSyncFlag) || Test.isRunningTest())// Adding Boolean flag to avoid the Duplicate execution INC3001686(ApexCpuTime Limit)
             if(!Cases.firstcall && !Cases.isIncidetSyncFlag && !Cases.oneTimeUpdateCall)// || Test.isRunningTest()) //SOQL 101 fix
             {
                 //Cases.firstcall =true;//SOQL 101 fix
                
                 //CRMD-10261 - S - Recordtypecheck
                 List<Case> cseList = Trigger.new;
                 for(Case caseObj : cseList){
                     if(caseObj.RecordTypeId == complaintsRecordTypeId || caseObj.RecordTypeId == GSRecordTypeId || 
                        caseObj.RecordTypeId == recordTypeIdReferral || caseObj.RecordTypeId == NFRecordTypeId || 
                        caseObj.RecordTypeId == CNTRecordTypeId || caseObj.RecordTypeId == recordTypeIdGE ||
                        caseObj.RecordTypeId == recordTypeId3PD ||   caseObj.RecordTypeId == recordTypeIdQuery||
                        caseObj.RecordTypeId == recordTypeIdSW || caseObj.RecordTypeId == recordTypeIdNRSWA ||
                        caseObj.RecordTypeId == recordTypeIdBudget || caseObj.RecordTypeId == recordTypeIdFormal ||
                        caseObj.RecordTypeId == recordTypeIdLCT ||  caseObj.RecordTypeId == recordTypeIdSI ||
                        caseObj.RecordTypeId == CaseUnplannedBypassRecordId || caseObj.RecordTypeId == CaseRecordUnplannedFaultId ||
                        caseObj.RecordTypeId == recordTypeIdConnectionReadOnly || caseObj.RecordTypeId == recordTypeIdTransmission || caseObj.RecordTypeId == recordTypeIdSI)//CRMD-10627 - SI added //CRMD-10752 - LCT Added
                     {
                         cseHandler.beforeCaseUpdate(Trigger.newMap,Trigger.oldMap);
                     }
                     if(caseObj.RecordTypeId == recordTypeIdTransmission){
                         Cases.populateCaseContractNumber(Trigger.new,Trigger.newMap,Trigger.oldMap);//CRMD-9978
                     }
                     
                     if(!transmissionCheck){
                         if((caseObj.RecordTypeId == recordTypeIdNRSWA || caseObj.RecordTypeId == recordTypeId3PD || caseObj.RecordTypeId == recordTypeIdSW
                             || caseObj.RecordTypeId == recordTypeIdQuery || caseObj.RecordTypeId == recordTypeIdGE || caseObj.RecordTypeId == recordTypeIdSI || caseObj.RecordTypeId == recordTypeIdLCT)) //CRMD-10441 //CRMD-10627 - SI added
                         {
                             Cases.populateStatusChangeDate(Trigger.new,Trigger.oldMap);//CRMD-7114
                         }
                         if(caseObj.RecordTypeId == complaintsRecordTypeId || caseObj.RecordTypeId == GSRecordTypeId || 
                            caseObj.RecordTypeId == recordTypeIdReferral || caseObj.RecordTypeId == NFRecordTypeId || 
                            caseObj.RecordTypeId == CNTRecordTypeId || caseObj.RecordTypeId == recordTypeIdGE ||
                            caseObj.RecordTypeId == recordTypeId3PD ||   caseObj.RecordTypeId == recordTypeIdQuery||
                            caseObj.RecordTypeId == recordTypeIdSW || caseObj.RecordTypeId == recordTypeIdNRSWA ||
                            caseObj.RecordTypeId == CaseUnplannedBypassRecordId || caseObj.RecordTypeId == CaseRecordUnplannedFaultId
                            || caseObj.RecordTypeId == recordTypeIdLCT
                           )
                         {
                             Cases.caseUpdateTimeFields(Trigger.newMap,Trigger.oldMap);
                         }
                         if(caseObj.RecordTypeId == CaseUnplannedBypassRecordId || caseObj.RecordTypeId == complaintsRecordTypeId || caseObj.RecordTypeId == GSRecordTypeId || caseObj.RecordTypeId == recordTypeIdReferral || caseObj.RecordTypeId == NFRecordTypeId || caseObj.RecordTypeId == CNTRecordTypeId)
                         {
                             Cases.caseUpdateZoneValue(Trigger.newMap,Trigger.oldMap);
                         }
                         if(caseObj.RecordTypeId == CaseUnplannedBypassRecordId || caseObj.RecordTypeId == CaseRecordUnplannedFaultId)//Recheck needed - Since R1 code this record type added for timebeing.
                         {
                             Cases.caseUpdateETROutageValue(Trigger.newMap,Trigger.oldMap);
                         }
                         
                         if(caseObj.recordTypeId == complaintsRecordTypeId || caseObj.recordTypeId == GSRecordTypeId || caseObj.recordTypeId == recordTypeIdGE)
                         {
                             new Cases().caseUpdateComplaintDates(Trigger.new,Trigger.oldMap);
                         }
                         
                         if(caseObj.RecordTypeId == recordTypeIdReferral || caseObj.RecordTypeId == GSRecordTypeId){
                             Cases.checkRecordType(Trigger.newMap, Trigger.oldMap, Trigger.new, Trigger.old);
                         }
                         if(caseObj.RecordTypeId == recordTypeIdBudget ||  caseObj.RecordTypeId == recordTypeIdFormal)
                         {
                             Cases.caseUpdateDitrictFromPostCode(Trigger.new,Trigger.newMap,Trigger.oldMap);//CRMD-6725
                         }
                         if(caseObj.RecordTypeId == recordTypeIdBudget || caseObj.RecordTypeId == recordTypeIdFormal || caseObj.RecordTypeId == recordTypeIdConnectionReadOnly)
                         {
                             Cases.populateDatesOnCase(Trigger.new,Trigger.newMap,Trigger.oldMap);//CRMD-6699
                         }
                         if(caseObj.RecordTypeId ==recordTypeIdSW || caseObj.RecordTypeId ==recordTypeId3PD || caseObj.RecordTypeId == recordTypeIdNRSWA)
                         {
                             Cases.chkDistrictForSW(Trigger.new);//CRMD-7284
                         }
                     }
                 }
                 //CRMD-10261 - E
             }
         }
            if(Trigger.isInsert && Trigger.isAfter)
         {
             if(!Cases.firstAFInsCall )//|| Test.isRunningTest()) //SOQL 101 fix 
             {
                  //CRMD-10261 - S - Recordtypecheck
                 List<Case> cseList = Trigger.new;
                 for(Case cse : cseList){
                     if(recordTypeIdTransmission == cse.RecordTypeId || recordTypeIdBudget == cse.RecordTypeId || 
                        recordTypeIdFormal == cse.RecordTypeId ||recordTypeIdConnectionReadOnly == cse.RecordTypeId ||
                        cse.RecordTypeId == CaseUnplannedBypassRecordId || CaseRecordUnplannedFaultId ==  cse.RecordTypeId
                        || cse.RecordTypeId == recordTypeIdSI || recordTypeIdGE ==  cse.RecordTypeId )
                     {
                         Cases.afterCaseInsert(Trigger.new);
                     }
                     if(cse.RecordTypeId == complaintsRecordTypeId || cse.RecordTypeId == GSRecordTypeId ||
                        cse.RecordTypeId == NFRecordTypeId || cse.RecordTypeId == CNTRecordTypeId ||
                        cse.RecordTypeId == recordTypeIdReferral ||  cse.RecordTypeId == recordTypeIdNRSWA ||
                        cse.RecordTypeId == recordTypeIdSW || cse.RecordTypeId == recordTypeId3PD || cse.RecordTypeId == recordTypeIdGE){//CRMD-10771
                            Cases.caseInsertAssignOwner(Trigger.new);
                            //Cases.createSMSAndVAForComplaintCase(Trigger.new);
                        }
                     if(cse.RecordTypeId == CaseUnplannedBypassRecordId ||  cse.RecordTypeId == CaseRecordUnplannedFaultId)
                     {
                         Cases.smsCreationOnOperHours(Trigger.new); 
                     }
                      if(cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == GSRecordTypeId){
                         Cases.checkRecordType(Trigger.newMap, null, Trigger.new, null);
                     }
                     if(cse.RecordTypeId == complaintsRecordTypeId || cse.RecordTypeId == GSRecordTypeId ||
                        cse.RecordTypeId == NFRecordTypeId || cse.RecordTypeId == CNTRecordTypeId ||
                        cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == recordTypeIdBudget || cse.RecordTypeId == recordTypeIdFormal || cse.RecordTypeId == recordTypeIdConnectionReadOnly){
                            Cases.sendNotificationsToQueues(Trigger.oldMap, Trigger.newMap);
                        }
                     if(cse.recordtypeid == recordTypeIdSW || cse.recordtypeid == recordTypeIdNRSWA ||
                        cse.recordtypeid == recordTypeIdQuery)
                     {
                         Cases.processCaseSLA(Trigger.oldMap, Trigger.newMap);
                     }
                 }
                  //CRMD-10261 - E
                 cases.firstAFInsCall = true;//soql 101 fix
             }
         }
         
            if(Trigger.isUpdate && Trigger.isAfter)
         {
             if((!Cases.firstcall && !Cases.isIncidetSyncFlag && !Cases.oneTimeUpdateCall) )//|| Test.isRunningTest()) SOQL 101 fix // Adding Boolean flag to avoid the Duplicate execution INC3001686(ApexCpuTime Limit)
             {
                 List<Case> cseList = Trigger.new;
                 Cases.updateQueryEmailThread(Trigger.newMap, Trigger.oldMap);
                 for(Case cse : cseList){
                     if(cse.RecordTypeId !=recordTypeId3PD){
                         Cases.updateTaskOwnerOnCaseOwnerChange(Trigger.newMap,Trigger.oldMap);
                     }
                     if(cse.RecordTypeId == complaintsRecordTypeId || cse.RecordTypeId == GSRecordTypeId || 
                     cse.RecordTypeId == recordTypeIdNRSWA || cse.RecordTypeId == NFRecordTypeId || 
                     cse.RecordTypeId == CNTRecordTypeId || cse.RecordTypeId == recordTypeIdSW)
                     {
                         Cases.caseUpdateAssignOwner(Trigger.newMap,Trigger.oldMap);  //Inline Edit
                     }
                     if(cse.RecordTypeId == complaintsRecordTypeId || cse.RecordTypeId == GSRecordTypeId || 
                     cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == NFRecordTypeId || 
                     cse.RecordTypeId == CNTRecordTypeId || cse.RecordTypeId == recordTypeIdBudget || cse.RecordTypeId == recordTypeIdFormal || cse.RecordTypeId == recordTypeIdConnectionReadOnly)
                     {
                         Cases.sendNotificationsToQueues(Trigger.oldMap, Trigger.newMap);
                     }
                     if(cse.RecordTypeId == recordTypeId3PD)
                     {
                         Cases.restrictCaseClouserforOpenQuery(Trigger.new);
                     }
                     /*if(cse.RecordTypeId == recordTypeId3PD || cse.RecordTypeId == recordTypeIdNRSWA
                     || cse.RecordTypeId == recordTypeIdSW || cse.RecordTypeId == recordTypeIdQuery || cse.RecordTypeId == recordTypeIdGE || cse.RecordTypeId == recordTypeIdSI || cse.RecordTypeId == recordTypeIdLCT) // GE added - CRMD-10441, //CRMD-10627 - SI added, //CRMD-10752- LCT added
                     {
                         Cases.updateQueryEmailThread(Trigger.newMap, Trigger.oldMap);
                     }*/
                     if(cse.RecordTypeId == recordTypeIdReferral || cse.RecordTypeId == GSRecordTypeId){
                         Cases.checkRecordType(Trigger.newMap, Trigger.oldMap , Trigger.new, Trigger.old);
                     }
                     if(cse.RecordTypeId == recordTypeIdBudget || cse.RecordTypeId == recordTypeIdFormal || cse.RecordTypeId == recordTypeIdConnectionReadOnly)
                     {
                         Cases.updateConnectionTaskDetails(Trigger.newMap, Trigger.oldMap);//SFAMS628, Connections related
                     }
                 }
                 if(Cases.isRecursiveFlag)
                 {
                     Cases.isRecursiveFlag = false;
                     for(Case cse : cseList){
                         if(cse.RecordTypeId == recordTypeIdTransmission || cse.RecordTypeId == recordTypeIdFormal ||
                            cse.RecordTypeId == recordTypeIdBudget || cse.RecordTypeId == recordTypeIdConnectionReadOnly||
                            cse.RecordTypeId == CaseUnplannedBypassRecordId || cse.RecordTypeId == CaseRecordUnplannedFaultId || cse.RecordTypeId == recordTypeIdGE) 
                         {
                             Cases.afterCaseUpdate(Trigger.oldMap,Trigger.new); 
                         }
                     }
                 }
                
             }
         }
     }
 }
}
/***************************************************************************
* @Author:      Shubhi
* @Date:        30/08/2023
* @UserStory:   CRMD-7688
* @Description: Queueable class for async processing after SW  and NRSWA case creation
*****************************************************************************/
public with sharing class SPEN_SyncStreetWorksCaseQueueable implements Queueable{
    static final String RESPONSIBLEPARTY_TYPE='Company';
    private static Id recordTypeIdCaseInfoNRSWA = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_NSRWA_Webform').getRecordTypeId();
	private static Id recordTypeIdCaseInfoSW = Schema.SObjectType.SPEN_CaseInformation__c.getRecordTypeInfosByDeveloperName().get('SPEN_SWWebform').getRecordTypeId();

    private SPEN_CaseInformation__c caseInfo;
    public SPEN_SyncStreetWorksCaseQueueable(SPEN_CaseInformation__c caseInfo) {
        this.caseInfo = caseInfo;
    }

    public void execute(System.QueueableContext context) {
        if(caseInfo.SPEN_Case__c!=null){
            createCaseEmployee(caseInfo);
        }
        if(String.isNotBlank(caseInfo.SPEN_Contractor__c) && caseinfo.SPEN_Case__c!=null){
            createResponsibleParty(caseInfo);
        }   
    }
    
    public void createCaseEmployee(SPEN_CaseInformation__c caseInfo){
        List<string> emailList=new List<String>();
        if(String.isNotBlank(caseInfo.SPEN_WorkRequestorEmail__c)){
            emailList.add(caseInfo.SPEN_WorkRequestorEmail__c);
        }
        if(String.isNotBlank(caseInfo.SPEN_NoticeRequestorEmail__c)&& caseInfo.SPEN_WorkRequestorEmail__c!=caseInfo.SPEN_NoticeRequestorEmail__c){
            emailList.add(caseInfo.SPEN_NoticeRequestorEmail__c);
        }
        List<SPEN_CaseEmployee__c> csEmpList=new List<SPEN_CaseEmployee__c>();
        try{
            for(SPEN_Employee__c emp:SPEN_EmployeeSelector.getEmployeeFromEmail(emailList)){      
                SPEN_CaseEmployee__c ce=new SPEN_CaseEmployee__c();
                ce.SPEN_Employee__c=emp.id;
                ce.SPEN_Case__c=caseInfo.SPEN_Case__c;
                if(emp.SPEN_EmailAddress__c == caseInfo.SPEN_WorkRequestorEmail__c){
                    ce.SPEN_WorkRequestor__c=true;
                }
                if(emp.SPEN_EmailAddress__c == caseInfo.SPEN_NoticeRequestorEmail__c){
                    ce.SPEN_NoticeRequestor__c=true;
                }
                csEmpList.add(ce);
            }
            insert csEmpList;
        }catch(Exception e){
            SEL_LoggingService.log(e);
        }
     }
    
    public void createResponsibleParty(SPEN_CaseInformation__c caseInfo){
        Account acc=new Account();
        if(caseInfo.RecordTypeId==recordTypeIdCaseInfoNRSWA){//crmd:7898
            acc=SPEN_AccountSelector.getNRSWAContractor(caseInfo.SPEN_Contractor__c);
        }else if(caseInfo.RecordTypeId==recordTypeIdCaseInfoSW){
            acc=SPEN_AccountSelector.getStreetWorkContractor(caseInfo.SPEN_Contractor__c);
        }
        if(acc!=null && Schema.sObjectType.SPEN_ResponsibleParty__c.isCreateable()){
			try{
                SPEN_ResponsibleParty__c responsibleparty=new SPEN_ResponsibleParty__c();
                responsibleparty.SPEN_Type__c=SPEN_SyncStreetWorksCaseQueueable.RESPONSIBLEPARTY_TYPE;
                responsibleparty.SPEN_Company__c=acc.id;
                responsibleparty.SPEN_Case__c=caseInfo.SPEN_Case__c;
                insert responsibleparty;
            }catch(Exception e){
                SEL_LoggingService.log(e);
            }
        }
    }
  
}
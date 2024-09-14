public with sharing class SPEN_ContentDocumentLinks {
    //CRMD-10890 - Start
    Public static Id recordTypeIdGE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GeneralEnquiries').getRecordTypeId();
    Public static Id recordTypeIdSI = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_SmartInterventions').getRecordTypeId();
    Public static Id recordTypeIdLCT = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_LCT').getRecordTypeId();
    Public static String partnerProfileId = [Select Id,Name from Profile where Name like '%SPEN Partner Portal Community User%'].Id; 
    
    public void onAfterInsert(list<ContentDocumentLink> lstCntLinks) {
        String strObjPrefix; 
        Set<Id> setCntDocIds = new set<Id>();
        set<Id> setAgmtIds = new set<Id>();
        set<Id> setPartnerIds = new set<Id>();
        Integer allowedSize = Integer.ValueOf(System.label.SPEN_AllowedGEFileSize);//30MB
        Set<String> allowedExtensions = new Set<String>(System.label.SPEN_AllowedGEFileExtension.split(','));
        map<Id, Case> mapAgmt;
 	Set<Id> recordtypeIdsSet = new set<Id>();
        recordtypeIdsSet.add(recordTypeIdGE);
        recordtypeIdsSet.add(recordTypeIdSI);
        recordtypeIdsSet.add(recordTypeIdLCT);
        try{
            for(ContentDocumentLink clIterator : lstCntLinks) {
                strObjPrefix = String.valueOf(clIterator.LinkedEntityId).substring(0, 3); 
                if(strObjPrefix == Case.sObjectType.getDescribe().getKeyPrefix()) {
                    setCntDocIds.add(clIterator.ContentDocumentId);
                    setAgmtIds.add(clIterator.LinkedEntityId);
                }
            }
            
            if(setCntDocIds.size() > 0 && setAgmtIds.size() > 0 ) {           
                mapAgmt = new map<Id, Case>([SELECT Id,RecordTypeId FROM Case WHERE Id IN :setAgmtIds and RecordTypeId IN:recordtypeIdsSet]);
                if(mapAgmt.size() > 0){
                    map<Id, ContentDocument> mapContentDocuments = new map<Id, ContentDocument>([SELECT Id, Title, FileExtension,ContentSize,ownerId FROM ContentDocument WHERE Id IN :setCntDocIds]);
                    list<ContentDocument> lstCntDocsToUpdate = new list<ContentDocument>();   
                    for(ContentDocumentLink cdlIterator : lstCntLinks) {
                        ContentDocument objCntDoc = mapContentDocuments.get(cdlIterator.ContentDocumentId);
                        if(UserInfo.getProfileId() == partnerProfileId)
                        {
                            if (!allowedExtensions.contains(objCntDoc.FileExtension)) {
                                cdlIterator.addError('Only files with extensions jpg, jpeg, png, pdf, doc, xls, xlsx, csv or docx are allowed.');
                            }
                            if(objCntDoc.ContentSize > allowedSize)
                            {
                                cdlIterator.addError('File size is too large. Please upload a smaller file. If uploading an image, please try resizing the image before re-uploading." ');
                            }
                        }
                        
                    }  
                }
            }
        }
        Catch (Exception ex){
            system.debug('Exception inSPEN_ContentDocumentLinks class :' + ex.getMessage());
        }
    }//CRMD-10890 - END
    public void beforeContentLinkInsert(List<ContentDocumentLink> cntList){
        Map<Id,Id> docVsEntity = new Map<Id,Id>();
        List<Id> jobLinkId = new List<Id>();
        List<Id> cdlIdList=new List<Id>();
        Map<Id, SPEN_Job__c> jobsMap;
        for(ContentDocumentLink cdl : cntList){
            
            cdlIdList.add(cdl.Id);
            Id objId = cdl.LinkedEntityId;
            String sobjectType = objId.getSObjectType().getDescribe().getName();
            if(('SPEN_Job__c').equals(sobjectType)){
            	jobLinkId.add(objId);
            }
        }
        if(jobLinkId != null){
            jobsMap = new Map<ID, SPEN_Job__c>([select Id, SPEN_JobStatus__c from SPEN_Job__c where Id IN : jobLinkId]);
        }
        Boolean isExternalUser = SPEN_ContentDocuments.isLoggedInAsExternalUser(); 
                
        
        Map<Id,ContentDocumentLink> newCDLMap=new Map<Id,ContentDocumentLink>([Select id,ContentDocumentId,ContentDocument.FileType from ContentDocumentLink  where id IN:cdlIdList]);
        
        for(ContentDocumentLink cdl : cntList){
            Id objId = cdl.LinkedEntityId;
            String sobjectType = objId.getSObjectType().getDescribe().getName();                        

            //csv file uploaded to on Demand message task needs to be parsed and stored in long text area
            if(('SPEN_MessagingTask__c').equals(sobjectType)){
				docVsEntity.put(cdl.ContentDocumentId,cdl.LinkedEntityId);
            }
            else if(('SPEN_Job__c').equals(sobjectType))
            {
                SPEN_Job__c jobObj = jobsMap.get(objId);
                if(jobObj != null && jobObj.SPEN_JobStatus__c != 'Draft' && jobObj.SPEN_JobStatus__c != 'Rejected' && isExternalUser && !newCDLMap.get(cdl.Id).ContentDocument.FileType.equals('SNOTE')){
                   cdl.addError('Documentation can only be added if Job Status is Draft');
                   ContentDocument cd = new ContentDocument(id= cdl.ContentDocumentID);
                   cd.addError('Documentation can only be added if Job Status is Draft');
                }                
            }
            else if(('SPEN_Land_Interest__c').equals(sobjectType) && !newCDLMap.get(cdl.Id).ContentDocument.FileType.equals('SNOTE'))
            {                
                if(isExternalUser){

                   cdl.addError('Document can not be linked to record as you do not have access to it');
                   ContentDocument cd = new ContentDocument(id= cdl.ContentDocumentID);
                   cd.addError('Document can not be linked to record as you do not have access to it');
                }                
            }
            else if(('SPEN_Planning__c').equals(sobjectType) && !newCDLMap.get(cdl.Id).ContentDocument.FileType.equals('SNOTE'))
            {
                 if(isExternalUser){

                   cdl.addError('Document can not be linked to record as you do not have access to it'); 
                    ContentDocument cd = new ContentDocument(id= cdl.ContentDocumentID);
                   cd.addError('Document can not be linked to record as you do not have access to it');
                }               
            }
        }
		if(!docVsEntity.isEmpty()){
			parseCsv(docVsEntity);
		}
	}
	
	public void parseCsv(Map<Id,Id> docVsEntity){
		List<ContentVersion> csvDoc = new List<ContentVersion>();
		String commaSepStr = '';
        String csvAsString = '';
        SPEN_ContentVersionSelector cvs=new SPEN_ContentVersionSelector();
		csvDoc = cvs.getContentVersionListFromDocids(docVsEntity.KeySet());
        //[SELECT VersionData,ContentDocumentId,ContentDocument.FileType 
            //FROM ContentVersion WHERE ContentDocumentId =:docVsEntity.KeySet() WITH SECURITY_ENFORCED];
		if(!csvDoc.isEmpty() && csvDoc[0].ContentDocument.FileType.equalsIgnoreCase('CSV')){
			csvAsString=csvDoc[0].VersionData.toString();
            commaSepStr=getPremiseIdString(csvAsString);
		}
		if(commaSepStr !=''){
			updateMessagingTask(commaSepStr,csvDoc,docVsEntity);
		}
	}
    private String getPremiseIdString(String csvAsString){
        String commaSepStr = '';
        List<String> csvFileLines = new List<String>();
        List<String> csvRecordData = new List<String>();
        if(String.isNotBlank(csvAsString)){
            if(csvAsString.contains('\r')){
                csvFileLines=csvAsString.split('\r\n');
            }
            else{
                csvFileLines=csvAsString.split('\n'); 
            } 
            Integer i=0;  
            while(i<csvFileLines.size()){
                csvRecordData=csvFileLines[i].split(',');
                if(commaSepStr == ''){
                    commaSepStr = csvRecordData[0];
                }
                else {
                    commaSepStr= commaSepStr +',' + csvRecordData[0];
                }
                i++;
            }
        }
        return commaSepStr;
    }
    private void updateMessagingTask(String commaSepStr,List<ContentVersion> csvDoc,Map<Id,Id> docVsEntity){
        if(String.isNotBlank(commaSepStr) && csvDoc!=null && !csvDoc.isEmpty()){
            SPEN_MessagingTask__c tempMT = new SPEN_MessagingTask__c();
			tempMT.Id=docVsEntity.get(csvDoc[0].ContentDocumentId);
			tempMT.SPEN_PremiseIds__c=commaSepStr;
            List<SPEN_MessagingTask__c> tempMTLst = new List<SPEN_MessagingTask__c>();
            tempMTLst.add(tempMT);
            Database.SaveResult[] srList = Database.update(tempMTLst,false);
			for(Database.SaveResult sr : srList){
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        SEL_LoggingService.log('UploadCSVFile', 'UploadCSVFile','parseForMessage',err.getMessage()); 
                    }
}
			}
		}
	}
    public void beforeDeleteContentLinks(List<ContentDocumentLink> cntList){   

        List<Id> jobLinkId = new List<Id>();
        Map<Id, SPEN_Job__c> jobsMap;
        for(ContentDocumentLink cdl : cntList){
            Id objId = cdl.LinkedEntityId;
            String sobjectType = objId.getSObjectType().getDescribe().getName();
            if(('SPEN_Job__c').equals(sobjectType)){
            	jobLinkId.add(objId);
            }
        }
        if(jobLinkId != null){
            jobsMap = new Map<ID, SPEN_Job__c>([select Id, SPEN_JobStatus__c from SPEN_Job__c where Id IN : jobLinkId]);
        }
        Boolean isExternalUser = SPEN_ContentDocuments.isLoggedInAsExternalUser(); 
        for(ContentDocumentLink cdl : cntList){
            Id objId = cdl.LinkedEntityId;            
            String sobjectType = objId.getSObjectType().getDescribe().getName();
            if(('SPEN_Job__c').equals(sobjectType)){

                SPEN_Job__c jobObj = jobsMap.get(objId);

                if(jobObj!= null && jobObj.SPEN_JobStatus__c != 'Draft' && jobObj.SPEN_JobStatus__c != 'Rejected' && isExternalUser){

                   cdl.addError('Documentation link can only be deleted if Job Status is Draft');
                   ContentDocument cd = new ContentDocument(id= cdl.ContentDocumentID);
                   cd.addError('Documentation link can only be deleted if Job Status is Draft');
                }
			}
        }
    }
}
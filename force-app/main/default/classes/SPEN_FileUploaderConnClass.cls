public with sharing class SPEN_FileUploaderConnClass {
    /*
* @method uploadFile() 
* @desc Creates a content version from a given file's base64 and name
* 
* @param {String} base64 - base64 string that represents the file
* @param {String} filename - full file name with extension, i.e. 'products.csv'
* @param {String} recordId - Id of the record you want to attach this file to
* 
* @return {ContentVersion} - returns the created ContentDocumentLink Id if the
*   upload was successful, otherwise returns null
*/
    Public static Id recordTypeIdGE = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_GeneralEnquiries').getRecordTypeId();
    Public static Id recordTypeIdSI = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SPEN_SmartInterventions').getRecordTypeId();
    
    public static ResponseWrapper uploadFile(String base64, String filename, Case caseObj) {
       
        String transStatus;
        ResponseWrapper resWrp;
        String responseMessage = '';
        try{

            HttpRequest req = new HttpRequest();

            String siteName = System.Label.SharePointSite;
            String siteNamedCred = System.Label.SharePointNamed;

            String sharepointFolder = '';
            if(caseObj.SPEN_SAPReference__c == null){
                sharepointFolder = caseObj.CaseNumber;
            }else{
                sharepointFolder = caseObj.SPEN_SAPReference__c.replace(' ','%20');
            }
           
            String strFileName = '\''+filename.replace(' ','%20')+'\'';
            system.debug('strFileName**' + strFileName);
            //req.setEndpoint('callout:DeepSPNamed/_api/web/GetFolderByServerRelativeUrl(\'/sites/deeprajsp/Shared%20Documents/folderneww\')/Files/add(url=\'deeprajdummy.png\',overwrite=true)');
            String str = '_api/web/GetFolderByServerRelativeUrl(\'/sites/'+siteName+'Shared%20Documents/' + sharepointFolder + '\')/Files/add(url=' + strFileName + ',overwrite=true)';
            String finalEndpoint= siteNamedCred + str;
            req.setEndpoint(finalEndpoint);
            req.setMethod('POST');
            req.setHeader('Accept', 'application/json;odata=verbose');
            req.setHeader('Content-Type','multipart/form-data');
            req.setBody(base64);
            Http http = new Http();
            system.debug('req --------->>>>>'+ req);
            HTTPResponse res = http.send(req);
            String resultStr = res.getBody();
            system.debug('res --------->>>>>'+ res);

            responseMessage = res.getBody();
            if( res.getStatusCode() == 200){ 
                transStatus = 'Success';
            }
            else {
                transStatus = 'Failure';
            }
            resWrp = new ResponseWrapper(transStatus,responseMessage);
        }catch(Exception ex){
             System.debug('In class SPEN_FileUploaderClass Upload file : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
                throw ex;
        }
        return resWrp;
        
    }
    @AuraEnabled
    public static FileUploasDetailsWrapper getCaseNumber(string caseRecordId){
        FileUploasDetailsWrapper docWrap = new FileUploasDetailsWrapper();
        String salesforceId;
        //String migratedDate = System.Label.SPEN_ConnMigrationDate;
        String caseOriginMig = System.Label.SPEN_ConnMigrationOrigin;
        //Datetime migratedDatetime;
        Organization OrgCheck = [SELECT Id,IsSandbox from Organization LIMIT 1];
        Case caseObj = [SELECT Id,Origin,CaseNumber,SPEN_SAPReference__c,CreatedDate FROM CASE WHERE Id=:caseRecordId LIMIT 1];
            Integer createdYear = (caseObj.CreatedDate).year();
            if(caseObj.Origin != caseOriginMig && !OrgCheck.IsSandbox){
                salesforceId = caseObj.CaseNumber;
                docWrap.salesforceId = salesforceId;
                docWrap.createdYear = createdYear;
		        docWrap.sharePointPath = System.Label.SharePointPath;
            }else if(caseObj.Origin == caseOriginMig && !OrgCheck.IsSandbox){
                salesforceId = caseObj.SPEN_SAPReference__c;
                docWrap.salesforceId = salesforceId;
		docWrap.sharePointPath = System.Label.SharePointMigratedPath;
            }else{
                salesforceId = caseObj.CaseNumber;
                docWrap.salesforceId = salesforceId;
		docWrap.sharePointPath = System.Label.SharePointPath;
            }
        return docWrap;
    }

    @AuraEnabled
    public static List<DocumentWrapper> fetchSPDocuments(string caseRecordId){
        List<DocumentWrapper> docWrapList = new List<DocumentWrapper>();
         String salesforceId;
        try{
             String siteNamedCred = '';
            String siteName = '';
            String transStatus ='';
            //String migratedDate = System.Label.SPEN_ConnMigrationDate;
            String caseOriginMig = System.Label.SPEN_ConnMigrationOrigin;
            //Datetime migratedDatetime;
	    String url = ''; 
         Case caseObj = [SELECT Id,Origin,CaseNumber,SPEN_SAPReference__c,CreatedDate FROM CASE WHERE Id=:caseRecordId LIMIT 1];  
         Organization OrgCheck = [SELECT Id,IsSandbox from Organization LIMIT 1];
            Integer createdYear = (caseObj.CreatedDate).year();
            
            if(caseObj.Origin != caseOriginMig && !OrgCheck.IsSandbox){
                siteNamedCred = System.Label.SharePointNamed+createdYear+'/';
                siteName = System.Label.SharePointSite+'-'+createdYear+'/'; //https://iberdrola.sharepoint.com/sites/spen-conn-2023
                salesforceId = caseObj.CaseNumber +'\'';
                url = System.Label.SharePointFetchProd+siteName+System.Label.SharepointFolderName+salesforceId;
            }else if(caseObj.Origin == caseOriginMig && !OrgCheck.IsSandbox){
                siteNamedCred = System.Label.SharePointNamed+'/';
                siteName = System.Label.SharePointSite+'/'; //- migrated site
                salesforceId = caseObj.SPEN_SAPReference__c +'\'';
                url = System.Label.SharePointFetchMigrated+siteName+System.Label.SharepointMigratedFolderName+salesforceId;
            }else{
                siteNamedCred = System.Label.SharePointNamed+'/';
                siteName = System.Label.SharePointSite+'/'; //- old site
                salesforceId = caseObj.CaseNumber +'\'';
                url = System.Label.SharePointFetchSanbox+siteName+System.Label.SharepointFolderName+salesforceId;
            }

            
                //salesforceId = '\''+ caseObj.CaseNumber +'\'';        
                //salesforceId =  caseObj.CaseNumber +'\''; 
    system.debug('salesforceId' + salesforceId);
   //String url = '_api/Web/lists/GetbyTitle(\'Documents\')/Items?$select=FileLeafRef,File_x0020_Type,FileRef,LinkFilename,EncodedAbsUrl,ID,GUID,Title,Created_x0020_Date&$filter=FileLeafRef%20eq%20'+salesforceId;
   //String url = '_api/Web/lists/GetbyTitle(\'Documents\')/Items?$select=FileLeafRef,File_x0020_Type,FileRef,LinkFilename,EncodedAbsUrl,ID,GUID,Title,Created_x0020_Date&$filter=FileDirRef%20eq%20\'/sites/'+siteName+'Shared%20Documents/'+salesforceId;
	system.debug('url' + url);
    HttpRequest req = new HttpRequest();
    String finalEndpoint= siteNamedCred + url;
    req.setEndpoint(finalEndpoint);
	req.setMethod('GET');
    req.setHeader('Accept', 'application/json;odata=verbose');
	Http http = new Http();
    HttpResponse httpResponse;
    system.debug('req' + req);
    HTTPResponse res = http.send(req);
    String resultStr = res.getBody();
    if( res.getStatusCode() == 200){		
      Map < String, Object > des1 = (Map < String, Object > ) JSON.deserializeUntyped(res.getBody());
      Map < String, Object > results = (Map < String, Object > ) des1.get('d');
      system.debug('results ' + results);
      List < Object > res2 = (List < Object > ) results.get('results');
      for (Object obj: res2) {
        Map < String, Object > fieldet = (Map < String, Object > ) obj;
        DocumentWrapper docWrap = new DocumentWrapper();
        docWrap.DocDate = String.valueOf(fieldet.get('Created_x0020_Date'));
        docWrap.DocId = String.valueOf(fieldet.get('ID'));
        docWrap.DocName = String.valueOf(fieldet.get('LinkFilename'));
        String viewLink = String.valueOf(fieldet.get('EncodedAbsUrl'));
        System.debug('viewLink' + viewLink);
        docWrap.DocViewLink = viewLink;
        docWrapList.add(docWrap);
        }
    }
        }catch(Exception ex){
            system.debug('exception***' + ex.getMessage());
        }
    return docWrapList;
  }

  public class DocumentWrapper {
    @AuraEnabled
    public String DocId;

    @AuraEnabled
    public String DocName;

    @AuraEnabled
    public String DocDate;

    @AuraEnabled
    public String DocViewLink;
	}
    
    public static String createFolder(Case caseObj) {
        try{
            //Case caseObj = [SELECT Id,CaseNumber,SPEN_SAPReference__c,Createddate FROM CASE WHERE Id=:caseid LIMIT 1];
            Boolean hasDataLoadPermission = FeatureManagement.checkPermission('SPEN_BypassTriggerCase');
            String siteNamedCred = '';
            String siteName = '';
            String transStatus ='';
            //String migratedDate = System.Label.SPEN_ConnMigrationDate;
            //Datetime migratedDatetime;
            String folderName = '';
            Organization OrgCheck = [SELECT Id,IsSandbox from Organization LIMIT 1];
            if(!hasDataLoadPermission){               
                Integer createdYear = (caseObj.CreatedDate).year();
                
                if(!OrgCheck.IsSandbox){
				//GE
                    if(caseObj.recordtypeId == recordTypeIdGE)
                    {
                        siteNamedCred = System.Label.GESharePointNamed+createdYear+'/';
                        siteName = System.Label.GESharePointSite+'-'+createdYear+'/'; 
                    }
                    //SI
                    else if(caseObj.recordtypeId == recordTypeIdSI)
                    {
                        siteNamedCred = System.Label.SISharePointNamed+createdYear+'/';
                        siteName = System.Label.SISharePointSite+'-'+createdYear+'/'; 
                    }
                    else 
                    {
                    	siteNamedCred = System.Label.SharePointNamed+createdYear+'/';
                    	siteName = System.Label.SharePointSite+'-'+createdYear+'/'; //https://iberdrola.sharepoint.com/sites/spen-conn-2023
                    }
                    folderName = caseObj.CaseNumber;
                }else{
                   
                    if(caseObj.recordtypeId == recordTypeIdGE)
                    {
                         siteNamedCred = System.Label.GESharePointNamed+'/';
                         siteName = System.Label.GESharePointSite+'/'; 
                    }
                    else if(caseObj.recordtypeId == recordTypeIdSI)
                    {
                         siteNamedCred = System.Label.SISharePointNamed+'/';
                         siteName = System.Label.SISharePointSite+'/'; 
                    }
                    else{
                         siteNamedCred = System.Label.SharePointNamed+'/';
                    	siteName = System.Label.SharePointSite+'/'; 
                    }
                   
                    folderName = caseObj.CaseNumber;
                }
                
                String urll = siteNamedCred + '_api/web/folders';
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(urll);
                req.setMethod('POST');
                req.setHeader('Accept', 'application/json;odata=verbose');
                req.setHeader('Content-Type', 'application/json;odata=verbose');
                req.setHeader('Content-Length', '148');               
                String domainName = System.Label.SharePointDomain;
                String bbdy = 	'{'+
                    '"__metadata": {'+
                    '"type": "SP.Folder"'+
                    '},'+
                    '"ServerRelativeUrl": "https://'+domainName+'.sharepoint.com/sites/'+siteName+System.Label.SharepointFolderName+folderName+'"'+
                    '}';
                req.setBody(bbdy);
                Http http = new Http();
                system.debug('req**' + req);
                HTTPResponse res = http.send(req);
                String resultStr = res.getBody();
                system.debug('res --------->>>>>'+ res);
                system.debug('resultStr --------->>>>>'+ resultStr);
                if( res.getStatusCode() == 200 || res.getStatusCode() == 201){
                    transStatus = 'Success';
                    system.debug('transStatus' +  transStatus);
                    createSubFolder(caseObj);
                }
                else {
                    transStatus = 'Failure';
                    system.debug('transStatus' +  transStatus);
                }
            }     
        }catch(exception ex){
                System.debug('In class SPEN_FileUploaderClass Create folder : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
                throw ex;
            }
        return 'Success';
    }

	public static String createSubFolder(Case caseObj) {
        try{ 
		String siteNamedCred = '';
            String siteName = '';
            //String migratedDate = System.Label.SPEN_ConnMigrationDate;
            //Datetime migratedDatetime;
             String folderName = '';
        
            Organization OrgCheck = [SELECT Id,IsSandbox from Organization LIMIT 1];
            Integer createdYear = (caseObj.CreatedDate).year();
            
            if(!OrgCheck.IsSandbox){
                 //GE
                 if(caseObj.recordtypeId == recordTypeIdGE)
                 {
                     siteNamedCred = System.Label.GESharePointNamed+createdYear+'/';
                     siteName = System.Label.GESharePointSite+'-'+createdYear+'/'; 
                 }
                //SI
                else if(caseObj.recordtypeId == recordTypeIdSI)
                {
                    siteNamedCred = System.Label.SISharePointNamed+createdYear+'/';
                    siteName = System.Label.SISharePointSite+'-'+createdYear+'/'; 
                }
                else{
                      siteNamedCred = System.Label.SharePointNamed+createdYear+'/';
                	siteName = System.Label.SharePointSite+'-'+createdYear+'/'; //https://iberdrola.sharepoint.com/sites/spen-conn-2023
                }
                folderName = caseObj.CaseNumber;
            }else{
                if(caseObj.recordtypeId == recordTypeIdGE)
                    {
                         siteNamedCred = System.Label.GESharePointNamed+'/';
                         siteName = System.Label.GESharePointSite+'/'; 
                    }
                    else if(caseObj.recordtypeId == recordTypeIdSI)
                    {
                         siteNamedCred = System.Label.SISharePointNamed+'/';
                         siteName = System.Label.SISharePointSite+'/'; 
                    }
                    else{
                         siteNamedCred = System.Label.SharePointNamed+'/';
                    	 siteName = System.Label.SharePointSite+'/'; 
                    }
                            
                folderName = caseObj.CaseNumber;
            }
            String transStatus ='';
            String urll = siteNamedCred + '_api/web/folders';
            folderName = caseObj.CaseNumber;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(urll);
            req.setMethod('POST');
            req.setHeader('Accept', 'application/json;odata=verbose');
            req.setHeader('Content-Type', 'application/json;odata=verbose');
            req.setHeader('Content-Length', '148');
            String domainName = System.Label.SharePointDomain;
            String bbdy = 	'{'+
                '"__metadata": {'+
                '"type": "SP.Folder"'+
                '},'+
                '"ServerRelativeUrl": "https://'+domainName+'.sharepoint.com/sites/'+siteName+System.Label.SharepointFolderName+folderName+'/Customer%20Shared%20Documents"'+
                '}';
            req.setBody(bbdy);
            Http http = new Http();
            system.debug('req**' + req);
            HTTPResponse res = http.send(req);
            String resultStr = res.getBody();
            system.debug('res --------->>>>>'+ res);
            system.debug('resultStr --------->>>>>'+ resultStr);
            if( res.getStatusCode() == 200 || res.getStatusCode() == 201){
                transStatus = 'Success';
                system.debug('transStatus' +  transStatus);
            }
            else {
                transStatus = 'Failure';
                system.debug('transStatus' +  transStatus);
            }
            
        }catch(exception ex){
                System.debug('In class SPEN_FileUploaderClass Create Sub folder : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
                throw ex;
            }
        return 'Success';
    }
    
    @future(callout=true)
    public static void uploadFile(List<ID> recordIdList) {
        String statusFolderCreation = 'Success';
        Set<Id> successCaseId = new Set<ID>();
        Set<Id> emailMsgId = new Set<ID>();
        map<id,case> caseIdVsCaseMap = new Map<Id,Case>();
        map<id,id> caseIdVsEmailMap = new Map<Id,id>();
        map<id,id> caseIdVsCon = new Map<Id,id>();
        List<ContentVersion> finalUpdateContVer = new List<ContentVersion>();
        List<ContentVersion> finalDeleteContVer = new List<ContentVersion>();
        set<id> deletContactDocIdSet = new Set<id>();
        ResponseWrapper respWrp;
        try{
            for(Case caseRec: [SELECT Id, recordtypeId,Origin,CaseNumber,SPEN_SAPReference__c,SPEN_Category__c,Createddate FROM CASE WHERE Id IN : recordIdList]){

                statusFolderCreation = createFolder(caseRec);

               /** if(statusFolderCreation == 'Success'){
                    successCaseId.add(caseRec.id);
                   caseIdVsCaseMap.put(caseRec.id,caseRec);   
                }
                system.debug('successCaseId' + successCaseId);**/
            }
            /**if(!successCaseId.isEmpty() && successCaseId.size()>0){
                Set<Id> contentDocLinkIdSet = new Set<Id>();
                List<EmailMessage> emailMsgList = [Select id, Parentid from EmailMessage where Parentid IN : successCaseId];
                for(EmailMessage emailMsg : emailMsgList){
                    emailMsgId.add(emailMsg.id);
                    caseIdVsEmailMap.put(emailMsg.id,emailMsg.Parentid);
                }
                List<ContentDocumentLink> comtDocLinkList = [select ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN : emailMsgId limit 50000];
                for(ContentDocumentLink link : comtDocLinkList){
                    contentDocLinkIdSet.add(link.ContentDocumentId);
                    if(caseIdVsEmailMap.containsKey(link.LinkedEntityId)){
                        caseIdVsCon.put(link.ContentDocumentId,caseIdVsEmailMap.get(link.LinkedEntityId));
                    }
                    
                }
                List<ContentVersion > contVersionList = [select id,ContentDocumentId,VersionData,Title,ContentSize,SPEN_SharePointFileUploadDeatils__c,SPEN_ManualFileUpload__c from ContentVersion 
                                                         where ContentDocumentId IN : contentDocLinkIdSet and SPEN_ManualFileUpload__c = false limit 50000];
                for(ContentVersion conVer : contVersionList){
                    ContentVersion conVersionRecord =  new ContentVersion();
                    conVersionRecord.id = conVer.id;
                    
                    Case caseRecord =  new Case();
                    
                    if(caseIdVsCon.containsKey(conVer.ContentDocumentId)){
                        caseRecord = caseIdVsCaseMap.get(caseIdVsCon.get(conVer.ContentDocumentId));
                    }
                    system.debug('caseRecord' + caseRecord) ;
                    
                    if(conVer.ContentSize <= 4.5*1024*1024){
                        
                        String base64Val = EncodingUtil.base64Encode(conVer.VersionData);
                        system.debug('base64Val***' + base64Val);
                      	respWrp = uploadFile(base64Val, conVer.Title, caseRecord);
                        if(respWrp.responsesStatus == 'Success'){
                            conVersionRecord.SPEN_SharePointFileUploadDeatils__c = 'File has been successfully uploaded to Sharepoint';
                            finalUpdateContVer.add(conVersionRecord);
			    //deletContactDocIdSet.add(conVer.ContentDocumentId);

                        }else{
                           conVersionRecord.SPEN_SharePointFileUploadDeatils__c = respWrp.responseMessage;
                        }
                        finalUpdateContVer.add(conVersionRecord);
                    }else{
                        conVersionRecord.SPEN_SharePointFileUploadDeatils__c = 'The file size greater than 4.5MB for ' + conVer.Title;
                        finalUpdateContVer.add(conVersionRecord);
                    }
                }
                if(finalUpdateContVer.size()> 0 ){
                    update(finalUpdateContVer);
                }
            }  **/  
        }Catch(Exception ex){
             System.debug('In class SPEN_FileUploaderClass : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            SEL_LoggingService.log(ex);
        }
    }
    
    public class ResponseWrapper{
        String responsesStatus;
        String responseMessage;
        public  ResponseWrapper(String responsesStatus,String responseMessage){
            this.responsesStatus = responsesStatus;
            this.responseMessage = responseMessage;
        }
    }
     public class FileUploasDetailsWrapper{
          @AuraEnabled
        public String salesforceId;
          @AuraEnabled
         public Integer createdYear;  
          @AuraEnabled
         public String sharePointPath;  
         
     }
    /**@AuraEnabled(cacheable=true)
     public static Boolean checkManualUploadRequired(String recordId) {
         Boolean manualUpload = false;
         Set<id> emailMsgId = new Set<Id>();
         Set<id> contentDocLinkIdSet = new Set<Id>();
          List<EmailMessage> emailMsgList = [Select id, Parentid from EmailMessage where Parentid =: recordId];
                for(EmailMessage emailMsg : emailMsgList){
                    emailMsgId.add(emailMsg.id);
                }
                List<ContentDocumentLink> comtDocLinkList = [select ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId IN : emailMsgId limit 50000];
                for(ContentDocumentLink link : comtDocLinkList){
                    contentDocLinkIdSet.add(link.ContentDocumentId);
                }
                List<ContentVersion > contVersionList = [select id,ContentDocumentId,VersionData,Title,ContentSize,SPEN_ManualFileUpload__c from ContentVersion 
                                                         where ContentDocumentId IN : contentDocLinkIdSet limit 50000];
                for(ContentVersion conVer : contVersionList){
                      if(!manualUpload && conVer.SPEN_ManualFileUpload__c){
                          manualUpload = true;
                      }
                }
         return manualUpload;
     }**/
    
    }
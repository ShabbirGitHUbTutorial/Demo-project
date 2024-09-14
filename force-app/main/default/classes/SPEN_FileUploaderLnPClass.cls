public with sharing class SPEN_FileUploaderLnPClass {
    
    public static String folderName = '';
    public static String siteName = '';
    public static String siteNamedCred = '';
    public class FolderCreationInput {
        @InvocableVariable(label='Name' description='Name of the job')
        public String jobName;
 
        @InvocableVariable(label='LicenseArea' description='Area of the job')
        public String jobLicenseArea;
    }
    
    @InvocableMethod(label='Folder Creation in Sharepoint' description='Creates folder in sharepoint')
    public static void createFolder(List<FolderCreationInput> folderInputs) {
        try{ 
            if (folderInputs != null && !folderInputs.isEmpty()){
                FolderCreationInput input = folderInputs[0]; // Assuming you only need the first input
                String jobName = input.jobName;
                String jobLicenseArea = input.jobLicenseArea;
                folderName = jobName;
			
             if (jobLicenseArea == 'SPD') {
                    siteNamedCred = System.Label.SPEN_SharepointLnPSPDCallout;
                    siteName = System.Label.SPEN_SharepointLnPSPDSiteName;
                } else if (jobLicenseArea == 'SPM') {
                    siteNamedCred = System.Label.SPEN_SharepointLnPSPMCallout;
                    siteName = System.Label.SPEN_SharepointLnPSPMSiteName;
                } else if (jobLicenseArea == 'SPT' || jobLicenseArea == 'SPM 132') {
                    siteNamedCred = System.Label.SPEN_SharepointLnPSPTCallout;
                    siteName = System.Label.SPEN_SharepointLnPSPTSiteName;
                }
            
            String url = siteNamedCred + '_api/web/folders';
            
            callout(url,folderName,siteName);
            
        }  
        }catch(exception ex){
            System.debug('In class SPEN_FileUploaderClass Create folder : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            throw ex;
        }
        
    }
    
    @future(callout=true)
    public static void callout(String url,String folderName, String siteName)
    {
        try{
            String transStatus ='';
            HttpRequest req = new HttpRequest();
            req.setEndpoint(url);
            req.setMethod('POST');
            req.setHeader('Accept', 'application/json;odata=verbose');
            req.setHeader('Content-Type', 'application/json;odata=verbose');
            req.setHeader('Content-Length', '148');
            String domainName = System.Label.SharePointDomain;//check
            String bbdy = 	'{'+
                '"__metadata": {'+
                '"type": "SP.Folder"'+
                '},'+
                '"ServerRelativeUrl": "https://'+domainName+'.sharepoint.com/sites/'+siteName+'Shared%20Documents/'+folderName+'"'+
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
            System.debug('In class SPEN_FileUploaderClass Create folder lower : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            throw ex;
        }
        
    }
    
}
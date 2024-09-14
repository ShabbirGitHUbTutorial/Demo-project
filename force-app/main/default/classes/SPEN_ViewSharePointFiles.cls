public with sharing class SPEN_ViewSharePointFiles {
    
    @AuraEnabled
    public static List<DocumentWrapper> fetchSPDocuments(string caseRecordId){
    List<DocumentWrapper> docWrapList = new List<DocumentWrapper>();
    String salesforceId = '\''+caseRecordId+'\'';
    String url = '_api/Web/lists/GetbyTitle(\'Documents\')/Items?$select=FileLeafRef,File_x0020_Type,FileRef,LinkFilename,EncodedAbsUrl,SALESFORCEID,CATEGORY,ID,GUID,Title,Created_x0020_Date&$filter=SALESFORCEID%20eq%20'+salesforceId;
	HttpRequest req = new HttpRequest();
    String siteNamedCred = System.Label.SharePointNamed;
    String finalEndpoint= siteNamedCred + url;
    req.setEndpoint(finalEndpoint);
	req.setMethod('GET');
    req.setHeader('Accept', 'application/json;odata=verbose');
	Http http = new Http();
    HttpResponse httpResponse;
    HTTPResponse res = http.send(req);
    String resultStr = res.getBody();
    if( res.getStatusCode() == 200){		
      Map < String, Object > des1 = (Map < String, Object > ) 
      JSON.deserializeUntyped(res.getBody());
      Map < String, Object > results = (Map < String, Object > ) des1.get('d');
      system.debug('results ' + results);
      List < Object > res2 = (List < Object > ) results.get('results');
      for (Object obj: res2) {
        Map < String, Object > fieldet = (Map < String, Object > ) obj;
        DocumentWrapper docWrap = new DocumentWrapper();
        docWrap.DocCategory =String.valueOf(fieldet.get('CATEGORY'));
        docWrap.DocDate = String.valueOf(fieldet.get('Created_x0020_Date'));
        docWrap.DocId = String.valueOf(fieldet.get('ID'));
        docWrap.DocName = String.valueOf(fieldet.get('LinkFilename'));
        String viewLink = String.valueOf(fieldet.get('EncodedAbsUrl'));
        Integer lastPos = viewLink.lastIndexOf('/');
        String folderPath = viewLink.left(lastPos);
        docWrap.DocViewLink = folderPath;
        docWrapList.add(docWrap);
        }
    } 
    return docWrapList;
  }

  public class DocumentWrapper {
    @AuraEnabled
    public String DocId;

    @AuraEnabled
    public String DocName;

    @AuraEnabled
    public String DocCategory;

    @AuraEnabled
    public String DocDate;

    @AuraEnabled
    public String DocViewLink;
	}
}
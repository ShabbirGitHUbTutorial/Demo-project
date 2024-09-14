/*------------------------------------------------------------------------------------
DESCRIPTION	:	Selector class of ContentVersion Object
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment

------------------------------------------------------------------------------------*/
public with sharing class SPEN_ContentVersionSelector {
    
    public List<ContentVersion> getContentVersionListFromDocids(Set<Id> contentDocIdSet){
        List<ContentVersion> csvDoc = new List<ContentVersion>();
        if(contentDocIdSet!=null && !contentDocIdSet.isEmpty()){
            csvDoc = [SELECT VersionData,ContentDocumentId,ContentDocument.FileType 
                FROM ContentVersion 
                WHERE ContentDocumentId IN:contentDocIdSet WITH SECURITY_ENFORCED];
        }
        return csvDoc;
    }
}
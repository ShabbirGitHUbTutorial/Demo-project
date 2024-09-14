public class SPEN_ContentDocuments {
	public void beforeDeleteContents(List<ContentDocument> cntList){
               
        Boolean isExternalUser = SPEN_ContentDocuments.isLoggedInAsExternalUser(); 
        //get prefix of Job exception record
        Schema.DescribeSObjectResult job = SPEN_Job__c.sObjectType.getDescribe();
        String jobKeyPrefix = job.getKeyPrefix();    
        List<Id> contentDocId = new List<Id>();
        Map<Id, Id> contDocLinkedMap = new Map<Id, Id>();        
        for(ContentDocument con : cntList){                        
            contentDocId.add(con.Id);
        }
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE ContentDocumentId IN : contentDocId]){
            if(jobKeyPrefix == String.valueOf(cdl.LinkedEntityId).left(3)){
                contDocLinkedMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);               
            }
        }
        Map<Id, SPEN_Job__c> jobsMap = new Map<ID, SPEN_Job__c>([select Id, SPEN_JobStatus__c from SPEN_Job__c where Id IN : contDocLinkedMap.values()]);
                           
        for(ContentDocument cdoc : cntList){
            //contDocLinkedMap.get(cdoc.Id) will give the LinkedEntityId
            if(isExternalUser && contDocLinkedMap.get(cdoc.id) != null && jobsMap.get(contDocLinkedMap.get(cdoc.id)).SPEN_JobStatus__c != 'Draft' && jobsMap.get(contDocLinkedMap.get(cdoc.id)).SPEN_JobStatus__c != 'Rejected' ){
                cdoc.adderror('Documentation can only be deleted if Job Status is Draft');
            }               
        }
    }
    
    public Static Boolean isLoggedInAsExternalUser(){
        Boolean isExternalUser = false;            
        Id userId = Userinfo.getUserId();
        Boolean hasPermission = FeatureManagement.checkPermission('SPEN_LnPExternalUsers');
        //System.debug('hasPermission==='+hasPermission);
        //User userDetail =[SELECT Id, Name, Email, Profile.Name, UserRole.Name FROM User where Id=:userId ];
        //if(userDetail!= null && (userDetail.UserRole.Name == 'External Distribution' || userDetail.UserRole.Name == 'External Manweb' || userDetail.UserRole.Name == 'External Transmission'))
        if(hasPermission==true)
        {
            isExternalUser=true;                
        } 
        return isExternalUser;
    }
}
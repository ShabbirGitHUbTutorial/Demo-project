public with sharing class SPEN_CreateRelatedRecordsController { 
    @AuraEnabled
    public static void insertRelatedProject(String relatedProject){ 
        List<RelatedProjectInfo> relatedProjectObj = (List<RelatedProjectInfo>) JSON.deserialize(relatedProject,List<RelatedProjectInfo>.class); 
        List<SPEN_RelatedProject__c> relatedProjectToInsertList = new List<SPEN_RelatedProject__c>();
        try{
            if(!relatedProjectObj.isEmpty()){ 
                for(RelatedProjectInfo relObj : relatedProjectObj){
                    SPEN_RelatedProject__c relatedProjectToInsert = new SPEN_RelatedProject__c();
                    relatedProjectToInsert.SPEN_Case__c = relObj.parentCase;
                    relatedProjectToInsert.SPEN_RelatedCase__c = relObj.relatedCaseId;
                    relatedProjectToInsert.SPEN_Stage__c = relObj.relatedStage;
                    relatedProjectToInsert.SPEN_Type__c = relObj.relatedType;
                    relatedProjectToInsert.SPEN_QueuePosition__c = relObj.relatedQueue;
                    relatedProjectToInsert.SPEN_Relationship__c = relObj.relatedRelationship;
                    relatedProjectToInsertList.add(relatedProjectToInsert);
                }
            }
            if(!relatedProjectToInsertList.isEmpty()){
                insert relatedProjectToInsertList;
            }
        } catch (Exception e) {
            SEL_LoggingService.log(e);
        }
    }

    public class RelatedProjectInfo{
        @AuraEnabled
        public String parentCase{get;set;}
        @AuraEnabled
        public String relatedCaseId{get;set;}
        @AuraEnabled
        public String relatedStage{get;set;}
        @AuraEnabled
        public String relatedType{get;set;}
        @AuraEnabled
        public String relatedQueue{get;set;}
        @AuraEnabled
        public String relatedRelationship{get;set;}
    }
}
public class SPEN_KnowledgeTriggerHandler {
    public static void updateDataCategories(Map<Id,SObject> newMapKnowledge){
        Map<Id, String> mapKnowledgeId2DatacatName = new Map<Id, String>();
        List<String> listCategory = new List<String>();
        List<Knowledge__kav> lstKnowledge = (List<Knowledge__kav>)newMapKnowledge.values();
        
        List<Knowledge__DataCategorySelection> lstDC = [SELECT ParentId,DataCategoryGroupName, toLabel(DataCategoryName)  
                                                        FROM Knowledge__DataCategorySelection
                                                        WHERE ParentId IN: newMapKnowledge.keySet() ];
        
        // Get DataCategory Tree
        Map<String,List<String>> mapGrpName2ListCat = getDataCategoryTree();
        
        if(!lstDC.isEmpty()){
            for(Knowledge__DataCategorySelection dcObj:lstDC)
            {   
                if(mapKnowledgeId2DatacatName.containsKey(dcObj.ParentId))
                {                 
                    String str =  mapKnowledgeId2DatacatName.get(dcObj.ParentId); 
                    
                    if(dcObj.DataCategoryName.equalsIgnoreCase('All')){
                        String str2 = string.join( mapGrpName2ListCat.get(dcObj.DataCategoryGroupName),';');
                        mapKnowledgeId2DatacatName.put(dcObj.ParentId, str + ';' + str2);    
                    }
                    else{
                        mapKnowledgeId2DatacatName.put(dcObj.ParentId, str + ';' + dcObj.DataCategoryName);  
                    }
                }
                else
                {   
                    if(dcObj.DataCategoryName.equalsIgnoreCase('All')){
                        String str = string.join( mapGrpName2ListCat.get(dcObj.DataCategoryGroupName),';');
                        mapKnowledgeId2DatacatName.put(dcObj.ParentId, str); 
                    }
                    else{
                        mapKnowledgeId2DatacatName.put(dcObj.ParentId, dcObj.DataCategoryName);        
                    }	
                 
                }
            }
            
            if(!mapKnowledgeId2DatacatName.isEmpty())
            {
                for(Knowledge__kav artObj:lstKnowledge)
                {
                    if(mapKnowledgeId2DatacatName.containsKey(artObj.Id))
                    {      
                        artObj.SPEN_DataCategories__c = mapKnowledgeId2DatacatName.get(artObj.Id);      
                    }
                }
            }
        }else{
            for(Knowledge__kav artObj:lstKnowledge)
            {
                artObj.SPEN_DataCategories__c = null;      
            }
        }
    }
    
    public static Map<String,List<String>> getDataCategoryTree(){
        List<DescribeDataCategoryGroupResult> describeCategoryResult;
        List<Schema.DescribeDataCategoryGroupStructureResult> results;
         Map<String,List<String>> mapGrpName2ListCat = new Map<String,List<String>>();
        List <DataCategoryGroupSobjectTypePair> pairs;
        try {
            //Creating the list of sobjects to use for the describe call
            List<String> objType = new List<String>();
            objType.add('KnowledgeArticleVersion');
            
            //Describe Call
            describeCategoryResult = Schema.describeDataCategoryGroups(objType);
           
            //Using the results and retrieving the information
            for(DescribeDataCategoryGroupResult singleResult : describeCategoryResult){
               
                mapGrpName2ListCat.put(singleResult.getName(), new List<String>());
                results = new List<Schema.DescribeDataCategoryGroupStructureResult>();
                
                try {
                    pairs = new List<DataCategoryGroupSobjectTypePair>();
                    
                    DataCategoryGroupSobjectTypePair pair1 = new DataCategoryGroupSobjectTypePair();
                    pair1.setSobject('KnowledgeArticleVersion');
                    pair1.setDataCategoryGroupName(singleResult.getName());
                    
                    pairs.add(pair1);
                    
                    results = Schema.describeDataCategoryGroupStructures(pairs, false);
                    
                    for (DescribeDataCategoryGroupStructureResult singleResult1 : results) {
                        for (Schema.DataCategory singleResultSubTopCatLevel1 : singleResult1.getTopCategories() ) 
                        {
                            for (Schema.DataCategory singleResultSubChildCatLevel2 : singleResultSubTopCatLevel1.getChildCategories() ) 
                            {
                                mapGrpName2ListCat.get(singleResult.getName()).add(singleResultSubChildCatLevel2.getLabel());
                                
                                //Uncomment this code if level 3 categories are introduced                                
                                /*for (Schema.DataCategory singleResultSubTopCatLevel3 : singleResultSubChildCatLevel2.childcategories ) 
                                {
									System.debug('LEVEL 3' + singleResultSubTopCatLevel3.getLabel());
                                    mapGrpName2ListCat.get(singleResult.getName()).add(singleResultSubTopCatLevel3.getLabel());
                                    
                                    for (Schema.DataCategory singleResultSubChildCatLevel4 : singleResultSubTopCatLevel3.childcategories ) 
                                    {
                                        System.debug('LEVEL 4' + singleResultSubChildCatLevel4.getLabel());
                                        mapGrpName2ListCat.get(singleResult.getName()).add(singleResultSubChildCatLevel4.getLabel());
                                    }
                                }*/
                            }
                        }
                    }
                } catch(Exception e){
                    System.debug(e.getMessage());
                }
            }
        } catch(Exception e){
            System.debug(e.getMessage());
        }
        return mapGrpName2ListCat;
    }
    /*************************************************************************
@Author: Rajat Verma
@Date: 08/03/24
@purpose: Update the new draft article and publish it
*************************************************************************************/
    @InvocableMethod(label='Publish New Draft Article' description='Update the new draft article and publish it')
    public static void updateAndPublishArticle(List<DraftKnowledgeDetails> articleIds){
        if(!articleIds.isEmpty()){
            Id articleId = articleIds[0].articleId;
            String reviewAction = articleIds[0].reviewAction;
            sendSoapCallout(articleId,reviewAction);
        }
    }
    
    @future(callout=true)
    public Static void sendSoapCallout(Id articleIds, String reviewAction) {
        List<Knowledge__kav> articleListToUpdate = new List<Knowledge__kav>();
        String articleToPublish = '';
        
        for(Knowledge__kav kavObj : [SELECT Id, Title, LastPublishedDate, NextReviewDate, ValidationStatus, PublishStatus, KnowledgeArticleId
                                     FROM Knowledge__kav where KnowledgeArticleId =: articleIds AND PublishStatus = 'Draft']){
                                         Knowledge__kav kav = new Knowledge__kav();
                                         kav.Id = kavObj.Id;
                                         if('No'.equalsIgnoreCase(reviewAction)){
                                             kav.SPEN_LastReviewOutcome__c = 'Reviewed, No Change Required';
                                             kav.NextReviewDate = System.now().addMonths(12);
                                             articleToPublish = kavObj.KnowledgeArticleId;
                                         }else if('Yes'.equalsIgnoreCase(reviewAction)){
                                             kav.SPEN_LastReviewOutcome__c = 'Reviewed, Change Required';
                                             kav.NextReviewDate = null;
                                             kav.ValidationStatus = 'Work In Progress';
                                         }
                                         articleListToUpdate.add(kav);
                                     }
        if(!articleListToUpdate.isEmpty()){
            update articleListToUpdate; 
        }
        if(String.isNotBlank(articleToPublish)){
            KbManagement.PublishingService.publishArticle(articleToPublish, true);
        }
    }
    
    public class DraftKnowledgeDetails{
        @InvocableVariable(required=true)
        public Id articleId;
        
        @InvocableVariable(required=true)
        public String reviewAction;
    }
    
}
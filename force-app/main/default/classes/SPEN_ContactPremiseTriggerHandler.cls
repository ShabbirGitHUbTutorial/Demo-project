public class SPEN_ContactPremiseTriggerHandler 
{   
    public void validateBeforeUpdate(Map<Id,SPEN_ContactPremise__c> oldCPMap, List<SPEN_ContactPremise__c> newCPList)
    {     Map<Id, String> mapOfContactWithPremise = new Map<Id, String>();
        List<SPEN_ContactPremise__c> conPremList = newCPList;
        Boolean primaryContactAllowed = true;
        Boolean newConPremAllowed = true;
        String errorMessage;
        Map<Id,Set<String>> contactPremiseMap = new Map<Id,Set<String>>();
        Set<Id> premiseIds = new Set<Id>();
        try
        {
            for(SPEN_ContactPremise__c con : conPremList)
            {
                SPEN_ContactPremise__c oldConPrem = oldCPMap.get(con.Id);
                // 5199 Related change start
                Set<String> setOfRoles = new Set<String>{'Alternative Contact', 'PSR Contact', 'PSR Contact (Alternative)', 'Premise Owner'};

                mapOfContactWithPremise = SPEN_ContactPremises.checkifContactisTaggedWithPremise(con.SPEN_RelatedContact__c, setOfRoles);
                if(!mapOfContactWithPremise.isEmpty() &&  (con.SPEN_Role__c != oldConPrem.SPEN_Role__c || con.SPEN_Premise__c != oldConPrem.SPEN_Premise__c) && con.SPEN_RelatedContact__c != null && oldConPrem.SPEN_Role__c != null  &&  con.SPEN_Role__c!=null  ){
                    String mapOfRolesAndPremise = mapOfContactWithPremise.get(con.SPEN_RelatedContact__c);
                    List<String> stringMessage =  mapOfRolesAndPremise.split('ConnectedWith');
                    
                    String originalMessage = System.Label.SPEN_ErrorMsgForMultipleContactTag;
                    String errorMsg = (originalMessage.replace('<ROLE>',stringMessage[0])).replace('<EXISTING PREMISE>',stringMessage[1]);
                    con.addError(errorMsg);
                    return;
                }
                // 5199 Related change end
                if(con.SPEN_RelatedContact__c != oldConPrem.SPEN_RelatedContact__c)
                {
                    newConPremAllowed = SPEN_ContactPremises.checkForExistingConPremRecord(con.SPEN_RelatedContact__c,con.SPEN_Premise__c);
                    if(newConPremAllowed)
                    {
                        if(con.SPEN_PremisePrimaryContact__c)
                        {
                            primaryContactAllowed = SPEN_ContactPremises.checkForDoublePrimaryContact(con.SPEN_Premise__c, con.SPEN_PremisePrimaryContact__c);
                        }
                    }
                    else
                    {
                        if(con.SPEN_PremisePrimaryContact__c)
                        {
                            primaryContactAllowed = SPEN_ContactPremises.checkForDoublePrimaryContact(con.SPEN_Premise__c, con.SPEN_PremisePrimaryContact__c);
                        } 
                    }
                    if(!newConPremAllowed)
                    {
                        errorMessage = 'Contact Premise record for this contact already exists';
                        con.addError(errorMessage);
                    } 
                    else if(!primaryContactAllowed)
                    {            
                        errorMessage = 'Only 1 primary contact allowed per permise. This premise already has a primary contact set. Please review and make necessary changes to change the primary contact.';
                        con.addError(errorMessage);
                    } 		
                    
                }
                if(con.SPEN_Role__c != oldConPrem.SPEN_Role__c){
                    premiseIds.add(con.SPEN_Premise__c);
                }		  
            }    
            if(!premiseIds.isEmpty())
            {
                for(SPEN_ContactPremise__c conRec: [Select Id,SPEN_Premise__c,SPEN_Role__c
                                                   FROM SPEN_ContactPremise__c WHERE SPEN_Premise__c IN: premiseIds
                                                   Order BY SPEN_Premise__c])
                {
                    Map<String,Integer> roleCount = new Map<String,Integer>();
                    Set<String> role = new Set<String>();
                    if(contactPremiseMap.containsKey(conRec.SPEN_Premise__c)){
                        role = contactPremiseMap.get(conRec.SPEN_Premise__c);
                        role.add(conRec.SPEN_Role__c);
                    }else{
                        role.add(conRec.SPEN_Role__c);
                    }
                    role.remove(null);
                    contactPremiseMap.put(conRec.SPEN_Premise__c,role);
                }
            }
            for(SPEN_ContactPremise__c conPremise : conPremList){
                if(contactPremiseMap.containsKey(conPremise.SPEN_Premise__c) && contactPremiseMap.get(conPremise.SPEN_Premise__c).contains(conPremise.SPEN_Role__c)){
                    errorMessage = 'There is Contact Premise record presents with the same role.';
                    conPremise.addError(errorMessage);
                }
            }
        }
        catch(CPException cp){
            SEL_LoggingService.log(cp,errorMessage);
        }
    }
    
    public void validateBeforeInsert(List<SPEN_ContactPremise__c> newCPList){
        Map<Id, String> mapOfContactWithPremise = new Map<Id, String>();
        List<SPEN_ContactPremise__c> conPremList = newCPList;
        Boolean primaryContactAllowed = true;
        Boolean newConPremAllowed = true;
        String errorMessage;
        Map<Id,Set<String>> contactPremiseMap = new Map<Id,Set<String>>();
        Set<Id> premiseIds = new Set<Id>();
        try{
            for(SPEN_ContactPremise__c con : conPremList){
                if(con.SPEN_RelatedContact__c != null && con.SPEN_Premise__c !=null && String.isBlank(con.SPEN_Role__c) && String.isBlank(con.SPEN_RelationshipWithPremise__c)){
                    con.addError(System.Label.SPEN_ErrorMsgForEmptyRoleOnCP);
                    return;
                }
                premiseIds.add(con.SPEN_Premise__c);
                newConPremAllowed = SPEN_ContactPremises.checkForExistingConPremRecord(con.SPEN_RelatedContact__c,con.SPEN_Premise__c);

                 // 5199 Related change start
                mapOfContactWithPremise = SPEN_ContactPremises.checkifContactisTaggedWithPremise(con.SPEN_RelatedContact__c, new Set<String>());
                if(!mapOfContactWithPremise.isEmpty() && String.isNotBlank(con.SPEN_Role__c) && con.SPEN_RelatedContact__c != null){
                   
                    String mapOfRolesAndPremise = mapOfContactWithPremise.get(con.SPEN_RelatedContact__c);
                    List<String> stringMessage =  mapOfRolesAndPremise.split('ConnectedWith');
                    
                    String originalMessage = System.Label.SPEN_ErrorMsgForMultipleContactTag;

                    String errorMsg = (originalMessage.replace('<ROLE>',stringMessage[0])).replace('<EXISTING PREMISE>',stringMessage[1]);
                    con.addError(errorMsg);
                    return;
                }
                // 5199 Related change end

                if(newConPremAllowed){
                    if(con.SPEN_PremisePrimaryContact__c){
                        primaryContactAllowed = SPEN_ContactPremises.checkForDoublePrimaryContact(con.SPEN_Premise__c, con.SPEN_PremisePrimaryContact__c);
                    }
                }            
                if(!newConPremAllowed){
                    errorMessage = 'Contact Premise record for this contact already exists';
                    con.addError(errorMessage);
                } 
                else if(!primaryContactAllowed){            
                    errorMessage = 'Only 1 primary contact allowed per permise. This premise already has a primary contact set. Please review and make necessary changes to change the primary contact.';
                    con.addError(errorMessage);
                }
            }
            
            if(!premiseIds.isEmpty()){
                for(SPEN_ContactPremise__c conRec: [Select Id,SPEN_Premise__c,SPEN_Role__c
                                                   FROM SPEN_ContactPremise__c WHERE SPEN_Premise__c IN: premiseIds
                                                   Order BY SPEN_Premise__c]){
                    Map<String,Integer> roleCount = new Map<String,Integer>();
                    Set<String> role = new Set<String>();
                    if(contactPremiseMap.containsKey(conRec.SPEN_Premise__c)){
                        role = contactPremiseMap.get(conRec.SPEN_Premise__c);
                        role.add(conRec.SPEN_Role__c);
                    }else{
                        role.add(conRec.SPEN_Role__c);
                    }
                    contactPremiseMap.put(conRec.SPEN_Premise__c,role);
                }
            }
            for(SPEN_ContactPremise__c conPremise : conPremList){
                if(contactPremiseMap.containsKey(conPremise.SPEN_Premise__c) && contactPremiseMap.get(conPremise.SPEN_Premise__c).contains(conPremise.SPEN_Role__c)){
                    errorMessage = 'There is Contact Premise record presents with the same role.';
                    conPremise.addError(errorMessage);
                }
            }
        }
        catch(CPException cp){
            SEL_LoggingService.log(cp,errorMessage);
        }        
    }
    
    public class CPException extends Exception{
    }
    
    public void updateContactAfterInsert( Map<Id,SPEN_ContactPremise__c> newCPMap)
    {
        List<Contact> updateContactList = new List<Contact>();
      
        try
        {
            for(SPEN_ContactPremise__c conPre : new SPEN_ContactPremisesSelector().getCPRecordsAfterInsert( newCPMap.keySet()))
            {    // 5199 Related change start
                if(conPre.SPEN_RelatedContact__c != null){
                   
                 conPre.SPEN_RelatedContact__r.SPEN_RequireSynctoADQM__c = true;
                 conPre.SPEN_RelatedContact__r.SPEN_ContactRole__c = conPre.SPEN_Role__c;//CRMD-8300
                }
                
                 
                if(conPre.SPEN_Role__c.equalsIgnoreCase('Customer') && conPre.SPEN_RelatedContact__c !=null && String.isBlank(conPre.SPEN_RelatedContact__r.SPEN_CustomerID__c))
                {
                    conPre.SPEN_RelatedContact__r.SPEN_CustomerID__c = conPre.SPEN_Premise__r.SPEN_PremiseID__c;
                }
                else if(!conPre.SPEN_Role__c.equalsIgnoreCase('Customer') && conPre.SPEN_RelatedContact__c !=null && String.isBlank(conPre.SPEN_RelatedContact__r.SPEN_CustomerID__c))
                {
                    conPre.SPEN_RelatedContact__r.SPEN_CustomerID__c = conPre.SPEN_Premise__r.SPEN_PremiseID__c+'-'+conPre.SPEN_Role__c;
                }
                // 5199 Related change end
                if(!updateContactList.contains(conPre.SPEN_RelatedContact__r))
                {
                    updateContactList.add(conPre.SPEN_RelatedContact__r);
                }
            }
            if(!updateContactList.isEmpty())
            {
                update updateContactList;
            }
        }catch(Exception exp)
        {
            SEL_LoggingService.log(exp,exp.getMessage());
        } 
    }
    // 5199 Related change start
    public void updateContactAfterUpdate( Map<Id,SPEN_ContactPremise__c> newCPMap, Map<Id,SPEN_ContactPremise__c> oldCPMap){
        List<Contact> updateContactList = new List<Contact>();
        try{
            for(SPEN_ContactPremise__c conPre : new SPEN_ContactPremisesSelector().getCPRecordsAfterInsert( newCPMap.keySet())){
                SPEN_ContactPremise__c oldConPrem = oldCPMap.get(conPre.Id);
                 
                if((conPre.SPEN_RelatedContact__c != null) && (oldConPrem.SPEN_RelatedContact__c != conPre.SPEN_RelatedContact__c) ){
                    conPre.SPEN_RelatedContact__r.SPEN_RequireSynctoADQM__c = true;
                    conPre.SPEN_RelatedContact__r.SPEN_ContactRole__c = conPre.SPEN_Role__c;//CRMD-8300
                }
                    
                if(!updateContactList.contains(conPre.SPEN_RelatedContact__r)){
                    updateContactList.add(conPre.SPEN_RelatedContact__r);
                }
            } 
            if(!updateContactList.isEmpty()){
                update updateContactList;
            }
        }catch(Exception exp){
            SEL_LoggingService.log(exp,exp.getMessage());
        } 
    }
    // 5199 Related change end
}
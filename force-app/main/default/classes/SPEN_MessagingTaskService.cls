/**
* @Author : 		Accenture
* @Description : 	This class holds the service implemenation of messaging task funcitonality.
* @Version : 		1.0
*/
public class SPEN_MessagingTaskService {
	Public SPEN_MessagingTask__c messagingTaskReferrence;
    
    /**
    * @Description : 	This method takes responsibility of creating instance of SPEN_MessagingTask__c
    */
    //public String createMessagingTask(String event, String incident, String recordType, String owner, String status)
    public String createMessagingTask(String event, Id incident, Id recordType,Id owner, String status)
    {

        try{
        String queueName;
        Incident incRec=new Incident();
        Group msgTaskQueue= new Group(); 
        if(incident != Null){
            incRec= [SELECT Id, SPEN_ZoneRegionFormula__c FROM Incident WHERE Id =:incident];
        }
        If(incRec.SPEN_ZoneRegionFormula__c != Null && (incRec.SPEN_ZoneRegionFormula__c.containsIgnoreCase('North') || incRec.SPEN_ZoneRegionFormula__c.containsIgnoreCase('UNKNOWN'))){
            queueName='Messaging_Task_SPD';
        }
        else If(incRec.SPEN_ZoneRegionFormula__c != Null && incRec.SPEN_ZoneRegionFormula__c.containsIgnoreCase('South')){
            queueName='Messaging_Task_SPM';
        }
        if(queueName != Null){
        msgTaskQueue=[select id,CreatedBy.name from Group where Type ='Queue' and DeveloperName =:queueName];
        }
        messagingTaskReferrence = new SPEN_MessagingTask__c();
        messagingTaskReferrence.SPEN_Event__c = event;
        messagingTaskReferrence.SPEN_IncidentId__c = incident;
        messagingTaskReferrence.RecordTypeId = recordType;
        if(!Test.isRunningTest()){
        messagingTaskReferrence.OwnerId = msgTaskQueue.id;
        }
        messagingTaskReferrence.SPEN_Status__c = status;
        insert messagingTaskReferrence;
        return messagingTaskReferrence.id;
     }

    catch(Exception ex){
        SEL_LoggingService.log(ex);
        throw ex;
    }
	
    }

    public String createMessagingTaskIncCreated(String event, Id incident, Id recordType,String zoneDetail, String status)
    {
        try{
        String queueName;
        spen_zone__c zoneRegion =new spen_zone__c();
        //Incident incRec=new Incident(); 
        Group msgTaskQueue = new Group();
        if(zoneDetail != Null){
        zoneRegion=[select id,SPEN_ZoneRegionFormula__c from spen_zone__c where name =:zoneDetail and SPEN_Type__c ='Zone' limit 1];
        }
        //if(incident != Null){
        //incRec=[select Id,SPEN_ZoneRegionFormula__c from Incident where id=:incident];
        //}
        If(zoneRegion.SPEN_ZoneRegionFormula__c != Null && zoneRegion.SPEN_ZoneRegionFormula__c.containsIgnoreCase('North')){
            queueName='Messaging_Task_SPD';
        }
        else If(zoneRegion.SPEN_ZoneRegionFormula__c != Null && zoneRegion.SPEN_ZoneRegionFormula__c.containsIgnoreCase('South')){
            queueName='Messaging_Task_SPM';
        }

        if(queueName != Null){
        msgTaskQueue=[select id,CreatedBy.name from Group where Type ='Queue' and DeveloperName =:queueName];
        }
        messagingTaskReferrence = new SPEN_MessagingTask__c();
        messagingTaskReferrence.SPEN_Event__c = event;
        messagingTaskReferrence.SPEN_IncidentId__c = incident;
        messagingTaskReferrence.RecordTypeId = recordType;
        messagingTaskReferrence.OwnerId = msgTaskQueue.id;
        messagingTaskReferrence.SPEN_Status__c = status;
        insert messagingTaskReferrence;
        return messagingTaskReferrence.id;
    }
    catch(Exception ex){
        SEL_LoggingService.log(ex);
        throw ex;
    }
    }

}
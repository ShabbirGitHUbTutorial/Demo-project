/**********************************************************************************************
* @Author:      Debapriya Saha
* @Date:        07/10/2022
* @Description: Incident Trigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   

***********************************************************************************************/

trigger IncidentTrigger on Incident (before update, after update,before insert){

    if(Trigger.isUpdate && Trigger.isBefore){
    	new Incidents().onBeforeUpdate(Trigger.new,Trigger.oldMap);
        new Incidents().onBeforeUpdateIVRMsg(Trigger.new,Trigger.oldMap);
    }
     if(Trigger.isInsert && Trigger.isBefore){
    	new Incidents().onBeforeInsert(Trigger.new);
     }
    if(Trigger.isUpdate && Trigger.isAfter){
    	new Incidents().onAfterUpdate(Trigger.oldMap, Trigger.new);
    	new Incidents().onAfterUpdateETRValueInCases(Trigger.new,Trigger.oldMap);
        new Incidents().create3PDCase(Trigger.newMap,Trigger.oldMap);
    }

    //new Incidents().onAfterUpdateMC(Trigger.old, Trigger.new);
    //SFBG_IncidentsController.afterIncidentUpdate(Trigger.new);
}
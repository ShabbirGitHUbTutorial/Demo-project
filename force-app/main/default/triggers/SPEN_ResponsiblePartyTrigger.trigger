/**********************************************************************************************
* @Author:      Swaathi KR
* @Date:        04/08/2023
* @Description: Responsible Party Trigger
**********************************************************************************************/
trigger SPEN_ResponsiblePartyTrigger on SPEN_ResponsibleParty__c (before insert) {
    if(Trigger.isInsert && Trigger.isBefore)
    {
        SPEn_ResponsibleParty.defaultPrimaryResponsibleParty(Trigger.new);
    }
}
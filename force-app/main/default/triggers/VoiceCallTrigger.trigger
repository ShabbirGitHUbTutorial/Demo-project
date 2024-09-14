/*-----------------------------------------------------------------------------
DESCRIPTION :   VoiceCall Trigger
LIBRARY     :   SPEN
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
NOV-11-2022     Ayush Mittal        Initial version
FEB-02-2023     Macjules Sevilla    Added after update
-----------------------------------------------------------------------------*/
trigger VoiceCallTrigger on VoiceCall (before update, after update, before insert) 
{
    if(Trigger.isBefore && Trigger.isInsert) { new VoiceCalls().onBeforeInsert(Trigger.new); }
    if(Trigger.isBefore && Trigger.isUpdate) { 
        if(!VoiceCalls.premiseUpdateFlag){
            new VoiceCalls().onBeforeUpdate(Trigger.oldMap, Trigger.new);
        } 
    }
    if(Trigger.isAfter && Trigger.isUpdate) { 
        if(!VoiceCalls.premiseUpdateFlag){
        new VoiceCalls().onAfterUpdate(Trigger.oldMap, Trigger.newMap); 
        }
    }
    
}
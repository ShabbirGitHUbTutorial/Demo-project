/*-----------------------------------------------------------------------------
DESCRIPTION	:	APEX Trigger for SEL_BatchStep__c custom object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-23-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
trigger SEL_BatchStep on SEL_BatchStep__c (before insert, after insert, before update, after update) 
{
	if(Trigger.isBefore)
	{
		if(Trigger.isInsert) { SEL_BatchSteps.onBeforeInsert(Trigger.new); }
		if(Trigger.isUpdate) { SEL_BatchSteps.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);}
	}
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert) { SEL_BatchSteps.onAfterInsert(Trigger.newMap); }
		if(Trigger.isUpdate) { SEL_BatchSteps.onAfterUpdate(Trigger.oldMap, Trigger.newMap); }
	}	
}
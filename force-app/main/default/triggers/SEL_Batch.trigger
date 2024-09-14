/*-----------------------------------------------------------------------------
DESCRIPTION	:	APEX Trigger for Batch__c custom object.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-23-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
trigger SEL_Batch on SEL_Batch__c (after insert, after update) 
{
	if(Trigger.isAfter)
	{
		if(Trigger.isInsert) { SEL_Batches.onAfterInsert(Trigger.newMap); }
		if(Trigger.isUpdate) { SEL_Batches.onAfterUpdate(Trigger.oldMap, Trigger.newMap); }
	}
}
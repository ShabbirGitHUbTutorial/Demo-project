/*----------------------------------------------------------------------------------
DESCRIPTION	:	Service layer for Asynchronous services.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Asynchronous DML Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
JAN-31-2021		Macjules Sevilla	Initial version
AUG-07-2021		Macjules Sevilla	Added whitelisting capabilities via CMT
APR-13-2021		Macjules Sevilla	Removed isActive check on isDmlAllowed method
----------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.CognitiveComplexity')
public inherited sharing class SEL_AsyncDmlService 
{
	@TestVisible
	private List<SEL_AsyncDml__e> unprocessedRecordsDueToLimits = new List<SEL_AsyncDml__e> ();
	@TestVisible
	private List<SEL_ApplicationLog__c> logs = new List<SEL_ApplicationLog__c>();
	@TestVisible
	private Map<String, SEL_AsyncDmlSetting__mdt> objectByConfig = new Map<String, SEL_AsyncDmlSetting__mdt>();
	@TestVisible
	private Map<String, Map<String, List<SObject>>> actionByObjectByData = new Map<String, Map<String, List<SObject>>>();

	// DESCRIPTION
	// Groups events into actions and objects.
	@SuppressWarnings('PMD.NcssConstructorCount')
	public SEL_AsyncDmlService(List<SEL_AsyncDml__e> events)
	{
		if(!(events == null || events.size() == 0))
		{
			this.getConfiguration(events);

			for(SEL_AsyncDml__e e : events)
			{
				String action = e.SEL_Action__c?.toLowerCase();
				String objectApi = e.SEL_Object__c;
				Type objectType = Type.forName(objectApi);

				if(!this.isMessageValid(e)) 
				{
					// WARNING MESSAGES
					// If invalid messages are recieved, store those as WARNING application Logs
					SEL_ApplicationLog__c invalidMessage = new SEL_ApplicationLog__c(
						RecordTypeId = SEL_AsyncDmlConstants.APPLICATION_LOG_RECORD_TYPE_ID_WARNING,
						SEL_Category__c = SEL_AsyncDmlConstants.TYPE_PLATFORM_EVENT,
						SEL_Details__c = JSON.serialize(e),
						SEL_Message__c = SEL_AsyncDmlConstants.MESSAGE_INVALID,
						SEL_RunningUserId__c = UserInfo.getUserId(),
						SEL_Source__c = SEL_AsyncDmlConstants.EVENT
					);
					logs.add(invalidMessage);
					continue;
				}
				
				// IMPORTANT
				// Events are grouped into action by object. This asynchronous service will execute
				// one DML per action-object combination. Order is not guaranteed so best not
				// bulk create objects with dependencies.
				if(this.actionByObjectByData.containsKey(action))
				{
					if(this.actionByObjectByData.get(action).containsKey(objectApi))
					{
						this.actionByObjectByData.get(action).get(objectApi).add((SObject) JSON.deserialize(e.SEL_Record__c, objectType));
					}
					else 
					{
						this.actionByObjectByData.get(action).put(objectApi, new List<SObject> { 
							(SObject) JSON.deserialize(e.SEL_Record__c, objectType) 
						});
					}
				}
				else 
				{
					this.actionByObjectByData.put(action, new Map<String, List<SObject>> { 
						objectApi => new List<SObject> { (SObject) JSON.deserialize(e.SEL_Record__c, objectType) }
					});
				}
			}
		}
	}

	// DESCRIPTION
	// Run all DMLs
	public void executeDmls()
	{
		// The sequence below is arranged based on performance
		executeDml(SEL_CoreConstants.DML_INSERT);
		executeDml(SEL_CoreConstants.DML_UPDATE);
		executeDml(SEL_CoreConstants.DML_UPSERT);
		executeDml(SEL_CoreConstants.DML_DELETE);
		executeDml(SEL_CoreConstants.DML_UNDELETE);

		// APPLICATION LOGS
		// Log exceptions and warnings
		if(logs.size() > 0) 
		{
			if(Schema.sObjectType.SEL_ApplicationLog__c.isCreateable()) 
			{ 
				insert logs;
			}
		}

		// IMPORTANT
		// While the approach below is not good in limiting the number of messages
		// in a platform event per 24-hours, the decision to implement rety mechanism
		// this is to reduce data loss. This is an important considering when using
		// this framework.
		if(unprocessedRecordsDueToLimits.size() > 0)
		{
			Eventbus.publish(unprocessedRecordsDueToLimits);
		}
	}

	// DESCRIPTION
	// Converts the contents of the map back to SEL_AsyncDml__e for processing later.
	@TestVisible
	private void convertUnprocessRecords(String action, String objectApi, List<SObject> records)
	{
		if(!(String.isBlank(action) || String.isBlank(objectApi) || records == null || records.size() < 1))
		{
			for(SObject o : records)
			{
				SEL_AsyncDml__e record = new SEL_AsyncDml__e(
					SEL_Action__c = action,
					SEL_Object__c = objectApi,
					SEL_Record__c = JSON.serialize(o)
				);
				this.unprocessedRecordsDueToLimits.add(record);
			}
		}
	}
	
	// DESCRIPTION
	// Perform an insert operation with partial save enabled
	@TestVisible
	private void executeDml(String action)
	{
		action = action.toLowerCase();

		if(this.actionByObjectByData.size() > 0 && this.actionByObjectByData.containsKey(action))
		{
			List<SEL_DatabaseResult> exceptions = new List<SEL_DatabaseResult>();
			
			for(String objectApi : this.actionByObjectByData.get(action).keySet())
			{
				// LIMIT CHECK
				// The number of DML statements is reduced by 1 to accommodate
				// the exception logging from this class.
				if(Limits.getDmlStatements() < Limits.getLimitDmlStatements() - 1)
				{
					switch on action
					{
						when 'delete'
						{
							Database.DeleteResult[] results = Database.delete(this.actionByObjectByData.get(action).get(objectApi), false);
							exceptions.addAll(SEL_DatabaseResults.getExceptions(this.actionByObjectByData.get(action).get(objectApi), results));
						}
						when 'insert'
						{
							Database.SaveResult[] results = Database.insert(this.actionByObjectByData.get(action).get(objectApi), false);
							exceptions.addAll(SEL_DatabaseResults.getExceptions('insert', this.actionByObjectByData.get(action).get(objectApi), results));
						}
						when 'undelete'
						{
							Database.UndeleteResult[] results = Database.undelete(this.actionByObjectByData.get(action).get(objectApi), false);
							exceptions.addAll(SEL_DatabaseResults.getExceptions(this.actionByObjectByData.get(action).get(objectApi), results));
						}
						when 'update'
						{
							Database.SaveResult[] results = Database.update(this.actionByObjectByData.get(action).get(objectApi), false);
							exceptions.addAll(SEL_DatabaseResults.getExceptions('update', this.actionByObjectByData.get(action).get(objectApi), results));
						}
						when 'upsert'
						{
							Database.UpsertResult[] results = Database.upsert(this.actionByObjectByData.get(action).get(objectApi), false);
							exceptions.addAll(SEL_DatabaseResults.getExceptions(this.actionByObjectByData.get(action).get(objectApi), results));
						}
					}
				}
				else 
				{
					// NOTE
					// This is an unlikely scenario however in order to prevent data loss this 
					// functionality will retry the to process the rest of the records in another event
					convertUnprocessRecords(action, objectApi, this.actionByObjectByData.get(action).get(objectApi));
				}
			}

			this.captureExceptions(exceptions);
		}
	}

	// DESCRIPTION
	// Copy partial exceptions as Application Log records
	@TestVisible
	private void captureExceptions(List<SEL_DatabaseResult> exceptions)
	{
		if(exceptions != null && exceptions.size() > 0)
		{
			for(SEL_DatabaseResult e : exceptions)
			{
				SEL_ApplicationLog__c errorMessage = new SEL_ApplicationLog__c(
					RecordTypeId = SEL_AsyncDmlConstants.APPLICATION_LOG_RECORD_TYPE_ID_EXCEPTION,
					SEL_Category__c = SEL_AsyncDmlConstants.TYPE_PLATFORM_EVENT,
					SEL_Details__c = JSON.serialize(e.record),
					SEL_Message__c = e.message,
					SEL_RunningUserId__c = UserInfo.getUserId(),
					SEL_Source__c = SEL_AsyncDmlConstants.EVENT,
					SEL_ErrorId__c = e.statusCode,
					SEL_Exception__c = SEL_AsyncDmlConstants.MESSAGE_EXCEPTION_TITLE,
					SEL_Method__c = e.dml,
					SEL_Stacktrace__c = e.fields
				);
				logs.add(errorMessage);
			}
		}
	}

	// DESCRIPTION
	// Retrieve the object-level configuration settings from SEL_AsyncDmlSetting__mdt
	@TestVisible
	@SuppressWarnings('PMD.TestDoNotUseIsRunningTest')
	private void getConfiguration(List<SEL_AsyncDml__e> events)
	{
		Set<String> objects = new Set<String>();
		for(SEL_AsyncDml__e e : events) { objects.add(e.SEL_Object__c); }

		if(Test.isRunningTest())
		{
			// UNIT TEST ONLY
			// For the purposes of unit testing, we will default all configuration records
			// to support all objects and allow all DML operations
			for(String s : objects)
			{
				this.objectByConfig.put(s.toLowerCase(), new SEL_AsyncDmlSetting__mdt(
					SEL_IsActive__c = true, 
					SEL_IsDeleteAllowed__c = true, 
					SEL_IsInsertAllowed__c = true, 
					SEL_IsUndeleteAllowed__c = true, 
					SEL_IsUpdateAllowed__c = true, 
					SEL_IsUpsertAllowed__c = true,
					SEL_Object__c = s
				));
			}
		}
		else 
		{
			for(SEL_AsyncDmlSetting__mdt c : new SEL_AsyncDmlSettingsSelector().selectByObjectApisByStatus(objects, true))
			{
				this.objectByConfig.put(c.SEL_Object__c.toLowerCase(), c);
			}
		}
	}

	// DESCRIPTION
	// Checks if the DML operation is permitted by the System Administrator. Returns TRUE if:
	// [1] the object is on the allow list AND 
	// [2] if the DML action on that object is permitted.
	private Boolean isDmlAllowed(String objectApi, String action)
	{
		Boolean isDmlAllowed = false;

		if(this.objectByConfig.containsKey(objectApi.toLowerCase()) && String.isNotBlank(action))
		{
			SEL_AsyncDmlSetting__mdt config = this.objectByConfig.get(objectApi.toLowerCase());
			switch on action.toLowerCase()
			{
				when 'delete'	{ isDmlAllowed = config.SEL_IsDeleteAllowed__c; }
				when 'insert'	{ isDmlAllowed = config.SEL_IsInsertAllowed__c; }
				when 'undelete'	{ isDmlAllowed = config.SEL_IsUndeleteAllowed__c; }
				when 'update'	{ isDmlAllowed = config.SEL_IsUpdateAllowed__c; }
				when 'upsert'	{ isDmlAllowed = config.SEL_IsUpsertAllowed__c; }
			}
		}
		
		return isDmlAllowed;
	}

	// DESCRIPTION
	// Validates the contents of an SEL_AsyncDml__e message. A message is considered VALID if all of the following conditions are met:
	// [1] The Action__c, Object__c, and Record__c fields have values
	// [2] The configuration indicates that the DML action for that object is allowed
	private Boolean isMessageValid(SEL_AsyncDml__e message)
	{
		return	!(
					String.isBlank(message.SEL_Action__c) || 
					String.isBlank(message.SEL_Object__c) || 
					String.isBlank(message.SEL_Record__c)
				) 
				&& 
				this.isDmlAllowed(message.SEL_Object__c, message.SEL_Action__c);
	}
}
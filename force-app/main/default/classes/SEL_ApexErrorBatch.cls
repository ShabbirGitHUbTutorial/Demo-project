/*-----------------------------------------------------------------------------------------
DESCRIPTION	:	Batch for running unit test against BatchApexError Trigger. 
				Do not use this class outside it purpose
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Logging Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
NOV-11-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------------------*/
public with sharing class SEL_ApexErrorBatch implements Database.Batchable<sObject>, Database.Stateful, Database.RaisesPlatformEvents
{
	@SuppressWarnings('PMD.SOQLSelectorPattern')
	public Database.QueryLocator start(Database.BatchableContext bc)
	{
        return Database.getQueryLocator([SELECT Id FROM User WHERE Id =: UserInfo.getUserId()]);
    }

	public void execute(Database.BatchableContext bc, List<SObject> scope)
	{
        Integer testInteger = 1 / 0;
    }

	@SuppressWarnings('PMD.EmptyStatementBlock')
	public void finish(Database.BatchableContext bc) { }
}
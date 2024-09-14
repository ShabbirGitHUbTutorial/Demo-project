/*------------------------------------------------------------------------------------
DESCRIPTION	:	Trigger handle for DML operations done via Platform Event.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Asynchronous DML Framework
TEST		:	AsynchronousDmls_Test
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
JAN-24-2021		Macjules Sevilla	Initial version
FEB-04-2021		Macjules Sevilla	Moved implementation to the Domain layer.
APR-19-2022		Macjules Sevilla	Changed API version to 54.0
------------------------------------------------------------------------------------*/
trigger SEL_AsyncDml on SEL_AsyncDml__e (after insert) 
{
	new SEL_AsyncDmls().onAfterInsert(Trigger.new);
}
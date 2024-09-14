/*------------------------------------------------------------------------------------
DESCRIPTION :   Trigger handle for Batch operations triggered via Platform Event.
AUTHOR      :   Macjules Sevilla
LIBRARY     :   SPEN
TEST        :   TBD
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
JAN-26-2023     Macjules Sevilla    Initial version
------------------------------------------------------------------------------------*/
trigger SPEN_AsyncBatch on SPEN_AsyncBatch__e (after insert)
{
	new SPEN_AsyncBatches().afterInsert(Trigger.New);
}
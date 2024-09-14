/*------------------------------------------------------------------------------------
DESCRIPTION :   Trigger handle for Future operations triggered via Platform Event.
AUTHOR      :   Deepraj Bhushan
LIBRARY     :   SPEN
TEST        :   TBD
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
FEB-20-2023     Deepraj Bhushan    Initial version
------------------------------------------------------------------------------------*/
trigger SPEN_AsyncFuture on SPEN_AsyncFuture__e (after insert)
{
  new SPEN_AsyncFutures().afterInsert(Trigger.New);
}
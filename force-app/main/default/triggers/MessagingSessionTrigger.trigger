/**********************************************************************************************
* @Author:      Ayush Mittal
* @Date:        11/11/2022
* @Description: MessagingSession Trigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
trigger MessagingSessionTrigger on MessagingSession(before insert) 
{
    new MessagingSessions().onBeforeInsert(Trigger.new);
}
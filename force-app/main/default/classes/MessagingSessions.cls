/**********************************************************************************************
* @Author:      Ayush Mittal
* @Date:        11/11/2022
* @Description: Handler class is on MessagingSessionTrigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public with sharing class MessagingSessions 
{ 
    SPEN_MessagingSessionService mesSession = new SPEN_MessagingSessionService();
    public void onBeforeInsert(List<MessagingSession> newMessagingSession)
    {
        if(Trigger.isInsert && Trigger.isBefore)
        {
        	mesSession.isUpdatingPremise(newMessagingSession);
        }
    }
}
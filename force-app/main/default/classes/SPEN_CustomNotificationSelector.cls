/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the Custom Notifications.
LIBRARY     :   Salesforce Enterprise Library - Case Queries
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
July-24-2023    Asmita Rajput       Initial version
-----------------------------------------------------------------------------*/
public without sharing class SPEN_CustomNotificationSelector {
   
    public static List<CustomNotificationType> getCaseAssignmentNotification()
    {
        List<CustomNotificationType> caseAssignmentTemplate = [SELECT Id, DeveloperName 
                                                                FROM CustomNotificationType
                                                                WHERE DeveloperName=: 'Case_Assignment_Notification_to_Queues'
                                                                WITH SECURITY_ENFORCED];
        return caseAssignmentTemplate;
    }
       
}
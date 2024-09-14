/*-----------------------------------------------------------------------------
DESCRIPTION :   Selector class of the User Queries.
LIBRARY     :   Salesforce Enterprise Library - User Queries
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
21-Jul-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SPEN_UserInfoSelector {
    /**************************************************
    @Author: Rohit Sharma
    @Date: 21-Jul-2023 
    @purpose: Method to get User details of loggedIn user.
    ***************************************************/
    public static List<User> getLoggedInUsersInfo(){
        List<User>	loggedInUser = new List<User>();
                    loggedInUser = [Select Id,SPEN_SAPId__c	
                                         FROM User
                                         WHERE Id=:UserInfo.getUserId() LIMIT 1];           
        return loggedInUser;     
    }
    
}
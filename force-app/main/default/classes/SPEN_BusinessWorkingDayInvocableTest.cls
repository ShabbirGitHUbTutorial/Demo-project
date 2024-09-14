/*----------------------------------------------------------------------------
DESCRIPTION :   Test class for SPEN_BusinessWorkingDayInvocableTest
AUTHOR      :   Rajat Kumar mishra
VERSION     :   1.0
HISTORY     :
Date            Author              	Comment
Sep-27-2023     Rajat Kumar mishra      Initial version
-----------------------------------------------------------------------------*/ 
@isTest
public class SPEN_BusinessWorkingDayInvocableTest {
	
    public static testMethod void IsBusinessDayTest(){
        
        User u = SPEN_TestDataUtility.createuser('System Administrator');
        Database.insert(u);                     
		System.runAs(u){
			
			Test.startTest();
				List<SPEN_BusinessWorkingDayInvocable.Request> milestoneReq = new List<SPEN_BusinessWorkingDayInvocable.Request>();
				SPEN_BusinessWorkingDayInvocable.Request req = new SPEN_BusinessWorkingDayInvocable.Request();					
            	req.businessHourName = 'Connection Business Hours';
            	req.providedDate = DateTime.newInstance(2023, 09, 27);
				milestoneReq.add(req);
				List<Boolean> result = SPEN_BusinessWorkingDayInvocable.isBusinessDay(milestoneReq);                      
			Test.stopTest();                
			system.assertNotEquals(result[0], null, 'Today is Business day') ;
		}
    }
}
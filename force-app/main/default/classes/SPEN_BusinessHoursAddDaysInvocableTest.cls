/*----------------------------------------------------------------------------
DESCRIPTION :   Test class for SPEN_BusineessHoursAddDaysInvocableTest
AUTHOR      :   Rajat Kumar mishra
VERSION     :   1.0
HISTORY     :
Date            Author              	Comment
Sep-01-2023     Rajat Kumar mishra      Initial version
-----------------------------------------------------------------------------*/ 

@isTest
public class SPEN_BusinessHoursAddDaysInvocableTest {
	
    public static testMethod void addDaysTest(){
        
        User u = SPEN_TestDataUtility.createuser('System Administrator');
        Database.insert(u);                     
		System.runAs(u){
			
			Test.startTest();
				List<SPEN_BusinessHoursAddDaysInvocable.Request> milestoneReq = new List<SPEN_BusinessHoursAddDaysInvocable.Request>();
				SPEN_BusinessHoursAddDaysInvocable.Request req = new SPEN_BusinessHoursAddDaysInvocable.Request();					
            	req.businessHourName = 'Connection Business Hours';
            	req.plannedStartDate = system.today();
            	req.leadTime = 5;
            	req.delayStart = 0;
				milestoneReq.add(req);
				List<DateTime> result = SPEN_BusinessHoursAddDaysInvocable.addDays(milestoneReq);                      
			Test.stopTest();                
			system.assertNotEquals(result[0], null, 'date is Returned') ;
		}
    }
}
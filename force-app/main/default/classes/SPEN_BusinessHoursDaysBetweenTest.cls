@isTest

private class SPEN_BusinessHoursDaysBetweenTest {

    	public static testMethod void testDaysBetween() {
        User u = SPEN_TestDataUtility.createuser('System Administrator');
        Database.insert(u);
        
        System.runAs(u){
            
        	// Set up the request for the invocable method

            SPEN_BusinessHoursDaysBetweenInvocable.Request req = new SPEN_BusinessHoursDaysBetweenInvocable.Request();
            List<BusinessHours> bhList = [Select id from BusinessHours where Name = 'Connection Business Hours' ];
            req.businessHourName = 'Connection Business Hours';
            //req.startDate = Datetime.newInstance(2023,8,29,0,0,0);
            //req.endDate = Datetime.newInstance(2023,9,5,23,59,59);
            req.startDate = system.today();
            req.endDate =  req.startDate.addDays(7);
            List<SPEN_BusinessHoursDaysBetweenInvocable.Request> requests = new List<SPEN_BusinessHoursDaysBetweenInvocable.Request> { req };
        	// Invoke the method
        	List<Integer> leadDelays = SPEN_BusinessHoursDaysBetweenInvocable.daysBetween(requests);
            // Assertions
            System.assertEquals(1, leadDelays.size(), 'Expected one result.');
        	System.assertEquals(SPEN_BusinessDaysCalculationUtil.daysBetween(bhList[0].Id,system.today() , system.today().addDays(7)), leadDelays[0], 'The calculated lead delay was incorrect.'); 
               
        }
    }

}
@isTest
public class SPEN_BusinessDaysCalculationUtilTest {
 @IsTest
    private static void testUtilMethods() {
        Test.startTest();
        String timeString = SPEN_BusinessDaysCalculationUtil.calculateTimeDiffinString(System.now(), System.now()+1);
         List<BusinessHours> SPMBusinessHr = [SELECT ID,name 
                                              FROM BusinessHours 
                                              WHERE name =: 'SPM Complaints Business Hours' AND IsActive = TRUE];
        Datetime dt = SPEN_BusinessDaysCalculationUtil.addDays(System.now(),5,SPMBusinessHr[0].id);
        Integer intMinutes = SPEN_BusinessDaysCalculationUtil.getAgentHandlingTimeinMinutes(System.now(),System.now().addHours(1));
        Test.stopTest();
    }
}
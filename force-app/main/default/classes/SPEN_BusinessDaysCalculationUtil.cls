public class SPEN_BusinessDaysCalculationUtil {
    
	public static final Integer MILLISECONDS_IN_A_DAY = 1000*60*60*24;
	
 	public static Datetime addDays(Datetime pointer, Integer days, Id BusinessHourId)
    {
        if(BusinessHourId != null)
        {
            pointer = BusinessHours.nextStartDate(BusinessHourId, pointer);
            for (Integer elapsed = 0; elapsed < days; elapsed++)
            {
                pointer = pointer.addDays(1);
                if (!BusinessHours.isWithin(BusinessHourId, pointer))
                    pointer = BusinessHours.nextStartDate(BusinessHourId, pointer);
            }
        }
        return pointer;
    }
    public Static Integer getAgentHandlingTimeinMinutes(DateTime startTime, DateTime endTime)
    {
        Long noOfWeekends = CalcNoOfWeekends(startTime,endTime);
        datetime start = startTime;
        datetime later = endTime;

        decimal millisecs = decimal.valueOf(later.getTime() - start.getTime());
        Integer seconds = Integer.valueOf(millisecs/1000);
        
        return seconds/60;
    }
    public static String calculateTimeDiffinString(DateTime startTime, DateTime endTime)
    {
        //get correct start date
        Long noOfWeekends = CalcNoOfWeekends(startTime,endTime);
        datetime start = startTime;
        datetime later = endTime;

        decimal millisecs = decimal.valueOf(later.getTime() - start.getTime());
        //millisecs = millisecs - decimal.valueOf(noOfWeekends);
        decimal dDays = millisecs/1000/60/60/24;
        integer iDays = integer.valueOF(math.floor(dDays));
        decimal remainderDays = dDays- iDays;

        decimal dHours = remainderDays * 24;
        integer iHours = integer.valueOf(math.floor(dHours));
        decimal remainderHours = dHours - iHours;

        decimal dMinutes = remainderHours * 60;
        integer iMinutes = integer.valueOf(math.floor(dMinutes));
        decimal remainderMinutes = dMinutes - iMinutes;

        decimal dSeconds = remainderMinutes * 60;
        integer iSeconds = integer.valueOf(math.floor(dSeconds));
        decimal remainderSeconds = dSeconds - iSeconds;

        String timeDiff= iDays+':'+iHours+':'+ iMinutes+':'+iSeconds;
        return timeDiff;
    }
    public static Long calcNoOfWeekends(Datetime startDate, Datetime endDate) {
        Integer i = 0;
        while (startDate < endDate) {
            if (startDate.format('E') == 'Sat' || startDate.format('E') == 'Sun') {
                i++;
            }
            startDate = startDate.addDays(1);
        }
        return i*24*60*60*1000;
    }
	
	/**************************************************
    @Author: Tanaya Chanda
    @Date: 29/08/23
    @purpose: To calculate days between two dates.
    ***************************************************/
    public static Integer daysBetween(Id businessHoursId, Datetime startDate, Datetime endDate) {

        Long diffMilliSec = BusinessHours.diff(businessHoursId, startDate, endDate);
        return (Integer) (diffMilliSec / MILLISECONDS_IN_A_DAY); // Convert millis to days

    }

    /**************************************************
    @Author: Rajat Kumar Mishra
    @Date: 26/09/23
    @purpose: To find that specific date occurs within business hours. 
    ***************************************************/
    
    public static Boolean isBusinessDay(String businessHoursId, Datetime targetDate){
        
        // Find whether the time is within the default business hours
        Boolean isWithin= BusinessHours.isWithin(businessHoursId, targetDate);
		return isWithin;
    }
    
}
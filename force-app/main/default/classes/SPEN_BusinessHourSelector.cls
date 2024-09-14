public class SPEN_BusinessHourSelector {
	public static List<BusinessHours> getBusinessHrs(Set<String> setBhNames)
    {
        List<BusinessHours> lstBusinessHour = new List<BusinessHours>();
        if(!setBhNames.isEmpty())
            lstBusinessHour =   [SELECT ID,name 
                        FROM BusinessHours 
                        WHERE name IN : setBhNames AND isActive = true];
        return lstBusinessHour;
    }
    //Code Implementation starts here. User Story : CRMD-5762. Date : 06/14/2023. Developer : sheker
    public static BusinessHours getConBusinessHrs()
    {
        BusinessHours bhs = new BusinessHours();
        bhs =   [SELECT Id,Name 
                 FROM BusinessHours 
                 WHERE Name ='Connection Business Hours' AND isActive = true //WITH SECURITY_ENFORCED //201
                 ];
        return bhs;
    }
    //Code Implementation ends here. User Story : CRMD-5762. Date : 06/14/2023. Developer : sheker
}
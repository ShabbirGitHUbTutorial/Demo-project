/**
 * @description  A utility class for all the batches and schedulable classes 
 */
public class SPEN_BatchUtil {
    /**
    * @description  Use this method to schedule a class having settings configured in Batch Settings 
   */
    public static void scheduleBatch (String jobName, String schedulableClassName){
		//Get batch setting for the schedulable class passed as the parameter
		List<SPEN_BatchSettings__mdt> batchSettings = getBatchSettings(schedulableClassName);
		if(batchSettings.isEmpty()){
			throw new UtilException('No records found for this class in Batch Settings custom metadata');
		}
		else
		{
		//Create an instance of the Schedulable Class
		Type t = Type.forName(schedulableClassName); 
		Schedulable classInstance = (Schedulable) t.newInstance(); 
		//Schedule the batch using schedule method of System class
		system.schedule(jobName , batchSettings[0].SPEN_CronExpression__c, classInstance);
		}
    }
    /**
    * @description  Use this method to schedule a class with a particular cron expression 
   */
    public static void scheduleBatchWithCron (String jobName, String schedulableClassName, String cron){
		//Create an instance of the Schedulable Class
		Type t = Type.forName(schedulableClassName); 
		Schedulable classInstance = (Schedulable) t.newInstance(); 		
		system.schedule(jobName, cron, classInstance);		
    }	
    /**
    * @description  Use this method to get Batch Setting records for a particular batch class
   */	
    public static List<SPEN_BatchSettings__mdt> getBatchSettings(String apiName) {
        return [SELECT Id, SPEN_CronExpression__c, SPEN_BatchSize__c
                FROM SPEN_BatchSettings__mdt WHERE QualifiedApiName =:apiName];
    }
    /**
    * @description  Inner class to be used for custom exceptions
   */	
	class UtilEXception extends Exception{
	}
}
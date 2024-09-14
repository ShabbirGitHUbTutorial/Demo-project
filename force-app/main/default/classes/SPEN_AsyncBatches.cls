/*-----------------------------------------------------------------------------
DESCRIPTION	:	Domain class to trigger Async Batch Processes.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
FEB-13-2023		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public with sharing class SPEN_AsyncBatches 
{
	@TestVisible
	private Boolean allowBatchDML = true;

	/**
	 * @description CONSTANTS
	 */
	public final static String ACTION_ADQM = 'Start ADQM Sync Process';

	
	/**
	 * @description BUSINESS LOGIC VARIABLES
	 */
	@TestVisible
	List<SEL_Batch__c> batches = new List<SEL_Batch__c>();

	/**
	 * @description Create Batch records. 
	 * 
	 * IMPORTANT: While this method was written to process bulkified requests; 
	 * 			  it is recommended to keep the batch size low to avoid performance issues.
	 */
    
	public void afterInsert(List<SPEN_AsyncBatch__e> requests)
	{
        List<SEL_Batch__c> lstBatch = new SEL_BatchesSelector().getTodaysBatchRecord();
        SEL_Batch__c existingBatch;
        if(lstBatch != null && !lstBatch.isEmpty())
            existingBatch = lstBatch[0];
        if(requests != null && !requests.isEmpty())
		{
			for(SPEN_AsyncBatch__e r : requests)
			{
				if(r?.SPEN_Action__c.equalsIgnoreCase(SPEN_AsyncBatches.ACTION_ADQM))
				{
                    if(existingBatch == null)
                    {
                        SEL_Batch__c b = new SEL_Batch__c();
                        b.SEL_BatchTemplate__c = SEL_BatchConstants.BATCH_TEMPLATE_ADQM_DELTA_SYNC;
                        b.SEL_Status__c = SEL_BatchConstants.STATUS_NOT_STARTED;
                        b.SPEN_AdqmLoadDate__c = System.today();
                        batches.add(b);
                    }
                    else {
                        existingBatch.SEL_Status__c = SEL_BatchConstants.STATUS_PROCESSING;
                    }
				}
			}
		}

		// RULE
		// Create batch records only if its not empty
		if(!batches.isEmpty() && this.allowBatchDML && Schema.sObjectType.SEL_Batch__c.isCreateable())
		{
			insert batches;
		}
        if(existingBatch != null)
        {
            update existingBatch;
        }
	}
}
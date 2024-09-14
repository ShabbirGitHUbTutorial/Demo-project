public with sharing class SPEN_AsyncFutures {
	
	/**
	 * @description CONSTANTS
	 */
	public final static String ACTION_MERGE = 'Incident Merge';
	public final static String ACTION_DELOG = 'Incident Delog';
	public final static String ACTION_ERTCHANGE = 'Incident ERTChange';
	public final static String ACTION_DROPCHANGE = 'Incident DROPChange';

	/**
	 * @description BUSINESS LOGIC VARIABLES
	 */
	@TestVisible
	List<String> incidentsToBeMerged = new List<String>();
	@TestVisible
	List<String> incidentsToBeDelogged = new List<String>();
	@TestVisible
	List<String> incidentsERTChanged = new List<String>();
	@TestVisible
	List<String> incidentsDROPChanged = new List<String>();

	/**
	 * @description Create Batch records. 
	 * 
	 * IMPORTANT: While this method was written to process bulkified requests; 
	 * 			  it is recommended to keep the batch size low to avoid performance issues.
	 */
	public void afterInsert(List<SPEN_AsyncFuture__e> requests)
	{
		if(requests != null && !requests.isEmpty())
		{
			for(SPEN_AsyncFuture__e r : requests)
			{
				if(r?.SPEN_Action__c.equalsIgnoreCase(SPEN_AsyncFutures.ACTION_MERGE))
				{
					incidentsToBeMerged.addAll((r.SPEN_RecordIds__c).split(','));
				}
				else if(r?.SPEN_Action__c.equalsIgnoreCase(SPEN_AsyncFutures.ACTION_DELOG))
				{
					incidentsToBeDelogged.addAll((r.SPEN_RecordIds__c).split(','));
				}
				else if(r?.SPEN_Action__c.equalsIgnoreCase(SPEN_AsyncFutures.ACTION_ERTCHANGE))
				{
					incidentsERTChanged.addAll((r.SPEN_RecordIds__c).split(','));
				}
				else if(r?.SPEN_Action__c.equalsIgnoreCase(SPEN_AsyncFutures.ACTION_DROPCHANGE))
				{
					incidentsDROPChanged.addAll((r.SPEN_RecordIds__c).split(','));
				}
			}
			//Below future method is called to drop all the outbound dialler records
			if(!incidentsToBeMerged.isEmpty()){
				SPEN_OutboundDialerService.dropOlderODTasksOnMerge(incidentsToBeMerged);
			}
			if(!incidentsToBeDelogged.isEmpty()){
				SPEN_OutboundDialerService.dropOlderODTasksOnDelog(incidentsToBeDelogged);
			}
			if(!incidentsERTChanged.isEmpty()){
				SPEN_OutboundDialerService.dropComfortODTasksOnERTChange(incidentsERTChanged);
			}
			if(!incidentsDROPChanged.isEmpty()){
				SPEN_OutboundDialerService.dropODTasksOnDROPChange(incidentsDROPChanged);
			}
		}
	}
}
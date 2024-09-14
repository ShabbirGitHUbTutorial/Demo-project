/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SPEN_AsyncBatches Domain class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	SPEN
VERSION		:	1.0

Time (MS)		Method
32				afterInsert
-----------------------------------------------------------------------------*/
@IsTest(isParallel = true)
public without sharing class SPEN_AsyncBatches_TEST 
{
	@IsTest
	private static void afterInsert() 
	{
		Test.startTest();

		// DATA
		List<SPEN_AsyncBatch__e> dataset1 = new List<SPEN_AsyncBatch__e> { new SPEN_AsyncBatch__e(SPEN_Action__c = 'MACJULESTESTACTION') };
		List<SPEN_AsyncBatch__e> dataset2 = new List<SPEN_AsyncBatch__e> { new SPEN_AsyncBatch__e(SPEN_Action__c = SPEN_AsyncBatches.ACTION_ADQM) };

		// SCENARIO 1
		// Pass null events
		SPEN_AsyncBatches domain1 = new SPEN_AsyncBatches();
		domain1.afterInsert(null);
		Assert.isTrue(domain1.batches.size() == 0, 'The batch list must be empty if the parameter is null');
		
		// SCENARIO 2
		// Pass empty collection
		SPEN_AsyncBatches domain2 = new SPEN_AsyncBatches();
		domain2.afterInsert(new List<SPEN_AsyncBatch__e>());
		Assert.isTrue(domain2.batches.size() == 0, 'The batch list must be empty if the parameter is null');

		// SCENARIO 3
		// Pass events with unknown Action values
		SPEN_AsyncBatches domain3 = new SPEN_AsyncBatches();
		domain3.afterInsert(dataset1);
		Assert.isTrue(domain3.batches.size() == 0, 'The batch list must be empty if the parameter is null');

		// SCENARIO 4
		// Pass valid event
		SPEN_AsyncBatches domain4 = new SPEN_AsyncBatches();
		domain4.allowBatchDML = false;
		domain4.afterInsert(dataset2);
		Assert.isTrue(domain4.batches.size() == 1, 'The batch list must have one value');
		Assert.isTrue(domain4.batches[0].SPEN_AdqmLoadDate__c == System.today(), 'The batch ADQM Load Date must be equal to today');

		Test.stopTest();
	}
}
/*-----------------------------------------------------------------------------
DESCRIPTION	:	Constants class of the Batch Framework.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-23-2021		Macjules Sevilla	Initial version
FEB-13-2023		Macjules Sevilla	Added Batch Template value for ADQM Delta
-----------------------------------------------------------------------------*/
public without sharing class SEL_BatchConstants 
{
	public static final String STATUS_COMPLETED = 'Completed';
	public static final String STATUS_FAILED = 'Failed';
	public static final String STATUS_NOT_STARTED = 'Not Started';
	public static final String STATUS_PROCESSING = 'Processing';
    
	// BUSINESS SPECIFIC
	public final static String BATCH_TEMPLATE_ADQM_DELTA_SYNC = 'ADQM Delta Sync';

	
	public static void getUnitTest()
    {
        //system.debug('For Code Coverage');
		Boolean isTest=true;
    }
}
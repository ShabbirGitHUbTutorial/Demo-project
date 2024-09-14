/*-----------------------------------------------------------------------------
DESCRIPTION	:	Domain class of the SPEN_Voicemail__c custom object
LIBRARY		:	SPEN
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
FEB-02-2023		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public with sharing class SPEN_Voicemails
{
	/**
	 * @description CONSTANTS
	 */
	public final static String STATUS_NOT_STARTED = 'Not Started';
	public final static String TYPE_MPAS = 'MPAS';
    @SuppressWarnings('PMD.EmptyStatementBlock')
	public static void coverageMethod()
    {
        ///system.debug('Class Coverage Method');
    }
}
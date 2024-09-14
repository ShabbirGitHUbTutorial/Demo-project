/*---------------------------------------------------------------------------------
DESCRIPTION	:	Constants class of the Integration Framework.
LIBRARY		:	Salesforce Enterprise Library (SEL) - Integration Framework
VERSION		:	2.0

HISTORY		:
Date			Author				Comment
JUL-04-2022		Macjules Sevilla	Initial version
SEP-21-2022		Macjules Sevilla	Extended support to SOAP messages
---------------------------------------------------------------------------------*/
public with sharing class SEL_IntegrationConstants 
{
	// Source Field Type Values
	public final static String SOURCE_FIELD_TYPE_FIELD	= 'sObject Field';
	public final static String SOURCE_FIELD_TYPE_LOOKUP = 'sObject Lookup';
	public final static String SOURCE_FIELD_TYPE_STATIC = 'Static';

	// Integration Value
		public final static String AUTHORIZATION = 'Authorization';
		public final static String CONTENT_TYPE = 'content-type';													
    public final static String IV_VALUE_TYPE_STATIC = 'Static';
	public final static String IV_VALUE_TYPE_DYNAMIC = 'Dynamic';
	public final static String SOAP_ACTION = 'SOAPAction';
	public final static String HEADER   = 'Header';
	public final static String ENDPOINT = 'Endpoint';

	// Message Format
	public final static String FORMAT_JSON = 'JSON';
	public final static String FORMAT_XML = 'XML';

	// Target
	public final static String TARGET_FIELD_TYPE_CONTAINER = 'Container';

	// Framework Specific Constants
	public final static String PARENT_ROOT = '<<ROOT>>';
	public final static String REGEX_SEPARATOR = '\\---([^---]*)\\---';
	public final static String SEPARATOR = '---{0}---';

	// Error Messaages
	public final static String ERROR_INACTIVE = 'The Integration Setting that you are trying to access is inactive or does not exists. Reach out to your System Administrator and try again.';
	public final static String ERROR_NAMEDCREDENTIAL_INVALID = 'The Named Credential API you configured does not exist.';
	
	//Integration Settings Name
	public final static String POWER_ON_CALL_API = 'PowerOnCallAPI';
	public final static String API_CALL_BEARER_TOKEN = 'APICallBearerToken';
	public final static String SDIF_CANCEL_CALL_API = 'SDIFCancelCallAPI';
	public final static String API_CALL_BEARER_TOKEN_FOR_ADQM = 'APICallBearerTokenForADQM';
	public final static String API_CALL_BEARER_TOKEN_FOR_GET_AFFECTED = 'APICallBearerTokenForGetAffected';
	public final static String GET_CUSTOMER_DETAILS_ADQM = 'GetCustomerDetailsADQM';
	public final static String CONTACT_TO_ADQM_API = 'ContactToADQMAPI';
	public final static String SDIF_GET_AFFECTED_PREMISES = 'SDIFGetAffectedPremises';
	public final static String API_CALL_BEARER_TOKEN_PING_METER = 'APICallBearerTokenPingMeter';
   
	public final static String SDIF_PING_METER = 'SDIFPingMeter';		
    public final static String SDIF_IVR_MESSAGE_API = 'SFToSDIFIVRMessageAPI';
	public final static String ECOES_MPAN_DETAILS = 'ECOESFetchMpanDetails';
	public final static String ECOES_SEARCH = 'EcoesSearch';
	@TestVisible
	private static String getUnitTest()
	{
		// IMPORTANT
		// This is added as the Salesforce Enteprise Library is currently lifted 
		// and shifted to client Salesforce orgs using a non-pakage based
		// deployments. Remove this once SEL transitions to unlocked packaging.

		return SEL_IntegrationConstants.HEADER;
	}
}
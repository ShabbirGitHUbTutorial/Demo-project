/*-----------------------------------------------------------------------------
DESCRIPTION	:	Selector class of the SEL_IntegrationSetting__mdt CMT.
LIBRARY		:	Salesforce Enterprise Library (SEL) - Integration Framework
VERSION		:	2.0
METHODS		:	+ selectByDeveloperName(String name)
HISTORY		:
Date			Author				Comment
JUN-09-2022		Macjules Sevilla	Initial version
SEP-21-2022		Macjules Sevilla	Extended support to SOAP messages
SEP-25-2022		Macjules Sevilla	Readded link to Data Mocks
-----------------------------------------------------------------------------*/
public inherited sharing class SEL_IntegrationsSelector 
{
	@TestVisible
	Boolean bypassParameterCheck = false;

	// USAGE
	// Returns the SEL_Integration__mdt record along it any related:
	// [1] Integration Values (covers both endpoint extension and header values)
	// [2] Message Body
	// [3] Data Mocks
	public SEL_IntegrationSetting__mdt selectByDeveloperName(String name) 
	{
		List<SEL_IntegrationSetting__mdt> r = new List<SEL_IntegrationSetting__mdt>();

		if(String.isNotBlank(name) || this.bypassParameterCheck)
		{
			r = [SELECT SEL_BaseObjectApi__c,
						SEL_ClientCertificate__c,
						SEL_EndpointExtension__c,
						SEL_HttpMethod__c,
						SEL_IsCompressed__c, 
						SEL_IsMockingEnabled__c, 
						SEL_IsActive__c,
						SEL_MessageFormat__c,
						SEL_NamedCredentials__c,
						SEL_Timeout__c,
						SEL_IntegrationDataMockId__r.SEL_Body__c,
						SEL_IntegrationDataMockId__r.SEL_Header__c,
						SEL_IntegrationDataMockId__r.SEL_StatusCode__c,
						SEL_IntegrationDataMockId__r.SEL_Status__c,
						(SELECT SEL_SourceObject__c, SEL_SourceField__c, SEL_SourceFieldType__c, SEL_TargetFieldLabel__c, SEL_TargetFieldType__c, SEL_TargetParentNode__c, SEL_TagretFieldCollectionItem__c,SPEN_XMLNamespace__c,SEL_Order__c FROM SEL_IntegrationMessages__r WHERE SEL_IsActive__c = true ORDER BY SEL_Order__c ASC),
						(SELECT SEL_Key__c, SEL_Value__c, SEL_Type__c,SEL_SourceValueType__c FROM SEL_IntegrationValues__r WHERE SEL_IsActive__c = true)
				 FROM   SEL_IntegrationSetting__mdt
				 WHERE  DeveloperName =: name
				 WITH   SECURITY_ENFORCED];
		}

		return r.size() == 0 ? new SEL_IntegrationSetting__mdt() : r[0];
	}
}
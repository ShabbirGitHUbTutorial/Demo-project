/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class of the SEL_IntegrationsTransformService class.
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Integration Frameworks

Time (MS)		Method
35				constructorNormal
44				constructorError
59				groupMessagesByParent
55				groupValuesByTypeHeader
54				groupValuesByTypeEndPoint
132				generateMessageJson
107				generateMessageXml
97				generateNodeObject
160				generateNodeObjects
99				getNodeValueForTypeString
39				getHeaders
-----------------------------------------------------------------------------*/
@IsTest
public with sharing class SEL_IntegrationsTransformService_TEST 
{
	@IsTest
	private static void constructorNormal() 
	{
		Test.startTest();

		// DATA
		SEL_IntegrationSetting__mdt setting = new SEL_IntegrationSetting__mdt( SEL_IsActive__c = true, SEL_NamedCredentials__c = 'namedCredential', SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_JSON);
		SEL_IntegrationsTransformService service = new SEL_IntegrationsTransformService(setting);
		
		// ASSERT
		System.assert(service.getEndpoint().startsWithIgnoreCase('callout:namedCredential'), 'The generated endpont must start with callout');

		Test.stopTest();
	}

	@IsTest
	private static void constructorError() 
	{
		try 
		{
			// TEST SCENARIO
			SEL_IntegrationsTransformService service = new SEL_IntegrationsTransformService(null);
		} 
		catch (SEL_ConfigurationException ex) 
		{
			// ASSERT
			System.assert(ex.getMessage().equalsIgnoreCase(SEL_IntegrationConstants.ERROR_INACTIVE), 'Passing a null parameter must set the configuration invalid');
		}
	}
	
	@IsTest
	private static void groupMessagesByParent()
	{
		Test.startTest();

		// DATA
		SEL_IntegrationSetting__mdt setting = new SEL_IntegrationSetting__mdt(SEL_BaseObjectApi__c = 'Case', SEL_IsActive__c = true, SEL_NamedCredentials__c = 'namedCredential', SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_JSON);
		SEL_IntegrationsTransformService service = new SEL_IntegrationsTransformService(setting);
		SEL_IntegrationMessage__mdt msg1 = new SEL_IntegrationMessage__mdt( SEL_TargetParentNode__c = 'Case', SEL_SourceObject__c = 'Case');
		SEL_IntegrationMessage__mdt msg2 = new SEL_IntegrationMessage__mdt( SEL_TargetParentNode__c = 'Case', SEL_SourceObject__c = 'Case');
		SEL_IntegrationMessage__mdt msg3 = new SEL_IntegrationMessage__mdt( SEL_TargetParentNode__c = 'Contact', SEL_SourceObject__c = 'Case.Contact');

		// TEST SCENARIO
		// Pass three SEL_IntegrationMessage__mdt with two records having the same parent value
		service.groupMessagesByParent(new List<SEL_IntegrationMessage__mdt> { msg1, msg2, msg3 });
		
		// ASSERT
		System.assert(service.configurationsByGroup.size() == 2, 'There must be two unique groups, Case and Contact');
		System.assert(service.baseObjectApi.equalsIgnoreCase('Case'), 'The based node is Case');

		Test.stopTest();	
	}

	@IsTest
	private static void groupValuesByTypeHeader()
	{
		Test.startTest();

		// DATA
		SEL_IntegrationSetting__mdt setting = new SEL_IntegrationSetting__mdt( SEL_IsActive__c = true, SEL_NamedCredentials__c = 'namedCredential', SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_JSON);
		SEL_IntegrationsTransformService service = new SEL_IntegrationsTransformService(setting);
		SEL_IntegrationValue__mdt staticHeader = new SEL_IntegrationValue__mdt( SEL_Type__c = 'Header', SEL_SourceValueType__c = 'Static', SEL_Key__c = 'H1', SEL_Value__c = 'HeaderTest');
		SEL_IntegrationValue__mdt dynamicHeader = new SEL_IntegrationValue__mdt( SEL_Type__c = 'Header', SEL_SourceValueType__c = 'Dynamic', SEL_Key__c = 'H2', SEL_Value__c = 'HeaderTestDynamic');

		// TEST SCENARIO
		service.groupValuesByType(new List<SEL_IntegrationValue__mdt> { dynamicHeader, staticHeader });

		// ASSERT
		System.assert(service.headerStaticMap.size() == 1, 'There must be one value.');
		System.assert(service.headerStaticMap.containsKey('H1') == true, 'There must be a key = H1');
		System.assert(service.headerStaticMap.get('H1').equalsIgnoreCase('HeaderTest') == true, 'The value must be HeaderTest');
		System.assert(service.headerDynamicMap.size() == 1, 'There must be one value.');
		System.assert(service.headerDynamicMap.containsKey('H2') == true, 'There must be a key = H2');
		System.assert(service.headerDynamicMap.get('H2').equalsIgnoreCase('HeaderTestDynamic') == true, 'The value must be HeaderTestDynamic');
		Test.stopTest();	
	}

	@IsTest
	private static void groupValuesByTypeEndPoint()
	{
		Test.startTest();

		// DATA
		SEL_IntegrationSetting__mdt setting = new SEL_IntegrationSetting__mdt( SEL_IsActive__c = true, SEL_NamedCredentials__c = 'namedCredential', SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_JSON);
		SEL_IntegrationsTransformService service = new SEL_IntegrationsTransformService(setting);
		SEL_IntegrationValue__mdt staticEndpoint = new SEL_IntegrationValue__mdt( SEL_Type__c = 'Endpoint', SEL_SourceValueType__c = 'Static', SEL_Key__c = 'E1', SEL_Value__c = 'EndpointTest');
		SEL_IntegrationValue__mdt dynamicEndpoint = new SEL_IntegrationValue__mdt( SEL_Type__c = 'Endpoint', SEL_SourceValueType__c = 'Dynamic', SEL_Key__c = 'E2', SEL_Value__c = 'EndpointTestDynamic');


		// TEST SCENARIO
		service.groupValuesByType(new List<SEL_IntegrationValue__mdt> { dynamicEndpoint, staticEndpoint });

		// ASSERT
		System.assert(service.endpointStaticMap.size() == 1, 'There must be one value.');
		System.assert(service.endpointStaticMap.containsKey('E1') == true, 'There must be a key = E1');
		System.assert(service.endpointStaticMap.get('E1').equalsIgnoreCase('EndpointTest') == true, 'The value must be EndpointTest');
		System.assert(service.endpointDynamicMap.size() == 1, 'There must be one value.');
		System.assert(service.endpointDynamicMap.containsKey('E2') == true, 'There must be a key = E2');
		System.assert(service.endpointDynamicMap.get('E2').equalsIgnoreCase('EndpointTestDynamic') == true, 'The value must be EndpointTestDynamic');

		Test.stopTest();	
	}

	@IsTest
	private static void generateMessageJson()
	{
		Test.startTest();

		// DATA
		SEL_IntegrationSetting__mdt setting = new SEL_IntegrationSetting__mdt( SEL_IsActive__c = true, SEL_NamedCredentials__c = 'namedCredential', SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_JSON);
		SEL_IntegrationMessage__mdt msgRequest = new SEL_IntegrationMessage__mdt( 
			SEL_SourceFieldType__c = SEL_IntegrationConstants.SOURCE_FIELD_TYPE_STATIC, 
			SEL_TargetFieldLabel__c = 'request', 
			SEL_TargetFieldType__c = 'Container',
			SEL_TargetParentNode__c = '<<ROOT>>'
		);
		SEL_IntegrationMessage__mdt msg = new SEL_IntegrationMessage__mdt(
			SEL_SourceObject__c = 'User',
			SEL_SourceField__c = 'Name', 
			SEL_SourceFieldType__c = SEL_IntegrationConstants.SOURCE_FIELD_TYPE_STATIC, 
			SEL_TargetFieldLabel__c = 'runningUser', 
			SEL_TargetFieldType__c = 'String',
			SEL_TargetParentNode__c = 'request'
		);
		User paramRecord = SEL_UsersSelector.getCurrentUser();

		// TEST
		SEL_IntegrationsTransformService service = new SEL_IntegrationsTransformService(setting);
		service.groupMessagesByParent(new List<SEL_IntegrationMessage__mdt> { msgRequest, msg });
		
		// ASSERT
		System.assert(service.generateMessage(paramRecord).endsWithIgnoreCase('{"request":{"runningUser":"Name"}}'), 'The return message must be in JSON');

		Test.stopTest();
	}

	@IsTest
	private static void generateMessageXml()
	{
		Test.startTest();

		// DATA
		SEL_IntegrationSetting__mdt setting = new SEL_IntegrationSetting__mdt( SEL_IsActive__c = true, SEL_NamedCredentials__c = 'namedCredential', SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_XML);
		SEL_IntegrationMessage__mdt msgRequest = new SEL_IntegrationMessage__mdt( 
			SEL_SourceFieldType__c = SEL_IntegrationConstants.SOURCE_FIELD_TYPE_STATIC, 
			SEL_TargetFieldLabel__c = 'request', 
			SEL_TargetFieldType__c = 'Container',
			SEL_TargetParentNode__c = '<<ROOT>>'
		);
		SEL_IntegrationMessage__mdt msg = new SEL_IntegrationMessage__mdt(
			SEL_SourceObject__c = 'User',
			SEL_SourceField__c = 'Name', 
			SEL_SourceFieldType__c = SEL_IntegrationConstants.SOURCE_FIELD_TYPE_STATIC, 
			SEL_TargetFieldLabel__c = 'runningUser', 
			SEL_TargetFieldType__c = 'String',
			SEL_TargetParentNode__c = 'request'
		);
		User paramRecord = SEL_UsersSelector.getCurrentUser();

		// TEST
		SEL_IntegrationsTransformService service = new SEL_IntegrationsTransformService(setting);
		service.groupMessagesByParent(new List<SEL_IntegrationMessage__mdt> { msgRequest, msg });
		
		// ASSERT
		System.assert(service.generateMessage(paramRecord).endsWithIgnoreCase('<request><runningUser>Name</runningUser></request>'), 'The return message must be in XML');

		Test.stopTest();
	}

	@IsTest
	private static void generateNodeObject()
	{
		Test.startTest();

		// DATA
		SEL_IntegrationSetting__mdt setting = new SEL_IntegrationSetting__mdt( SEL_IsActive__c = true, SEL_NamedCredentials__c = 'namedCredential', SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_JSON);
		SEL_IntegrationMessage__mdt msg = new SEL_IntegrationMessage__mdt(
			SEL_SourceObject__c = 'user',
			SEL_SourceField__c = 'Name', 
			SEL_SourceFieldType__c = SEL_IntegrationConstants.SOURCE_FIELD_TYPE_FIELD, 
			SEL_TargetFieldLabel__c = 'runningUser', 
			SEL_TargetFieldType__c = 'String'
		);
		SEL_IntegrationsTransformService service = new SEL_IntegrationsTransformService(setting);
		User paramRecord = SEL_UsersSelector.getCurrentUser();

		// ASSERT
		// Generate JSON
		System.assert(service.generateNode(new List<SEL_IntegrationMessage__mdt> { msg }, SEL_IntegrationConstants.FORMAT_JSON, paramRecord, false).equalsIgnoreCase('\"runningUser\":\"' + paramRecord.Name + '\"'), 'The node label and value must be in JSON format.');

		// ASSERT
		// Generate XML
		System.assert(service.generateNode(new List<SEL_IntegrationMessage__mdt> { msg }, SEL_IntegrationConstants.FORMAT_XML, paramRecord, false).equalsIgnoreCase('<runningUser>' + paramRecord.Name + '</runningUser>'), 'The node label and value must be in XML format.');
		
		// ASSERT
		// Generate BLANK
		System.assert(String.isBlank(service.generateNode(null, SEL_IntegrationConstants.FORMAT_JSON, paramRecord, false)), 'The node label and value must be BLANK.');

		Test.stopTest();
	}

	@IsTest
	private static void generateNodeObjects()
	{
		Test.startTest();

		// DATA
		SEL_IntegrationSetting__mdt setting = new SEL_IntegrationSetting__mdt( 
			SEL_BaseObjectApi__c = 'User',
			SEL_IsActive__c = true, 
			SEL_NamedCredentials__c = 'namedCredential', 
			SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_JSON);
		SEL_IntegrationMessage__mdt msg = new SEL_IntegrationMessage__mdt(
			SEL_SourceObject__c = 'User',
			SEL_SourceField__c = 'Name', 
			SEL_SourceFieldType__c = SEL_IntegrationConstants.SOURCE_FIELD_TYPE_FIELD, 
			SEL_TargetParentNode__c = '<<ROOT>>',
			SEL_TargetFieldLabel__c = 'user', 
			SEL_TargetFieldType__c = 'String',
			SEL_TagretFieldCollectionItem__c = 'users',
			SEL_IsActive__c = true
		);
		User paramRecord = SEL_UsersSelector.getCurrentUser();

		// ASSERT
		// Generate JSON
		SEL_IntegrationsTransformService service1 = new SEL_IntegrationsTransformService(setting);
		String expectedJSON = '[{\"user\":\"' + paramRecord.Name + '\"}]';
		String resultJSON = service1.generateNode(new List<SEL_IntegrationMessage__mdt> { msg }, SEL_IntegrationConstants.FORMAT_JSON, new List<SObject> { paramRecord }, false);
		System.assert(resultJSON.equalsIgnoreCase(expectedJSON), 'The node label and value must be a JSON collection.');

		// ASSERT
		// Generate XML
		setting.SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_XML;
		SEL_IntegrationsTransformService service2 = new SEL_IntegrationsTransformService(setting);
		String expectedXML = '<users><user>' + paramRecord.Name + '</user></users>';
		String resultXML = service2.generateNode(new List<SEL_IntegrationMessage__mdt> { msg }, SEL_IntegrationConstants.FORMAT_XML, new List<SObject> { paramRecord }, false);
		System.assert(resultXML.equalsIgnoreCase(expectedXML), 'The node label and value must be an XML collection.');

		// ASSERT
		// Generate BLANK
		String resultBlank = service2.generateNode(null, SEL_IntegrationConstants.FORMAT_XML, new List<SObject> { paramRecord, paramRecord }, false);
		System.assert(String.isBlank(resultBlank), 'The node label and value must be BLANK.');

		Test.stopTest();
	}

	@IsTest
	private static void getNodeValueForTypeString()
	{
		Test.startTest();

		// DATA
		SEL_IntegrationMessage__mdt msg1 = new SEL_IntegrationMessage__mdt(SEL_SourceFieldType__c = SEL_IntegrationConstants.SOURCE_FIELD_TYPE_STATIC, SEL_TargetFieldType__c = 'String', SEL_SourceField__c = 'Name');
		SEL_IntegrationMessage__mdt msg2 = new SEL_IntegrationMessage__mdt(SEL_SourceFieldType__c = SEL_IntegrationConstants.SOURCE_FIELD_TYPE_FIELD , SEL_TargetFieldType__c = 'String', SEL_SourceField__c = 'Name');
		SEL_IntegrationMessage__mdt msg3 = new SEL_IntegrationMessage__mdt(SEL_SourceFieldType__c = SEL_IntegrationConstants.SOURCE_FIELD_TYPE_LOOKUP, SEL_TargetFieldType__c = 'String', SEL_SourceField__c = 'Profile.Name');
		SEL_IntegrationMessage__mdt msg4 = new SEL_IntegrationMessage__mdt(SEL_SourceFieldType__c = SEL_IntegrationConstants.SOURCE_FIELD_TYPE_LOOKUP, SEL_TargetFieldType__c = 'Container', SEL_SourceField__c = 'Profile.Name', SEL_TargetFieldLabel__c = 'Profiles');
		User u = SEL_UsersSelector.getCurrentUser();

		// ASSERT
		// String + Static Combination
		System.assert(SEL_IntegrationsTransformService.getNodeValue(msg1, SEL_IntegrationConstants.FORMAT_JSON, null).equalsIgnoreCase('\"Name\"'), 'String + Static combination must return \"Name\" value');

		// ASSERT
		// Static + sObject Field Combination
		System.assert(SEL_IntegrationsTransformService.getNodeValue(msg2, SEL_IntegrationConstants.FORMAT_JSON, u).equalsIgnoreCase('\"' + u.Name + '\"'), 'String + sObject Field combination must return the current users name.');	

		// ASSERT
		// Static + sObject Lookup Combination
		System.assert(SEL_IntegrationsTransformService.getNodeValue(msg3, SEL_IntegrationConstants.FORMAT_JSON, u).equalsIgnoreCase('\"' + u.Profile.Name + '\"'), 'String + sObject Lookup combination must return the current users profile.');	

		// ASSERT
		// Static + sObject Lookup + Container Combination
		System.assert(SEL_IntegrationsTransformService.getNodeValue(msg4, SEL_IntegrationConstants.FORMAT_JSON, u).equalsIgnoreCase('---Profiles---'), 'The container label must be enclosed with --- characters.');

		Test.stopTest();
	}
   
	@isTest
	private static void getHeaders()
	{
		Test.startTest();

        // DATA
		SEL_IntegrationSetting__mdt setting = new SEL_IntegrationSetting__mdt(
			SEL_EndpointExtension__c = '/services/{record}/create/{var1}',
			SEL_HttpMethod__c = 'Post', 
			SEL_IsActive__c = true,
			SEL_IsCompressed__c = false,
			SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_JSON,
			SEL_NamedCredentials__c = 'Salesforce'
		);
		SEL_IntegrationValue__mdt val1 = new SEL_IntegrationValue__mdt(SEL_Key__c = 'Accept', SEL_Value__c = 'application/json', SEL_Type__c = 'Header', SEL_SourceValueType__c = 'Static' );
		SEL_IntegrationValue__mdt val2 = new SEL_IntegrationValue__mdt(SEL_Key__c = 'Idempotency-Key', SEL_Value__c = '', SEL_Type__c = 'Header', SEL_SourceValueType__c = 'Dynamic' );
		SEL_IntegrationsTransformService service = new SEL_IntegrationsTransformService(setting);
		service.groupValuesByType(new List<SEL_IntegrationValue__mdt> {val1 , val2});
		
		// TEST
		Map<String,String> headerMap = service.getHeaders(new Map<String,String>{ 'Idempotency-Key' => 'importantKey', 'connection' => 'keep-alive'});

		// ASSERT
		// Using Static header
        system.assert(service.getHeaders().get('Accept').equalsIgnoreCase('application/json'), 'The result must by application/json.');

        // ASSERT
		// Using Dynamic Header
		system.assert(headerMap.get('Idempotency-Key').equalsIgnoreCase('importantKey'), 'The value of dynamic header must be "importantKey".');

        // ASSERT
		// Using Invalid Header 
		system.assert(headerMap.size() == 2, 'There must be only 2 headers.');

		Test.stopTest();
	}

	@isTest
	private static void getEndpoint()
	{
		Test.startTest();

		// DATA
		SEL_IntegrationSetting__mdt setting = new SEL_IntegrationSetting__mdt(
			SEL_EndpointExtension__c = '/services/{record}/create/{var1}',
			SEL_HttpMethod__c = 'Get', 
			SEL_IsActive__c = true, 
			SEL_IsCompressed__c = false,
			SEL_MessageFormat__c = SEL_IntegrationConstants.FORMAT_JSON,
			SEL_NamedCredentials__c = 'Salesforce'
		);
		SEL_IntegrationValue__mdt val1 = new SEL_IntegrationValue__mdt( SEL_Key__c = 'var1',  SEL_Value__c = '324',  SEL_Type__c = 'Endpoint', SEL_SourceValueType__c = 'Static' );
		SEL_IntegrationValue__mdt val2 = new SEL_IntegrationValue__mdt( SEL_Key__c = 'record',  SEL_Value__c = '',  SEL_Type__c = 'Endpoint', SEL_SourceValueType__c = 'Dynamic' );
		SEL_IntegrationsTransformService service = new SEL_IntegrationsTransformService(setting);
		service.groupValuesByType(new List<SEL_IntegrationValue__mdt> {val1 , val2});
		
		// TEST
		// Using Static Endpoint
		String ep = service.getEndpoint();
		System.assert(ep.equalsIgnoreCase('callout:Salesforce/services/{record}/create/324'), 'The endpoint must match.');

		// TEST 
		// Dynamic Endpoint
		ep = service.getEndpoint(new Map<String, String>{ 'record' => 'testRecord' });
		System.assert(ep.equalsIgnoreCase('callout:Salesforce/services/testRecord/create/324'), 'The Endpint should contain record value');
		
		Test.stopTest();
	}
}
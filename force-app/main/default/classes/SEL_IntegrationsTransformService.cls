/*---------------------------------------------------------------------------------
DESCRIPTION	:	Transformation class specific to Integration rules and limitations.
LIBRARY		:	Salesforce Enterprise Library (SEL) - Integration Framework
VERSION		:	1.0
AUTHORS		:	Macjules Sevilla
				Kuldeep Parihar
				Ritidipa Mahanta
				Joe Allcock
METHODS		:	+ generateMessage(SObject source)
				+ getHeaders()
				+ getHeaders(Map<String , String> overrideData)
				+ getEndpoint()
				+ getEndpoint(Map<String , String> overrideData)
HISTORY		:
Date			Author				Comment
JUN-12-2022		Macjules Sevilla	Initial version
SEP-21-2022		Macjules Sevilla	Extended support to SOAP messages
---------------------------------------------------------------------------------*/
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class SEL_IntegrationsTransformService 
{
	@TestVisible
	private Boolean isMessageConfigurationValid = false;
	@TestVisible
	private String baseObjectApi = null;
	@TestVisible
	private String endpointUrl = null;
	@TestVisible
	private String messageFormat = null;
	@TestVisible
	private Map<String, List<SEL_IntegrationMessage__mdt>> configurationsByGroup = new Map<String, List<SEL_IntegrationMessage__mdt>>();
	@TestVisible
	private Map<String,String> headerStaticMap = new Map<String, String>();
	@TestVisible
	private Map<String,String> headerDynamicMap = new Map<String, String>();
	@TestVisible
	private Map<String,String> endpointStaticMap = new Map<String, String>();
	@TestVisible
	private Map<String,String> endpointDynamicMap = new Map<String, String>();

	// CONSTRUCTOR
	// To use this transform service to generate JSON message
	public SEL_IntegrationsTransformService(SEL_IntegrationSetting__mdt config)
	{
		if(config?.SEL_IsActive__c == true)
		{
			this.endpointUrl = this.endpointUrl = 'callout:' + config.SEL_NamedCredentials__c + (String.isBlank(config?.SEL_EndpointExtension__c) ? '' : config?.SEL_EndpointExtension__c);
			this.baseObjectApi = config.SEL_BaseObjectApi__c;
			this.messageFormat = config.SEL_MessageFormat__c;

			// SET
			// Message body parameters
			this.groupMessagesByParent(config?.SEL_IntegrationMessages__r);

			// SET
			// Headers and endpoint extensions parameters
			this.groupValuesByType(config?.SEL_IntegrationValues__r);
		}
		else 
		{
			// Throw exception
			throw new SEL_ConfigurationException(SEL_IntegrationConstants.ERROR_INACTIVE);
		}
	}

	// USAGE
	// Use this to group messages together by SEL_TargetParentNode__c. This method  
	// was separated from the constructor to add flexbility in unit testing.
	@TestVisible
	private void groupMessagesByParent(List<SEL_IntegrationMessage__mdt> messages)
	{
		if(messages.isEmpty() == false)
		{
			for(SEL_IntegrationMessage__mdt message : messages)
			{
				if(configurationsByGroup.containsKey(message.SEL_TargetParentNode__c))
				{
					configurationsByGroup.get(message.SEL_TargetParentNode__c).add(message);
				}
				else 
				{
					configurationsByGroup.put(message.SEL_TargetParentNode__c, new List<SEL_IntegrationMessage__mdt> { message });
				}
			}
		}
	}

	// USAGE
	// Use this to group values into their respective maps. Values encompass both header
	// and endpoint data, which are further classified as either static or dynamic
	//@TestVisible
	public List<Map<String,String>> groupValuesByType(List<SEL_IntegrationValue__mdt> values)
	{
		List<Map<String,String>> lstMapIntValues = new List<Map<String,String>>();
		if(values.isEmpty() == false)
		{
			for(SEL_IntegrationValue__mdt setting : values)
			{
				if(setting.SEL_Type__c.equalsIgnoreCase(SEL_IntegrationConstants.HEADER))
				{
					if(setting.SEL_SourceValueType__c.equalsIgnoreCase(SEL_IntegrationConstants.IV_VALUE_TYPE_STATIC))
					{
						headerStaticMap.put(setting.SEL_Key__c, setting.SEL_Value__c);						
					}
					else if(setting.SEL_SourceValueType__c.equalsIgnoreCase(SEL_IntegrationConstants.IV_VALUE_TYPE_DYNAMIC))
					{
						headerDynamicMap.put(setting.SEL_Key__c, setting.SEL_Value__c);
					}
				} 
				else if(setting.SEL_Type__c.equalsIgnoreCase(SEL_IntegrationConstants.ENDPOINT))
				{
					if(setting.SEL_SourceValueType__c.equalsIgnoreCase(SEL_IntegrationConstants.IV_VALUE_TYPE_STATIC))
					{
						endpointStaticMap.put(setting.SEL_Key__c, setting.SEL_Value__c);						
					}
					else if(setting.SEL_SourceValueType__c.equalsIgnoreCase(SEL_IntegrationConstants.IV_VALUE_TYPE_DYNAMIC))
					{
						endpointDynamicMap.put(setting.SEL_Key__c, setting.SEL_Value__c);
					}
				}
			}
			if(!headerStaticMap.isEmpty()) lstMapIntValues.add(headerStaticMap);
			if(!headerDynamicMap.isEmpty()) lstMapIntValues.add(headerDynamicMap);
			if(!endpointStaticMap.isEmpty()) lstMapIntValues.add(endpointStaticMap);
			if(!endpointDynamicMap.isEmpty()) lstMapIntValues.add(endpointDynamicMap);
			//System.debug('lstMapIntValues....:' +lstMapIntValues);
		}
		return lstMapIntValues;
	}


	// USAGE
	// Generates the JSON message based on the sObject and the SEL_IntegrationSetting__mdt.
	// The sObject must not be blank.
	@SuppressWarnings('PMD.CognitiveComplexity')
	public String generateMessage(SObject source)
	{
		//List<String> result = new List<String>();
		Map<String, String> nodeByParent = new Map<String, String>();
		String result = '';

		// STEP 1 of 2
		// This block is responsible for generating segments of the XML or JSON nodes 
		if(source != null)
		{
			for(String nodeGroup : configurationsByGroup.keySet())
			{
				String relationship = nodeGroup.removeStartIgnoreCase(this.baseObjectApi + '.');

				// IMPORTANT
				// At the moment, there is no "safe" way of checking if the relationship exists in an sObject 
				// other than thru serialization. Not the most performant approach but will do for now. This also
				// means that empty child relationships expected JSON node will not show up in the absence of records.

				if(JSON.serialize(source).containsIgnoreCase('\"' + relationship + '\"'))
				{
					if(source.getSObjects(relationship) != null)
					{
						nodeByParent.put(nodeGroup, this.generateNode(configurationsByGroup.get(nodeGroup), this.messageFormat, source.getSObjects(relationship), true));
					}
				}
				else
				{
					nodeByParent.put(nodeGroup, this.generateNode(configurationsByGroup.get(nodeGroup), this.messageFormat, source, false));
				}
			}
		}

		// STEP 2 of 2
		// This block is responsible for combining different segments together 
		if(!nodeByParent.isEmpty())
		{
			if(nodeByParent.containsKey(SEL_IntegrationConstants.PARENT_ROOT))
			{
				result = nodeByParent.get(SEL_IntegrationConstants.PARENT_ROOT);
				Set<String> nextMatch = new Set<String>();
				Matcher pm = Pattern.compile(SEL_IntegrationConstants.REGEX_SEPARATOR).matcher(result);
				while (pm.find()) 
				{ 
					nextMatch.add(pm.group(1)); 
				}

				// Construct the message recursively
				result = this.constructMessage(nodeByParent, result, nextMatch, this.messageFormat);
			}
		}
		
		return messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_JSON) ? '{' + result + '}' : result;
	}

	// USAGE
	// Recursively puts together all segments of the message body
	@SuppressWarnings('PMD.CognitiveComplexity, PMD.ExcessiveParameterList')
	private String constructMessage(Map<String, String> nodeByParent, String result, Set<String> matches, String messageFormat)
	{
		for(String match : matches)
		{
			if(nodeByParent.containsKey(match))
			{
				if(messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_XML))
				{
					result = result.replaceAll('---' + match + '---', nodeByParent.get(match));
				}
				else 
				{
					result = result.replaceAll('---' + match + '---', nodeByParent.get(match).left(1).equalsIgnoreCase('[') ? nodeByParent.get(match) : '{' + nodeByParent.get(match) + '}');
				}
			}
			else 
			{
				result = result.replaceAll('---' + match + '---', messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_XML) ? '' : '{}');
			}
		}

		Set<String> nextMatch = new Set<String>();
		Matcher pm = Pattern.compile(SEL_IntegrationConstants.REGEX_SEPARATOR).matcher( result );
		while (pm.find()) 
		{ 
			nextMatch.add(pm.group(1)); 
		}

		if(!nextMatch.isEmpty())
		{
			// NOTE
			// If there are more placeholders that have yet to be populated, then 
			// recursively call the method again.
			result = this.constructMessage(nodeByParent, result, nextMatch, messageFormat);
		}

		return result;
	}

	// USAGE
	// Returns a JSON string containing the node and value fields of a single sObject.
	@TestVisible
	@SuppressWarnings('PMD.ExcessiveParameterList')
	private String generateNode(List<SEL_IntegrationMessage__mdt> messages, String messageFormat, SObject record, Boolean bypassCollectionCheck)
	{
		List<String> result = new List<String>();

		if(messages != null && messages.size() > 0)
		{
			for(SEL_IntegrationMessage__mdt message : messages)
			{
				Boolean isCollection = false;
				Boolean isValid = true;
				if(String.isNotBlank(message?.SEL_SourceObject__c) && message?.SEL_SourceObject__c?.containsAny('.') && String.isNotBlank(message?.SEL_TagretFieldCollectionItem__c)) 
				{
					isCollection = true; 
				}

				if(isCollection && !bypassCollectionCheck && String.isNotBlank(message?.SEL_SourceObject__c))
				{
					// IMPORTANT
					// This logic was added to catch instances wherein relationships 
					// in the submitted data is not present.
					String relationship = message.SEL_SourceObject__c.removeStartIgnoreCase(this.baseObjectApi + '.');
					isValid = JSON.serialize(record).containsIgnoreCase('\"' + relationship + '\"');
				}

				// NOTE
				// Sometimes the record that is passed does not have child 
				if(isValid) 
				{
					if(messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_XML))
					{
                        if(message.SPEN_XMLNamespace__c!= null){
                        result.add('<' + message.SEL_TargetFieldLabel__c + ' ' + message.SPEN_XMLNamespace__c + '>' + SEL_IntegrationsTransformService.getNodeValue(message, messageFormat, record) + '</' + message.SEL_TargetFieldLabel__c + '>');	    
                        }
                        else{
						result.add('<' + message.SEL_TargetFieldLabel__c + '>' + SEL_IntegrationsTransformService.getNodeValue(message, messageFormat, record) + '</' + message.SEL_TargetFieldLabel__c + '>');	
                        }
					}
					else 
					{
						result.add('\"' + message.SEL_TargetFieldLabel__c + '\":' + SEL_IntegrationsTransformService.getNodeValue(message, messageFormat, record));	
					}	
				}
				else 
				{
					if(messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_JSON))
					{
						result.add('[]');
					}
				}
			}
		}

		return result.isEmpty() ? '' : (messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_XML) ? String.join(result, '') : String.join(result, ','));
	}

	// USAGE
	// Returns a JSON string containing the node and value fields from multiple sObjects.
	@TestVisible
	@SuppressWarnings('PMD.CognitiveComplexity, PMD.ExcessiveParameterList')
	private String generateNode(List<SEL_IntegrationMessage__mdt> messages, String messageFormat, List<SObject> records, Boolean bypassCollectionCheck)
	{
		List<String> result = new List<String>();
		String parentNode = '';
		String collectionItemContainer = '';

		if(messages != null && messages.size() > 0 && records != null && records.size() > 0) 
		{
			// COLLECTION NODE
			// Loop through all SEL_IntegrationMessage__mdt in a group and whatever  
			// SEL_TargetParentNode__c is found first, use that as the JSON array node name.
			for(SEL_IntegrationMessage__mdt message : messages)
			{
				if(String.isNotBlank(message.SEL_TargetParentNode__c))
				{
					parentNode = message.SEL_TargetParentNode__c;
					collectionItemContainer = message.SEL_TagretFieldCollectionItem__c;
					break;
				}
			}

			for(sObject record : records)
			{
				if(messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_XML))
				{
					result.add('<' + collectionItemContainer + '>' + this.generateNode(messages, messageFormat, record, true) + '</' + collectionItemContainer + '>');
				}
				else 
				{
					result.add('{' + this.generateNode(messages, messageFormat, record, true) + '}');
				}
			}
		}
		
		return result.isEmpty() ? '' : messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_XML) ? String.join(result, ''): '[' + String.join(result, ',') + ']';
	}

	// USAGE
	// Use to generate the node and value combination
	@TestVisible
	@SuppressWarnings('PMD.CognitiveComplexity')
	private static String getNodeValue(SEL_IntegrationMessage__mdt message, String messageFormat, SObject source)
	{
		String result = '';

		if(message.SEL_TargetFieldType__c.equalsIgnoreCase(SEL_IntegrationConstants.TARGET_FIELD_TYPE_CONTAINER))
		{
			// NOTE
			// Container values are treated the same way regardless on the Field Type
			result += '---' + message.SEL_TargetFieldLabel__c + '---';
		}
		else if(message.SEL_SourceFieldType__c.equalsIgnoreCase(SEL_IntegrationConstants.SOURCE_FIELD_TYPE_STATIC))
		{
			switch on message.SEL_TargetFieldType__c.toLowerCase()
			{
				when 'boolean'	{ result += Boolean.valueOf(message.SEL_SourceField__c); }
				when 'number' 	{ result += Integer.valueOf(message.SEL_SourceField__c); }
				when else 		{ result += messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_JSON) ? '\"' + message.SEL_SourceField__c + '\"' : message.SEL_SourceField__c; }
			}
		}
		else if(message.SEL_SourceFieldType__c.equalsIgnoreCase(SEL_IntegrationConstants.SOURCE_FIELD_TYPE_FIELD))
		{
			switch on message.SEL_TargetFieldType__c.toLowerCase()
			{
				when 'boolean'	{ result += source.isSet(message.SEL_SourceField__c) ? (source.get(message.SEL_SourceField__c) == null ? '' : Boolean.valueOf(source.get(message.SEL_SourceField__c)) + '') : ''; }
				when 'number' 	{ result += source.isSet(message.SEL_SourceField__c) ? (source.get(message.SEL_SourceField__c) == null ? '' : Integer.valueOf(source.get(message.SEL_SourceField__c)) + '') : ''; }
				when else	 	{ result += source.isSet(message.SEL_SourceField__c) ? (messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_JSON) ? '\"' + (source.get(message.SEL_SourceField__c) == null ? '' : string.valueOf(source.get(message.SEL_SourceField__c)).stripHtmlTags().escapeXml().replace('$', ''))  + '\"' : (source.get(message.SEL_SourceField__c) == null ? '' : String.valueOf(source.get(message.SEL_SourceField__c)).stripHtmlTags().escapeXml().replace('$', ''))): (messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_JSON) ? '\"\"' : ''); }
			}
		}
		else if(message.SEL_SourceFieldType__c.equalsIgnoreCase(SEL_IntegrationConstants.SOURCE_FIELD_TYPE_LOOKUP))
		{
			switch on message.SEL_TargetFieldType__c.toLowerCase()
			{
				when 'boolean'	{ result += Boolean.valueOf(SEL_IntegrationsTransformService.getSObjectLookupValue(source, message)); }
				when 'number' 	{ result += Integer.valueOf(SEL_IntegrationsTransformService.getSObjectLookupValue(source, message)); }
				when else	 	{ result += messageFormat.equalsIgnoreCase(SEL_IntegrationConstants.FORMAT_JSON) ? '\"' + SEL_IntegrationsTransformService.getSObjectLookupValue(source, message).escapeXml().replace('$', '')  + '\"' : SEL_IntegrationsTransformService.getSObjectLookupValue(source, message).escapeXml().replace('$', ''); }
			}
		}
		
		return result;
	}
	
	// USAGE
	// Use to retrieve the value located in lookup or master-detail relationship. 
	// This method supports multi-level hierarchy.
	@TestVisible
	private static String getSObjectLookupValue(SObject source, SEL_IntegrationMessage__mdt message)
	{
		String result = '';
		
		if(source != null && message != null && String.isNotBlank(message?.SEL_SourceField__c) && message?.SEL_SourceField__c?.containsAny('.') == true)
		{
			SObject record = null;
            List<String> parts = message.SEL_SourceField__c.split('\\.');
			String relFieldName = '';
            if(parts[0].contains('__r'))
            {
                relFieldName = parts[0].replace('__r','__c');
            }
            else
            {
                relFieldName = parts[0]+'Id';
            }
            if(String.valueOf(source).contains(relFieldName))
            {
                for(integer x = 0; x < parts.size(); x++)
			{
				if(parts.size() - (x + 1) == 0)
                {
                   if(record.get((parts.get(x) == null ? '' : parts.get(x))) != NULL)
                   result = record.get((parts.get(x) == null ? '' : parts.get(x))).toString();
                    
                }
				else
				{
					if(record == null) { record = (SObject) source.getSobject(parts.get(x)); }
					else { record = (SObject) record.getSobject(parts.get(x)); }
				}
			}
                
            }
			
		}

		return result;
	}

	// USAGE
	// Generates the header with static values. 
    public Map<String, String> getHeaders()
	{ 
		return getHeaders(null);
	}
	
    // USAGE
	// Generates the header with static and dynamic values. 
	public Map<String, String> getHeaders(Map<String , String> overrideData)
	{
		if(overrideData != null && overrideData.size() > 0)
		{
			for(String key : overrideData.keySet())
			{
				if(this.headerDynamicMap.containsKey(key))
				{
					this.headerStaticMap.put(key, overrideData.get(key));
				}
			}
		 }
		return this.headerStaticMap;
	}

	//Usage
	//Generate the endpoint URL including variable available in Integration value.
	public String getEndpoint()
	{ 
		return this.getEndpoint(null);
	}

    // USAGE
	// Generate the endpoint URL including variable available in Integration value.
	// Use this method to override dynamic Endpoint
	@SuppressWarnings('PMD.CognitiveComplexity')
	public String getEndpoint(Map<String , String> overrideData)
	{ 
		String result = '';

		if(String.isNotBlank(this.endpointUrl))
		{
			result = this.endpointUrl;
			if(overrideData != null && overrideData.size() > 0 && this.endpointDynamicMap.size() > 0)
			{
				// RULE
				// If dynamic values are found, move those values to the static map
				for(String key : overrideData.keySet())
				{ 
					if(this.endpointDynamicMap.containsKey(key))
					{
						this.endpointStaticMap.put(key, overrideData.get(key));
					}
				}
			}

			if(this.endpointStaticMap.size() > 0)
			{
				// IMPORTANT
				// Key is case sensitive
				for(String key : this.endpointStaticMap.keySet()){
					result = result.replace('{' + key + '}', this.endpointStaticMap.get(key));
				}
			}
		}

		return result;
	}
}
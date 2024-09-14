/*-----------------------------------------------------------------------------
DESCRIPTION	:	Domain class of the SEL_BatchStepTemplate__mdt custom metadata type
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library - Batch Framework
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
AUG-23-2021		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public inherited sharing class SEL_BatchStepTemplates 
{
	// DESCRIPTION
	// Group BatchStepTemplate__mdt by the parent template name
	public static Map<String, List<SEL_BatchStepTemplate__mdt>> groupByTemplate(List<SEL_BatchStepTemplate__mdt> steps)
	{
		Map<String, List<SEL_BatchStepTemplate__mdt>> result = new Map<String, List<SEL_BatchStepTemplate__mdt>>();

		// NOTE
		// If the parameter is null, return an empty Map
		if(!(steps == null || steps.isEmpty()))
		{ 
			for(SEL_BatchStepTemplate__mdt step : steps)
			{
				String templateName = Test.isRunningTest() ? 'SEL_BatchStepTemplate' : step.SEL_BatchTemplateId__r.MasterLabel;
				if(result.containsKey(templateName))
				{
					result.get(templateName).add(step);
				}
				else 
				{
					result.put(templateName, new List<SEL_BatchStepTemplate__mdt> { step });
				}
			}
		}

		return result;
	}
}
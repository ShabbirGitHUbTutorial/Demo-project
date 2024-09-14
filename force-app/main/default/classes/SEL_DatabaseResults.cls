/*-----------------------------------------------------------------------------
DESCRIPTION	:	Get Database.<DML>Result errors
AUTHOR		:	Macjules Sevilla
LIBRARY		:	Salesforce Enterprise Library (SEL) - Core
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
APR-19-2022		Macjules Sevilla	Initial version
-----------------------------------------------------------------------------*/
public with sharing class SEL_DatabaseResults 
{
	// DESCRIPTION	
	// Use this method to retrieve errors from Database.DeleteResult[]
	public static List<SEL_DatabaseResult> getExceptions(List<SObject> records, Database.DeleteResult[] results)
	{
		List<SEL_DatabaseResult> data = new List<SEL_DatabaseResult>();

		if(!(records == null || results == null || records.size() == 0 || results.size() == 0)) 
		{ 
			Integer i = 0;
			for(Database.DeleteResult r : results)
			{
				if (!r.isSuccess()) 
				{ 
					data.addAll(SEL_DatabaseResults.convert(SEL_CoreConstants.DML_DELETE, records.get(i), r.getErrors())); 
				}
				i++;
			}
		}
		
		return data;
	}

	// DESCRIPTION
	// Use this method to retrieve errors from Database.SaveResult[]
	public static List<SEL_DatabaseResult> getExceptions(String dml, List<SObject> records, Database.SaveResult[] results)
	{
		List<SEL_DatabaseResult> data = new List<SEL_DatabaseResult>();

		if(!(String.isBlank(dml) || records == null || results == null || records.size() == 0 || results.size() == 0)) 
		{ 
			Integer i = 0;
			for(Database.SaveResult r : results)
			{
				if (!r.isSuccess()) 
				{ 
					data.addAll(SEL_DatabaseResults.convert(dml, records.get(i), r.getErrors())); 
				}
				i++;
			}
		}

		return data;
	}

	// DESCRIPTION
	// Use this method to retrieve errors from Database.UndeleteResult[]
	public static List<SEL_DatabaseResult> getExceptions(List<SObject> records, Database.UndeleteResult[] results)
	{
		List<SEL_DatabaseResult> data = new List<SEL_DatabaseResult>();

		if(!(records == null || results == null || records.size() == 0 || results.size() == 0)) 
		{ 
			Integer i = 0;
			for(Database.UndeleteResult r : results)
			{
				if (!r.isSuccess()) 
				{ 
					data.addAll(SEL_DatabaseResults.convert(SEL_CoreConstants.DML_UNDELETE, records.get(i), r.getErrors())); 
				}
				i++;
			}
		}
		
		return data;
	}

	// DESCRIPTION
	// Use this method to retrieve errors from Database.UpsertResult[]
	public static List<SEL_DatabaseResult> getExceptions(List<SObject> records, Database.UpsertResult[] results)
	{
		List<SEL_DatabaseResult> data = new List<SEL_DatabaseResult>();

		if(!(records == null || results == null || records.size() == 0 || results.size() == 0)) 
		{ 
			Integer i = 0;
			for(Database.UpsertResult r : results)
			{
				if (!r.isSuccess()) 
				{ 
					data.addAll(SEL_DatabaseResults.convert(SEL_CoreConstants.DML_UPSERT, records.get(i), r.getErrors())); 
				}
				i++;
			}
		}
		
		return data;
	}

	// DESCRIPTION
	// Converts error messages in Database.Error[] into List<DatabaseResult>.
	private static List<SEL_DatabaseResult> convert(String dml, SObject record, Database.Error[] errors)
	{
		List<SEL_DatabaseResult> result = new List<SEL_DatabaseResult>();
		
		if(!(String.isBlank(dml) || record == null || errors == null || errors.size() == 0))
		{
			// WARNING
			// This logic grabs the first error message only
			SEL_DatabaseResult d = new SEL_DatabaseResult();
			d.dml = dml;
			d.fields = String.join(errors[0].getFields(), ', ');
			d.message = errors[0].getMessage();
			d.record = JSON.serialize(record);
			d.statusCode = String.valueOf(errors[0].getStatusCode());

			result.add(d);
		}

		return result;
	}
}
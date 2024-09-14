/*-----------------------------------------------------------------------------
DESCRIPTION	:	Test class for CasesConstants
AUTHOR		:	Nitish Dharm
VERSION		:	1.0

Method		:	getUnitTest
			
-----------------------------------------------------------------------------*/
@IsTest 
public with sharing class CasesConstantsTEST 
{
    @IsTest 
	private static void getUnitTest()
	{
		Assert.areEqual(CasesConstants.getUnitTest(),CasesConstants.OtherCategory );
	}
	@IsTest 
    private static void getConnectionUnitTest()
    {
        Assert.areEqual(CasesConstants.getConnectionUnitTest(),CasesConstants.Case_Design );
    }
}
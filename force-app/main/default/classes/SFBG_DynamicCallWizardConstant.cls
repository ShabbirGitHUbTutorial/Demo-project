/*---------------------------------------------------------------------------------
DESCRIPTION	:	Constants class of the Dynamic Call Wizard Framework.
LIBRARY		:	Salesforce Enterprise Library - Dynamic Call Wizard Framework.
VERSION		:	1.0

HISTORY		:
Date			Author				Comment
SEP-16-2022		  	                Initial version
---------------------------------------------------------------------------------*/
public without sharing class SFBG_DynamicCallWizardConstant {
	public static final String Case_ShocksFromEquipInt = 'ESF2';    
	public static final String Case_ShocksFromEquipExt = 'ESF3';    
	public static final String Case_TreeCutReq = 'TREE';    
	public static final String Case_WireHangingFromMeter = 'ESF5';    
	public static final String Case_LowGrndConductor = 'COND';    
	public static final String Case_MeterDamInterference = 'ESF7';    
	public static final String Case_FlickeringLights= 'ESF1';    
	public static final String Case_SmellOfBurning = 'FIR2';    
	public static final String Case_KeyMeter = 'KEY';//()REmarks    
	public static final String Case_HiEarthReading = 'HELI';    
	public static final String Case_FireCall = 'FIR1';    
	public static final String Case_3PDamageEquip = 'FDAM';    
	public static final String Case_NSOffPeak = 'EOS1';
    
    @TestVisible
	private static String getUnitTest()
	{
		return SFBG_DynamicCallWizardConstant.Case_NSOffPeak;
	}
}
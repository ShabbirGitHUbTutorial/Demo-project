/*-----------------------------------------------------------------------------
DESCRIPTION :   Handler for Connection Specific Case Trigger 
AUTHOR      :   Akshay Pandit

HISTORY     :
Date            Author              Comment
June-06-2023     Akshay Pandit         Initial version
-----------------------------------------------------------------------------*/
public with sharing class SPEN_CasesConnectionService 
{
    public static void updateBMSOMS(List<Case> lstCase)
    {
        try
        {
            Map <String,List<String>> mapBMS = new Map <String,List<String>>();
            String mapBMSKey;
            String mapBMSValue;
            for(SPEN_BusinessMarketSegmentRule__c bms : [select id, SPEN_JobType__c, SPEN_QuotationType__c, SPEN_CustomerClass__c,SPEN_RequiredPhase__c,SPEN_POCVoltage__c,SPEN_MeteringVoltage__c,SPEN_MaximumPlotsNumber__c,SPEN_MaximunLoad__c,SPEN_BusinessMarketSegment__c,SPEN_OfgemMarketSegment__c,SPEN_NoofDaysforGSDueDate__c,SPEN_MinimumPlotsNumber__c,SPEN_MinimumLoad__c from SPEN_BusinessMarketSegmentRule__c where SPEN_IsActive__c=TRUE WITH SECURITY_ENFORCED order by SPEN_MaximunLoad__c asc ])
            {
                String keyString = bms.SPEN_JobType__c+'_1_'+bms.SPEN_QuotationType__c+'_2_'+bms.SPEN_CustomerClass__c+'_3_'+bms.SPEN_RequiredPhase__c+'_4_'+bms.SPEN_POCVoltage__c+'_5_'+bms.SPEN_MeteringVoltage__c+'_6_'+bms.SPEN_MaximumPlotsNumber__c+'_7_'+bms.SPEN_MaximunLoad__c+'_8_'+bms.SPEN_BusinessMarketSegment__c+'_ENDBMS_'+bms.SPEN_OfgemMarketSegment__c+'_ENDOMS_'+bms.SPEN_NoofDaysforGSDueDate__c+'_GSDT_'+bms.SPEN_MinimumPlotsNumber__c+'_MinPlot_'+bms.SPEN_MinimumLoad__c+'_MinLoad_';
                
                mapBMSKey = bms.SPEN_JobType__c+'_1_'+bms.SPEN_QuotationType__c+'_2_'+bms.SPEN_CustomerClass__c+'_3_'+bms.SPEN_RequiredPhase__c+'_4_'+bms.SPEN_POCVoltage__c+'_5_'+bms.SPEN_MeteringVoltage__c+'_6_';

                mapBMSValue = bms.SPEN_MaximumPlotsNumber__c+'_7_'+bms.SPEN_MaximunLoad__c+'_8_'+bms.SPEN_BusinessMarketSegment__c+'_ENDBMS_'+bms.SPEN_OfgemMarketSegment__c+'_ENDOMS_'+bms.SPEN_NoofDaysforGSDueDate__c+'_GSDT_'+bms.SPEN_MinimumPlotsNumber__c+'_MinPlot_'+bms.SPEN_MinimumLoad__c+'_MinLoad_';

                if(mapBMS.containsKey(mapBMSKey))
                {
                    mapBMS.get(mapBMSKey).add(mapBMSValue);
                }
                else
                {
                    List<String> mapBMSValueTemp= new List<String>{mapBMSValue};
                    mapBMS.put(mapBMSKey,mapBMSValueTemp);
                }
                
            }
            
            BusinessHours bh =SPEN_BusinessHourSelector.getConBusinessHrs();
            
            
            for(Case cse : lstCase)
            {
                String keyCase = cse.SPEN_JobType__c+'_1_'+cse.SPEN_QuotationType__c+'_2_'+cse.SPEN_CustomerClass__c+'_3_'+cse.SPEN_RequiredPhase__c+'_4_'+cse.SPEN_POCVoltage__c+'_5_'+cse.SPEN_MeteringVoltage__c+'_6_';
                
                if(keyCase != null && mapBMS.containsKey(keyCase))
                {
                    Integer cnt = mapBMS.get(keyCase).size();
                    for(String strMapBMSVal : mapBMS.get(keyCase))
                    {                        
                        //Integer size = mapBMS.get(keyCase).size();
                        
                        system.debug('CBMS>>'+cse.SPEN_BusinessMarketSegment__c+'<<>substring>>'+strMapBMSVal.substringBetween('_8_', '_ENDBMS_')+'>>>'+cse.SPEN_TotalPlots__c);

                        system.debug('COMS>>'+cse.SPEN_OfgemMarketSegment__c+'<<>substring>>'+strMapBMSVal.substringBetween('_ENDBMS_', '_ENDOMS_')+'>>>'+cse.SPEN_RequiredPower__c);

                        if(strMapBMSVal != null && cse.SPEN_TotalPlots__c >= Integer.valueOf(strMapBMSVal.substringBetween('_GSDT_','_MinPlot_')) && cse.SPEN_TotalPlots__c <= Integer.valueOf(strMapBMSVal.substringBefore('_7_')) && cse.SPEN_RequiredPower__c >= Double.valueOf(strMapBMSVal.substringBetween('_MinPlot_' ,'_MinLoad_')) && cse.SPEN_RequiredPower__c <= Double.valueOf(strMapBMSVal.substringBetween('_7_' ,'_8_')))
                        {
                            if(cse.SPEN_ContactReceivedDate__c != null && (strMapBMSVal.substringBetween('_ENDOMS_','_GSDT_') != 'null') && !(cse.SPEN_SubStatus__c == 'Competent' && cse.Status == 'Design')) //SFAMS-708 : Added the adcondition to check the status and SubStatus
                                {
                                    cse.SPEN_GSDueDate__c = Cases.getWorkingDays(bh.Id, cse.SPEN_ContactReceivedDate__c, Long.valueOf(strMapBMSVal.substringBetween('_ENDOMS_','_GSDT_')));
                                }
                            system.debug('GSDT>>'+strMapBMSVal.substringBetween('_ENDOMS_','_GSDT_'));

                            //system.debug('COMS>>'+cse.SPEN_OfgemMarketSegment__c+'<<>substring>>'+strMapBMSVal.substringBetween('_ENDBMS_', '_ENDOMS_'));
                            
                            if(!String.isBlank(strMapBMSVal.substringBetween('_ENDOMS_','_GSDT_')) && bh != null && ((cse.SPEN_BusinessMarketSegment__c != strMapBMSVal.substringBetween('_8_', '_ENDBMS_')) || (cse.SPEN_OfgemMarketSegment__c != strMapBMSVal.substringBetween('_ENDBMS_', '_ENDOMS_'))))//CRMD 6365
                            {
                                system.debug('Inside if 54>>');
                                //cse.SPEN_ContactReceivedDate__c = system.now();
                                /**if(cse.SPEN_ContactReceivedDate__c != null)
                                {
                                    cse.SPEN_GSDueDate__c = Cases.getWorkingDays(bh.Id, cse.SPEN_ContactReceivedDate__c, Long.valueOf(strMapBMSVal.substringBetween('_ENDOMS_','_GSDT_')));
                                }**/
                                
                                cse.SPEN_NoofDaysinGSDueDate__c = Integer.valueOf(strMapBMSVal.substringBetween('_ENDOMS_','_GSDT_'));
                                if(strMapBMSVal.substringBetween('_ENDBMS_', '_ENDOMS_') == 'LVSSA')
                                {
                                    cse.SPEN_DesignTaskTriggerDate__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(strMapBMSVal.substringBetween('_ENDOMS_','_GSDT_'))-1);
                                    cse.SPEN_CaseNeedsActionTillDate__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(System.label.SPEN_LVSSACaseNeedsActionBeforeDays));
                                }
                                else if(strMapBMSVal.substringBetween('_ENDBMS_', '_ENDOMS_') == 'LVSSB')
                                {
                                    cse.SPEN_DesignTaskTriggerDate__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(strMapBMSVal.substringBetween('_ENDOMS_','_GSDT_'))-3);
                                    cse.SPEN_CaseNeedsActionTillDate__c = Cases.getWorkingDays(bh.Id, system.now(), Long.valueOf(System.label.SPEN_LVSSBCaseNeedsActionBeforeDays));
                                }
                            }
                            String combineKey = keyCase+strMapBMSVal;
                            String substringBMS = strMapBMSVal.substringBetween('_8_', '_ENDBMS_');
                            cse.SPEN_BusinessMarketSegment__c = (substringBMS == 'null') ? '' : substringBMS;
                            String substringOMS = strMapBMSVal.substringBetween('_ENDBMS_', '_ENDOMS_') ;
                            cse.SPEN_OfgemMarketSegment__c = (substringOMS == 'null') ? '' : substringOMS;
                            break;
                        }
                        system.debug('before cnt'+cnt);
                        cnt = cnt-1;
                        if(cnt == 0)
                        {
                            cse.SPEN_BusinessMarketSegment__c = null;
                            cse.SPEN_OfgemMarketSegment__c = null;
                        }
                    }
                }
                else
                {
                    cse.SPEN_BusinessMarketSegment__c = null;
                    cse.SPEN_OfgemMarketSegment__c = null;
                }
            }
        }
        catch(exception e)
        {
            SEL_LoggingService.log(e);

        }
    }



    public static void updateAddressInfo(List<Case> lstCase, List<Id> lstConId)
    {
        try
        {
            Map<Id,SPEN_ContactPremise__c> mapConIdVsConPrem = new Map<Id,SPEN_ContactPremise__c>();
            for(SPEN_ContactPremise__c conPre : [select id,SPEN_RelatedContact__c,SPEN_Premise__r.Name,SPEN_Premise__r.SPEN_Street__c,SPEN_Premise__r.SPEN_Town__c,SPEN_Premise__r.SPEN_PostCode__c,SPEN_Premise__r.SPEN_FlatNumber__c,SPEN_Premise__r.SPEN_PremiseNumber__c,SPEN_Premise__r.SPEN_BuildingNameNumber__c,SPEN_Premise__r.SPEN_Zone__r.Name,SPEN_Premise__r.SPEN_XCoOrdinate__c,SPEN_Premise__r.SPEN_YCoOrdinate__c from SPEN_ContactPremise__c where SPEN_Role__c='Customer' and SPEN_RelatedContact__c != null and SPEN_Premise__c != null and SPEN_RelatedContact__c = :lstConId WITH SECURITY_ENFORCED ])
            {
                mapConIdVsConPrem.put(conPre.SPEN_RelatedContact__c,conPre);
            } 
            system.debug('In updateAddInfo>>>>map'+mapConIdVsConPrem);
            //Map<Id, RecordTypeInfo> rtInfo = Contact.getDescribe().getRecordTypeInfosById();

            Map<Id, Contact> mapIdVsCon = new Map<Id, Contact>([SELECT id, MobilePhone, Phone, SPEN_CallingPreferenceNumber__c, FirstName, LastName, SPEN_Company__c, Email from Contact WHERE Id IN :lstConId WITH SECURITY_ENFORCED]);
            
            for(Case cse :  lstCase)
            {
                String conCaseContactRecTypeName;
                system.debug(cse.SPEN_ContactRecordType__c+'<<cse.Contact.RecordTypeId>>');
                if(cse.SPEN_ContactRecordType__c != null)
                {
                    //conCaseContactRecTypeName = Schema.getGlobalDescribe().get('Contact').getDescribe().getRecordTypeInfosById().get(cse.SPEN_ContactRecordType__c).getDeveloperName();
                    conCaseContactRecTypeName = ((SObject)Type.forName('Contact').newInstance()).getSObjectType().getDescribe().getRecordTypeInfosById().get(cse.SPEN_ContactRecordType__c).getDeveloperName();
                }
                //system.debug('RecType>>>>'+conCaseContactRecTypeName);
                if(conCaseContactRecTypeName == 'SPEN_ContactConnectionsCRM' && cse.AccountId != null)
                //if(rtInfo.containsKey(cse.SPEN_ContactRecordType) && cse.AccountId != null)
                {
                    system.debug('Inside if 92>>>>'+cse.SPEN_AccountBillingStreet__c+'>>'+cse.SPEN_AccountBillingCity__c+'>>'+cse.SPEN_AccountBillingPostalCode__c+'>>'+cse.SPEN_AccountBillingCountry__c+'>>');

                    cse.SPEN_ApplicantStreet__c =  (cse.SPEN_AccountBillingStreet__c != null) ? cse.SPEN_AccountBillingStreet__c : null;
                    cse.SPEN_ApplicantTownCity__c = (cse.SPEN_AccountBillingCity__c != null) ? cse.SPEN_AccountBillingCity__c : null;
                    cse.SPEN_ApplicantPostCode__c = (cse.SPEN_AccountBillingPostalCode__c != null) ? cse.SPEN_AccountBillingPostalCode__c : null;
                    cse.SPEN_ApplicantFlatNo__c = null;
                    cse.SPEN_ApplicantCountry__c = (cse.SPEN_AccountBillingCountry__c != null) ? cse.SPEN_AccountBillingCountry__c : null;

                    
                    cse.SPEN_SiteName__c = null;
                    cse.SPEN_SiteContactFlatNumber__c = null;
                    cse.SPEN_SiteContactHouseNo__c = null;
                    cse.SPEN_SiteContactBuildingName__c = null;
                    cse.SPEN_SiteContactStreet__c = (cse.SPEN_AccountBillingStreet__c != null) ? cse.SPEN_AccountBillingStreet__c : null;
                    cse.SPEN_SiteUPRN__c = null;
                    cse.SPEN_SiteContactLocality__c = null;
                    cse.SPEN_SiteContactTownCity__c = (cse.SPEN_AccountBillingCity__c != null) ? cse.SPEN_AccountBillingCity__c : null;
                    cse.SPEN_SiteContactPostCode__c = (cse.SPEN_AccountBillingPostalCode__c != null) ? cse.SPEN_AccountBillingPostalCode__c : null;
                    cse.SPEN_SiteContactCountry__c = 'GB';
                    cse.SPEN_XCoOrdinate__c = null;
                    cse.SPEN_YCoOrdinate__c = null;

                    if(mapIdVsCon.containsKey(cse.ContactId))
                    {
                        cse.SPEN_ApplicantMobileNumber__c = (mapIdVsCon.get(cse.ContactId).MobilePhone != null) ? (mapIdVsCon.get(cse.ContactId).MobilePhone) : null; 

                        cse.SPEN_ApplicantPhoneNumber__c = (mapIdVsCon.get(cse.ContactId).Phone != null) ? (mapIdVsCon.get(cse.ContactId).Phone) : null; 

                        cse.SPEN_CallingPreferenceNumber__c = (mapIdVsCon.get(cse.ContactId).SPEN_CallingPreferenceNumber__c != null) ? (mapIdVsCon.get(cse.ContactId).SPEN_CallingPreferenceNumber__c) : null; 

                        cse.SPEN_SiteContactFirstName__c = (mapIdVsCon.get(cse.ContactId).FirstName != null) ? (mapIdVsCon.get(cse.ContactId).FirstName) : null; 

                        cse.SPEN_SiteContactLastName__c = (mapIdVsCon.get(cse.ContactId).LastName != null) ? (mapIdVsCon.get(cse.ContactId).LastName) : null; 

                        cse.SPEN_SiteContactCompanyName__c = (mapIdVsCon.get(cse.ContactId).SPEN_Company__c != null) ? (mapIdVsCon.get(cse.ContactId).SPEN_Company__c) : null; 

                        cse.SPEN_ApplicantSiteIdentifier__c = null;

                        cse.SPEN_SiteContactMobile__c = (mapIdVsCon.get(cse.ContactId).MobilePhone != null) ? (mapIdVsCon.get(cse.ContactId).MobilePhone) : null; 

                        cse.SPEN_SiteContactPhone__c = (mapIdVsCon.get(cse.ContactId).Phone != null) ? (mapIdVsCon.get(cse.ContactId).Phone) : null; 

                        cse.SPEN_SiteContactEmail__c = (mapIdVsCon.get(cse.ContactId).Email != null) ? (mapIdVsCon.get(cse.ContactId).Email) : null; 
                        
                    }

                    
                }

                else if(conCaseContactRecTypeName != 'SPEN_ContactConnectionsCRM' && !mapConIdVsConPrem.isEmpty())
                //else if(!rtInfo.containsKey(cse.SPEN_ContactRecordType) && !mapConIdVsConPrem.isEmpty())
                {
                    system.debug(cse.ContactId+'<<<Inside else if>>>>'+mapConIdVsConPrem);
                    if(mapConIdVsConPrem.containsKey(cse.ContactId))
                    {
                        system.debug('Inside else if if 105>>>>'+mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Street__c);
                        cse.SPEN_ApplicantStreet__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Street__c != null) ?mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Street__c : null ;
                        
                        cse.SPEN_ApplicantTownCity__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Town__c != null) ?mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Town__c : null ;
                        
                        cse.SPEN_ApplicantPostCode__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_PostCode__c != null) ?mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_PostCode__c : null ;
                        
                        cse.SPEN_ApplicantFlatNo__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_FlatNumber__c != null) ?mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_FlatNumber__c : null ;

                        cse.SPEN_ApplicantCountry__c = 'United Kingdom';

                        system.debug('mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.Name>>>'+mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.Name);

                        cse.SPEN_SiteName__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.Name != null) ? removeSpecialCharacters(mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.Name) : null;
                        
                        cse.SPEN_SiteContactFlatNumber__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_FlatNumber__c != null) ? removeSpecialCharacters(mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_FlatNumber__c) : null;
                        
                        cse.SPEN_SiteContactHouseNo__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_PremiseNumber__c != null) ? removeSpecialCharacters(mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_PremiseNumber__c) : null;

                        cse.SPEN_SiteContactBuildingName__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_BuildingNameNumber__c != null) ? removeSpecialCharacters(mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_BuildingNameNumber__c) : null;

                        cse.SPEN_SiteContactStreet__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Street__c != null) ? removeSpecialCharacters(mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Street__c) : null ;

                        cse.SPEN_SiteUPRN__c = null;

                        cse.SPEN_SiteContactLocality__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Zone__r.Name != null) ? removeSpecialCharacters(mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Zone__r.Name) : null;

                        cse.SPEN_SiteContactTownCity__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Town__c != null) ? removeSpecialCharacters(mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_Town__c) : null ;

                        cse.SPEN_SiteContactPostCode__c = (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_PostCode__c != null) ? removeSpecialCharacters(mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_PostCode__c) : null ;

                        cse.SPEN_SiteContactCountry__c = 'GB';

                        cse.SPEN_XCoOrdinate__c = (((mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_XCoOrdinate__c) != null) && (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_XCoOrdinate__c).contains('.')) ?(mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_XCoOrdinate__c).substringbefore('.').left(8) : ((mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_XCoOrdinate__c) != null) ? (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_XCoOrdinate__c).left(8) : null ;

                        cse.SPEN_YCoOrdinate__c = (((mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_YCoOrdinate__c) != null) && (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_YCoOrdinate__c).contains('.')) ?(mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_YCoOrdinate__c).substringbefore('.').left(8) : ((mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_YCoOrdinate__c) != null) ? (mapConIdVsConPrem.get(cse.ContactId).SPEN_Premise__r.SPEN_YCoOrdinate__c).left(8) : null ;

                        if(mapIdVsCon.containsKey(cse.ContactId))
                        {
                            cse.SPEN_ApplicantMobileNumber__c = (mapIdVsCon.get(cse.ContactId).MobilePhone != null) ? (mapIdVsCon.get(cse.ContactId).MobilePhone) : null; 

                            cse.SPEN_ApplicantPhoneNumber__c = (mapIdVsCon.get(cse.ContactId).Phone != null) ? (mapIdVsCon.get(cse.ContactId).Phone) : null; 

                            cse.SPEN_CallingPreferenceNumber__c = (mapIdVsCon.get(cse.ContactId).SPEN_CallingPreferenceNumber__c != null) ? (mapIdVsCon.get(cse.ContactId).SPEN_CallingPreferenceNumber__c) : null; 

                            cse.SPEN_SiteContactFirstName__c = (mapIdVsCon.get(cse.ContactId).FirstName != null) ? (mapIdVsCon.get(cse.ContactId).FirstName) : null; 

                            cse.SPEN_SiteContactLastName__c = (mapIdVsCon.get(cse.ContactId).LastName != null) ? (mapIdVsCon.get(cse.ContactId).LastName) : null; 

                            cse.SPEN_SiteContactCompanyName__c = (mapIdVsCon.get(cse.ContactId).SPEN_Company__c != null) ? (mapIdVsCon.get(cse.ContactId).SPEN_Company__c) : null; 

                            cse.SPEN_ApplicantSiteIdentifier__c = null;

                            cse.SPEN_SiteContactMobile__c = (mapIdVsCon.get(cse.ContactId).MobilePhone != null) ? (mapIdVsCon.get(cse.ContactId).MobilePhone) : null; 

                            cse.SPEN_SiteContactPhone__c = (mapIdVsCon.get(cse.ContactId).Phone != null) ? (mapIdVsCon.get(cse.ContactId).Phone) : null; 

                            cse.SPEN_SiteContactEmail__c = (mapIdVsCon.get(cse.ContactId).Email != null) ? (mapIdVsCon.get(cse.ContactId).Email) : null; 
                            
                        }
                    }

                    else
                    {
                        cse.SPEN_ApplicantStreet__c = null;                        
                        cse.SPEN_ApplicantTownCity__c = null;
                        cse.SPEN_ApplicantPostCode__c = null;                        
                        cse.SPEN_ApplicantFlatNo__c = null;
                        cse.SPEN_ApplicantCountry__c = 'United Kingdom';
                        cse.SPEN_SiteName__c = null;                        
                        cse.SPEN_SiteContactFlatNumber__c = null;                        
                        cse.SPEN_SiteContactHouseNo__c = null;
                        cse.SPEN_SiteContactBuildingName__c = null;
                        cse.SPEN_SiteContactStreet__c = null;
                        cse.SPEN_SiteUPRN__c = null;
                        cse.SPEN_SiteContactLocality__c = null;
                        cse.SPEN_SiteContactTownCity__c = null;
                        cse.SPEN_SiteContactPostCode__c = null;
                        cse.SPEN_SiteContactCountry__c = 'GB';
                        cse.SPEN_XCoOrdinate__c = null;
                        cse.SPEN_YCoOrdinate__c = null;
                        if(mapIdVsCon.containsKey(cse.ContactId))
                        {
                            cse.SPEN_ApplicantMobileNumber__c = (mapIdVsCon.get(cse.ContactId).MobilePhone != null) ? (mapIdVsCon.get(cse.ContactId).MobilePhone) : null; 

                            cse.SPEN_ApplicantPhoneNumber__c = (mapIdVsCon.get(cse.ContactId).Phone != null) ? (mapIdVsCon.get(cse.ContactId).Phone) : null; 

                            cse.SPEN_CallingPreferenceNumber__c = (mapIdVsCon.get(cse.ContactId).SPEN_CallingPreferenceNumber__c != null) ? (mapIdVsCon.get(cse.ContactId).SPEN_CallingPreferenceNumber__c) : null; 

                            cse.SPEN_SiteContactFirstName__c = (mapIdVsCon.get(cse.ContactId).FirstName != null) ? (mapIdVsCon.get(cse.ContactId).FirstName) : null; 

                            cse.SPEN_SiteContactLastName__c = (mapIdVsCon.get(cse.ContactId).LastName != null) ? (mapIdVsCon.get(cse.ContactId).LastName) : null; 

                            cse.SPEN_SiteContactCompanyName__c = (mapIdVsCon.get(cse.ContactId).SPEN_Company__c != null) ? (mapIdVsCon.get(cse.ContactId).SPEN_Company__c) : null; 

                            cse.SPEN_ApplicantSiteIdentifier__c = null;

                            cse.SPEN_SiteContactMobile__c = (mapIdVsCon.get(cse.ContactId).MobilePhone != null) ? (mapIdVsCon.get(cse.ContactId).MobilePhone) : null; 

                            cse.SPEN_SiteContactPhone__c = (mapIdVsCon.get(cse.ContactId).Phone != null) ? (mapIdVsCon.get(cse.ContactId).Phone) : null; 

                            cse.SPEN_SiteContactEmail__c = (mapIdVsCon.get(cse.ContactId).Email != null) ? (mapIdVsCon.get(cse.ContactId).Email) : null; 
                            
                        }
                    }
                }
            }
            /*Map<Id, Contact> mapIdCon = new Map<Id, Contact>([SELECT id, MobilePhone, Phone from Contact WHERE Id IN :caseConIds WITH SECURITY_ENFORCED]);
            //&& (String.isBlank((cse.SPEN_CustomerMobilePhone__c)) || String.isBlank(String.valueOf(cse.SPEN_CustomerPhoneNumber__c)))
            for(Case cse : lstCase)
            {
                if(mapIdCon.containsKey(cse.ContactId))
                {
                    cse.SPEN_CustomerMobilePhone__c = (String.isBlank((cse.SPEN_CustomerMobilePhone__c))) ? mapIdCon.get(cse.ContactId).MobilePhone : cse.SPEN_CustomerMobilePhone__c;
                    cse.SPEN_CustomerPhoneNumber__c = (String.isBlank(String.valueOf(cse.SPEN_CustomerPhoneNumber__c))) ? mapIdCon.get(cse.ContactId).Phone : cse.SPEN_CustomerPhoneNumber__c;
                    system.debug('Inside if 90 cse.SPEN_CustomerMobilePhone__c>>>>'+cse.SPEN_CustomerMobilePhone__c+'<<<cse.SPEN_CustomerPhoneNumber__c>>>'+cse.SPEN_CustomerPhoneNumber__c);
                }
            }*/

        }
        catch(exception e)
        {
            SEL_LoggingService.log(e);
        }
    }

    /*public static DateTime getWorkingDays(Id businessHrId, DateTime baseDate, Long days)
    {
        Long addNDays = 86400000 *days;
        return BusinessHours.add(businessHrId, baseDate, addNDays);
    }*/

    @InvocableMethod(label='SAP Callout Before Case Is Competent' description='SAP Callout Before Making Case Competent')
    public static void callSAPCalloutBeforeCompetent(List<Id> caseIds)
    {
        try
        {
            //String phyInfoId;
            //List<Id> lstCaseId = new List<Id>();
            //SPEN_PhysicalInformation__c phyInfo = SPEN_PhysicalInformationSelector.getPhysicalInfoFromPhyInfoIds(phyInfoIds);
            //phyInfoId= phyInfo.id;
            //lstCaseId.add(phyInfo.SPEN_Case__c);
            //if(!System.isfuture())
            //{
            SPEN_SAPQASCallout.sendSoapCalloutSyncCall('MODIFY_QAS', caseIds);
            //}
            
        }
        catch(Exception ex)
        {
            System.debug('In class SPEN_CasesConnectionService : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            SEL_LoggingService.log(ex);
        }

    }

    public static void updatePaymentDecision(List<Case> lstCase)
    {
        try
        {
            for(Case cse : lstCase)
            {
                /*if(cse.SPEN_PaymentDecision__c == PIA)
                {
                    cse.SPEN_RequestedtoRelease__c = 100;
                }
                else if(cse.SPEN_PaymentDecision__c == POC)
                {
                    cse.SPEN_RequestedtoRelease__c = 0;
                }
                else if(cse.SPEN_PaymentDecision__c == STG)
                {
                    cse.SPEN_RequestedtoRelease__c = 25;
                }*/
                if(!string.isBlank(cse.SPEN_PaymentDecision__c))
                {
                    switch on cse.SPEN_PaymentDecision__c 
                    {
                        when 'PIA' 
                        {
                            cse.SPEN_RequestedtoRelease__c = 100;                        
                        }
                        when 'POC'
                        {
                            cse.SPEN_RequestedtoRelease__c = 0;
                        }
                        when 'STG'
                        {
                            cse.SPEN_RequestedtoRelease__c = 25;
                        }
                    }
                }
            }            
        }
        catch(Exception ex)
        {
            System.debug('In class SPEN_CasesConnectionService : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            SEL_LoggingService.log(ex);
        }

    }
    //SFAMS-774
    // Method to remove special characters from site address
    public static String removeSpecialCharacters(String fieldValue) {
        String regex = '[^a-zA-Z0-9 ]';
        
        return fieldValue.replaceAll(regex, ' ');
    }
    
}
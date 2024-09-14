/**********************************************************************************************
* @Author:      Ayush Mittal
* @Date:        12/01/2023
* @Description: SPEN_MeterDetailsIntegrationRequest class
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/
public class SPEN_MeterDetailsIntegrationRequest 
{
    public string dccServiceFlagValue;
    public String suppMpidValue;
    public String meterTypeValue;
    
    public void send(Id intgReqRecordId, String mpanNumber)
    {
        try
        {
            SPEN_IntegrationRequest__c intgReqRecord = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(intgReqRecordId);
            SPEN_MPAN__c mpanRcd = SPEN_MPANSelector.getRecordForMpan(mpanNumber);
            SPEN_SupplierDetails__c suppDetails = new SPEN_SupplierDetails__c();
            
            String resultStr ='';
            String jsonString = '{'+
                '   \"Authentication\":{'+
                '       \"Key\": \"'+System.Label.SPEN_SearchUtilityAddressEndPointKey+'\"'+
                '   }'+','+
                '   \"ParameterSets\":[{'+
                '       \"Parameters\":[{'+
                '       	\"Key\": \"'+'MPAN'+'\",'+
                '       	\"Value\": \"'+mpanNumber+'\"'+
                		'}'+
                		']'+
                	'}'+']'+
                '}';
            
            //system.debug('jsonString'+jsonString);
            SPEN_EcoesSmartMeterWrapper testBody = SPEN_EcoesSmartMeterWrapper.parse(jsonString);
            system.debug('testBody----->'+testBody);
            //system.debug('JSON.serialize(testBody) --------->>>>>'+ JSON.serialize(testBody));
			List<SEL_IntegrationValue__mdt> intValuesAll = SEL_IntegrationValue__mdt.getAll().values();
            SEL_IntegrationSetting__mdt cmt = new SEL_IntegrationsSelector().selectByDeveloperName(SEL_IntegrationConstants.ECOES_MPAN_DETAILS);
            SEL_IntegrationsTransformService ser = new SEL_IntegrationsTransformService(cmt);

            List<SEL_IntegrationValue__mdt> intValues = new List<SEL_IntegrationValue__mdt>();

            for(SEL_IntegrationValue__mdt intValueInstance : intValuesAll)
            {
                if(intValueInstance.SEL_IntegrationSettingId__r.DeveloperName == SEL_IntegrationConstants.ECOES_MPAN_DETAILS)
                {
                    intValues.add(intValueInstance);
                }
                else
                {
                    continue;
                }
            }
            HttpRequest req = new HttpRequest();
            
            List<Map<String,String>> lstMapIntValues = ser.groupValuesByType(intValues);
            //System.debug('exepected values.. '+lstMapIntValues);
            req = SPEN_IntegrationUtility.prepareRequestsWithBearerToken(lstMapIntValues, req);
            req.setMethod(cmt.SEL_HttpMethod__c);
            //System.debug('req : '+req);
            req.setBody(JSON.serialize(testBody));
            Http http = new Http();
            HTTPResponse res = http.send(req);
            resultStr = res.getBody();
            
            system.debug('res --------->>>>>'+ res);
            //system.debug('resultStr --------->>>>>'+ resultStr);
            
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201)
            {    
                //system.debug('AFTER GETTING RESPONSE');
				if(resultStr.containsIgnoreCase('MissingMPANFault') || resultStr.startsWithIgnoreCase('<Fault'))         
                {
                    intgReqRecord.SPEN_Status__c = 'Completed';
                    intgReqRecord.SPEN_Result__c = 'MPAN core '+mpanNumber+' was not found.';
                    update intgReqRecord;
                }
				else
				{
					SPEN_GetMeterDetailsWrapper getMeterDetailsWrapper = (SPEN_GetMeterDetailsWrapper) System.JSON.deserialize(res.getBody(), SPEN_GetMeterDetailsWrapper.class);
					//system.debug('getMeterDetailsWrapper ---->'+getMeterDetailsWrapper);
                
					if(getMeterDetailsWrapper.Results[0].Errors.isEmpty() && !getMeterDetailsWrapper.Results[0].UtilityMatches.isEmpty())
					{
						for(SPEN_GetMeterDetailsWrapper.UtilityMatches val : getMeterDetailsWrapper.Results[0].UtilityMatches)
						{
							for(SPEN_GetMeterDetailsWrapper.Parameters nextVal : val.UtilityDetails)
							{
								if(nextVal.key == 'dcc_service_flag')
								{
									dccServiceFlagValue = nextVal.Value;
								}
								if(nextVal.key == 'supplier_mpid')
								{
									suppMpidValue = nextVal.Value;
								}
							}
							
							for(SPEN_GetMeterDetailsWrapper.Meters nextValue : val.Meters)
							{
								for(SPEN_GetMeterDetailsWrapper.Parameters nextValForMeter : nextValue.MeterDetails)
								{
									if(nextValForMeter.key == 'meter_type')
									{
										meterTypeValue = nextValForMeter.Value;
									}
								}
							}                         
						}
						//system.debug('mpanRcd--------->'+mpanRcd);
						if(mpanRcd.Id!=null)
						{
							if(suppMpidValue!=null)
							{
								suppDetails	= SPEN_SupplierDetailsSelector.getSupplierDetailsRecord(suppMpidValue);
								mpanRcd.SPEN_SupplierMPID__c = suppMpidValue;
								mpanRcd.SPEN_SupplierName__c = suppDetails.Name;
								mpanRcd.SPEN_SupplierPhoneNumber__c = suppDetails.SPEN_SupplierPhoneNumber__c;
							}
							mpanRcd.SPEN_MeterType__c = meterTypeValue;
							mpanRcd.SPEN_DCCServiceFlag__c = dccServiceFlagValue;
							mpanRcd.SPEN_LastEchoesSyncDate__c = system.now();
							
							intgReqRecord.SPEN_Status__c = 'Completed';
							//intgReqRecord.SPEN_Result__c = mpanRcd.SPEN_Premise__r.SPEN_PremiseId__c;
							update mpanRcd;
							update intgReqRecord;
						}
						else
						{
							intgReqRecord.SPEN_Status__c = 'Completed';
							intgReqRecord.SPEN_Result__c = 'The MPAN Number '+mpanNumber+' does not exist in SF Database';
							update intgReqRecord;
						}
					}
				}
            }
        }
        catch(Exception ex)
        {
            SEL_LoggingService.log(ex);
            throw ex;            
        }
    }
}
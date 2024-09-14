/**********************************************************************************************
* @Author:      Ayush Mittal
* @Date:        07/12/2022
* @Description: AdditionalService class from SPEN_SearchEcoesService
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
public with sharing class SPEN_SearchEcoesIntegrationRequest extends SEL_IntegrationsOutboundMessageBase
{
    Boolean valCheck = false;
    public string postcodeToCompare;
    public String mpancoreValue ='';
    public String meterTypeValue;
    public String suppMpidValue;
    public String dccFlagValue;
    public string temp;
    
    public String postcode;
    public String buildingNumber;
    public String flatNumber;
    
    public SPEN_SearchEcoesIntegrationRequest() 
    {
        super('SearchEcoesForMpan');
    }
    public void send(Id intgReqRecordId, String intgReqRecordsDetails)
    {
        try
        {
            SPEN_IntegrationRequest__c inteReqRcrd = SPEN_IntegrationRequestSelector.getIntegrationRequestRecord(intgReqRecordId);
            
            List<string> uname = intgReqRecordsDetails.split('\\|');
            List<string> keyvalue = uname[0].split(':');
            List<string> keyvalue1 = uname[1].split(':');
            List<string> keyvalue2 = uname[2].split(':');
    		
            postcodeToCompare = keyvalue[1].trim();
            
            postcode = postcodeToCompare.replace(' ','');
            buildingNumber = keyvalue1[1].trim();
            flatNumber = keyvalue2[1].trim();
            //system.debug('flatNumber--->'+flatNumber);
            
            HttpRequest request = super.getHttpRequest(inteReqRcrd);
            if(super.getIsMockingEnabled())
            {
                /*
                HttpResponse response = super.send(request);
                system.debug('response --->'+ response.getBody());
                if(response.getStatusCode() == 200)
                {
                    SPEN_ECOESSupplierDetailsWrapper.RequestBody searchWrapper = (SPEN_ECOESSupplierDetailsWrapper.RequestBody) System.JSON.deserialize(response.getBody(), SPEN_ECOESSupplierDetailsWrapper.RequestBody.class);
                    if(postcode !='' && buildingNumber !='')  
                    {
                        if(!searchWrapper.UtilityAddressMatches.isEmpty())
                        {
                            valCheck = true;
                            SPEN_MPAN__c mpanRcd = new SPEN_MPAN__c();
                            SPEN_SupplierDetails__c suppDetails = new SPEN_SupplierDetails__c();
                            for(SPEN_ECOESSupplierDetailsWrapper.UtilityAddressMatches val : searchWrapper.UtilityAddressMatches)
                            {
                                for(SPEN_ECOESSupplierDetailsWrapper.Parameters nextVal : val.AddressDetails)
                                {
                                    if(valCheck)
                                    {
                                        if(nextVal.Key == 'mpancore'){
                                            mpancoreValue = nextVal.Value;
                                        }
                                        if(nextVal.Key == 'meter_type'){
                                            meterTypeValue = nextVal.Value;
                                        }
                                        if(nextVal.Key == 'supplier_mpid'){
                                            suppMpidValue = nextVal.Value;
                                        }
                                        if(nextVal.Key == 'dcc_service_flag'){
                                            dccFlagValue = nextVal.Value;
                                        }
                                        temp = 'IfExecuted';
                                    }
                                }
                            }
                            if(temp == 'IfExecuted')
                            {
                                mpanRcd = SPEN_MPANSelector.getRecordForMpan(mpancoreValue);
                                suppDetails = SPEN_SupplierDetailsSelector.getSupplierDetailsRecord(suppMpidValue);
                                mpanRcd.SPEN_MeterType__c = meterTypeValue;
                                mpanRcd.SPEN_SupplierMPID__c = suppMpidValue;
                                mpanRcd.SPEN_SupplierName__c = suppDetails.Name;
                                mpanRcd.SPEN_SupplierPhoneNumber__c = suppDetails.SPEN_SupplierPhoneNumber__c;
                                mpanRcd.SPEN_DCCServiceFlag__c = dccFlagValue;
                                
                                inteReqRcrd.SPEN_Result__c = mpanRcd.SPEN_Premise__r.SPEN_PremiseId__c;
                                inteReqRcrd.SPEN_Status__c = 'Completed';
                                
                                update mpanRcd;
                                update inteReqRcrd;
                            }
                        }
                        else if(!searchWrapper.Errors.isEmpty())
                        {
                            inteReqRcrd.SPEN_Result__c = 'Address not found in ECOES';
                            inteReqRcrd.SPEN_Status__c = 'Completed';
                            update inteReqRcrd;
                        }
                	}
                }
                */
            }
            else
            {
                //String tempBody = '{"Authentication":{"Key":"52NT-7PP0-TTAK-L76M"},"ParameterSets":[{"Parameters":[{"Key":"Postcode","Value":"G743SY"},{"Key":"BuildingNumber","Value":"38"},{"Key":"returndataforsingleresult","Value":"true"}]}]}';
                
                String resultStr ='';
                if(postcode !='' && buildingNumber !='')
                {
                    String jsonString = '{'+
                        '   \"Authentication\":{'+
                        '       \"Key\": \"'+System.Label.SPEN_SearchUtilityAddressEndPointKey+'\"'+
                        '   }'+','+
                        '   \"ParameterSets\":[{'+
                        '       \"Parameters\":[{'+
                        '       	\"Key\": \"'+'Postcode'+'\",'+
                        '       	\"Value\": \"'+postcode+'\"'+
                        		'}'+','+
                        		'{'+
                        '			\"Key\": \"'+'BuildingNumber'+'\",'+
                        '       	\"Value\": \"'+buildingNumber+'\"'+
                        		'}'+','+
                        		'{'+
                        '			\"Key\": \"'+'SubBuilding'+'\",'+
                        '       	\"Value\": \"'+flatNumber+'\"'+                                
                        		'}'+','+
                        		'{'+
                        '			\"Key\": \"'+'returndataforsingleresult'+'\",'+
                        '       	\"Value\": \"'+'true'+'\"'+
                        		'}'+
                        		']'+
                        	'}'+']'+
                        '}';
                    
                    //system.debug('jsonString ---> '+ jsonString);
                    SPEN_EcoesSmartMeterWrapper testBody = SPEN_EcoesSmartMeterWrapper.parse(jsonString);
                    system.debug('testBody --------->>>>>'+ testBody);
                    //system.debug('JSON.serialize(testBody) --------->>>>>'+ JSON.serialize(testBody));
                    
					List<SEL_IntegrationValue__mdt> intValuesAll = SEL_IntegrationValue__mdt.getAll().values();
                    SEL_IntegrationSetting__mdt cmt = new SEL_IntegrationsSelector().selectByDeveloperName(SEL_IntegrationConstants.ECOES_SEARCH);
                    SEL_IntegrationsTransformService ser = new SEL_IntegrationsTransformService(cmt);
        
                    List<SEL_IntegrationValue__mdt> intValues = new List<SEL_IntegrationValue__mdt>();
        
                    for(SEL_IntegrationValue__mdt intValueInstance : intValuesAll)
                    {
                        if(intValueInstance.SEL_IntegrationSettingId__r.DeveloperName == SEL_IntegrationConstants.ECOES_SEARCH)
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
                    
                    if(res.getStatusCode() == 200)
                    {
                        SPEN_ECOSActualResponseWrapper ecosWrapper = (SPEN_ECOSActualResponseWrapper) System.JSON.deserialize(res.getBody(), SPEN_ECOSActualResponseWrapper.class);
                        system.debug('ecosWrapper ---->'+ecosWrapper); 
						
                        Map<String, String> activeMpanMap = new Map<String, String>();
                        
                        if(!ecosWrapper.Results[0].Errors.isEmpty())
                        {
                            inteReqRcrd.SPEN_Result__c = 'Address not found in ECOES';
                            inteReqRcrd.SPEN_Status__c = 'Completed';
                            update inteReqRcrd;
                            //system.debug('inteReqRcrd-------------->'+inteReqRcrd);
                        }
                        
                        else if(!ecosWrapper.Results[0].UtilityAddressMatches.isEmpty())
                        {
                            valCheck = true;
                            SPEN_MPAN__c mpanRcd = new SPEN_MPAN__c();
                            
                            if(ecosWrapper.Results[0].UtilityAddressMatches.size()>1)
                            {
                                for(SPEN_ECOSActualResponseWrapper.UtilityAddressMatches values : ecosWrapper.Results[0].UtilityAddressMatches)
                                {
                                    for(SPEN_ECOSActualResponseWrapper.Parameters nextValues : values.AddressDetails)
                                    {
                                        if(nextValues.key == 'mpan_core')
                                        {
                                            mpancoreValue = nextValues.Value;
                                        }
                                        if(nextValues.key == 'trading_status' && nextValues.Value != 'X')
                                        {
                                            activeMpanMap.put(nextValues.Value,mpancoreValue);
                                        }
                                    }
                                    break;
                                }
                                if(!activeMpanMap.isEmpty())
                                {
                                    temp = 'ElseExecuted';
                                }
                            }
                            
                            else
                            {
                                for(SPEN_ECOSActualResponseWrapper.UtilityAddressMatches val : ecosWrapper.Results[0].UtilityAddressMatches)
                                {
                                    for(SPEN_ECOSActualResponseWrapper.Parameters nextVal : val.AddressDetails)
                                    {
                                        if(valCheck)
                                        {
                                            if(nextVal.Key == 'mpancore')
                                            {
                                                mpancoreValue = nextVal.Value;
                                            }
                                            temp = 'IfExecuted';
                                        }
                                    } 
                                }
                            }
                            //system.debug('activeMpanMap---------->'+activeMpanMap);
                            
                            if(temp == 'IfExecuted' && mpancoreValue != '')
                            {
                                inteReqRcrd.SPEN_Response__c = mpancoreValue.left(2);
                                inteReqRcrd.SPEN_Status__c = 'Completed';
                                update inteReqRcrd; 
                            }
                            else if(temp == 'ElseExecuted')
                            {
                                inteReqRcrd.SPEN_Status__c = 'Completed';
                                if(activeMpanMap.get('T') != null){
                                    inteReqRcrd.SPEN_Response__c = activeMpanMap.get('T').left(2);
                                }
                                //inteReqRcrd.SPEN_Result__c = activeMpanMap.get('T');
                                update inteReqRcrd;
                            }
                            //system.debug('inteReqRcrd-------------->'+inteReqRcrd);
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
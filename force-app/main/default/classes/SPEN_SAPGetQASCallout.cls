/*-----------------------------------------------------------------------------
DESCRIPTION :   This class callouts Create Edit QAS operation
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
06-Jun-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/
public class SPEN_SAPGetQASCallout {
    public static List <SPEN_Plot__c> lstPlotToUpdated = new List<SPEN_Plot__c>();
    public static List<String> supplyPointCodes=new List<String>();
    public static Map<String,String> supplyPointCodetoMpan1Map = new Map<String,String>();
    public static Map<String,String> supplyPointCodetoMpan2Map = new Map<String,String>();
    @AuraEnabled
    //@future(callout=true)
    public Static void sendSoapCallout(String sapReference) 
    {
       try
       {
        	
            String enableAPI = System.Label.EnableSAPGetQas;
            String requestBody;
            String responseBody;
            String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_GetQas;
        	requestBody=SPEN_GetQASService.generateGetQASRequest(sapReference);
            HttpRequest request = new HttpRequest();
            //request.setEndpoint('callout:SAPNEW/getqas');
            request.setEndpoint(endPointURL);
            request.setMethod('POST');        
            request.setHeader('Content-Type', 'text/xml; charset=utf-8');
            request.setTimeout(Integer.valueOf(System.Label.SPEN_SAPTimeOut));
            request.setHeader('SOAPAction', 'urn:sap-com:document:sap:soap:functions:mc-style:ZJ_WS_SAPCREATEEDITQAS:ZJws001SapcreateeditqasRequest');
            request.setBody(requestBody);
            if(enableAPI.equalsIgnoreCase('True') && !Test.isRunningTest())
                {
                    Http http = new Http();
                    HTTPResponse response = http.send(request);
                    responseBody = response.getBody();
                    system.debug('actual callout route --------->>>>>');
                    system.debug('response --------->>>>>'+ response);
                    //system.debug('responseBody --------->>>>>'+ responseBody);                    
                    if( response.getStatusCode() == 200)
                    {
                        parseResponse(responseBody,'success');
                    }
                    else 
                    {
                        //parseResponse(operation,responseBody,caseRef,'fault');
                    }
                    
                }
           		else
                {
                    responseBody='<soap-env:Envelope 	xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZJws002SapgetqasResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style"><Returncode>000</Returncode><Zincontracting><Ukc1>0000824882</Ukc1><Ukc2>0000824882</Ukc2></Zincontracting><Zjews00message/><Zjews02cancel></Zjews02cancel><Zjews02plots><item><Zcodps>0001084405</Zcodps><Zplotid>1</Zplotid><Zclaseps>PS-UPUNTSUM</Zclaseps><Zperfilps>UPS00001</Zperfilps><Zpotensoli>18.0</Zpotensoli><Zupoten>KVA</Zupoten><Zfutphase>01</Zfutphase><Ztipsuelo/><Ztipprop>0000000002</Ztipprop><Zidproperty>7000075358</Zidproperty><Zheatmt>2</Zheatmt><Zheatyp>39</Zheatyp><Zdiscon/><Zdiscondate/><Zindtrataps/><Zmpan1>1800061258113</Zmpan1><Zmpan2/><Zsupplier/><Zcablivsch/><Zcablivact/><Zcodfinca/><ZnumCasa/><ZnumEdi/><Zbuilding/><Zcalle>Whitburn Road</Zcalle><Zbarrio/><Zcity>Bathgate</Zcity><Zcodpais>GB</Zcodpais><Zcodprov>FI</Zcodprov><Zcodpostal>EH48 1HH</Zcodpostal><Zuprn/><Numbed/><Evcharg/><Evquan/><Evgrid/><Zdistload>0.0</Zdistload><Zdistloadd/><Zcommty/><Zcomoth/></item></Zjews02plots><Zjews02pocont></Zjews02pocont><Zjews02proj></Zjews02proj><Zjews02qas><Zcodqas>000613487281</Zcodqas><Zcodestqas>Q0003</Zcodestqas><Zcodestcr>EX027</Zcodestcr><Zusuario>SP030745</Zusuario></Zjews02qas><Zjews02qashead></Zjews02qashead><Zjews02sitecont></Zjews02sitecont><Zjtegendet/><Zjtplogendt/></n0:ZJws002SapgetqasResponse></soap-env:Body></soap-env:Envelope>';
                	system.debug('mock callout route --------->>>>>');
                    parseResponse(responseBody,'mock');
                }
            
            if(!lstPlotToUpdated.isEmpty() && enableAPI.equalsIgnoreCase('True'))
            {
                update lstPlotToUpdated;
                system.debug('Plot details have been updated --------->>>>>'+lstPlotToUpdated);
            }
       }catch(Exception ex){
          System.debug('In class SPEN_SAPGetQASCallout : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
          SEL_LoggingService.log(ex);
          throw ex;
      }
    }
    
    Public Static Void parseResponse(String responseBody, String result)
    {
        DOM.Document document = new DOM.Document();
        document.load(responseBody);
        for (DOM.XmlNode node : document.getRootElement().getChildren())
        {
            if(node.getName() == 'Body')
            {
                for (DOM.XmlNode node2 : node.getChildren())
                {
                    if(result=='success' || result=='mock')
                    {
                        if(node2.getName() == 'ZJws002SapgetqasResponse')
                        {
                            for (DOM.XmlNode node3 : node2.getChildren())
                            {
                                if(node3.getName() == 'Zjews02plots')
                                {
                                    for (DOM.XmlNode node4 : node3.getChildren())
                                    {
                                        if(node4.getName() == 'item')
                                        {
                                            String supplyPointCode,mpan1,mpan2;
                                            for (DOM.XmlNode node5 : node4.getChildren())
                                            { 
                                                if(node5.getName() == 'Zmpan1')
                                        		{
                                                    mpan1=node5.getText();
                                                    system.debug('--------->>>>>>mpan1'+mpan1);
                                                }
                                                if(node5.getName() == 'Zmpan2')
                                        		{
                                                    mpan2=node5.getText();
                                                    system.debug('--------->>>>>mpan2'+mpan2);
                                                }
                                                if(node5.getName() == 'Zcodps')
                                                {
                                                    supplyPointCode=node5.getText();
                                                    system.debug('--------->>>>>supplyPointCode'+supplyPointCode);
                                                }
                                                    
                                            }
                                            supplyPointCodes.add(supplyPointCode);
                                            supplyPointCodetoMpan1Map.put(supplyPointCode,mpan1);
                                            supplyPointCodetoMpan2Map.put(supplyPointCode,mpan2);
                                        }
                                    }
                            	}
                        	}
                    	}
                    }
                }
    		}
		}
        
        List<SPEN_Plot__c> plotList=SPEN_PlotSelector.getPlotsFromSupplyPointCode(supplyPointCodes);
        //system.debug('--------->>>>>plotList from supply point code '+plotList);
        for(SPEN_Plot__c plotRef:plotList)
        {
            //system.debug('--------->>>>>supplyPointCodetoMpan1Map.get(plotRef.SPEN_SupplyPointCode__c)'+supplyPointCodetoMpan1Map.get(plotRef.SPEN_SupplyPointCode__c));
            plotRef.SPEN_MPAN1__c= supplyPointCodetoMpan1Map.get(plotRef.SPEN_SupplyPointCode__c);
            plotRef.SPEN_MPAN2__c= supplyPointCodetoMpan2Map.get(plotRef.SPEN_SupplyPointCode__c);
            lstPlotToUpdated.add(plotRef);
        }
    }

}
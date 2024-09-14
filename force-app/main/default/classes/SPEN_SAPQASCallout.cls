/*-----------------------------------------------------------------------------
DESCRIPTION :   This class callouts Create Edit QAS operation
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
06-Jun-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/
Global class SPEN_SAPQASCallout{
    public static List <Case> lstCaseToUpdated = new List<Case>();
    public static String sapMessage;
    public static List <SPEN_Plot__c> lstPlotToUpdated = new List<SPEN_Plot__c>();
    public static List <SPEN_Plot__c> lstPlotToDelete = new List<SPEN_Plot__c>();
    public static List <String> lstSupplyCodeToDelete = new List<String>();
    Public static List<SPEN_Plot__c> plotList = new List<SPEN_Plot__c>();
    public static Map<String,String> plotIdToSuplierCodeMap=new Map<String,String>();
    public static String plotRecordIdPrefix;
    public static Map<String,String> phyInfoKeyToItemIdMap = new Map<String, String>();//Akshay
    public static List<SPEN_PhysicalInformation__c> physInfoList = new List<SPEN_PhysicalInformation__c>();//Akshay
    public static List <SPEN_PhysicalInformation__c> lstPhysInfoToUpdated = new List<SPEN_PhysicalInformation__c>();//Akshay
    public static SPEN_PhysicalInformation__c physInfoRecord;
    @AuraEnabled
   @future(callout=true)
    public Static void sendSoapCallout(String operation, List<Id> lstCase) 
    {
        try
        {
            system.debug('Invoked sendSoapCallout of class SPEN_SAPQASCallout --------->>>>>'+lstCase);
            
            for(Case caseRef : SPEN_CaseSelector.getCaseDetailsForIds(lstCase))
            {
                String requestBody;
                system.debug('caseRef---'+caseRef);
                HttpRequest request = new HttpRequest();
                if(!caseRef.SPEN_IsCaseCompetentInSAP__c || 'TRANSFER_QAS'.equalsIgnoreCase(operation)) //createeditqas API
                {
                    String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_CreateEditQas;
                    request.setEndpoint(endPointURL);
                    //request.setEndpoint('callout:SAPCON/createeditqas');
                    requestBody = SPEN_SAPCreateEditQASService.generateCreateEditRequest(operation,caseRef); // to be updated by operatoin
                }
                else //physicalinf API (Competent)
                {
                    String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_PhysicalInf;
                    request.setEndpoint(endPointURL);
                    requestBody = SPEN_SAPCreateEditQASService.generatePhysInfoRequest(operation); // Operation is id of physical information record
                }
                
                request.setMethod('POST');    
                request.setTimeout(Integer.valueOf(System.Label.SPEN_SAPTimeOut));
                request.setHeader('Content-Type', 'text/xml; charset=utf-8');
                request.setHeader('SOAPAction', 'urn:sap-com:document:sap:soap:functions:mc-style:ZJ_WS_SAPCREATEEDITQAS:ZJws001SapcreateeditqasRequest');
                
                request.setBody(requestBody);
                system.debug('request --------->>>>>'+ request);
                system.debug('requestBody --------->>>>>'+ requestBody);
                String enableAPI = System.Label.EnableSAPCreateQas;
                String responseBody;
                if(enableAPI.equalsIgnoreCase('True') && !Test.isRunningTest())
                {
                    Http http = new Http();
                    HTTPResponse response = http.send(request);
                    responseBody = response.getBody();
                    system.debug('actual callout route --------->>>>>');
                    system.debug('response --------->>>>>'+ response);
                    system.debug('responseBody --------->>>>>'+ responseBody);
                    if( response.getStatusCode() == 200)
                    {
                        parseResponse(operation,responseBody,caseRef,'success');
                    }
                    else 
                    {
                        parseResponse(operation,responseBody,caseRef,'fault');
                    }
                }
                else if(!caseRef.SPEN_IsCaseCompetentInSAP__c)
                {
                    responseBody=	'<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/>'+
                        '<soap-env:Body><n0:ZJws001SapcreateeditqasResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                        '<Returncode>000</Returncode><Zcodqas>000612762162</Zcodqas><Zjews00message><item><Type>W</Type><Language>E</Language>'+
                        '<Id>ZDSPW</Id><Number>011</Number><Message>QAS Customer Req. 0000285363 created and not transferred</Message></item>'+	//Success
                        '<item><Type>E</Type><Language>E</Language><Id>ZDSPW</Id><Number>003</Number><Message>Errors in the Control record</Message></item>'+	//Error
                        '<item><Type>E</Type><Language>E</Language><Id>ZDSPW</Id><Number>007</Number><Message>Errors in the "Plots Data" table</Message></item>'	+//Error
                        '</Zjews00message><Zjews01enclet/><Zjews01letter/><Zjews01note/>'+
                        '<Zjews01pendinf>'+
                        '<item><Zimb>I</Zimb><Ziditem>000000098856</Ziditem><Zclaseitem>IT-UITEM</Zclaseitem><Zperfilitem>UIT00001</Zperfilitem><Zit1/><Ztexti1> physical information trial</Ztexti1><Zfecharecitem>20230725</Zfecharecitem><Zhorarecitem>080500</Zhorarecitem><Zit2/><Ztexti2>physical informaiton</Ztexti2><Zfechasolitem>20230725</Zfechasolitem><Zhorasolitem>080500</Zhorasolitem></item>'+
                        '</Zjews01pendinf>'+
                        
                        '<Zjews01plots>'+
                        '<item><Zimb>I</Zimb><Zcodps>0001022853</Zcodps><Zplotid/><Zclaseps>PS-UPUNTSUM</Zclaseps><Zperfilps>UPS00001</Zperfilps><Zpotensoli>69.0</Zpotensoli><Zupoten>KVA</Zupoten><Zfutphase>03</Zfutphase><Ztipsuelo>01</Ztipsuelo><Ztipprop>0000000001</Ztipprop><Zidproperty>26000000b1Hf</Zidproperty><Zheatmt>2</Zheatmt><Zheatyp>00</Zheatyp><Zdiscon>D</Zdiscon><Zdiscondate/><Zindtrataps>X</Zindtrataps><Zmpan1/><Zmpan2/><Zsupplier/><Zcablivsch/><Zcablivact/><Zcodfinca/><ZnumCasa/><ZnumEdi/><Zbuilding/><Zcalle>Test</Zcalle><Zbarrio/><Zcity>Test</Zcity><Zcodpais/><Zcodprov/><Zcodpostal>G2 5AD</Zcodpostal><Zuprn/><Zconnected/><Zvoltagemet/><Numbed/><Evcharg/><Evquan/><Evgrid/><Zdistload>0.0</Zdistload><Zdistloadd/><Zcommty/><Zcomoth/></item>'+
                        '<item><Zimb>I</Zimb><Zcodps>0001022854</Zcodps><Zplotid/><Zclaseps>PS-UPUNTSUM</Zclaseps><Zperfilps>UPS00001</Zperfilps><Zpotensoli>4.0</Zpotensoli><Zupoten>KVA</Zupoten><Zfutphase>01</Zfutphase><Ztipsuelo>03</Ztipsuelo><Ztipprop>0000000006</Ztipprop><Zidproperty>26000000b1Ha</Zidproperty><Zheatmt>2</Zheatmt><Zheatyp>00</Zheatyp><Zdiscon>D</Zdiscon><Zdiscondate/><Zindtrataps/><Zmpan1/><Zmpan2/><Zsupplier/><Zcablivsch/><Zcablivact/><Zcodfinca/><ZnumCasa/><ZnumEdi>51 Beech R</ZnumEdi><Zbuilding/><Zcalle>51 Beech Road</Zcalle><Zbarrio/><Zcity>St Albans</Zcity><Zcodpais/><Zcodprov/><Zcodpostal>AL3 5AP</Zcodpostal><Zuprn/><Zconnected/><Zvoltagemet/><Numbed/><Evcharg/><Evquan/><Evgrid/><Zdistload>0.0</Zdistload><Zdistloadd/><Zcommty/><Zcomoth/></item>'+
                        '</Zjews01plots>'+
                        '<Zjtegendet/>'+'<Zjtplogendt/><Zusuario/></n0:ZJws001SapcreateeditqasResponse></soap-env:Body></soap-env:Envelope>';
                    system.debug('mock callout route --------->>>>>');
                    system.debug('responseBody --------->>>>>'+ responseBody);
                    parseResponse(operation,responseBody,caseRef,'mock');        
                }
                else 
                {
                     responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
                        '<soap-env:Body>'+'<n0:Fault xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                        '<Returncode>000</Returncode>'+'<faultstring>000000098886</faultstring>'+'<Zjews00message>'+
                        '<item>'+'<Type/>'+'<Language/>'+'<Id/>'+'<Number>000</Number>'+'<Message/>'+'</item>'+'<item>'+
                        '<Type>W</Type>'+'<Language>E</Language>'+'<Id>ZDSPW</Id>'+'<Number>008</Number>'+
                        '<Message>Physical Information saved successfully</Message>'+
                        '</item>'+'</Zjews00message>'+'<Zjews05letter>'+'<item>'+
                        '<Zlettertemple/>'+'<Zfield/>'+'<Text/>'+'</item>'+'</Zjews05letter>'+
                        '</n0:Fault>'+'</soap-env:Body>'+'</soap-env:Envelope>' ; 
                    parseResponse(operation,responseBody,caseRef,'mock');  
                    
                    responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
                        '<soap-env:Body>'+'<n0:Fault xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                        '<Returncode>000</Returncode>'+'<faultstring>000000098886</faultstring>'+'<Zjews00message>'+
                        '<item>'+'<Type/>'+'<Language/>'+'<Id/>'+'<Number>000</Number>'+'<Message/>'+'</item>'+'<item>'+
                        '<Type>W</Type>'+'<Language>E</Language>'+'<Id>ZDSPW</Id>'+'<Number>008</Number>'+
                        '<Message>Physical Information saved successfully</Message>'+
                        '</item>'+'</Zjews00message>'+'<Zjews05letter>'+'<item>'+
                        '<Zlettertemple/>'+'<Zfield/>'+'<Text/>'+'</item>'+'</Zjews05letter>'+
                        '</n0:Fault>'+'</soap-env:Body>'+'</soap-env:Envelope>' ; 
                    parseResponse(operation,responseBody,caseRef,'Fault');                          


                    responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
                        '<soap-env:Body>'+'<n0:ZJws005SapcrcreatephysiNamsResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                        '<Returncode>000</Returncode>'+'<Ziditem>000000098886</Ziditem>'+'<Zjews00message>'+
                        '<item>'+'<Type/>'+'<Language/>'+'<Id/>'+'<Number>000</Number>'+'<Message/>'+'</item>'+'<item>'+
                        '<Type>W</Type>'+'<Language>E</Language>'+'<Id>ZDSPW</Id>'+'<Number>008</Number>'+
                        '<Message>Physical Information saved successfully</Message>'+
                        '</item>'+'</Zjews00message>'+'<Zjews05letter>'+'<item>'+
                        '<Zlettertemple/>'+'<Zfield/>'+'<Text/>'+'</item>'+'</Zjews05letter>'+
                        '</n0:ZJws005SapcrcreatephysiNamsResponse>'+'</soap-env:Body>'+'</soap-env:Envelope>' ; 
                    
                    system.debug('mock callout route --------->>>>>');
                    system.debug('responseBody --------->>>>>'+ responseBody);
                    parseResponse(operation,responseBody,caseRef,'mock');                          
                }
            }
            if(!lstCaseToUpdated.isEmpty())
            {
                system.debug('lstCaseToUpdated==='+lstCaseToUpdated);
                update lstCaseToUpdated;
                system.debug('Case details have been updated --------->>>>>');
            }
            if(!lstPlotToUpdated.isEmpty())
            {
                update lstPlotToUpdated;
                system.debug('Plot details have been updated --------->>>>>');
            }
            if(!lstPlotToDelete.isEmpty())
            {
                delete lstPlotToDelete;
                system.debug('Plot details have been deleted --------->>>>>');
            }
            if(!lstPhysInfoToUpdated.isEmpty())
            {
                update lstPhysInfoToUpdated;
                system.debug('Physical Infomration details have been updated --------->>>>>');
            }
            
        }catch(Exception ex){
            System.debug('In class SPEN_SAPQASCallout : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            SEL_LoggingService.log(ex);
            throw new StringException(sapMessage);// MyCustomException(String.valueOf(ex.getMessage()), sapMessage);      
            
        }
        
    }

    public Static void sendSoapCalloutSyncCall(String operation, List<Id> lstCase) 
    {
        try
        {
            system.debug('Invoked sendSoapCalloutSyncCall of class SPEN_SAPQASCallout --------->>>>>'+lstCase);
            
            for(Case caseRef : SPEN_CaseSelector.getCaseDetailsForIds(lstCase))
            {
                String requestBody;
                system.debug('caseRef---'+caseRef);
                HttpRequest request = new HttpRequest();
                if(!caseRef.SPEN_IsCaseCompetentInSAP__c) //createeditqas API
                {
                     String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_CreateEditQas;
                    request.setEndpoint(endPointURL);
                    requestBody = SPEN_SAPCreateEditQASService.generateCreateEditRequest(operation,caseRef); // to be updated by operatoin
                }
                else //physicalinf API (Competent)
                {
                    String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_PhysicalInf;
                    request.setEndpoint(endPointURL);
                    requestBody = SPEN_SAPCreateEditQASService.generatePhysInfoRequest(operation); // Operation is id of physical information record
                }
                
                request.setMethod('POST');        
                request.setHeader('Content-Type', 'text/xml; charset=utf-8');
                request.setHeader('SOAPAction', 'urn:sap-com:document:sap:soap:functions:mc-style:ZJ_WS_SAPCREATEEDITQAS:ZJws001SapcreateeditqasRequest');
                request.setTimeout(Integer.valueOf(System.Label.SPEN_SAPTimeOut));
                request.setBody(requestBody);
                system.debug('request --------->>>>>'+ request);
                system.debug('requestBody --------->>>>>'+ requestBody);
                String enableAPI = System.Label.EnableSAPCreateQas;
                String responseBody;
                if(enableAPI.equalsIgnoreCase('True') && !Test.isRunningTest())
                {
                    Http http = new Http();
                    HTTPResponse response = http.send(request);
                    responseBody = response.getBody();
                    system.debug('actual callout route --------->>>>>');
                    system.debug('response --------->>>>>'+ response);
                    system.debug('responseBody --------->>>>>'+ responseBody);
                    if( response.getStatusCode() == 200)
                    {
                        parseResponse(operation,responseBody,caseRef,'success');
                    }
                    else 
                    {
                        parseResponse(operation,responseBody,caseRef,'fault');
                    }
                }
                else if(!caseRef.SPEN_IsCaseCompetentInSAP__c)
                {
                   responseBody=	'<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/>'+
                                    '<soap-env:Body><n0:ZJws001SapcreateeditqasResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                                    '<Returncode>000</Returncode><Zcodqas>000612762162</Zcodqas><Zjews00message><item><Type>W</Type><Language>E</Language>'+
                                    '<Id>ZDSPW</Id><Number>011</Number><Message>QAS Customer Req. 0000285363 created and not transferred</Message></item>'+	//Success
                        			'<item><Type>E</Type><Language>E</Language><Id>ZDSPW</Id><Number>003</Number><Message>Errors in the Control record</Message></item>'+	//Error
                        			'<item><Type>E</Type><Language>E</Language><Id>ZDSPW</Id><Number>007</Number><Message>Errors in the "Plots Data" table</Message></item>'	+//Error
                                    '</Zjews00message><Zjews01enclet/><Zjews01letter/><Zjews01note/>'+
									'<Zjews01pendinf>'+
									'<item><Zimb>I</Zimb><Ziditem>000000098856</Ziditem><Zclaseitem>IT-UITEM</Zclaseitem><Zperfilitem>UIT00001</Zperfilitem><Zit1/><Ztexti1> physical information trial</Ztexti1><Zfecharecitem>20230725</Zfecharecitem><Zhorarecitem>080500</Zhorarecitem><Zit2/><Ztexti2>physical informaiton</Ztexti2><Zfechasolitem>20230725</Zfechasolitem><Zhorasolitem>080500</Zhorasolitem></item>'+
									'</Zjews01pendinf>'+
									
                       				'<Zjews01plots>'+
                       				'<item><Zimb>I</Zimb><Zcodps>0001022853</Zcodps><Zplotid/><Zclaseps>PS-UPUNTSUM</Zclaseps><Zperfilps>UPS00001</Zperfilps><Zpotensoli>69.0</Zpotensoli><Zupoten>KVA</Zupoten><Zfutphase>03</Zfutphase><Ztipsuelo>01</Ztipsuelo><Ztipprop>0000000001</Ztipprop><Zidproperty>26000000b1Hf</Zidproperty><Zheatmt>2</Zheatmt><Zheatyp>00</Zheatyp><Zdiscon>D</Zdiscon><Zdiscondate/><Zindtrataps>X</Zindtrataps><Zmpan1/><Zmpan2/><Zsupplier/><Zcablivsch/><Zcablivact/><Zcodfinca/><ZnumCasa/><ZnumEdi/><Zbuilding/><Zcalle>Test</Zcalle><Zbarrio/><Zcity>Test</Zcity><Zcodpais/><Zcodprov/><Zcodpostal>G2 5AD</Zcodpostal><Zuprn/><Zconnected/><Zvoltagemet/><Numbed/><Evcharg/><Evquan/><Evgrid/><Zdistload>0.0</Zdistload><Zdistloadd/><Zcommty/><Zcomoth/></item>'+
                       				'<item><Zimb>I</Zimb><Zcodps>0001022854</Zcodps><Zplotid/><Zclaseps>PS-UPUNTSUM</Zclaseps><Zperfilps>UPS00001</Zperfilps><Zpotensoli>4.0</Zpotensoli><Zupoten>KVA</Zupoten><Zfutphase>01</Zfutphase><Ztipsuelo>03</Ztipsuelo><Ztipprop>0000000006</Ztipprop><Zidproperty>26000000b1Ha</Zidproperty><Zheatmt>2</Zheatmt><Zheatyp>00</Zheatyp><Zdiscon>D</Zdiscon><Zdiscondate/><Zindtrataps/><Zmpan1/><Zmpan2/><Zsupplier/><Zcablivsch/><Zcablivact/><Zcodfinca/><ZnumCasa/><ZnumEdi>51 Beech R</ZnumEdi><Zbuilding/><Zcalle>51 Beech Road</Zcalle><Zbarrio/><Zcity>St Albans</Zcity><Zcodpais/><Zcodprov/><Zcodpostal>AL3 5AP</Zcodpostal><Zuprn/><Zconnected/><Zvoltagemet/><Numbed/><Evcharg/><Evquan/><Evgrid/><Zdistload>0.0</Zdistload><Zdistloadd/><Zcommty/><Zcomoth/></item>'+
                       				'</Zjews01plots>'+
                       				'<Zjtegendet/>'+'<Zjtplogendt/><Zusuario/></n0:ZJws001SapcreateeditqasResponse></soap-env:Body></soap-env:Envelope>';
                    system.debug('mock callout route --------->>>>>');
                    system.debug('responseBody --------->>>>>'+ responseBody);
                    parseResponse(operation,responseBody,caseRef,'mock');        
                }
                else 
                {
                    responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
                        '<soap-env:Body>'+'<n0:ZJws005SapcrcreatephysiNamsResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                        '<Returncode>000</Returncode>'+'<Ziditem>000000098886</Ziditem>'+'<Zjews00message>'+
                        '<item>'+'<Type/>'+'<Language/>'+'<Id/>'+'<Number>000</Number>'+'<Message/>'+'</item>'+'<item>'+
                        '<Type>W</Type>'+'<Language>E</Language>'+'<Id>ZDSPW</Id>'+'<Number>008</Number>'+
                        '<Message>Physical Information saved successfully</Message>'+
                        '</item>'+'</Zjews00message>'+'<Zjews05letter>'+'<item>'+
                        '<Zlettertemple/>'+'<Zfield/>'+'<Text/>'+'</item>'+'</Zjews05letter>'+
                        '</n0:ZJws005SapcrcreatephysiNamsResponse>'+'</soap-env:Body>'+'</soap-env:Envelope>' ; 
                    
                    system.debug('mock callout route --------->>>>>');
                    system.debug('responseBody --------->>>>>'+ responseBody);
                    parseResponse(operation,responseBody,caseRef,'mock');                          
                }
            }
        if(!lstCaseToUpdated.isEmpty())
        {
            update lstCaseToUpdated;
            system.debug('Case details have been updated --------->>>>>');
        }
        if(!lstPlotToUpdated.isEmpty())
        {
            update lstPlotToUpdated;
            system.debug('Plot details have been updated --------->>>>>');
        }
        if(!lstPlotToDelete.isEmpty())
        {
            delete lstPlotToDelete;
            system.debug('Plot details have been deleted --------->>>>>');
        }
        if(!lstPhysInfoToUpdated.isEmpty())
        {
            update lstPhysInfoToUpdated;
            system.debug('Physical Infomration details have been updated --------->>>>>');
        }
        
        }catch(Exception ex){
            System.debug('In class SPEN_SAPQASCallout : exception block='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            SEL_LoggingService.log(ex);
            throw ex;
        }
        
    }
    
    Public Static Void parseResponse(String operation,String responseBody,Case caseRef,String result)
    {
        Case caseObj=caseRef;
        plotList = 	SPEN_PlotSelector.getPlotsFromCase(caseRef.Id);
        String sapCaseReferecnce;
        String errorMessage='';
        //Boolean isError=false;
        physInfoList = SPEN_PhysicalInformationSelector.getPhysicalInfoFromCase(caseRef.Id);//Akshay
        // physInfoRecord = [select id from SPEN_PhysicalInformation__c where id =: operation limit 1]; 
        String phyInfoReference; 
        
        if(!plotList.isEmpty())
        {
            String strId = plotList[0].Id;
            plotRecordIdPrefix=strId.substring(0, 3);
        }
  
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
                        if(node2.getName() == 'ZJws001SapcreateeditqasResponse') //This block handles createeditqas API
                        {
                            for (DOM.XmlNode node3 : node2.getChildren())
                            {
                                if(node3.getName() == 'Zcodqas')
                                {
                                    // to be saved in contact - sapqasid : externalid 
                                    System.debug('sapqasid --------->>>>>'+node3.getName()+'  '+node3.getText());
                                    sapCaseReferecnce=node3.getText();
                                }else if(node3.getName() == 'Zjews00message'){
                                    for (DOM.XmlNode node4 : node3.getChildren()){
                                        if(node4.getName() == 'item'){
                                            for (DOM.XmlNode node5 : node4.getChildren()){
                                                /*if(node5.getName() == 'Type' && node5.getText() == 'E'){
                                                    //isError=true;
                                                } */ //PMD Rule no action in if block                                               
                                                //else if(isError && node5.getName() == 'Message'){
                                                if(node5.getName() == 'Message'){
                                                    errorMessage=errorMessage+node5.getText()+'.';
                                                    //isError=false;
                                                    system.debug('errorMessage --------->>>>>'+errorMessage);
                                                }
                                            } 
                                        }
                                    }   
                                }else if(node3.getName() == 'Zjews01plots'){
                                    for (DOM.XmlNode node4 : node3.getChildren()){
                                        if(node4.getName() == 'item'){
                                            String insertUpdateFlag='';
                                            
                                            String propertyId='';
                                            String supplyPointCode='';
                                            for (DOM.XmlNode node5 : node4.getChildren()){
                                                if(node5.getName() == 'Zimb'){
                                                    insertUpdateFlag=node5.getText();
                                                }
                                                if(node5.getName() == 'Zcodps'){
                                                    supplyPointCode=node5.getText();
                                                }
                                                if(node5.getName() == 'Zidproperty'){
                                                    propertyId=plotRecordIdPrefix+node5.getText();
                                                }
                                            }
                                            if(insertUpdateFlag.equalsIgnoreCase('I'))
                                            {
                                                plotIdToSuplierCodeMap.put(propertyId,supplyPointCode);
                                            }
                                            else if (errorMessage.contains('QAS Customer Req.') && insertUpdateFlag.equalsIgnoreCase('B'))
                                            {
											    lstSupplyCodeToDelete.add(supplyPointCode);    //PMD Curly braces                                     
                                            }
                                        }
                                    }   
                                }
                                else if(node3.getName() == 'Zjews01pendinf'){//Akshay
                                    for (DOM.XmlNode node4 : node3.getChildren()){
                                        if(node4.getName() == 'item'){
                                            String insertUpdatePhysInfoFlag='';
                                            
                                            String physInfoId='';
                                            String itemID='';
                                            for (DOM.XmlNode node5 : node4.getChildren()){
                                                if(node5.getName() == 'Zimb'){
                                                    insertUpdatePhysInfoFlag=node5.getText();
                                                }
                                                if(node5.getName() == 'Ziditem'){
                                                    itemID=node5.getText();
                                                }
                                                if(node5.getName() == 'Ztexti1'){
                                                    physInfoId=(node5.getText()).substringBetween('{Ref:','}');
                                                }
                                            }
                                            if(insertUpdatePhysInfoFlag.equalsIgnoreCase('I'))
                                            {
                                                phyInfoKeyToItemIdMap.put(physInfoId,itemID);
                                            }
                                            //else if (errorMessage.contains('QAS Customer Req.') && insertUpdateFlag.equalsIgnoreCase('B'))
											//lstSupplyCodeToDelete.add(supplyPointCode);                                         
                                        }
                                    }   
                                }                            
                                /*else if(node3.getName() == 'Zjews00message'){
                                    for (DOM.XmlNode node4 : node3.getChildren()){
                                        if(node4.getName() == 'item'){
                                            for (DOM.XmlNode node5 : node4.getChildren()){                                                
                                                if(node5.getName() == 'Message'){
                                                    //case SPEN_SAPReference__c
                                                    System.debug('SPEN_SAPReference__c full text--------->>>>>'+node5.getName()+'  '+node5.getText());
                                                    //String sapReference = parseNumberFromString(node5.getText());
                                                    //System.debug('SPEN_SAPReference__c--------->>>>>'+sapReference);
                                                }
                                            } 
                                        }
                                    }   
                                }*/
                            }
                        }
                        else if(node2.getName() == 'ZJws005SapcrcreatephysiNamsResponse') //This block handles physicalinf (Competent) API
                        {
                            for (DOM.XmlNode node3 : node2.getChildren())
                            {
                                if(node3.getName() == 'Ziditem'){
                                    //Need to save in Physical Information record : externalid
                                    System.debug('phyInfoid --------->>>>>'+node3.getName()+'  '+node3.getText());
                                    phyInfoReference=node3.getText();
                                }else if(node3.getName() == 'Zjews00message'){
                                    for (DOM.XmlNode node4 : node3.getChildren()){
                                        if(node4.getName() == 'item'){
                                            for (DOM.XmlNode node5 : node4.getChildren()){
                                                if(node5.getName() == 'Message'){
                                                    errorMessage=errorMessage+node5.getText()+'.';
                                                    //isError=false;
                                                    system.debug('errorMessage --------->>>>>'+errorMessage);
                                                }
                                            } 
                                        }
                                    }                               
                                }
                            }
                        }
                        
                        if(node2.getName() == 'Fault')
                        {
                            for (DOM.XmlNode node3 : node2.getChildren())
                            {
                                if(node3.getName() == 'faultstring')
                                {
                                    errorMessage=errorMessage+node3.getText()+'.';
                                }
                            }
                        }
                    }
                    else
                    {
                        if(node2.getName() == 'Fault')
                        {
                            for (DOM.XmlNode node3 : node2.getChildren())
                            {
                                if(node3.getName() == 'faultstring')
                                {
                                    errorMessage=errorMessage+node3.getText()+'.';
                                }
                            }
                        }
                    }
                    
                }
            }
        }
        if(operation=='CREATE_QAS')
        {
            caseObj.SPEN_SAPReference__c=sapCaseReferecnce;
            if(sapCaseReferecnce != null)
            {
                SPEN_FinancialInformation__c finInfo = new SPEN_FinancialInformation__c(Name = caseObj.CaseNumber+' : '+'Financial Info'+' : '+sapCaseReferecnce ,SPEN_SAPReference__c = sapCaseReferecnce);
                insert finInfo;
                caseObj.SPEN_FinancialInformation__c = finInfo.id;
            }
        }
        caseObj.SPEN_SAPErrorDetails__c=errorMessage;
        SapMessage = errorMessage;
        if (errorMessage.containsIgnoreCase('and transferred'))
        {
            caseObj.SPEN_SyncToSAPDate__c=System.now(); //CRMD-7242 : Rajat
            caseObj.SPEN_IsCaseCompetentInSAP__c = true ;
            if(caseObj.SPEN_CaseTransferredDateTimeInSAP__c == null)
            {
                caseObj.SPEN_CaseTransferredDateTimeInSAP__c = System.now(); 
            }
        }
        else if(errorMessage.containsIgnoreCase('modified and not transferred')) {
            caseObj.SPEN_SyncToSAPDate__c=System.now(); //CRMD-7242 : Rajat
        }
        else {
            caseObj.SPEN_SyncToSAPDate__c=null; //CRMD-7242 : Rajat
        }
        // Started changes for CRMD-10704 Enh 
       if(!caseObj.SPEN_IsCaseCompetentInSAP__c || 'TRANSFER_QAS'.equalsIgnoreCase(operation)){
         if(errorMessage != null && !errorMessage.containsIgnoreCase('QAS Customer Req.') &&
           !errorMessage.containsIgnoreCase('.Physical Information saved successfully') && 
            !errorMessage.containsIgnoreCase('.Cancel QAS saved successfully.') && 
            !errorMessage.containsIgnoreCase('PM update success.')
           ){
              caseObj.SPEN_SubStatus__c = CasesConstants.CASE_NOTCOMPETENT;
           }
        } // End changes for CRMD-10704 Enh 
        
        System.debug('caseObj to be save --------->>>>>'+caseObj);
        lstCaseToUpdated.add(caseObj);
        
        if(operation.length() != 18)
        {
            //Update supplycode in Plot
            System.debug('plotIdToSuplierCodeMap --------->>>>>'+plotIdToSuplierCodeMap);
            for (SPEN_Plot__c plotObjRef:plotList)
            {
                String plotId=plotObjRef.Id;
                plotId=plotId.substring(0, plotId.length()-3);
                if(plotIdToSuplierCodeMap.containsKey(plotId))
                {
                    
                    plotObjRef.SPEN_SupplyPointCode__c=plotIdToSuplierCodeMap.get(plotId);
                    lstPlotToUpdated.add(plotObjRef);
                }
                if(lstSupplyCodeToDelete.contains(plotObjRef.SPEN_SupplyPointCode__c) || (plotObjRef.SPEN_Status__c=='To be delete' && String.isBlank(plotObjRef.SPEN_SupplyPointCode__c)))
                {
                    //plotObjRef.SPEN_Status__c='Deleted';
                    lstPlotToDelete.add(plotObjRef);
                }
            }
            System.debug('plots to be save --------->>>>>'+lstPlotToUpdated);
            System.debug('plots to be deleted --------->>>>>'+lstPlotToDelete);
            
            //Update supplycode in Physical Information Akshay
            System.debug('plotIdToSuplierCodeMap --------->>>>>'+phyInfoKeyToItemIdMap );
            for (SPEN_PhysicalInformation__c physInfoObjRef:physInfoList)
            {
                String physInfoId = physInfoObjRef.Id;
                if(phyInfoKeyToItemIdMap.containsKey(physInfoId))
                {
                    physInfoObjRef.SPEN_ItemID__c=phyInfoKeyToItemIdMap.get(physInfoId);
                    physInfoObjRef.Sync_Sap_Status__c = 'Success';
                    lstPhysInfoToUpdated.add(physInfoObjRef);
                }
            }
            System.debug('Physical Information to be save --------->>>>>'+lstPhysInfoToUpdated);
        }
        else 
        {
            physInfoRecord = [select id,SPEN_ItemID__c,Sync_Sap_Status__c from SPEN_PhysicalInformation__c where id =: operation limit 1]; 
            if(!String.isBlank(phyInfoReference) && physInfoRecord.SPEN_ItemID__c == null)
            {
                physInfoRecord.SPEN_ItemID__c =  phyInfoReference;
                physInfoRecord.Sync_Sap_Status__c = 'Success';
            }
            lstPhysInfoToUpdated.add(physInfoRecord);
        }
        
    }
    public String parseNumberFromString(String content)
    {
        String parsedResult;
        if(!String.isEmpty(content))
        {
            Pattern pat = Pattern.compile('([0-9]+)');
            Matcher matcher = pat.matcher(content);
            Boolean matches = matcher.find();
            parsedResult=matcher.group(1);
        }
        return parsedResult;
    }
}
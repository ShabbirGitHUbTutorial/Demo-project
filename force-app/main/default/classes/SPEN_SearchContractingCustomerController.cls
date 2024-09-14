public with sharing class SPEN_SearchContractingCustomerController {
    
    @AuraEnabled
    public static List<SearchCustomerWrapperClass> getSearchData(SearchWrapper searchParam){
        List<SearchCustomerWrapperClass> searchResObjList = new List<SearchCustomerWrapperClass>();
        try{
            System.debug('searchParam>>>>>'+searchParam);
            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'urn:sap-com:document:sap:rfc:functions';
            dom.XmlNode results = doc.createRootElement('Envelope', soapNS, 'soapenv');
            results.setNamespace('urn', xsi);
            dom.XmlNode headerTag = results.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyTag = results.addChildElement('soapenv:Body', null, null);
            dom.XmlNode urnDEUDORESTag = bodyTag.addChildElement('urn:Z_RF01FCGBUSQ_DEUDORES', null, null);
            dom.XmlNode iENTRADATag = urnDEUDORESTag.addChildElement('I_ENTRADA', null, null);
            dom.XmlNode iREGISTROSag = urnDEUDORESTag.addChildElement('I_REGISTROS', null, null);
            dom.XmlNode originTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'ORIGIN', ('SF') );
            dom.XmlNode customerTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CUSTOMER', ('') );
            dom.XmlNode formOfADTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'FORM_OF_AD', ('') );
            dom.XmlNode nameTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'NAME', (!String.isEmpty(searchParam.companyName) ? (searchParam.companyName).toUpperCase() : ''));
            dom.XmlNode streetTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'STREET', (!String.isEmpty(searchParam.street) ? (searchParam.street).toUpperCase() : ''));
            dom.XmlNode houseNumTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'HOUSE_NUM1', (''));
            dom.XmlNode street2Tag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'STREET2', (!String.isEmpty(searchParam.building) ? (searchParam.building).toUpperCase() : ''));
            dom.XmlNode postCodeTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'POSTL_CODE', (!String.isEmpty(searchParam.postcode) ? (searchParam.postcode).toUpperCase() : ''));
            dom.XmlNode cityTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CITY', ('') );
            dom.XmlNode countyTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'COU', ('') );
            dom.XmlNode countryTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'COUN', ('') );
            dom.XmlNode emailTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'EMAIL', (!String.isEmpty(searchParam.email) ? (searchParam.email).toUpperCase() : ''));
            dom.XmlNode customerTypeTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CUSTOMERTYPE', ('') );
            dom.XmlNode customerClassTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CUSTOMERCLASS', ('') );
            dom.XmlNode faxNumberTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'FAX_NUMBER', (!String.isEmpty(searchParam.fax) ? searchParam.fax : ''));
            dom.XmlNode telephoneTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'TELEPHONE', (!String.isEmpty(searchParam.phone) ? searchParam.phone : ''));
            dom.XmlNode mobileTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'MOBILE', (!String.isEmpty(searchParam.mobile) ? searchParam.mobile : ''));
            dom.XmlNode companyCodeTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'COMPANY_CODE',(''));
            dom.XmlNode tax1Tag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'TAX1', (!String.isEmpty(searchParam.vat) ? (searchParam.vat).toUpperCase() : ''));
            dom.XmlNode tax2Tag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'TAX2', (!String.isEmpty(searchParam.crn) ? searchParam.crn : '') );
            String xmlstring = doc.toXmlString();
            String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_SearchData;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
            req.setHeader('SOAPAction', 'urn:sap-com:document:sap:soap:functions:mc-style:ZJ_WS_SAPCREATEEDITQAS:ZJws001SapcreateeditqasRequest');
            req.setTimeout(Integer.valueOf(System.Label.SPEN_SAPTimeOut));
            req.setBody(xmlstring);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String resultStr = res.getBody();
            if( res.getStatusCode() == 200){
                String enableAPI = System.Label.EnableSAPSearch;
                if(enableAPI.equalsIgnoreCase('false') || Test.isRunningTest()){
                    resultStr ='<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">   <soap-env:Header/>   <soap-env:Body>      <n0:Z_RF01FCGBUSQ_DEUDORESResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">         <E_RC/>         <E_RETURN/>         <E_SALIDA>            <item>               <KUNNR>0000819647</KUNNR>               <BILL_TO_PARTY>0000819647</BILL_TO_PARTY>               <NAME1>test integracion</NAME1>               <STREET>test integracion</STREET>               <ZHOUSE_NUM/>               <STR_SUPPL1/>               <PSTLZ>G74 3SY</PSTLZ>               <CITY1>test integracion</CITY1>               <LAND1>GB</LAND1>               <TELF1>01355458775</TELF1>               <SMTP_ADDR/>               <STCEG/>               <STCD1/>               <ZMOTIVO/>               <ZBLOQUEO>N</ZBLOQUEO>               <ZDELFLAG>N</ZDELFLAG>            </item>            <item>               <KUNNR>0000824801</KUNNR>               <BILL_TO_PARTY>0000824801</BILL_TO_PARTY>               <NAME1>GRAEME LANG</NAME1>               <STREET>38</STREET>               <ZHOUSE_NUM/>               <STR_SUPPL1/>               <PSTLZ>G74 3SY</PSTLZ>               <CITY1>EAST KILBRIDE</CITY1>               <LAND1>GB</LAND1>               <TELF1>07715111111</TELF1>               <SMTP_ADDR/>               <STCEG/>               <STCD1/>               <ZMOTIVO/>               <ZBLOQUEO>N</ZBLOQUEO>               <ZDELFLAG>N</ZDELFLAG>            </item>  <item>               <KUNNR>0000818867</KUNNR>               <BILL_TO_PARTY>0000818867</BILL_TO_PARTY>               <NAME1>SCOTTISH POWER FOUNDATION</NAME1>               <STREET>320 ST VINCENT ST</STREET>               <ZHOUSE_NUM/>               <STR_SUPPL1/>               <PSTLZ>G2 5AD</PSTLZ>               <CITY1>GLASGOW</CITY1>               <LAND1>GB</LAND1>               <TELF1>01416140209</TELF1>               <SMTP_ADDR/>               <STCEG/>               <STCD1/>               <ZMOTIVO/>               <ZBLOQUEO>N</ZBLOQUEO>               <ZDELFLAG>N</ZDELFLAG>            </item> <item>               <KUNNR>0000714791</KUNNR>               <BILL_TO_PARTY>0000761632</BILL_TO_PARTY>               <NAME1>SP ENERGY NETWORKS</NAME1>               <STREET>3, prenton way</STREET>               <ZHOUSE_NUM/>               <STR_SUPPL1/>               <PSTLZ>CH43 3ET</PSTLZ>               <CITY1>prenton</CITY1>               <LAND1>GB</LAND1>               <TELF1>141614603</TELF1>               <SMTP_ADDR/>               <STCEG/>               <STCD1/>               <ZMOTIVO/>               <ZBLOQUEO>Y</ZBLOQUEO>               <ZDELFLAG>N</ZDELFLAG>            </item>        </E_SALIDA>         <E_SOCIEDADES>            <item>               <CUSTOMER>0000819647</CUSTOMER>               <BUKRS>8301</BUKRS>            </item>            <item>               <CUSTOMER>0000824801</CUSTOMER>               <BUKRS>8301</BUKRS>            </item>         </E_SOCIEDADES>      </n0:Z_RF01FCGBUSQ_DEUDORESResponse>   </soap-env:Body></soap-env:Envelope>';
                }
                DOM.Document document = new DOM.Document();
                System.debug('resultStr>>>>'+resultStr);
                document.load(resultStr);
                
                for (DOM.XmlNode node : document.getRootElement().getChildren())
                {
                    if(node.getName() == 'Body'){
                        for (DOM.XmlNode node2 : node.getChildren()){
                            System.debug('getName>>>>'+node2.getName());
                            if(node2.getName() != null && node2.getName().containsIgnoreCase('Z_RF01FCGBUSQ_DEUDORESResponse')){
                                for (DOM.XmlNode node3 : node2.getChildren()){
                                    if(node3.getName() == 'E_SALIDA'){
                                        for (DOM.XmlNode node4 : node3.getChildren()){
                                            if(node4.getName() == 'item'){
                                                SearchCustomerWrapperClass searchResObj = new SearchCustomerWrapperClass();
                                                for (DOM.XmlNode node5 : node4.getChildren()){
                                                    System.debug(node5.getName()+'  '+node5.getText());
                                                    if(node5.getName() == 'KUNNR'){
                                                        searchResObj.ukc1 = node5.getText();
                                                    }else if(node5.getName() == 'BILL_TO_PARTY'){
                                                        searchResObj.ukc2 = node5.getText();
                                                    }else if(node5.getName() == 'ZBLOQUEO'){
                                                        searchResObj.block = node5.getText();
                                                    }else if(node5.getName() == 'NAME1'){
                                                        searchResObj.companyName = node5.getText();
                                                    }else if(node5.getName() == 'STREET'){
                                                        searchResObj.address = node5.getText();
                                                    }else if(node5.getName() == 'TELF1'){
                                                        searchResObj.phoneNumber = node5.getText();
                                                    }else if(node5.getName() == 'SMTP_ADDR'){
                                                        searchResObj.email = node5.getText();
                                                    }else if(node5.getName() == 'STCEG'){
                                                        searchResObj.vat = node5.getText();
                                                    }else if(node5.getName() == 'STCD1'){
                                                        searchResObj.crn = node5.getText();
                                                    }else if(node5.getName() == 'PSTLZ'){
                                                        searchResObj.postcode = node5.getText();
                                                    }
                                                }
                                                searchResObjList.add(searchResObj);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }  
            return searchResObjList;
        }catch (Exception e) {
            SEL_LoggingService.log(e);
            return null;
        }
    }

    @AuraEnabled
    public static String checkQASValue(Id caseRecordId){
        String returnCheck='';
        if(String.isNotBlank(caseRecordId)){
            Case caseObj = SPEN_CaseSelector.getCaseDetailsForSAPCallout(caseRecordId)[0];
            if(String.isEmpty(caseObj.AccountId)){
                returnCheck = 'NOACCEXIST';
            }
            else {
                if(String.isNotBlank(caseObj.AccountId)){
                    List<Case> caseRelated = SPEN_CaseSelector.getAccountDetailsFromCase(caseObj.AccountId);
                    if(!caseRelated.isEmpty()){
                        returnCheck = 'ACCEXISTWITHSAP';
                    }
                    else{
                        returnCheck = 'ACCEXISTWITHOUTSAP';
                    }
                }
            }
        }
        return returnCheck;
    }

    @AuraEnabled
    public static List<SearchCustomerWrapperClass> getSearchbyQAS(Id caseRecordId){
        List<SearchCustomerWrapperClass> searchResObjList = new List<SearchCustomerWrapperClass>();
        Set<String> saprefSet = new Set<String>();
        try {
            
            if(String.isNotBlank(caseRecordId)){
                Case caseObj = SPEN_CaseSelector.getCaseDetailsForSAPCallout(caseRecordId)[0];
                if(String.isNotBlank(caseObj.AccountId)){
                    List<Case> caseRelated = SPEN_CaseSelector.getAccountDetailsFromCase(caseObj.AccountId);
                    
                    if(!caseRelated.isEmpty()){
                        for(Case caseRec:caseRelated){
                            saprefSet.add(caseRec.SPEN_SAPReference__c);
                        }
                    }
                }
            }
            User loggedInUser = SPEN_UserInfoSelector.getLoggedInUsersInfo()[0];
            List<String> currentTimeStr = String.ValueOf(system.now()).split(' ');
            String timeStr = currentTimeStr[0].replace('-', '');
            String hourStr = currentTimeStr[1].replace(':', '');

            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'urn:sap-com:document:sap:rfc:functions';
            dom.XmlNode results = doc.createRootElement('Envelope', soapNS, 'soapenv');
            results.setNamespace('urn', xsi);
            dom.XmlNode headerTag = results.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyTag = results.addChildElement('soapenv:Body', null, null);
            dom.XmlNode urnSAPSDCUSTBYQASTag = bodyTag.addChildElement('urn:Z_JWS039_SAPSDCUSTBYQAS', null, null);
            dom.XmlNode zJEWS00HEADERTag = urnSAPSDCUSTBYQASTag.addChildElement('ZJEWS00HEADER', null, null);
            dom.XmlNode zJEWS00MESSAGETag = urnSAPSDCUSTBYQASTag.addChildElement('ZJEWS00MESSAGE', null, null);
            dom.XmlNode zJEWS39CODQASTag = urnSAPSDCUSTBYQASTag.addChildElement('ZJEWS39CODQAS', null, null);
            dom.XmlNode zJEWS39CONTRACTPARTYTag = urnSAPSDCUSTBYQASTag.addChildElement('ZJEWS39CONTRACTPARTY', null, null);
            dom.XmlNode zJEWS39CUSTCOMPTag = urnSAPSDCUSTBYQASTag.addChildElement('ZJEWS39CUSTCOMP', null, null);
            dom.XmlNode zJEWS39CUSTQASTag = urnSAPSDCUSTBYQASTag.addChildElement('ZJEWS39CUSTQAS', null, null);
            dom.XmlNode languageTag = SPEN_SAPCreateEditQASService.prepareChildTag(zJEWS00HEADERTag,'LANGUAGE', ('E') );
            dom.XmlNode userTag = SPEN_SAPCreateEditQASService.prepareChildTag(zJEWS00HEADERTag,'USER', (!String.isEmpty(loggedInUser.SPEN_SAPId__c) ? loggedInUser.SPEN_SAPId__c : System.Label.DefaultSAPUser) );
            dom.XmlNode timeTag = SPEN_SAPCreateEditQASService.prepareChildTag(zJEWS00HEADERTag,'TIME', (timeStr) );
            dom.XmlNode hourTag = SPEN_SAPCreateEditQASService.prepareChildTag(zJEWS00HEADERTag,'HOUR', (hourStr));
            if(!saprefSet.isEmpty()){
                for(String caseSAPRef:saprefSet){
                    dom.XmlNode itemTag = zJEWS39CODQASTag.addChildElement('item', null, null);
                    dom.XmlNode zCODQASTag = SPEN_SAPCreateEditQASService.prepareChildTag(itemTag,'ZCODQAS', caseSAPRef);
                }
            }
            
            String xmlstring = doc.toXmlString();
            System.debug('getSearchbyQAS xmlstring>>>>'+xmlstring);
            String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_SearchbyQAS;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
            req.setHeader('SOAPAction', 'urn:sap-com:document:sap:soap:functions:mc-style:ZJ_WS_SAPCREATEEDITQAS:ZJws001SapcreateeditqasRequest');
            req.setTimeout(Integer.valueOf(System.Label.SPEN_SAPTimeOut));
            req.setBody(xmlstring);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String resultStr = res.getBody();
            System.debug('getSearchbyQAS resultStr>>>>'+resultStr);
            if( res.getStatusCode() == 200){
                String enableAPI = System.Label.EnableSAPSearch;
                if(enableAPI.equalsIgnoreCase('false') || Test.isRunningTest()){
                    resultStr = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">    <soap-env:Header/>    <soap-env:Body>        <n0:Z_JWS039_SAPSDCUSTBYQASResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">            <RETURNCODE>000</RETURNCODE>            <ZJEWS00MESSAGE/>            <ZJEWS39CODQAS>                <item>                    <ZCODQAS>000612762162</ZCODQAS>                </item>            </ZJEWS39CODQAS>            <ZJEWS39CONTRACTPARTY>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <BLOCKED>Y</BLOCKED>                    <TITLE>0003</TITLE>                    <NAME>SCOTTISH POWER UK PLC</NAME>                    <STREET>320 ST. VINCENT STREET</STREET>                    <STREET2/>                    <ZIP>G2 5AD</ZIP>                    <CITY>GLASGOW</CITY>                    <COUNTRY>GB</COUNTRY>                    <COUNTY/>                    <EMAIL>adrian.lomasgarnil@nttdata.com</EMAIL>                    <CUST_TYPE>C</CUST_TYPE>                    <CUST_CLASS>EF</CUST_CLASS>                    <FAX/>                    <PHONE>014153396598</PHONE>                    <MOBILE/>                    <VAT>GB659372008</VAT>                    <CRN>SC117120</CRN>                </item>            </ZJEWS39CONTRACTPARTY>            <ZJEWS39CUSTCOMP>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8301</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8303</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>1000</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8401</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>1100</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8400</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8300</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>1115</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8100</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>1150</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>1007</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8108</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8302</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8105</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8350</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8101</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8103</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8107</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>1001</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8000</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8102</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8104</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8203</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8212</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8251</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8205</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8213</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8200</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8304</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8349</COMPANY>                </item>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <COMPANY>8017</COMPANY>                </item>            </ZJEWS39CUSTCOMP>            <ZJEWS39CUSTQAS>                <item>                    <UKC1>0000020794</UKC1>                    <UKC2>0000020794</UKC2>                    <ZCODQAS>000612762162</ZCODQAS>                </item>            </ZJEWS39CUSTQAS>        </n0:Z_JWS039_SAPSDCUSTBYQASResponse>    </soap-env:Body></soap-env:Envelope>';
                }
                DOM.Document document = new DOM.Document();
                document.load(resultStr);
                for (DOM.XmlNode node : document.getRootElement().getChildren())
                {
                    if(node.getName() == 'Body'){
                        for (DOM.XmlNode node2 : node.getChildren()){
                            if(node2.getName() != null && node2.getName().containsIgnoreCase('Z_JWS039_SAPSDCUSTBYQASResponse')){
                                for (DOM.XmlNode node3 : node2.getChildren()){
                                    if(node3.getName() == 'ZJEWS39CONTRACTPARTY'){
                                        for (DOM.XmlNode node4 : node3.getChildren()){
                                            if(node4.getName() == 'item'){
                                                SearchCustomerWrapperClass searchResObj = new SearchCustomerWrapperClass();
                                                for (DOM.XmlNode node5 : node4.getChildren()){
                                                    System.debug(node5.getName()+'  '+node5.getText());
                                                    if(node5.getName() == 'UKC1'){
                                                        searchResObj.ukc1 = node5.getText();
                                                    }else if(node5.getName() == 'UKC2'){
                                                        searchResObj.ukc2 = node5.getText();
                                                    }else if(node5.getName() == 'BLOCKED'){
                                                        searchResObj.block = node5.getText();
                                                    }else if(node5.getName() == 'NAME'){
                                                        searchResObj.companyName = node5.getText();
                                                    }else if(node5.getName() == 'STREET'){
                                                        searchResObj.address = node5.getText();
                                                    }else if(node5.getName() == 'STREET2'){
                                                        searchResObj.flatNumber = node5.getText();
                                                    }else if(node5.getName() == 'PHONE'){
                                                        searchResObj.phoneNumber = node5.getText();
                                                    }else if(node5.getName() == 'MOBILE'){
                                                        searchResObj.mobileNumber = node5.getText();
                                                    }else if(node5.getName() == 'FAX'){
                                                        searchResObj.faxNumber = node5.getText();
                                                    }else if(node5.getName() == 'EMAIL'){
                                                        searchResObj.email = node5.getText();
                                                    }else if(node5.getName() == 'VAT'){
                                                        searchResObj.vat = node5.getText();
                                                    }else if(node5.getName() == 'CRN'){
                                                        searchResObj.crn = node5.getText();
                                                    }else if(node5.getName() == 'TITLE'){
                                                        searchResObj.title = node5.getText();
                                                    }else if(node5.getName() == 'ZIP'){
                                                        searchResObj.postcode = node5.getText();
                                                    }else if(node5.getName() == 'CITY'){
                                                        searchResObj.city = node5.getText();
                                                    }else if(node5.getName() == 'COUNTRY'){
                                                        searchResObj.country = node5.getText();
                                                    }else if(node5.getName() == 'CUST_TYPE'){
                                                        searchResObj.customerType = node5.getText();
                                                    }else if(node5.getName() == 'CUST_CLASS'){
                                                        searchResObj.customerClass = node5.getText();
                                                    }
                                                }
                                                searchResObjList.add(searchResObj);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }  
            return searchResObjList;
        } catch (Exception e) {
            SEL_LoggingService.log(e);
            return null;
        }
    }

    @AuraEnabled
    public static void getSearchbyUKC(String caseRecord){
        SearchCustomerWrapperClass caseObj = (SearchCustomerWrapperClass) JSON.deserialize(caseRecord,SearchCustomerWrapperClass.class); 
        SearchCustomerWrapperClass searchResObj = new SearchCustomerWrapperClass();
        try {
            User loggedInUser = SPEN_UserInfoSelector.getLoggedInUsersInfo()[0];
            List<String> currentTimeStr = String.ValueOf(system.now()).split(' ');
            String timeStr = currentTimeStr[0].replace('-', '');
            String hourStr = currentTimeStr[1].replace(':', '');

            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'urn:sap-com:document:sap:rfc:functions';
            dom.XmlNode results = doc.createRootElement('Envelope', soapNS, 'soapenv');
            results.setNamespace('urn', xsi);
            dom.XmlNode headerTag = results.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyTag = results.addChildElement('soapenv:Body', null, null);
            dom.XmlNode urnSAPSDCUSTBYUKCTag = bodyTag.addChildElement('urn:Z_JWS035_SAPSDCUSTBYID', null, null);
            dom.XmlNode zJEWS00HEADERTag = urnSAPSDCUSTBYUKCTag.addChildElement('ZJEWS00HEADER', null, null);
            dom.XmlNode zJEWS00MESSAGETag = urnSAPSDCUSTBYUKCTag.addChildElement('ZJEWS00MESSAGE', null, null);
            dom.XmlNode zJEWS39CODQASTag = urnSAPSDCUSTBYUKCTag.addChildElement('ZJEWS35CODQAS', null, null);
            dom.XmlNode zJEWS39CUSTCOMPTag = urnSAPSDCUSTBYUKCTag.addChildElement('ZJEWS35COMPANY', null, null);
            dom.XmlNode languageTag = SPEN_SAPCreateEditQASService.prepareChildTag(zJEWS00HEADERTag,'LANGUAGE', ('E') );
            dom.XmlNode userTag = SPEN_SAPCreateEditQASService.prepareChildTag(zJEWS00HEADERTag,'USER', (!String.isEmpty(loggedInUser.SPEN_SAPId__c) ? loggedInUser.SPEN_SAPId__c : System.Label.DefaultSAPUser) );
            dom.XmlNode timeTag = SPEN_SAPCreateEditQASService.prepareChildTag(zJEWS00HEADERTag,'TIME', (timeStr) );
            dom.XmlNode hourTag = SPEN_SAPCreateEditQASService.prepareChildTag(zJEWS00HEADERTag,'HOUR', (hourStr));
            dom.XmlNode itemTag = zJEWS39CODQASTag.addChildElement('item', null, null);
            dom.XmlNode ukc1Tag = SPEN_SAPCreateEditQASService.prepareChildTag(urnSAPSDCUSTBYUKCTag,'UKC1', caseObj.ukc1);
            dom.XmlNode ukc2Tag = SPEN_SAPCreateEditQASService.prepareChildTag(urnSAPSDCUSTBYUKCTag,'UKC2', caseObj.ukc2);
            String xmlstring = doc.toXmlString();
            System.debug('getSearchbyUKC xmlstring>>>>'+xmlstring);
            String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_SearchbyUKC;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
            req.setHeader('SOAPAction', 'urn:sap-com:document:sap:soap:functions:mc-style:ZJ_WS_SAPCREATEEDITQAS:ZJws001SapcreateeditqasRequest');
            req.setTimeout(Integer.valueOf(System.Label.SPEN_SAPTimeOut));
            req.setBody(xmlstring);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String resultStr = res.getBody();
            System.debug('getSearchbyUKC resultStr>>>>'+resultStr);
            if( res.getStatusCode() == 200){
                String enableAPI = System.Label.EnableSAPSearch;
                if(enableAPI.equalsIgnoreCase('false') || Test.isRunningTest()){
                    resultStr = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">    <soap-env:Header/>    <soap-env:Body>        <n0:Z_JWS035_SAPSDCUSTBYIDResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">            <RETURNCODE>000</RETURNCODE>            <ZJEWS00MESSAGE/>            <ZJEWS35CODQAS/>            <ZJEWS35COMPANY>                <item>                    <COMPANY>8303</COMPANY>                </item>            </ZJEWS35COMPANY>            <ZJEWS35CONTRACTPARTY>                <UKC1>0000819248</UKC1>                <UKC2>0000819248</UKC2>                <BLOCKED>N</BLOCKED>                <TITLE>0003</TITLE>                <NAME>JAYA CHANDRA N</NAME>                <STREET>23 NEW LANE</STREET>                <STREET2/>                <ZIP>G2 5AD</ZIP>                <CITY>WEASLEY</CITY>                <COUNTRY>GB</COUNTRY>                <COUNTY/>                <EMAIL>TEST4@TEST.COM</EMAIL>                <CUST_TYPE>C</CUST_TYPE>                <CUST_CLASS>PF</CUST_CLASS>                <FAX>07897656543</FAX>                <PHONE>07897656543</PHONE>                <MOBILE/>                <VAT/>                <CRN/>            </ZJEWS35CONTRACTPARTY>        </n0:Z_JWS035_SAPSDCUSTBYIDResponse>    </soap-env:Body></soap-env:Envelope>';
                }
                DOM.Document document = new DOM.Document();
                document.load(resultStr);
                for (DOM.XmlNode node : document.getRootElement().getChildren())
                {
                    if(node.getName() == 'Body'){
                        for (DOM.XmlNode node2 : node.getChildren()){
                            if(node2.getName() != null && node2.getName().containsIgnoreCase('Z_JWS035_SAPSDCUSTBYIDResponse')){
                                for (DOM.XmlNode node3 : node2.getChildren()){
                                    if(node3.getName() == 'ZJEWS35CONTRACTPARTY'){
                                        for (DOM.XmlNode node4 : node3.getChildren()){
                                            System.debug(node4.getName()+'  '+node4.getText());
                                            if(node4.getName() == 'UKC1'){
                                                searchResObj.ukc1 = node4.getText();
                                            }else if(node4.getName() == 'UKC2'){
                                                searchResObj.ukc2 = node4.getText();
                                            }else if(node4.getName() == 'BLOCKED'){
                                                searchResObj.block = node4.getText();
                                            }else if(node4.getName() == 'NAME'){
                                                searchResObj.companyName = node4.getText();
                                            }else if(node4.getName() == 'STREET'){
                                                searchResObj.address = node4.getText();
                                            }else if(node4.getName() == 'STREET2'){
                                                searchResObj.flatNumber = node4.getText();
                                            }else if(node4.getName() == 'PHONE'){
                                                searchResObj.phoneNumber = node4.getText();
                                            }else if(node4.getName() == 'MOBILE'){
                                                searchResObj.mobileNumber = node4.getText();
                                            }else if(node4.getName() == 'FAX'){
                                                searchResObj.faxNumber = node4.getText();
                                            }else if(node4.getName() == 'EMAIL'){
                                                searchResObj.email = node4.getText();
                                            }else if(node4.getName() == 'VAT'){
                                                searchResObj.vat = node4.getText();
                                            }else if(node4.getName() == 'CRN'){
                                                searchResObj.crn = node4.getText();
                                            }else if(node4.getName() == 'TITLE'){
                                                searchResObj.title = node4.getText();
                                            }else if(node4.getName() == 'ZIP'){
                                                searchResObj.postcode = node4.getText();
                                            }else if(node4.getName() == 'CITY'){
                                                searchResObj.city = node4.getText();
                                            }else if(node4.getName() == 'COUNTRY'){
                                                searchResObj.country = node4.getText();
                                            }else if(node4.getName() == 'CUST_TYPE'){
                                                searchResObj.customerType = node4.getText();
                                            }else if(node4.getName() == 'CUST_CLASS'){
                                                searchResObj.customerClass = node4.getText();
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }  
            searchResObj.caseRecordId = caseObj.caseRecordId;
            String caseRecDetails = JSON.serialize(searchResObj);
            updateCase(caseRecDetails);
        } catch (Exception e) {
            SEL_LoggingService.log(e);
        }
    }

    @AuraEnabled
    public static List<SearchCustomerWrapperClass> createSDCustomerSAP(CaseInfo fields){
        List<SearchCustomerWrapperClass> searchResObjList = new List<SearchCustomerWrapperClass>();
        String calloutResponse ='';
        try{
            
            
            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'urn:sap-com:document:sap:rfc:functions';
            dom.XmlNode results = doc.createRootElement('Envelope', soapNS, 'soapenv');
            results.setNamespace('urn', xsi);
            dom.XmlNode headerTag = results.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyTag = results.addChildElement('soapenv:Body', null, null);
            dom.XmlNode urnRF01FCGALTATag = bodyTag.addChildElement('urn:Z_RF01FCGALTA_DEUDORES', null, null);
            dom.XmlNode iENTRADATag = urnRF01FCGALTATag.addChildElement('I_ENTRADA', null, null);
            
            dom.XmlNode originTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'ORIGIN', ('ATHOS') );
            dom.XmlNode customerTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CUSTOMER', (''));
            dom.XmlNode formOfADTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'FORM_OF_AD', (!String.isEmpty(fields.spenTitle) ? fields.spenTitle : ''));
            dom.XmlNode nameTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'NAME', (!String.isEmpty(fields.spenCompanyPersonName) ? (fields.spenCompanyPersonName).toUpperCase() : ''));
            dom.XmlNode streetTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'STREET', (!String.isEmpty(fields.spenBuildingNumberStreet) ? (fields.spenBuildingNumberStreet).toUpperCase() : ''));
            dom.XmlNode houseNumTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'HOUSE_NUM1', (''));
            dom.XmlNode street2Tag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'STREET2', (!String.isEmpty(fields.spenBuildingNameFlatNumber) ? fields.spenBuildingNameFlatNumber : ''));
            dom.XmlNode postCodeTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'POSTL_CODE', (!String.isEmpty(fields.spenPostCode) ? (fields.spenPostCode).toUpperCase() : ''));
            dom.XmlNode cityTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CITY', (!String.isEmpty(fields.spenTownCity) ? (fields.spenTownCity).toUpperCase() : ''));
            dom.XmlNode countyTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'COU', (!String.isEmpty(fields.spenCountry) ? (fields.spenCountry).toUpperCase() : ''));
            dom.XmlNode countryTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'COUN', (''));
            dom.XmlNode emailTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'EMAIL', (!String.isEmpty(fields.spenEmailAddress) ? (fields.spenEmailAddress).toUpperCase() : ''));
            dom.XmlNode customerTypeTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CUSTOMERTYPE', (!String.isEmpty(fields.spenCustomerType) ? fields.spenCustomerType : ''));
            dom.XmlNode customerClassTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CUSTOMERCLASS', (!String.isEmpty(fields.spenCustomerClass) ? fields.spenCustomerClass : ''));
            dom.XmlNode faxNumberTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'FAX_NUMBER', (!String.isEmpty(fields.spenFAXNumber) ? fields.spenFAXNumber : ''));
            dom.XmlNode telephoneTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'TELEPHONE', (!String.isEmpty(fields.spenPhoneNumber) ? fields.spenPhoneNumber : ''));
            dom.XmlNode mobileTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'MOBILE', (!String.isEmpty(fields.spenMobileNumber) ? fields.spenMobileNumber : ''));
            dom.XmlNode companyCodeTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'COMPANY_CODE', ((!String.isEmpty(fields.spenCompanyId) && fields.spenCompanyId == 'SPD') ? '8301' : '8303'));
            String vatValue ='';
            if(!String.isEmpty(fields.spenVAT) && fields.spenVAT.containsIgnoreCase('GB')){
                vatValue = fields.spenVAT.replace('GB', '');
            }
            dom.XmlNode tax1Tag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'TAX1', (!String.isEmpty(fields.spenVAT) ? vatValue : ''));
            dom.XmlNode tax2Tag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'TAX2', (!String.isEmpty(fields.spenCRN) ? fields.spenCRN : ''));
            String xmlstring = doc.toXmlString();
            System.debug('createSDCustomerSAP xmlstring>>>>'+xmlstring);
            String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_CreateCustomerSAP;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
            req.setHeader('SOAPAction', 'urn:sap-com:document:sap:soap:functions:mc-style:ZJ_WS_SAPCREATEEDITQAS:ZJws001SapcreateeditqasRequest');
            req.setTimeout(Integer.valueOf(System.Label.SPEN_SAPTimeOut));
            req.setBody(xmlstring);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String resultStr = res.getBody();
            System.debug('createSDCustomerSAP resultStr>>>>'+resultStr);
            if( res.getStatusCode() == 200){
                String enableAPI = System.Label.EnableSAPSearch;
                if(enableAPI.equalsIgnoreCase('false') || Test.isRunningTest()){
                    resultStr = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">   <soap-env:Header/>   <soap-env:Body>      <n0:Z_RF01FCGALTA_DEUDORESResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">         <E_RC/>         <E_RETURN/>         <E_SALIDA>            <ZPRINCIPAL>0000824809</ZPRINCIPAL>            <ZSECUNDARIO>0000824809</ZSECUNDARIO>            <ZMOTIVO/>            <ZBLOQUEO/>            <ZCHANGED/>         </E_SALIDA>      </n0:Z_RF01FCGALTA_DEUDORESResponse>   </soap-env:Body></soap-env:Envelope>';
                }
                DOM.Document document = new DOM.Document();
                System.debug('createSDCustomerSAPExt resultStr>>>>'+resultStr);
                document.load(resultStr);
                
                for (DOM.XmlNode node : document.getRootElement().getChildren())
                {
                    if(node.getName() == 'Body'){
                        for (DOM.XmlNode node2 : node.getChildren()){
                            if(node2.getName() != null && node2.getName().containsIgnoreCase('Z_RF01FCGALTA_DEUDORESResponse')){
                                for (DOM.XmlNode node3 : node2.getChildren()){
                                    if(node3.getName() == 'E_RETURN' && node3.getText() != ''){
                                        calloutResponse='Error:'+node3.getText();
                                        SearchCustomerWrapperClass searchResObj = new SearchCustomerWrapperClass();
                                        searchResObj.ukc1 = 'ERROR';
                                        searchResObj.ukc2 = calloutResponse;
                                        searchResObjList.add(searchResObj);
                                    }
                                    else if(calloutResponse == '' && node3.getName() == 'E_SALIDA'){
                                        SearchCustomerWrapperClass searchResObj = new SearchCustomerWrapperClass();
                                        for (DOM.XmlNode node4 : node3.getChildren()){
                                            
                                            if(node4.getName() == 'ZPRINCIPAL'){
                                                searchResObj.ukc1 = node4.getText();
                                            }else if(node4.getName() == 'ZSECUNDARIO'){
                                                searchResObj.ukc2 = node4.getText();
                                            }
                                        }
                                        if(searchResObj != null && searchResObj.ukc2 !=null && searchResObj.ukc1 == null){
                                            searchResObj.ukc1 = searchResObj.ukc2;
                                        }
                                        searchResObjList.add(searchResObj);
                                        calloutResponse ='SUCCESS';
                                    }
                                }
                            }
                        }
                    }
                }
            }  
            return searchResObjList;
        }catch (Exception e) {
            SEL_LoggingService.log(e);
            return null;
        }
    }

    @AuraEnabled
    public static String updateSDCustomerSAP(CaseInfo caseInfoFields){
            String calloutResponse='';
        try {
            
            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'urn:sap-com:document:sap:rfc:functions';
            dom.XmlNode results = doc.createRootElement('Envelope', soapNS, 'soapenv');
            results.setNamespace('urn', xsi);
            dom.XmlNode headerTag = results.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyTag = results.addChildElement('soapenv:Body', null, null);
            dom.XmlNode urnRF01FCGALTATag = bodyTag.addChildElement('urn:Z_RF01FCGMODIF_DEUDORES', null, null);
            dom.XmlNode iENTRADATag = urnRF01FCGALTATag.addChildElement('I_ENTRADA', null, null);
            
            dom.XmlNode originTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'ORIGIN', ('ATHOS') );
            if(caseInfoFields.spenUKC1 != caseInfoFields.spenUKC2){
                dom.XmlNode customerTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CUSTOMER', (!String.isEmpty(caseInfoFields.spenUKC2) ? caseInfoFields.spenUKC2 : '') );
            }else{
                dom.XmlNode customerTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CUSTOMER', (!String.isEmpty(caseInfoFields.spenUKC1) ? caseInfoFields.spenUKC1 : '') );
            }
            dom.XmlNode formOfADTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'FORM_OF_AD', (!String.isEmpty(caseInfoFields.spenTitle) ? caseInfoFields.spenTitle : '') );
            dom.XmlNode nameTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'NAME', (!String.isEmpty(caseInfoFields.spenCompanyPersonName) ? (caseInfoFields.spenCompanyPersonName).toUpperCase() : ''));
            dom.XmlNode streetTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'STREET', (!String.isEmpty(caseInfoFields.spenBuildingNumberStreet) ? (caseInfoFields.spenBuildingNumberStreet).toUpperCase() : ''));
            dom.XmlNode houseNumTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'HOUSE_NUM1', (''));
            dom.XmlNode street2Tag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'STREET2', (!String.isEmpty(caseInfoFields.spenBuildingNameFlatNumber) ? caseInfoFields.spenBuildingNameFlatNumber : ''));
            dom.XmlNode postCodeTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'POSTL_CODE', (!String.isEmpty(caseInfoFields.spenPostCode) ? (caseInfoFields.spenPostCode).toUpperCase() : ''));
            dom.XmlNode cityTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CITY', (!String.isEmpty(caseInfoFields.spenTownCity) ? (caseInfoFields.spenTownCity).toUpperCase() : ''));
            dom.XmlNode countyTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'COU', (!String.isEmpty(caseInfoFields.spenCountry) ? (caseInfoFields.spenCountry).toUpperCase() : ''));
            dom.XmlNode countryTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'COUN', (''));
            dom.XmlNode emailTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'EMAIL', (!String.isEmpty(caseInfoFields.spenEmailAddress) ? (caseInfoFields.spenEmailAddress).toUpperCase() : ''));
            dom.XmlNode customerTypeTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CUSTOMERTYPE', (!String.isEmpty(caseInfoFields.spenCustomerType) ? caseInfoFields.spenCustomerType : ''));
            dom.XmlNode customerClassTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'CUSTOMERCLASS', (!String.isEmpty(caseInfoFields.spenCustomerClass) ? caseInfoFields.spenCustomerClass : ''));
            dom.XmlNode faxNumberTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'FAX_NUMBER', (!String.isEmpty(caseInfoFields.spenFAXNumber) ? caseInfoFields.spenFAXNumber : ''));
            dom.XmlNode telephoneTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'TELEPHONE', (!String.isEmpty(caseInfoFields.spenPhoneNumber) ? caseInfoFields.spenPhoneNumber : ''));
            dom.XmlNode mobileTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'MOBILE', (!String.isEmpty(caseInfoFields.spenMobileNumber) ? caseInfoFields.spenMobileNumber : ''));
            dom.XmlNode companyCodeTag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'COMPANY_CODE', ((!String.isEmpty(caseInfoFields.spenCompanyId) && caseInfoFields.spenCompanyId == 'SPD') ? '8301' : '8303'));
            String vatValue ='';
            if(!String.isEmpty(caseInfoFields.spenVAT) && caseInfoFields.spenVAT.containsIgnoreCase('GB')){
                vatValue = caseInfoFields.spenVAT.replace('GB', '');
            }
            dom.XmlNode tax1Tag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'TAX1', (!String.isEmpty(vatValue) ? vatValue : ''));
            dom.XmlNode tax2Tag = SPEN_SAPCreateEditQASService.prepareChildTag(iENTRADATag,'TAX2', (!String.isEmpty(caseInfoFields.spenCRN) ? caseInfoFields.spenCRN : ''));
            String xmlstring = doc.toXmlString();
            System.debug('updateSDCustomerSAP xmlstring>>>>'+xmlstring);
            String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_UpdateCustomerSAP;
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endPointURL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml; charset=utf-8');
            req.setHeader('SOAPAction', 'urn:sap-com:document:sap:soap:functions:mc-style:ZJ_WS_SAPCREATEEDITQAS:ZJws001SapcreateeditqasRequest');
            req.setTimeout(Integer.valueOf(System.Label.SPEN_SAPTimeOut));
            req.setBody(xmlstring);
            Http http = new Http();
            HTTPResponse res = http.send(req);
            String resultStr = res.getBody();
            System.debug('updateSDCustomerSAP resultStr>>>>'+resultStr);
            if( res.getStatusCode() == 200){
                
                String enableAPI = System.Label.EnableSAPSearch;
                if(enableAPI.equalsIgnoreCase('false') || Test.isRunningTest()){
                    resultStr = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">   <soap-env:Header/>   <soap-env:Body>      <n0:Z_RF01FCGMODIF_DEUDORESResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">         <E_RC/>         <E_RETURN/>         <E_SALIDA>            <ZPRINCIPAL>0000824809</ZPRINCIPAL>            <ZSECUNDARIO>0000824809</ZSECUNDARIO>            <ZMOTIVO/>            <ZBLOQUEO/>            <ZCHANGED>Y</ZCHANGED>         </E_SALIDA>      </n0:Z_RF01FCGMODIF_DEUDORESResponse>   </soap-env:Body></soap-env:Envelope>';
                }
                DOM.Document document = new DOM.Document();
                System.debug('updateSDCustomerSAPExt resultStr>>>>'+resultStr);
                document.load(resultStr);
                String warningStr = '';
                for (DOM.XmlNode node : document.getRootElement().getChildren())
                {
                    if(node.getName() == 'Body'){
                        for (DOM.XmlNode node2 : node.getChildren()){
                            if(node2.getName() != null && node2.getName().containsIgnoreCase('Z_RF01FCGMODIF_DEUDORESResponse')){
                                for (DOM.XmlNode node3 : node2.getChildren()){
                                    
                                    if(node3.getName() == 'E_RETURN' && node3.getText() != ''){
                                        warningStr = 'Warning';
                                        calloutResponse='Error:'+node3.getText();
                                    } 
                                    if(node3.getName() == 'E_SALIDA'){
                                        for(DOM.XmlNode node4 : node3.getChildren()){
                                            if(node4.getName() == 'ZCHANGED' && node4.getText() == 'Y' ){
                                                warningStr += 'isThere';
                                            }
                                        }
                                    }
                                }
                            }
                            if(warningStr == 'WarningisThere'){
                                calloutResponse += ' : Warning';
                            }else if(warningStr == 'isThere'){
                                calloutResponse = 'Success';
                            }
                        }
                    }
                }
            }  
            return calloutResponse;
        } catch (Exception e) {
            SEL_LoggingService.log(e);
            return null;
        }
    }

    @AuraEnabled
    public static void updateCase(String caseRecord){
        SearchCustomerWrapperClass caseObj = (SearchCustomerWrapperClass) JSON.deserialize(caseRecord,SearchCustomerWrapperClass.class); 
        List<Case> caseListToUpdate = new List<Case>();
        try{
            if(caseObj != null){
                Case caseToUpdate = new Case();
                caseToUpdate.Id = caseObj.caseRecordId;
                caseToUpdate.SPEN_UKC1ID__c = caseObj.ukc1;
                caseToUpdate.SPEN_UKC2ID__c = caseObj.ukc2;
                caseToUpdate.SPEN_CPBlocked__c = caseObj.block;
                caseToUpdate.SPEN_CPCompanyPersonName__c = caseObj.companyName;
                caseToUpdate.SPEN_CPPhoneNumber__c = caseObj.phoneNumber;
                caseToUpdate.SPEN_CPEmailAddress__c = caseObj.email;
                caseToUpdate.SPEN_VAT__c = caseObj.vat;
                caseToUpdate.SPEN_CRN__c = caseObj.crn;
                caseToUpdate.SPEN_CPPostCode__c = caseObj.postcode;
                caseToUpdate.SPEN_CPMobileNumber__c = caseObj.mobileNumber;
                caseToUpdate.SPEN_CPFaxNumber__c = caseObj.faxNumber;
                caseToUpdate.SPEN_CPCountry__c = caseObj.country;
                caseToUpdate.SPEN_CPCustomerClass__c = caseObj.customerClass;
                caseToUpdate.SPEN_CPCustomerType__c = caseObj.customerType;
                caseToUpdate.SPEN_CPBuildingNumberStreet__c = caseObj.address;
                caseToUpdate.SPEN_CPBuildingNameFlatNumber__c = caseObj.flatNumber;
                caseToUpdate.SPEN_CPTitle__c = caseObj.title;
                caseToUpdate.SPEN_CPTownCity__c = caseObj.city;
                caseListToUpdate.add(caseToUpdate);
            }
            if(!caseListToUpdate.isEmpty()){
                update caseListToUpdate;
            }
        } catch (Exception e) {
            SEL_LoggingService.log(e);
        }
    }

    public class SearchCustomerWrapperClass{
        @AuraEnabled
        public String caseRecordId{get;set;}
        @AuraEnabled
        public String ukc1{get;set;}
        @AuraEnabled
        public String ukc2{get;set;}
        @AuraEnabled
        public String block{get;set;}
        @AuraEnabled
        public String companyName{get;set;}
        @AuraEnabled
        public String address{get;set;}
        @AuraEnabled
        public String flatNumber{get;set;}
        @AuraEnabled
        public String postcode{get;set;}
        @AuraEnabled
        public String phoneNumber{get;set;}
        @AuraEnabled
        public String mobileNumber{get;set;}
        @AuraEnabled
        public String faxNumber{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String vat{get;set;}
        @AuraEnabled
        public String crn{get;set;}
        @AuraEnabled
        public String title{get;set;}
        @AuraEnabled
        public String city{get;set;}
        @AuraEnabled
        public String country{get;set;}
        @AuraEnabled
        public String customerType{get;set;}
        @AuraEnabled
        public String customerClass{get;set;}
    }

    public class SearchWrapper{
        @AuraEnabled
        public String companyName{get;set;}
        @AuraEnabled
        public String phone{get;set;}
        @AuraEnabled
        public String building{get;set;}
        @AuraEnabled
        public String mobile{get;set;}
        @AuraEnabled
        public String vat{get;set;}
        @AuraEnabled
        public String postcode{get;set;}
        @AuraEnabled
        public String email{get;set;}
        @AuraEnabled
        public String street{get;set;}
        @AuraEnabled
        public String fax{get;set;}
        @AuraEnabled
        public String crn{get;set;}
    }
    
    public class CaseInfo{
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String spenUKC1{get;set;}
        @AuraEnabled
        public String spenUKC2{get;set;}
        @AuraEnabled
        public String spenCustomerType{get;set;}
        @AuraEnabled
        public String spenCustomerClass{get;set;}
        @AuraEnabled
        public String spenTitle{get;set;}
        @AuraEnabled
        public String spenCompanyPersonName{get;set;}
        @AuraEnabled
        public String spenBuildingNameFlatNumber{get;set;}
        @AuraEnabled
        public String spenBuildingNumberStreet{get;set;}
        @AuraEnabled
        public String spenTownCity{get;set;}
        @AuraEnabled
        public String spenPostCode{get;set;}
        @AuraEnabled
        public String spenCountry{get;set;}
        @AuraEnabled
        public String spenPhoneNumber{get;set;}
        @AuraEnabled
        public String spenMobileNumber{get;set;}
        @AuraEnabled
        public String spenFAXNumber{get;set;}
        @AuraEnabled
        public String spenEmailAddress{get;set;}
        @AuraEnabled
        public String spenCompanyId{get;set;}
        @AuraEnabled
        public String spenCRN{get;set;}
        @AuraEnabled
        public String spenVAT{get;set;}
    }
}
/*-----------------------------------------------------------------------------
DESCRIPTION :   This class callouts Project Assign operation
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
16-Oct-2023     Rajat Verma        Initial version
-----------------------------------------------------------------------------*/
public class SPEN_SAPProjectAssignCallOut {
    public static List<Case> lstCaseToUpdated = new List<Case>();
    
    @AuraEnabled
    @future(callout=true)
    public static void sendProjectAssignCallout(List<Id> lstDelivery){
        Map<Id,String> deliveryVSErrorMap = new Map<Id,String>(); 
        try{
            for(SPEN_Delivery__c deliveryRef : SPEN_CaseSelector.getCaseDetailsFromDeliveryRecords(lstDelivery)){
                String requestBody = generateProjectAssignRequest(deliveryRef);
                String responseBody = '';
                String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_ProjectAssignCallout;
                HttpRequest request = new HttpRequest();
                request.setMethod('POST');        
                request.setTimeout(Integer.valueOf(System.Label.SPEN_SAPTimeOut));
                request.setHeader('Content-Type', 'text/xml; charset=utf-8');
                request.setHeader('SOAPAction', 'urn:sap-com:document:sap:soap:functions:mc-style:ZJ_WS_SAPCREATEEDITQAS:ZJws001SapcreateeditqasRequest');
                request.setEndpoint(endPointURL);
                request.setBody(requestBody);
                system.debug('request --------->>>>>'+ request);
                system.debug('requestBody --------->>>>>'+ requestBody);
                
                if(!Test.isRunningTest()){
                    Http http = new Http();
                    HTTPResponse response = http.send(request);
                    responseBody = response.getBody();
                    /*                    
responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
'<soap-env:Body>'+'<n0:ZJws013SapprojectassignNamsResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
'<Returncode>004</Returncode>'+'<Zjews00message>'+
'<item>'+'<Type/>'+'<Language>E</Language>'+'<Id>SP036391</Id>'+'<Number>000</Number>'+'<Message/>'+'</item>'+'<item>'+
'<Type>E</Type>'+'<Language>E</Language>'+'<Id>ZDSPW</Id>'+'<Number>099</Number>'+
'<Message>QAS Code not found</Message>'+
'</item>'+'</Zjews00message>'+
'</n0:ZJws013SapprojectassignNamsResponse>'+'</soap-env:Body>'+'</soap-env:Envelope>';*/
                    
                    system.debug('response --------->>>>>'+ response);
                    system.debug('responseBody --------->>>>>'+ responseBody);
                    if(response.getStatusCode() == 200){
                        deliveryVSErrorMap =   parseResponse(responseBody,deliveryRef,'success');
                    }else{
                        deliveryVSErrorMap =   parseResponse(responseBody,deliveryRef,'fault');
                    }
                }else{
                    responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
                        '<soap-env:Body>'+'<n0:ZJws013SapprojectassignNamsResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                        '<Returncode>000</Returncode>'+'<Zjews00message>'+
                        '<item>'+'<Type/>'+'<Language>E</Language>'+'<Id>SP030701</Id>'+'<Number>000</Number>'+'<Message/>'+'</item>'+
                        '</Zjews00message>'+
                        '</n0:ZJws013SapprojectassignNamsResponse>'+'</soap-env:Body>'+'</soap-env:Envelope>';
                    deliveryVSErrorMap = parseResponse(responseBody,deliveryRef,'mock'); 
                    
                    responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
                        '<soap-env:Body>'+'<n0:Fault xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                        '<Returncode>000</Returncode>'+'<faultstring>'+
                        '<item>'+'<Type/>'+'<Language>E</Language>'+'<Id>SP030701</Id>'+'<Number>000</Number>'+'<Message>Fault Occurred</Message>'+'</item>'+
                        '</faultstring>'+
                        '</n0:Fault>'+'</soap-env:Body>'+'</soap-env:Envelope>';
                    Map<Id,String> deliveryVSErrorMapTest = parseResponse(responseBody,deliveryRef,'mock');
                    
                    responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
                        '<soap-env:Body>'+'<n0:Fault xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                        '<Returncode>000</Returncode>'+'<faultstring>Fault Occurred</faultstring>'+
                        '</n0:Fault>'+'</soap-env:Body>'+'</soap-env:Envelope>';
                    Map<Id,String> deliveryVSErrorMapTestExt = parseResponse(responseBody,deliveryRef,'fault');
                }
            }
            for(Case cseObj : [Select Id, SPEN_SAPErrorDetails__c,SPEN_Delivery__c From Case where SPEN_Delivery__c =: deliveryVSErrorMap.KeySet()]){
                Case cse = new Case();
                cse.Id = cseObj.Id;
                cse.SPEN_SAPErrorDetails__c = deliveryVSErrorMap.get(cseObj.SPEN_Delivery__c);
                lstCaseToUpdated.add(cse);
            }
            
            if(!lstCaseToUpdated.isEmpty()){
                system.debug('lstCaseToUpdated==='+lstCaseToUpdated);
                update lstCaseToUpdated;
            }
            
        }catch(Exception ex){
            System.debug('SPEN_SAPProjectAssignCallOut:sendProjectAssignCallout==='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
    
    public static Map<Id,String> parseResponse(String responseBody,SPEN_Delivery__c deliveryRef,String result){
        String errorMessage='';
        Map<Id,String> deliveryAndErrorMap = new Map<Id,String>();
        
        DOM.Document document = new DOM.Document();
        document.load(responseBody);
        for (DOM.XmlNode node : document.getRootElement().getChildren()){
            if(node.getName() == 'Body'){
                for (DOM.XmlNode node2 : node.getChildren()){
                    if(result=='success' || result=='mock'){
                        if(node2.getName() == 'ZJws013SapprojectassignNamsResponse'){
                            for (DOM.XmlNode node3 : node2.getChildren()){
                                if(node3.getName() == 'Returncode' && node3.getText() == '000'){
                                    errorMessage = errorMessage + 'PM update success';
                                }else if(node3.getName() == 'Zjews00message'){
                                    for (DOM.XmlNode node4 : node3.getChildren()){
                                        if(node4.getName() == 'item'){
                                            for (DOM.XmlNode node5 : node4.getChildren()){
                                                if(node5.getName() == 'Message'){
                                                    errorMessage = errorMessage + node5.getText()+'.';
                                                }
                                            } 
                                        }
                                    } 
                                }
                            }
                        }
                        if(node2.getName() == 'Fault'){
                            for (DOM.XmlNode node3 : node2.getChildren()){
                                if(node3.getName() == 'faultstring'){
                                    errorMessage = errorMessage + node3.getText()+'.';
                                }
                            }
                        }
                    }else{
                        if(node2.getName() == 'Fault'){
                            for (DOM.XmlNode node3 : node2.getChildren()){
                                if(node3.getName() == 'faultstring'){
                                    errorMessage = errorMessage + node3.getText()+'.';
                                }
                            }
                        }
                    }
                }
            }
        }
        deliveryAndErrorMap.put(deliveryRef.Id,errorMessage);
        return deliveryAndErrorMap;
    }
    
    public static string generateProjectAssignRequest(SPEN_Delivery__c deliveryObj){
        String xmlstring = '';	
        List<User> loggedInUser = SPEN_UserInfoSelector.getLoggedInUsersInfo();
        
        try{
            //Time format values
            String dateValueHeader = system.now().format('yyyyMMdd');
            String dateValue = system.now().format('yyyyMMdd');
            String timeValue = system.now().format('HHmmss');
            
            //User Info
            String userDetail=(!String.isEmpty(loggedInUser[0].SPEN_SAPId__c) ? loggedInUser[0].SPEN_SAPId__c : System.Label.DefaultSAPUser);
            
            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'urn:sap-com:document:sap:soap:functions:mc-style';
            dom.XmlNode rootTag = doc.createRootElement('Envelope', soapNS, 'soapenv');
            rootTag.setNamespace('urn', xsi);
            dom.XmlNode headerTag = rootTag.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyTag = rootTag.addChildElement('soapenv:Body', null, null);
            dom.XmlNode zjws013SapprojectassignNamsTag = bodyTag.addChildElement('urn:ZJws013SapprojectassignNams', null, null);
            dom.XmlNode zcodqasTag = prepareChildTag(zjws013SapprojectassignNamsTag,'Zcodqas',(String.isNotBlank(deliveryObj.SPEN_CaseSAPRefFormula__c) ? deliveryObj.SPEN_CaseSAPRefFormula__c :''));
            dom.XmlNode zjews00headerTag = zjws013SapprojectassignNamsTag.addChildElement('Zjews00header', null, null);
            dom.XmlNode zjews00messageTag = zjws013SapprojectassignNamsTag.addChildElement('Zjews00message', null, null);
            dom.XmlNode zjews13prdesTag = zjws013SapprojectassignNamsTag.addChildElement('Zjews13prdes', null, null);
            
            //zjews00headerTag                
            dom.XmlNode zjews00headerLangTag = prepareChildTag(zjews00headerTag,'Language','E'); 
            dom.XmlNode zjews00headerUserTag = prepareChildTag(zjews00headerTag,'User',userDetail); //Mapping - Sap Id 
            dom.XmlNode zjews00headerTimeTag = prepareChildTag(zjews00headerTag,'Time',dateValueHeader); //Mapping - current date in format ddmmyyyy
            dom.XmlNode zjews00headerHourTag = prepareChildTag(zjews00headerTag,'Hour',timeValue);
            
            //zjews00messageTag
            dom.XmlNode zjews00messageItemTag = zjews00messageTag.addChildElement('item', null, null);
            dom.XmlNode zjews00messageItemTypeTag = prepareChildTag(zjews00messageItemTag,'Type',null);	
            dom.XmlNode zjews00messageItemLangTag = prepareChildTag(zjews00messageItemTag,'Language','E');	
            dom.XmlNode zjews00messageItemIdTag = prepareChildTag(zjews00messageItemTag,'Id',(String.isNotBlank(deliveryObj.SPEN_DeliveryProjectManager__r.SPEN_SAPId__c) ? deliveryObj.SPEN_DeliveryProjectManager__r.SPEN_SAPId__c :''));	
            dom.XmlNode zjews00messageItemNumTag = prepareChildTag(zjews00messageItemTag,'Number',null);	
            dom.XmlNode zjews00messageItemMsgTag = prepareChildTag(zjews00messageItemTag,'Message',null);
            
            //zjews13prdesTag
            dom.XmlNode zresppralTag = prepareChildTag(zjews13prdesTag,'Zresppral',(String.isNotBlank(deliveryObj.SPEN_DeliveryProjectManager__r.SPEN_SAPId__c) ? deliveryObj.SPEN_DeliveryProjectManager__r.SPEN_SAPId__c :''));	
            
            xmlstring = doc.toXmlString();
            
        }catch(Exception ex){
            System.debug('SPEN_SAPProjectAssignCallOut:generateProjectAssignRequest==='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            SEL_LoggingService.log(ex);
        }
        return xmlstring;
    }
    
    public static dom.XmlNode prepareChildTag(dom.XmlNode parentNode, string tagName, String tagValue)
    {
        dom.XmlNode xmlNodeVar;
        parentNode.addChildElement(tagName, null, null).addTextNode(!String.isEmpty(tagValue) ? tagValue : '');
        return xmlNodeVar;
    }
}
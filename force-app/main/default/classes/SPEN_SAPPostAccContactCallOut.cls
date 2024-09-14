/*-----------------------------------------------------------------------------
DESCRIPTION :   This class callouts Post Accept Contact Callout
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
17-Oct-2023     Amrita Sarkar      Initial version
-----------------------------------------------------------------------------*/
public class SPEN_SAPPostAccContactCallOut {
    @future(callout=true)
    public static void sendPostAccContactCallout(List<Id> lstDelv){
        List<SPEN_Delivery__c> deliveryList = [Select id,SPEN_GSCallCompletionDate__c,SPEN_CaseSAPRefFormula__c,
                                               SPEN_Case__c,SPEN_SuccessSAP__c,SPEN_Case__r.SPEN_SubStatus__c,SPEN_Case__r.Status,SPEN_SAPDetails__c from SPEN_Delivery__c where id IN : lstDelv];
        List<Case> caseList = new List<Case>();
        List<SPEN_Delivery__c> updateDelList = new List<SPEN_Delivery__c>();
        List<Case> updateCaseList = new List<Case>();
        Map<Id,SPEN_Delivery__c> successResDelIdMap = new Map<Id,SPEN_Delivery__c>();
        try{
            for(SPEN_Delivery__c delvRef : deliveryList){
                String requestBody = generatePostAccContactRequest(delvRef);
                String responseBody = '';
                String endPointURL = 'callout:SAPCON/' + System.label.SPEN_SapApiName_PostAccContactCallout;
                HttpRequest request = new HttpRequest();
                request.setMethod('POST');        
                request.setHeader('Content-Type', 'text/xml; charset=utf-8');
                request.setHeader('SOAPAction', 'urn:sap-com:document:sap:soap:functions:mc-style:ZJ_WS_SAPCREATEEDITQAS:ZJws001SapcreateeditqasRequest');
                request.setEndpoint(endPointURL);
                request.setTimeout(Integer.valueOf(System.Label.SPEN_SAPTimeOut));
                request.setBody(requestBody);
                system.debug('request --------->>>>>'+ request);
                system.debug('requestBody --------->>>>>'+ requestBody);
                
                if(!Test.isRunningTest()){
                    Http http = new Http();
                    HTTPResponse response = http.send(request);
                    responseBody = response.getBody();
                    system.debug('response --------->>>>>'+ response);
                    system.debug('responseBody --------->>>>>'+ responseBody);
                    if( response.getStatusCode() == 200)
                    {
                        successResDelIdMap =  parseResponse(responseBody,delvRef,'success');
                    }else{
                        successResDelIdMap = parseResponse(responseBody,delvRef,'Fault');
                    }
                }else{
                    responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
                            '<soap-env:Body>'+'<n0:Fault xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                            '<Returncode>000</Returncode>'+'<faultstring>'+
                            '<item>'+'<Type/>'+'<Language/>'+'<Id/>'+'<Number>000</Number>'+'<Message/>'+'</item>'+'<item>'+
                            '<Type>W</Type>'+'<Language>E</Language>'+'<Id>ZDSPW</Id>'+'<Number>014</Number>'+
                            '<Message>Post Acceptance Contact saved successfully</Message>'+
                            '</item>'+'</faultstring>'+'<Zjews12letter/>'+'<Zjews12pocont>'+
                            '<Zcodqas>612762818</Zcodqas>'+'<Zdcontcus>20231020</Zdcontcus>'+'<Zhcontcus>110000</Zhcontcus>'+
                            '<Zscontcus>Y</Zscontcus>'+'<Zletdata>N</Zletdata>'+'</Zjews12pocont>'+
                            '</n0:Fault>'+'</soap-env:Body>'+'</soap-env:Envelope>';
                      Map<Id,SPEN_Delivery__c> successResDelIdMapTest =  parseResponse(responseBody,delvRef,'Fault');
                    
                     responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
                            '<soap-env:Body>'+'<n0:Fault xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                            '<Returncode>000</Returncode>'+'<faultstring>'+
                            '<item>'+'<Type/>'+'<Language/>'+'<Id/>'+'<Number>000</Number>'+'<Message/>'+'</item>'+'<item>'+
                            '<Type>W</Type>'+'<Language>E</Language>'+'<Id>ZDSPW</Id>'+'<Number>014</Number>'+
                            '<Message>Post Acceptance Contact saved successfully</Message>'+
                            '</item>'+'</faultstring>'+'<Zjews12letter/>'+'<Zjews12pocont>'+
                            '<Zcodqas>612762818</Zcodqas>'+'<Zdcontcus>20231020</Zdcontcus>'+'<Zhcontcus>110000</Zhcontcus>'+
                            '<Zscontcus>Y</Zscontcus>'+'<Zletdata>N</Zletdata>'+'</Zjews12pocont>'+
                            '</n0:Fault>'+'</soap-env:Body>'+'</soap-env:Envelope>';
                  Map<Id,SPEN_Delivery__c> successResDelIdMapTest2 =  parseResponse(responseBody,delvRef,'mock');
                    
                    responseBody =  '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">'+'<soap-env:Header/>'+
                            '<soap-env:Body>'+'<n0:ZJws012PostacceptcontactResponse xmlns:n0="urn:sap-com:document:sap:soap:functions:mc-style">'+
                            '<Returncode>000</Returncode>'+'<Zjews00message>'+
                            '<item>'+'<Type/>'+'<Language/>'+'<Id/>'+'<Number>000</Number>'+'<Message/>'+'</item>'+'<item>'+
                            '<Type>W</Type>'+'<Language>E</Language>'+'<Id>ZDSPW</Id>'+'<Number>014</Number>'+
                            '<Message>Post Acceptance Contact saved successfully</Message>'+
                            '</item>'+'</Zjews00message>'+'<Zjews12letter/>'+'<Zjews12pocont>'+
                            '<Zcodqas>612762818</Zcodqas>'+'<Zdcontcus>20231020</Zdcontcus>'+'<Zhcontcus>110000</Zhcontcus>'+
                            '<Zscontcus>Y</Zscontcus>'+'<Zletdata>N</Zletdata>'+'</Zjews12pocont>'+
                            '</n0:ZJws012PostacceptcontactResponse>'+'</soap-env:Body>'+'</soap-env:Envelope>';
                  successResDelIdMap =  parseResponse(responseBody,delvRef,'mock');                     
                }
            }
            system.debug('message***' + successResDelIdMap);
            if(successResDelIdMap != null && !successResDelIdMap.isEmpty()){
                for(SPEN_Delivery__c delvryRef : deliveryList){
                    delvryRef.SPEN_SuccessSAP__c = successResDelIdMap.get(delvryRef.id).SPEN_SuccessSAP__c;
                    delvryRef.SPEN_SAPDetails__c = successResDelIdMap.get(delvryRef.id).SPEN_SAPDetails__c;
                    updateDelList.add(delvryRef);
                    if(delvryRef.SPEN_SuccessSAP__c && delvryRef.SPEN_Case__r.Status == 'Delivery Work Planning'){
                        Case updateCase = New Case();
                        updateCase.id = delvryRef.SPEN_Case__c;
                        updateCase.SPEN_SubStatus__c = 'GS Call Complete';
                        updateCaseList.add(updateCase);
                    }
                    system.debug('message***' + successResDelIdMap.get(delvryRef.id));
                }
            }
            if(updateDelList != null && updateDelList.size()> 0){
                update updateDelList;
            }
            if(updateCaseList != null && updateCaseList.size()> 0){
                update updateCaseList;
            }
        }catch(Exception ex){
            System.debug('SPEN_SAPProjectAssignCallOut:sendProjectAssignCallout==='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
            SEL_LoggingService.log(ex);
            throw ex;
        }
    }
    
    public static string generatePostAccContactRequest(SPEN_Delivery__c delvRef){
        String xmlstring = '';	
        List<User> loggedInUser = SPEN_UserInfoSelector.getLoggedInUsersInfo();
        
        try{
            //Time format values
            String dateValueHeader = system.now().format('yyyyMMdd');
            String dateValue = system.now().format('yyyyMMdd');
            String timeValue = system.now().format('HHmmss');
            String custContDateValue = (delvRef.SPEN_GSCallCompletionDate__c).format('yyyyMMdd');
            String custContTimeValue = (delvRef.SPEN_GSCallCompletionDate__c).format('HHmmss');
            
            //User Info
            String userDetail=(!String.isEmpty(loggedInUser[0].SPEN_SAPId__c) ? loggedInUser[0].SPEN_SAPId__c : System.Label.DefaultSAPUser);
            
            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'urn:sap-com:document:sap:soap:functions:mc-style';
            dom.XmlNode rootTag = doc.createRootElement('Envelope', soapNS, 'soapenv');
            rootTag.setNamespace('urn', xsi);
            dom.XmlNode headerTag = rootTag.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyTag = rootTag.addChildElement('soapenv:Body', null, null);
            dom.XmlNode zjws013SapPostAccContNamsTag = bodyTag.addChildElement('urn:ZJws012Postacceptcontact', null, null);
            dom.XmlNode zjews00headerTag = zjws013SapPostAccContNamsTag.addChildElement('Zjews00header', null, null);
            dom.XmlNode zjews00messageTag = zjws013SapPostAccContNamsTag.addChildElement('Zjews00message', null, null);
            dom.XmlNode zjews00letterTag = zjws013SapPostAccContNamsTag.addChildElement('Zjews12letter', null, null);
            dom.XmlNode zjews12pocontTag = zjws013SapPostAccContNamsTag.addChildElement('Zjews12pocont', null, null);
            
            //zjews00headerTag                
            dom.XmlNode zjews00headerLangTag = prepareChildTag(zjews00headerTag,'Language','E'); 
            dom.XmlNode zjews00headerUserTag = prepareChildTag(zjews00headerTag,'User',userDetail); //Mapping - Sap Id 
            dom.XmlNode zjews00headerTimeTag = prepareChildTag(zjews00headerTag,'Time',dateValueHeader); //Mapping - current date in format ddmmyyyy
            dom.XmlNode zjews00headerHourTag = prepareChildTag(zjews00headerTag,'Hour',timeValue);
            
            //zjews00messageTag
            dom.XmlNode zjews00messageItemTag = zjews00messageTag.addChildElement('item', null, null);
            dom.XmlNode zjews00messageItemTypeTag = prepareChildTag(zjews00messageItemTag,'Type',null);	
            dom.XmlNode zjews00messageItemLangTag = prepareChildTag(zjews00messageItemTag,'Language','E');	
            dom.XmlNode zjews00messageItemIdTag = prepareChildTag(zjews00messageItemTag,'Id',userDetail);	
            dom.XmlNode zjews00messageItemNumTag = prepareChildTag(zjews00messageItemTag,'Number',null);	
            dom.XmlNode zjews00messageItemMsgTag = prepareChildTag(zjews00messageItemTag,'Message',null);
            
            //Zjews12letterTag
            dom.XmlNode zjews00letterItemTag = zjews00letterTag.addChildElement('item', null, null);
            dom.XmlNode zjews00letterLetterTempTag = prepareChildTag(zjews00letterTag,'Zlettertemple',null);	
            dom.XmlNode zjews00letterFieldTag = prepareChildTag(zjews00letterTag,'Zfield',null);	
            dom.XmlNode zjews00letterTextTag = prepareChildTag(zjews00letterTag,'Text',null);
            
            //Zjews12pocontTag
            dom.XmlNode zcodqasTag = prepareChildTag(zjews12pocontTag,'Zcodqas',(String.isNotBlank(delvRef.SPEN_CaseSAPRefFormula__c) ? delvRef.SPEN_CaseSAPRefFormula__c :''));
            dom.XmlNode zdcontcusTag = prepareChildTag(zjews12pocontTag,'Zdcontcus',custContDateValue);
            dom.XmlNode zhcontcusTag = prepareChildTag(zjews12pocontTag,'Zhcontcus',custContTimeValue);
            dom.XmlNode zscontcusTag = prepareChildTag(zjews12pocontTag,'Zscontcus','Y');
            dom.XmlNode zletdataTag = prepareChildTag(zjews12pocontTag,'Zletdata','N');
            
            xmlstring = doc.toXmlString();
            
        }catch(Exception ex){
            System.debug('SPEN_SAPPostAccContactCallOut:sendPostAccContactCallout==='+ex.getMessage() +ex.getLineNumber() +ex.getStackTraceString());
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
    
      public static Map<Id,SPEN_Delivery__c> parseResponse(String responseBody,SPEN_Delivery__c deliveryRef,String result){
        String errorMessage='';
        Map<Id,SPEN_Delivery__c> deliveryAndErrorMap = new Map<Id,SPEN_Delivery__c>();
        
        DOM.Document document = new DOM.Document();
        document.load(responseBody);
        for (DOM.XmlNode node : document.getRootElement().getChildren()){
            if(node.getName() == 'Body'){
                for (DOM.XmlNode node2 : node.getChildren()){
                    if(result=='success' || result=='mock'){
                        if(node2.getName() == 'ZJws012PostacceptcontactResponse'){
                            for (DOM.XmlNode node3 : node2.getChildren()){
                                system.debug('node3-----'+node3 +'===NAME--'+node3.getName() + '--TEXT--'+node3.getText());
                                if(node3.getName() == 'Returncode' && node3.getText() == '000'){
                                    deliveryRef.SPEN_SuccessSAP__c = true;
                                    deliveryRef.SPEN_SAPDetails__c = 'Post Acceptance Contact saved successfully';
                                    system.debug('message***' + deliveryRef.SPEN_SuccessSAP__c);
                                }else if(node3.getName() == 'Zjews00message'){                                   
                                    for (DOM.XmlNode node4 : node3.getChildren()){
                                        if(node4.getName() == 'item'){
                                            for (DOM.XmlNode node5 : node4.getChildren()){
                                                if(node5.getName() == 'Message'){
                                                    if(!deliveryRef.SPEN_SuccessSAP__c){
                                                        deliveryRef.SPEN_SAPDetails__c = errorMessage + node5.getText()+'.';
                                                    }
                                                    system.debug('message***' + deliveryRef.SPEN_SuccessSAP__c);
                                                }
                                            } 
                                        }
                                    } 
                                }
                                system.debug('message***' + deliveryRef.SPEN_SuccessSAP__c);
                            }
                        }
                        if(node2.getName() == 'Fault'){
                          deliveryRef.SPEN_SuccessSAP__c = false;
                            for (DOM.XmlNode node3 : node2.getChildren()){
                                if(node3.getName() == 'faultstring'){
                                     deliveryRef.SPEN_SAPDetails__c = errorMessage + node3.getText()+'.';
                                }
                            }
                        }
                        system.debug('message***' + deliveryRef.SPEN_SuccessSAP__c);
                    }else{
                        if(node2.getName() == 'Fault'){
                          deliveryRef.SPEN_SuccessSAP__c = false;
                            for (DOM.XmlNode node3 : node2.getChildren()){
                                if(node3.getName() == 'faultstring'){
                                     deliveryRef.SPEN_SAPDetails__c = errorMessage + node3.getText()+'.';
                                }
                            }
                        }
                        system.debug('message***' + deliveryRef.SPEN_SuccessSAP__c);
                    }
                }
            }
        }
        system.debug('message***' + deliveryRef.SPEN_SuccessSAP__c);
        system.debug('errorMessage --------->>>>>'+deliveryRef.SPEN_SAPDetails__c);
        deliveryAndErrorMap.put(deliveryRef.Id,deliveryRef);
        system.debug('deliveryAndErrorMap --------->>>>>'+deliveryAndErrorMap);
        return deliveryAndErrorMap;
    }
}
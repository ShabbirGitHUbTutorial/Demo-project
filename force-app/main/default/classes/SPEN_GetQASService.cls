/*-----------------------------------------------------------------------------
DESCRIPTION :   This is Service class used to generate "Get QAS" xml request
VERSION     :   1.0

HISTORY     :
Date            Author              Comment
26-Dec-2023     Rohit Sharma        Initial version
-----------------------------------------------------------------------------*/
public class SPEN_GetQASService {
    public static string generateGetQASRequest(String sapReference)
    {
        String xmlstring = '';
        try 
        {
            List<User>	loggedInUser = new List<User>();
            loggedInUser = SPEN_UserInfoSelector.getLoggedInUsersInfo(); //TBC : if no value default System.Label.DefaultSAPUser
            //Time format values
            String dateValueHeader = system.now().format('yyyyMMdd');
            String dateValue = system.now().format('yyyyMMdd');
            String timeValue = system.now().format('HHmmss');
            String userDetail=(!String.isEmpty(loggedInUser[0].SPEN_SAPId__c) ? loggedInUser[0].SPEN_SAPId__c : System.Label.DefaultSAPUser);
            
            DOM.Document doc = new DOM.Document();
            String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
            String xsi = 'urn:sap-com:document:sap:soap:functions:mc-style';
            dom.XmlNode rootTag = doc.createRootElement('Envelope', soapNS, 'soapenv');
            rootTag.setNamespace('urn', xsi);
            dom.XmlNode headerTag = rootTag.addChildElement('soapenv:Header', null, null);
            dom.XmlNode bodyTag = rootTag.addChildElement('soapenv:Body', null, null);
            dom.XmlNode ZJws002SapgetqasTag = bodyTag.addChildElement('urn:ZJws002Sapgetqas', null, null);
            
            //Tags under ZJws002Sapgetqas
            dom.XmlNode zcodqasTag = prepareChildTag(ZJws002SapgetqasTag,'Zcodqas',sapReference);
            dom.XmlNode zjews00headerTag = ZJws002SapgetqasTag.addChildElement('Zjews00header', null, null);
            dom.XmlNode zjews02noteTag = prepareChildTag(ZJws002SapgetqasTag,'Zjews02note',null);
            dom.XmlNode zjews02pendinfTag = prepareChildTag(ZJws002SapgetqasTag,'Zjews02pendinf',null);
            dom.XmlNode zjews02plotsTag = prepareChildTag(ZJws002SapgetqasTag,'Zjews02plots',null);
            
            //zjews00headerTag                
            dom.XmlNode zjews00headerLangTag = prepareChildTag(zjews00headerTag,'Language','E'); //Mapping - Should be hard code
            dom.XmlNode zjews00headerUserTag = prepareChildTag(zjews00headerTag,'User',userDetail); //Mapping - Sap Id //U334219 
            dom.XmlNode zjews00headerTimeTag = prepareChildTag(zjews00headerTag,'Time',dateValueHeader); //Mapping - current date in format ddmmyyyy
            dom.XmlNode zjews00headerHourTag = prepareChildTag(zjews00headerTag,'Hour',timeValue); //Mapping - current time
            
            xmlstring = doc.toXmlString();
        
        }catch(Exception ex){
            System.debug('In class SPEN_GetQASService : exception block='+ex.getMessage()  +ex.getLineNumber() +ex.getStackTraceString());
            SEL_LoggingService.log(ex);
        }
        return xmlstring;
    }
    
    public static dom.XmlNode prepareChildTag(dom.XmlNode parentNode, string tagName)
    {
        dom.XmlNode xmlNodeVar;
        parentNode.addChildElement(tagName, null, null);
        return xmlNodeVar;
    }
    public static dom.XmlNode prepareChildTag(dom.XmlNode parentNode, string tagName, String tagValue)
    {
        dom.XmlNode xmlNodeVar;
        parentNode.addChildElement(tagName, null, null).addTextNode(!String.isEmpty(tagValue) ? tagValue : '');
        return xmlNodeVar;
    }
    
}
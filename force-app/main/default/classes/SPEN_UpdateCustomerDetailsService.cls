/*
 * Service class created to generate 
 * update customer details xml request
*/ 
public class SPEN_UpdateCustomerDetailsService {
	
    public static string generateCustomerDetailsRequest(Id contactId, SPEN_ContactPSRWrapper.getcustomerdetailsResponse getCustDetails)
    //public static void generateCustomerDetailsRequest()
    {
        Boolean psrUpdateFlag = false;
        List<SPEN_ContactPremise__c> contactPremiseList = new List<SPEN_ContactPremise__c>();
        contactPremiseList = [Select Id,SPEN_Premise__c,SPEN_RelatedContact__c,SPEN_Role__c,
                             SPEN_RelatedContact__r.SPEN_AgentID__c,SPEN_RelatedContact__r.MobilePhone,
                             SPEN_RelatedContact__r.Phone,SPEN_RelatedContact__r.HomePhone,SPEN_RelatedContact__r.OtherPhone,
                             SPEN_RelatedContact__r.Email,SPEN_RelatedContact__r.SPEN_ConsentToShareFamilyandNeighbours__c,
                             SPEN_RelatedContact__r.SPEN_VersionNumber__c, SPEN_RelatedContact__r.SPEN_PSRSynctoADQM__c,
                             SPEN_RelatedContact__r.Salutation,SPEN_RelatedContact__r.MiddleName,
							 SPEN_RelatedContact__r.FirstName,SPEN_RelatedContact__r.LastName,
                             SPEN_RelatedContact__r.Name,
                             SPEN_Premise__r.SPEN_ConsentToSharePSRGiven__c
                             FROM SPEN_ContactPremise__c
                             WHERE SPEN_RelatedContact__c =: contactId LIMIT 1];
        //system.debug('-----contactPremiseList-----'+contactPremiseList);
        if(contactPremiseList[0].SPEN_Role__c == 'PSR Contact' || contactPremiseList[0].SPEN_Role__c == 'PSR Contact (Alternative)')
        {
           psrUpdateFlag = true; 
        }
        String xmlstring = '';
        DOM.Document doc = new DOM.Document();
        String soapNS = 'http://schemas.xmlsoap.org/soap/envelope/';
        String xsi = 'http://adqm_adaptor/AdqmWS.wsdl';
        String envType = 'http://adqm_adaptor/AdqmWS.wsdl/types/';
        //String serviceNS = 'http://www.myservice.com/services/MyService/';
        dom.XmlNode results = doc.createRootElement('Envelope', soapNS, 'soapenv');
        results.setNamespace('adq', xsi);
        results.setNamespace('typ', envType);
        dom.XmlNode headerTag = results.addChildElement('soapenv:Header', null, null);
        dom.XmlNode bodyTag = results.addChildElement('soapenv:Body', null, null);
        dom.XmlNode updateCustDetailsTag = bodyTag.addChildElement('adq:updatecustomerdetails', null, null);
        dom.XmlNode agentIdTag = prepareChildTag(updateCustDetailsTag,'agentid', (!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.SPEN_AgentID__c) ? contactPremiseList[0].SPEN_RelatedContact__r.SPEN_AgentID__c : '') );//updateCustDetailsTag.addChildElement('agentid', null, null).addTextNode('U345572');//replace with contact AgentId field
        dom.XmlNode premiseIdTag = prepareChildTag(updateCustDetailsTag,'premisesid', (!String.isEmpty(getCustDetails.Customerdetails[0].premisesid) ? getCustDetails.Customerdetails[0].premisesid : '') );
        dom.XmlNode passwordTag = prepareChildTag(updateCustDetailsTag,'password', (!String.isEmpty(getCustDetails.Customerdetails[0].password) ? getCustDetails.Customerdetails[0].password : '') );
        dom.XmlNode customertypecodeTag = prepareChildTag(updateCustDetailsTag,'customertypecode', (!String.isEmpty(getCustDetails.Customerdetails[0].customertypecode) ? getCustDetails.Customerdetails[0].customertypecode : '') );
        
        String salutationValue = ((getCustDetails.Customerdetails[0].salutation != contactPremiseList[0].SPEN_RelatedContact__r.Salutation) && contactPremiseList[0].SPEN_Role__c == 'Customer') ? contactPremiseList[0].SPEN_RelatedContact__r.Salutation : getCustDetails.Customerdetails[0].salutation;
        String initialsValue = ((getCustDetails.Customerdetails[0].initials != contactPremiseList[0].SPEN_RelatedContact__r.MiddleName)&& contactPremiseList[0].SPEN_Role__c == 'Customer') ? contactPremiseList[0].SPEN_RelatedContact__r.MiddleName : getCustDetails.Customerdetails[0].initials;
        String forenameValue = ((getCustDetails.Customerdetails[0].forename != contactPremiseList[0].SPEN_RelatedContact__r.FirstName)&& contactPremiseList[0].SPEN_Role__c == 'Customer') ? contactPremiseList[0].SPEN_RelatedContact__r.FirstName : getCustDetails.Customerdetails[0].forename;
        String surnameValue = ((getCustDetails.Customerdetails[0].surname != contactPremiseList[0].SPEN_RelatedContact__r.LastName)&& contactPremiseList[0].SPEN_Role__c == 'Customer') ? contactPremiseList[0].SPEN_RelatedContact__r.LastName : getCustDetails.Customerdetails[0].surname;
        
        dom.XmlNode salutationTag = prepareChildTag(updateCustDetailsTag,'salutation', salutationValue );
        dom.XmlNode initialsTag = prepareChildTag(updateCustDetailsTag,'initials', initialsValue);
        dom.XmlNode forenameTag = prepareChildTag(updateCustDetailsTag,'forename', forenameValue);
        dom.XmlNode surnameTag = prepareChildTag(updateCustDetailsTag,'surname', surnameValue);
        dom.XmlNode positionTag = prepareChildTag(updateCustDetailsTag,'position', (!String.isEmpty(getCustDetails.Customerdetails[0].position) ? getCustDetails.Customerdetails[0].position : '') );
        dom.XmlNode companyTag = prepareChildTag(updateCustDetailsTag,'company', (!String.isEmpty(getCustDetails.Customerdetails[0].company) ? getCustDetails.Customerdetails[0].company : '') );
        //CustomerAdd Start
        dom.XmlNode customeraddressTag = updateCustDetailsTag.addChildElement('customeraddress',null,null);
        dom.XmlNode custbuildingnameTag = prepareChildTag(customeraddressTag,'typ:buildingname', (!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].buildingname) ? getCustDetails.Customerdetails[0].Custaddress[0].buildingname : '') );
        dom.XmlNode custsubbuildingnamenoTag = prepareChildTag(customeraddressTag,'typ:subbuildingnameno',(!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].subbuildingnameno) ? getCustDetails.Customerdetails[0].Custaddress[0].subbuildingnameno : '') );
        dom.XmlNode custcountyTag = prepareChildTag(customeraddressTag,'typ:county',(!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].county) ? getCustDetails.Customerdetails[0].Custaddress[0].county : ''));
        dom.XmlNode custdoubledependentlocalityTag = prepareChildTag(customeraddressTag,'typ:doubledependentlocality',(!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].doubledependentlocality) ? getCustDetails.Customerdetails[0].Custaddress[0].doubledependentlocality : ''));
        dom.XmlNode custlocalityTag = prepareChildTag(customeraddressTag,'typ:locality',(!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].locality) ? getCustDetails.Customerdetails[0].Custaddress[0].locality : ''));
        dom.XmlNode custstreetnameTag = prepareChildTag(customeraddressTag,'typ:streetname',(!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].streetname) ? getCustDetails.Customerdetails[0].Custaddress[0].streetname : ''));
        dom.XmlNode custhousenumberTag = prepareChildTag(customeraddressTag,'typ:housenumber',(!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].housenumber) ? getCustDetails.Customerdetails[0].Custaddress[0].housenumber : ''));
        dom.XmlNode custpostcodeTag = prepareChildTag(customeraddressTag,'typ:postcode',(!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].postcode) ? getCustDetails.Customerdetails[0].Custaddress[0].postcode : ''));
        dom.XmlNode custdependentthoroughfareTag = prepareChildTag(customeraddressTag,'typ:dependentthoroughfare',(!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].dependentthoroughfare) ? getCustDetails.Customerdetails[0].Custaddress[0].dependentthoroughfare : ''));
        dom.XmlNode custposttownTag = prepareChildTag(customeraddressTag,'typ:posttown',(!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].posttown) ? getCustDetails.Customerdetails[0].Custaddress[0].posttown : ''));
        dom.XmlNode custplotTag = prepareChildTag(customeraddressTag,'typ:plot',(!String.isEmpty(getCustDetails.Customerdetails[0].Custaddress[0].plot) ? getCustDetails.Customerdetails[0].Custaddress[0].plot : ''));
        //CustomerAdd end
        String contactName;
        if(contactPremiseList[0].SPEN_RelatedContact__r.Salutation!=NULL){
            contactName = contactPremiseList[0].SPEN_RelatedContact__r.Salutation + ' ' + contactPremiseList[0].SPEN_RelatedContact__r.Name;
        }
        else{
            contactName =  contactPremiseList[0].SPEN_RelatedContact__r.Name;
        }
        //SiteAdd start
        //String sitecontactnameValue = ((getCustDetails.Customerdetails[0].sitecontactname != contactName) && contactPremiseList[0].SPEN_Role__c == 'Site Contact') ? contactName : getCustDetails.Customerdetails[0].sitecontactname;
        dom.XmlNode sitecontactnameTag = prepareChildTag(updateCustDetailsTag,'sitecontactname',getCustDetails.Customerdetails[0].sitecontactname);
        dom.XmlNode siteaddressTag = updateCustDetailsTag.addChildElement('sitecontactaddress',null,null);
        dom.XmlNode sitebuildingnameTag = prepareChildTag(siteaddressTag,'typ:buildingname',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].buildingname) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].buildingname : ''));
        dom.XmlNode sitesubbuildingnamenoTag = prepareChildTag(siteaddressTag,'typ:subbuildingnameno',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].subbuildingnameno) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].subbuildingnameno : ''));
        dom.XmlNode sitecountyTag = prepareChildTag(siteaddressTag,'typ:county',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].county) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].county : ''));
        dom.XmlNode sitedoubledependentlocalityTag = prepareChildTag(siteaddressTag,'typ:doubledependentlocality',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].doubledependentlocality) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].doubledependentlocality : ''));
        dom.XmlNode sitelocalityTag = prepareChildTag(siteaddressTag,'typ:locality',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].locality) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].locality : ''));
        dom.XmlNode sitestreetnameTag = prepareChildTag(siteaddressTag,'typ:streetname',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].streetname) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].streetname : ''));
        dom.XmlNode sitehousenumberTag = prepareChildTag(siteaddressTag,'typ:housenumber',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].housenumber) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].housenumber : ''));
        dom.XmlNode sitepostcodeTag = prepareChildTag(siteaddressTag,'typ:postcode',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].postcode) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].postcode : ''));
        dom.XmlNode sitedependentthoroughfareTag = prepareChildTag(siteaddressTag,'typ:dependentthoroughfare',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].dependentthoroughfare) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].dependentthoroughfare : ''));
        dom.XmlNode siteposttownTag = prepareChildTag(siteaddressTag,'typ:posttown',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].posttown) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].posttown : ''));
        dom.XmlNode siteplotTag = prepareChildTag(siteaddressTag,'typ:plot',(!String.isEmpty(getCustDetails.Customerdetails[0].sitecontactaddress[0].plot) ? getCustDetails.Customerdetails[0].sitecontactaddress[0].plot : ''));
        //SiteAdd end
        
        //AltAdd start
        String alternativedetailsnameValue = ((getCustDetails.Customerdetails[0].altdetailsname != contactName) && contactPremiseList[0].SPEN_Role__c == 'Alternative Contact') ? contactName : getCustDetails.Customerdetails[0].altdetailsname;
        dom.XmlNode alternativedetailsnameTag = prepareChildTag(updateCustDetailsTag,'alternativedetailsname',alternativedetailsnameValue);
		dom.XmlNode altaddressTag = updateCustDetailsTag.addChildElement('alternativedetailsaddress',null,null);
        dom.XmlNode altbuildingnameTag = prepareChildTag(altaddressTag,'typ:buildingname',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].buildingname) ? getCustDetails.Customerdetails[0].altdetsaddress[0].buildingname : ''));
        dom.XmlNode altsubbuildingnamenoTag = prepareChildTag(altaddressTag,'typ:subbuildingnameno',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].subbuildingnameno) ? getCustDetails.Customerdetails[0].altdetsaddress[0].subbuildingnameno : ''));
        dom.XmlNode altcountyTag = prepareChildTag(altaddressTag,'typ:county',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].county) ? getCustDetails.Customerdetails[0].altdetsaddress[0].county : ''));
        dom.XmlNode altdoubledependentlocalityTag = prepareChildTag(altaddressTag,'typ:doubledependentlocality',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].doubledependentlocality) ? getCustDetails.Customerdetails[0].altdetsaddress[0].doubledependentlocality : ''));
        dom.XmlNode altlocalityTag = prepareChildTag(altaddressTag,'typ:locality',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].locality) ? getCustDetails.Customerdetails[0].altdetsaddress[0].locality : ''));
        dom.XmlNode altstreetnameTag = prepareChildTag(altaddressTag,'typ:streetname',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].streetname) ? getCustDetails.Customerdetails[0].altdetsaddress[0].streetname : ''));
        dom.XmlNode althousenumberTag = prepareChildTag(altaddressTag,'typ:housenumber',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].housenumber) ? getCustDetails.Customerdetails[0].altdetsaddress[0].housenumber : ''));
        dom.XmlNode altpostcodeTag = prepareChildTag(altaddressTag,'typ:postcode',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].postcode) ? getCustDetails.Customerdetails[0].altdetsaddress[0].postcode : ''));
        dom.XmlNode altdependentthoroughfareTag = prepareChildTag(altaddressTag,'typ:dependentthoroughfare',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].dependentthoroughfare) ? getCustDetails.Customerdetails[0].altdetsaddress[0].dependentthoroughfare : ''));
        dom.XmlNode altposttownTag = prepareChildTag(altaddressTag,'typ:posttown',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].posttown) ? getCustDetails.Customerdetails[0].altdetsaddress[0].posttown	 : ''));
        dom.XmlNode altplotTag = prepareChildTag(altaddressTag,'typ:plot',(!String.isEmpty(getCustDetails.Customerdetails[0].altdetsaddress[0].plot) ? getCustDetails.Customerdetails[0].altdetsaddress[0].plot	 : ''));
        
        //AltAdd end
        
        //PremiseAdd end
		
        String premisesownernameValue = ((getCustDetails.Customerdetails[0].premisesowner != contactName) && contactPremiseList[0].SPEN_Role__c == 'Premise Owner') ? contactName : getCustDetails.Customerdetails[0].premisesowner;
        dom.XmlNode premisesownernameTag = prepareChildTag(updateCustDetailsTag,'premisesownername',premisesownernameValue);
		dom.XmlNode premOwnerAddressTag = updateCustDetailsTag.addChildElement('premisesowneraddress',null,null);
        /*dom.XmlNode premOwnerbuildingnameTag = prepareChildTag(premOwnerAddressTag,'typ:buildingname',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].buildingname) ? getCustDetails.Customerdetails[0].premiseaddress[0].buildingname : ''));
        dom.XmlNode premOwnersubbuildingnamenoTag = prepareChildTag(premOwnerAddressTag,'typ:subbuildingnameno',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].subbuildingnameno) ? getCustDetails.Customerdetails[0].premiseaddress[0].subbuildingnameno : ''));
        dom.XmlNode premOwnercountyTag = prepareChildTag(premOwnerAddressTag,'typ:county',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].county) ? getCustDetails.Customerdetails[0].premiseaddress[0].county : ''));
        System.debug('====premOwnercountyTag==='+premOwnercountyTag);
        dom.XmlNode premOwnerdoubledependentlocalityTag = prepareChildTag(premOwnerAddressTag,'typ:doubledependentlocality',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].doubledependentlocality) ? getCustDetails.Customerdetails[0].premiseaddress[0].doubledependentlocality : ''));
        dom.XmlNode premOwnerlocalityTag = prepareChildTag(premOwnerAddressTag,'typ:locality',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].locality) ? getCustDetails.Customerdetails[0].premiseaddress[0].locality : ''));
        dom.XmlNode premOwnerstreetnameTag = prepareChildTag(premOwnerAddressTag,'typ:streetname',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].streetname) ? getCustDetails.Customerdetails[0].premiseaddress[0].streetname : ''));
        dom.XmlNode premOwnerhousenumberTag = prepareChildTag(premOwnerAddressTag,'typ:housenumber',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].housenumber) ? getCustDetails.Customerdetails[0].premiseaddress[0].housenumber : ''));
        dom.XmlNode premOwnerpostcodeTag = prepareChildTag(premOwnerAddressTag,'typ:postcode',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].postcode) ? getCustDetails.Customerdetails[0].premiseaddress[0].postcode : ''));
        dom.XmlNode premOwnerdependentthoroughfareTag = prepareChildTag(premOwnerAddressTag,'typ:dependentthoroughfare',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].dependentthoroughfare) ? getCustDetails.Customerdetails[0].premiseaddress[0].dependentthoroughfare : ''));
        dom.XmlNode premOwnerposttownTag = prepareChildTag(premOwnerAddressTag,'typ:posttown',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].posttown) ? getCustDetails.Customerdetails[0].premiseaddress[0].posttown : ''));
        dom.XmlNode premOwnerplotTag = prepareChildTag(premOwnerAddressTag,'typ:plot',(!String.isEmpty(getCustDetails.Customerdetails[0].premiseaddress[0].plot) ? getCustDetails.Customerdetails[0].premiseaddress[0].plot : ''));*/
        dom.XmlNode premOwnerbuildingnameTag = prepareChildTag(premOwnerAddressTag,'typ:buildingname',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].buildingname) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].buildingname : ''));
        dom.XmlNode premOwnersubbuildingnamenoTag = prepareChildTag(premOwnerAddressTag,'typ:subbuildingnameno',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].subbuildingnameno) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].subbuildingnameno : ''));
        dom.XmlNode premOwnercountyTag = prepareChildTag(premOwnerAddressTag,'typ:county',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].county) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].county : ''));
        //System.debug('====premOwnercountyTag==='+premOwnercountyTag);
        dom.XmlNode premOwnerdoubledependentlocalityTag = prepareChildTag(premOwnerAddressTag,'typ:doubledependentlocality',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].doubledependentlocality) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].doubledependentlocality : ''));
        dom.XmlNode premOwnerlocalityTag = prepareChildTag(premOwnerAddressTag,'typ:locality',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].locality) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].locality : ''));
        dom.XmlNode premOwnerstreetnameTag = prepareChildTag(premOwnerAddressTag,'typ:streetname',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].streetname) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].streetname : ''));
        dom.XmlNode premOwnerhousenumberTag = prepareChildTag(premOwnerAddressTag,'typ:housenumber',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].housenumber) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].housenumber : ''));
        dom.XmlNode premOwnerpostcodeTag = prepareChildTag(premOwnerAddressTag,'typ:postcode',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].postcode) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].postcode : ''));
        dom.XmlNode premOwnerdependentthoroughfareTag = prepareChildTag(premOwnerAddressTag,'typ:dependentthoroughfare',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].dependentthoroughfare) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].dependentthoroughfare : ''));
        dom.XmlNode premOwnerposttownTag = prepareChildTag(premOwnerAddressTag,'typ:posttown',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].posttown) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].posttown : ''));
        dom.XmlNode premOwnerplotTag = prepareChildTag(premOwnerAddressTag,'typ:plot',(!String.isEmpty(getCustDetails.Customerdetails[0].Premisesownaddress[0].plot) ? getCustDetails.Customerdetails[0].Premisesownaddress[0].plot : ''));
        //PremiseAdd end
        
        //Phone tags to be added post Sheker add those into wrapper
        dom.XmlNode sitephonenumberlistTag = updateCustDetailsTag.addChildElement('sitephonenumberlist',null,null);
        dom.XmlNode customerphonenumberlistTag = updateCustDetailsTag.addChildElement('customerphonenumberlist',null,null);
        dom.XmlNode altdetailsphonenumberlistTag = updateCustDetailsTag.addChildElement('altdetailsphonenumberlist',null,null);
        dom.XmlNode premisesownphonenumberlistTag = updateCustDetailsTag.addChildElement('premisesownphonenumberlist',null,null);
        
        dom.XmlNode sitecontemailaddresslistTag = updateCustDetailsTag.addChildElement('sitecontemailaddresslist',null,null);
        dom.XmlNode customeremailaddresslistTag = updateCustDetailsTag.addChildElement('customeremailaddresslist',null,null);
        dom.XmlNode altdetailsemailaddresslistTag = updateCustDetailsTag.addChildElement('altdetailsemailaddresslist',null,null);
        dom.XmlNode premsownemailaddresslistTag = updateCustDetailsTag.addChildElement('premsownemailaddresslist',null,null);
        
        if(!contactPremiseList.isEmpty())
        {
            dom.XmlNode requiredPhoneTag;
            dom.XmlNode requiredEmailTag;
            if(contactPremiseList[0].SPEN_Role__c == 'Customer')
            {
                requiredPhoneTag = customerphonenumberlistTag;
                requiredEmailTag = customeremailaddresslistTag;
            }
            /*else if(contactPremiseList[0].SPEN_Role__c == 'Site Contact'){
                requiredPhoneTag = sitephonenumberlistTag;
                requiredEmailTag = sitecontemailaddresslistTag;
            }*/
            else if(contactPremiseList[0].SPEN_Role__c == 'Premise Owner'){
                requiredPhoneTag = premisesownphonenumberlistTag;
                requiredEmailTag = premsownemailaddresslistTag;
            }
            else if(contactPremiseList[0].SPEN_Role__c == 'Alternative Contact'){
                requiredPhoneTag = altdetailsphonenumberlistTag;
                requiredEmailTag = altdetailsemailaddresslistTag;
            }
            //if(contactPremiseList[0].SPEN_Role__c != 'Site Contact')
            {
				//PSR Primary & ALternate contact covered under PSRDetails section, hence this condition is required
                if(contactPremiseList[0].SPEN_Role__c != 'PSR Contact' && contactPremiseList[0].SPEN_Role__c != 'PSR Contact (Alternative)')
                {
                    if(!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.MobilePhone))
                    {
                        dom.XmlNode phonedetailsTag = requiredPhoneTag.addChildElement('typ:phonedetails',null,null);
                        dom.XmlNode phonenoTag =  prepareChildTag(phonedetailsTag,'typ:phoneno',contactPremiseList[0].SPEN_RelatedContact__r.MobilePhone);
                        dom.XmlNode phonetypeTag = prepareChildTag(phonedetailsTag,'typ:phonetype','MOBILE');
                    }
                    if(!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.Phone))
                    {
                        dom.XmlNode phonedetailsTag = requiredPhoneTag.addChildElement('typ:phonedetails',null,null);
                        dom.XmlNode phonenoTag =  prepareChildTag(phonedetailsTag,'typ:phoneno',contactPremiseList[0].SPEN_RelatedContact__r.Phone);
                        dom.XmlNode phonetypeTag = prepareChildTag(phonedetailsTag,'typ:phonetype','HOME');
                    }
                    if(!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.OtherPhone))
                    {
                        dom.XmlNode phonedetailsTag = requiredPhoneTag.addChildElement('typ:phonedetails',null,null);
                        dom.XmlNode phonenoTag =  prepareChildTag(phonedetailsTag,'typ:phoneno',contactPremiseList[0].SPEN_RelatedContact__r.OtherPhone);
                        dom.XmlNode phonetypeTag = prepareChildTag(phonedetailsTag,'typ:phonetype','OTHER');
                    }
                    if(!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.Email))
                    {
                        dom.XmlNode emailDetailsTag = requiredEmailTag.addChildElement('typ:emaildetails',null,null);
                        dom.XmlNode emailaddressTag =  prepareChildTag(emailDetailsTag,'typ:emailaddress',contactPremiseList[0].SPEN_RelatedContact__r.Email);
                    }
                    
                }
                if(!getCustDetails.Customerdetails[0].custphonelist.isEmpty() && contactPremiseList[0].SPEN_Role__c != 'Customer')
                {
                   for(Integer i=0;i<getCustDetails.Customerdetails[0].custphonelist[0].phonedetails.size();i++)
                    {
                        dom.XmlNode phonedetailsTag = customerphonenumberlistTag.addChildElement('typ:phonedetails',null,null);
                        dom.XmlNode phonenoTag = prepareChildTag(phonedetailsTag,'typ:phoneno',getCustDetails.Customerdetails[0].custphonelist[0].phonedetails[i].phoneno);
                        dom.XmlNode phonetypeTag = prepareChildTag(phonedetailsTag,'typ:phonetype',getCustDetails.Customerdetails[0].custphonelist[0].phonedetails[i].phonetype);
                    } 
                }
                //if(!getCustDetails.Customerdetails[0].sitephonelist.isEmpty() && contactPremiseList[0].SPEN_Role__c != 'Site Contact')
				//sitephonenumberlist data will be from what its in ADQM
                if(!getCustDetails.Customerdetails[0].sitephonelist.isEmpty() )
                {
                   for(Integer i=0;i<getCustDetails.Customerdetails[0].sitephonelist[0].phonedetails.size();i++)
                    {
                        dom.XmlNode phonedetailsTag = sitephonenumberlistTag.addChildElement('typ:phonedetails',null,null);
                        dom.XmlNode phonenoTag = prepareChildTag(phonedetailsTag,'typ:phoneno',getCustDetails.Customerdetails[0].sitephonelist[0].phonedetails[i].phoneno);
                        dom.XmlNode phonetypeTag = prepareChildTag(phonedetailsTag,'typ:phonetype',getCustDetails.Customerdetails[0].sitephonelist[0].phonedetails[i].phonetype);
                    } 
                }
                
                if(!getCustDetails.Customerdetails[0].altphonelist.isEmpty() && contactPremiseList[0].SPEN_Role__c != 'Alternative Contact')
                {
                   for(Integer i=0;i<getCustDetails.Customerdetails[0].altphonelist[0].phonedetails.size();i++)
                    {
                        dom.XmlNode phonedetailsTag = altdetailsphonenumberlistTag.addChildElement('typ:phonedetails',null,null);
                        dom.XmlNode phonenoTag = prepareChildTag(phonedetailsTag,'typ:phoneno',getCustDetails.Customerdetails[0].altphonelist[0].phonedetails[i].phoneno);
                        dom.XmlNode phonetypeTag = prepareChildTag(phonedetailsTag,'typ:phonetype',getCustDetails.Customerdetails[0].altphonelist[0].phonedetails[i].phonetype);
                    } 
                }
                
                if(!getCustDetails.Customerdetails[0].ownphonelist.isEmpty() && contactPremiseList[0].SPEN_Role__c != 'Premise Owner')
                {
                   for(Integer i=0;i<getCustDetails.Customerdetails[0].ownphonelist[0].phonedetails.size();i++)
                    {
                        dom.XmlNode phonedetailsTag = premisesownphonenumberlistTag.addChildElement('typ:phonedetails',null,null);
                        dom.XmlNode phonenoTag = prepareChildTag(phonedetailsTag,'typ:phoneno',getCustDetails.Customerdetails[0].ownphonelist[0].phonedetails[i].phoneno);
                        dom.XmlNode phonetypeTag = prepareChildTag(phonedetailsTag,'typ:phonetype',getCustDetails.Customerdetails[0].ownphonelist[0].phonedetails[i].phonetype);
                    } 
                }
                
                if(!getCustDetails.Customerdetails[0].custemaillist.isEmpty() && contactPremiseList[0].SPEN_Role__c != 'Customer')
                {
                   for(Integer i=0;i<getCustDetails.Customerdetails[0].custemaillist[0].emaildetails.size();i++)
                    {
                        dom.XmlNode emailDetailsTag = customeremailaddresslistTag.addChildElement('typ:emaildetails',null,null);
                        dom.XmlNode emailaddressTag = prepareChildTag(emailDetailsTag,'typ:emailaddress',getCustDetails.Customerdetails[0].custemaillist[0].emaildetails[i].emailaddress);
                    } 
                }
				// Set site email data from ADQM
                //if(!getCustDetails.Customerdetails[0].siteemaillist.isEmpty() && contactPremiseList[0].SPEN_Role__c != 'Site Contact')
				if(!getCustDetails.Customerdetails[0].siteemaillist.isEmpty() )
                {
                   for(Integer i=0;i<getCustDetails.Customerdetails[0].siteemaillist[0].emaildetails.size();i++)
                    {
                        dom.XmlNode emailDetailsTag = sitecontemailaddresslistTag.addChildElement('typ:emaildetails',null,null);
                        dom.XmlNode emailaddressTag = prepareChildTag(emailDetailsTag,'typ:emailaddress',getCustDetails.Customerdetails[0].siteemaillist[0].emaildetails[i].emailaddress);
                    } 
                }
                if(!getCustDetails.Customerdetails[0].altemaillist.isEmpty() && contactPremiseList[0].SPEN_Role__c != 'Alternative Contact')
                {
                    for(Integer i=0;i<getCustDetails.Customerdetails[0].altemaillist[0].emaildetails.size();i++)
                    {
                        dom.XmlNode emailDetailsTag = altdetailsemailaddresslistTag.addChildElement('typ:emaildetails',null,null);
                        dom.XmlNode emailaddressTag = prepareChildTag(emailDetailsTag,'typ:emailaddress',getCustDetails.Customerdetails[0].altemaillist[0].emaildetails[i].emailaddress);
                    } 
                }
				
				if(!getCustDetails.Customerdetails[0].premisesemaillist.isEmpty() && contactPremiseList[0].SPEN_Role__c != 'Premise Owner')
                {
                   for(Integer i=0;i<getCustDetails.Customerdetails[0].premisesemaillist[0].emaildetails.size();i++)
                    {
                        dom.XmlNode emailDetailsTag = premsownemailaddresslistTag.addChildElement('typ:emaildetails',null,null);
                        dom.XmlNode emailaddressTag = prepareChildTag(emailDetailsTag,'typ:emailaddress',getCustDetails.Customerdetails[0].premisesemaillist[0].emaildetails[i].emailaddress);
                    } 
                }
                
                
            }
		}
        
        dom.XmlNode psrdetailsTag = updateCustDetailsTag.addChildElement('psrdetails',null,null);
        //system.debug('----contactPremiseList[0].SPEN_RelatedContact__r.SPEN_PSRSynctoADQM__c-----'+contactPremiseList[0].SPEN_RelatedContact__r.SPEN_PSRSynctoADQM__c);
        String psrDetailsTagVal = 'F';
        if(contactPremiseList[0].SPEN_RelatedContact__r.SPEN_PSRSynctoADQM__c || psrUpdateFlag)
        {
            psrDetailsTagVal = 'T';
        }
        
        dom.XmlNode psrdetailsupdatedTag = prepareChildTag(psrdetailsTag,'typ:psrdetailsupdated',psrDetailsTagVal);
        //system.debug('----contactPremiseList[0].SPEN_Premise__r.SPEN_ConsentToSharePSRGiven__c-----'+contactPremiseList[0].SPEN_Premise__r.SPEN_ConsentToSharePSRGiven__c);
        String conesntVal = contactPremiseList[0].SPEN_Premise__r.SPEN_ConsentToSharePSRGiven__c ? 'T' : 'F';
        //system.debug('--conesntVal---'+conesntVal);
        //dom.XmlNode consenttosharegivenTag = prepareChildTag(psrdetailsTag,'typ:consenttosharegiven',String.valueOf(contactPremiseList[0].SPEN_RelatedContact__r.SPEN_ConsentToShareFamilyandNeighbours__c));//Contact field mapped
        dom.XmlNode consenttosharegivenTag = prepareChildTag(psrdetailsTag,'typ:consenttosharegiven',conesntVal);
        dom.XmlNode psrprimarycontactTag = psrdetailsTag.addChildElement('typ:psrprimarycontact',null,null);
        dom.XmlNode contactphonenumbersTag = psrprimarycontactTag.addChildElement('typ:contactphonenumbers',null,null);
        dom.XmlNode psralternatecontactTag = psrdetailsTag.addChildElement('typ:psralternatecontact',null,null);
        dom.XmlNode psrAltcontactphonenumbersTag = psralternatecontactTag.addChildElement('typ:contactphonenumbers',null,null);
        String psrPrimaryConName = ((getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactName != contactName) && contactPremiseList[0].SPEN_Role__c == 'PSR Contact') ? contactName : getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactName;
        String psrAltConName = ((getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactName != contactName) && contactPremiseList[0].SPEN_Role__c == 'PSR Contact (Alternative)') ? contactName : getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactName;
        if(!getCustDetails.Customerdetails[0].psrDetails.IsEmpty())
        {
			
			dom.XmlNode contactnameTag = prepareChildTag(psrprimarycontactTag,'typ:contactname',psrPrimaryConName);
			/*dom.XmlNode contactfreetextTag = prepareChildTag(psrprimarycontactTag,'typ:contactfreetext',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactFreetExt);
			dom.XmlNode contactsubbuildingTag = prepareChildTag(psrprimarycontactTag,'typ:contactsubbuilding',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactsubbuilding);
			dom.XmlNode contactbuildingnameTag = prepareChildTag(psrprimarycontactTag,'typ:contactbuildingname',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactbuildingname);
			dom.XmlNode contactdepthoroughfareTag = prepareChildTag(psrprimarycontactTag,'typ:contactdepthoroughfare',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactdepthoroughfare);
			dom.XmlNode contactstreetTag = prepareChildTag(psrprimarycontactTag,'typ:contactstreet',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactstreet);
			dom.XmlNode contactvillageTag = prepareChildTag(psrprimarycontactTag,'typ:contactvillage',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactvillage);
			dom.XmlNode contactdistrictTag = prepareChildTag(psrprimarycontactTag,'typ:contactdistrict',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactdistrict);
			dom.XmlNode contacttownTag = prepareChildTag(psrprimarycontactTag,'typ:contacttown',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contacttown);
			dom.XmlNode contactcountyTag = prepareChildTag(psrprimarycontactTag,'typ:contactcounty',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactcounty);
			dom.XmlNode contactpostcodeTag = prepareChildTag(psrprimarycontactTag,'typ:contactpostcode',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactpostcode);*/
            dom.XmlNode contactfreetextTag = prepareChildTag(psrprimarycontactTag,'typ:contactfreetext',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactfreetext);
			dom.XmlNode contactsubbuildingTag = prepareChildTag(psrprimarycontactTag,'typ:contactsubbuilding',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactsubbuilding);
			dom.XmlNode contactbuildingnameTag = prepareChildTag(psrprimarycontactTag,'typ:contactbuildingname',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactbuildingname);
			dom.XmlNode contactdepthoroughfareTag = prepareChildTag(psrprimarycontactTag,'typ:contactdepthoroughfare',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactdepthoroughfare);
			dom.XmlNode contactstreetTag = prepareChildTag(psrprimarycontactTag,'typ:contactstreet',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactstreet);
			dom.XmlNode contactvillageTag = prepareChildTag(psrprimarycontactTag,'typ:contactvillage',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactvillage);
			dom.XmlNode contactdistrictTag = prepareChildTag(psrprimarycontactTag,'typ:contactdistrict',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactdistrict);
			dom.XmlNode contacttownTag = prepareChildTag(psrprimarycontactTag,'typ:contacttown',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contacttown);
			dom.XmlNode contactcountyTag = prepareChildTag(psrprimarycontactTag,'typ:contactcounty',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactCounty);
			dom.XmlNode contactpostcodeTag = prepareChildTag(psrprimarycontactTag,'typ:contactpostcode',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactPostCode);
			
            
            dom.XmlNode conPhoneTag;
            dom.XmlNode conAltPhoneTag;
            //contactPremiseList[0].SPEN_Role__c == 'PSR Contact' || contactPremiseList[0].SPEN_Role__c == 'PSR Contact (Alternative)')
            if(contactPremiseList[0].SPEN_Role__c == 'PSR Contact'){
                conPhoneTag = contactphonenumbersTag;
                if(!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.MobilePhone))
                {
                    dom.XmlNode psrconphonedetsTag = conPhoneTag.addChildElement('typ:psrconphonedets',null,null);
                    dom.XmlNode phonenumberTag =  prepareChildTag(psrconphonedetsTag,'typ:phonenumber',contactPremiseList[0].SPEN_RelatedContact__r.MobilePhone);
                    dom.XmlNode phonetypeTag = prepareChildTag(psrconphonedetsTag,'typ:phonetype','MOBILE');
                }
                if(!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.Phone))
                {
                    dom.XmlNode psrconphonedetsTag = conPhoneTag.addChildElement('typ:psrconphonedets',null,null);
                    dom.XmlNode phonenumberTag =  prepareChildTag(psrconphonedetsTag,'typ:phonenumber',contactPremiseList[0].SPEN_RelatedContact__r.Phone);
                    dom.XmlNode phonetypeTag = prepareChildTag(psrconphonedetsTag,'typ:phonetype','HOME');
                }
                if(!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.OtherPhone))
                {
                    dom.XmlNode psrconphonedetsTag = conPhoneTag.addChildElement('typ:psrconphonedets',null,null);
                    dom.XmlNode phonenumberTag =  prepareChildTag(psrconphonedetsTag,'typ:phonenumber',contactPremiseList[0].SPEN_RelatedContact__r.OtherPhone);
                    dom.XmlNode phonetypeTag = prepareChildTag(psrconphonedetsTag,'typ:phonetype','OTHER');
                }
            }
            else if(contactPremiseList[0].SPEN_Role__c == 'PSR Contact (Alternative)')
            {
				conAltPhoneTag = psrAltcontactphonenumbersTag;
				if(!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.MobilePhone))
                {
                    dom.XmlNode psrconphonedetsTag = conAltPhoneTag.addChildElement('typ:psrconphonedets',null,null);
                    dom.XmlNode phonenumberTag =  prepareChildTag(psrconphonedetsTag,'typ:phonenumber',contactPremiseList[0].SPEN_RelatedContact__r.MobilePhone);
                    dom.XmlNode phonetypeTag = prepareChildTag(psrconphonedetsTag,'typ:phonetype','MOBILE');
                }
                if(!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.Phone))
                {
                    dom.XmlNode psrconphonedetsTag = conAltPhoneTag.addChildElement('typ:psrconphonedets',null,null);
                    dom.XmlNode phonenumberTag =  prepareChildTag(psrconphonedetsTag,'typ:phonenumber',contactPremiseList[0].SPEN_RelatedContact__r.Phone);
                    dom.XmlNode phonetypeTag = prepareChildTag(psrconphonedetsTag,'typ:phonetype','HOME');
                }
                if(!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.OtherPhone))
                {
                    dom.XmlNode psrconphonedetsTag = conAltPhoneTag.addChildElement('typ:psrconphonedets',null,null);
                    dom.XmlNode phonenumberTag =  prepareChildTag(psrconphonedetsTag,'typ:phonenumber',contactPremiseList[0].SPEN_RelatedContact__r.OtherPhone);
                    dom.XmlNode phonetypeTag = prepareChildTag(psrconphonedetsTag,'typ:phonetype','OTHER');
                }                
            }
            
            
            if(!getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactPhoneNumbers.isEmpty() && conPhoneTag == NULL)
            {
                for(Integer i=0;i<getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactPhoneNumbers[0].psrConPhoneDets.size();i++)
                {
                    dom.XmlNode psrconphonedetsTag = contactphonenumbersTag.addChildElement('typ:psrconphonedets',null,null);
                    dom.XmlNode phonenumberTag = prepareChildTag(psrconphonedetsTag,'typ:phonenumber',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactPhoneNumbers[0].psrConPhoneDets[i].phonenumber);      
                    dom.XmlNode phonetypeTag = prepareChildTag(psrconphonedetsTag,'typ:phonetype',getCustDetails.Customerdetails[0].psrDetails[0].psrPrimaryContact[0].contactPhoneNumbers[0].psrConPhoneDets[i].phonetype);
                }
            }
            
            //Alternate Contact tags
            dom.XmlNode altcontactnameTag = prepareChildTag(psralternatecontactTag,'typ:contactname',psrAltConName);
            //dom.XmlNode altcontactnameTag = prepareChildTag(psralternatecontactTag,'typ:contactname',contactPremiseList[0].SPEN_RelatedContact__r.Name);
            dom.XmlNode altcontactfreetextTag = prepareChildTag(psralternatecontactTag,'typ:contactfreetext',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactFreetExt);
            dom.XmlNode altcontactsubbuildingTag = prepareChildTag(psralternatecontactTag,'typ:contactsubbuilding',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactsubbuilding);
            dom.XmlNode altcontactbuildingnameTag = prepareChildTag(psralternatecontactTag,'typ:contactbuildingname',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactbuildingname);
            dom.XmlNode altcontactdepthoroughfareTag = prepareChildTag(psralternatecontactTag,'typ:contactdepthoroughfare',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactdepthoroughfare);
            dom.XmlNode altcontactstreetTag = prepareChildTag(psralternatecontactTag,'typ:contactstreet',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactstreet);
            dom.XmlNode altcontactvillageTag = prepareChildTag(psralternatecontactTag,'typ:contactvillage',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactvillage);
            dom.XmlNode altcontactdistrictTag = prepareChildTag(psralternatecontactTag,'typ:contactdistrict',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactdistrict);
            dom.XmlNode altcontacttownTag = prepareChildTag(psralternatecontactTag,'typ:contacttown',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contacttown);
            dom.XmlNode altcontactcountyTag = prepareChildTag(psralternatecontactTag,'typ:contactcounty',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactcounty);
            dom.XmlNode altcontactpostcodeTag = prepareChildTag(psralternatecontactTag,'typ:contactpostcode',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactpostcode);
            if(!getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactPhoneNumbers.isEmpty() && conAltPhoneTag == NULL)
            {
               for(Integer i=0;i<getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactPhoneNumbers[0].psrConPhoneDets.size();i++)
                {
                    dom.XmlNode psrconphonedetsTag = psrAltcontactphonenumbersTag.addChildElement('typ:psrconphonedets',null,null);
                    dom.XmlNode phonenumberTag = prepareChildTag(psrconphonedetsTag,'typ:phonenumber',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactPhoneNumbers[0].psrConPhoneDets[i].phonenumber);      
                    dom.XmlNode phonetypeTag = prepareChildTag(psrconphonedetsTag,'typ:phonetype',getCustDetails.Customerdetails[0].psrDetails[0].psrAlternateContact[0].contactPhoneNumbers[0].psrConPhoneDets[i].phonetype);
                } 
            }
            
        }
        //SF PSR data tags
        dom.XmlNode psrcodesTag = psrdetailsTag.addChildElement('typ:psrcodes',null,null);
        Set<String> tempPSrCodes = new Set<String>();
        
        for(String tempPSRCode : System.Label.SPEN_TemporaryPSRCodes.split(';'))
        {
            tempPSrCodes.add(tempPSRCode);
        }
        for(SPEN_PSR__c psrRec : [Select Id,SPEN_FirstLanguage__c,SPEN_AdditionalInfo__c,
                                 SPEN_SourceofPSRUpdate__c,SPEN_PSREffectiveToDate__c,
                                 SPEN_PSRVulnerabilityType__r.SPEN_Code__c
                                 FROM SPEN_PSR__c
                                 WHERE SPEN_Premise__c =: contactPremiseList[0].SPEN_Premise__c])
        {
            String reviewPeriodVal = '';
            if(!tempPSrCodes.isEmpty() && tempPSrCodes.contains(psrRec.SPEN_PSRVulnerabilityType__r.SPEN_Code__c))
            {
                reviewPeriodVal = '6 Months';
            }
            dom.XmlNode psrcodedetailsTag = psrcodesTag.addChildElement('typ:psrcodedetails',null,null);
            dom.XmlNode psrcodeTag = prepareChildTag(psrcodedetailsTag,'typ:psrcode', psrRec.SPEN_PSRVulnerabilityType__r.SPEN_Code__c.leftPad(2,'0'));
            if(psrRec.SPEN_PSRVulnerabilityType__r.SPEN_Code__c == '17')
            dom.XmlNode languageTag = prepareChildTag(psrcodedetailsTag,'typ:language', psrRec.SPEN_FirstLanguage__c);
            dom.XmlNode additionalinfoTag = prepareChildTag(psrcodedetailsTag,'typ:additionalinfo', psrRec.SPEN_AdditionalInfo__c);
            dom.XmlNode formreceiveddateTag = prepareChildTag(psrcodedetailsTag,'typ:formreceiveddate', '');
            dom.XmlNode expirydateTag = prepareChildTag(psrcodedetailsTag,'typ:expirydate', (!String.isEmpty(String.valueOf(psrRec.SPEN_PSREffectiveToDate__c))) ? String.valueOf(psrRec.SPEN_PSREffectiveToDate__c).replace('-','') : '' );
            dom.XmlNode sourceTag = prepareChildTag(psrcodedetailsTag,'typ:source', psrRec.SPEN_SourceofPSRUpdate__c);
            dom.XmlNode patientnameTag = prepareChildTag(psrcodedetailsTag,'typ:patientname', '');
            dom.XmlNode setreviewdateTag = prepareChildTag(psrcodedetailsTag,'typ:setreviewdate', '');
            dom.XmlNode reviewperiodTag = prepareChildTag(psrcodedetailsTag,'typ:reviewperiod', reviewPeriodVal);
            dom.XmlNode dobTag = prepareChildTag(psrcodedetailsTag,'typ:dob', '');
        }
        dom.XmlNode customerversionnumberTag = prepareChildTag(updateCustDetailsTag,'customerversionnumber', (!String.isEmpty(contactPremiseList[0].SPEN_RelatedContact__r.SPEN_VersionNumber__c) ? contactPremiseList[0].SPEN_RelatedContact__r.SPEN_VersionNumber__c : '') );
        xmlstring = doc.toXmlString();
        System.debug('xmlstring==> ' + xmlstring);
        return xmlstring;
    }
    
    private static dom.XmlNode prepareChildTag(dom.XmlNode parentNode, string tagName, String tagValue)
    {
        dom.XmlNode xmlNodeVar;
        parentNode.addChildElement(tagName, null, null).addTextNode(!String.isEmpty(tagValue) ? tagValue : '');
        return xmlNodeVar;
    }    
}
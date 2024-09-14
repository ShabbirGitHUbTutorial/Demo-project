public class SPEN_ContactPSRXMLNode 
{
	 @SuppressWarnings('PMD.CodeBestPracticesUseNamedCredentials')
     //private final static String NAMESPACE = 'ENMAC/TCS';
     private final static String NAMESPACE = 'http://adqm_adaptor/AdqmWS.wsdl';
     private final static String PREFIX = '';
    public SPEN_ContactPSRXMLNode()
    {
        
    }
    /*public class SoapBodyNode extends XmlNode.XmlRootNode
    {
        public List<RequestBodyNode> RequestBody = new List<RequestBodyNode>();
        
        protected override void registerXML() 
        {
            //system.debug'RequestBody' +RequestBody);
            //system.debug'IN SoapBodyNode');
            registerChildren(RequestBody, 'RequestBody', NAMESPACE, PREFIX);
        }
        
    }*/
    
    //public class RequestBodyNode extends XmlNode
    public class SoapBodyNode extends XmlNode.XmlRootNode
    {
		public List<GetcustomerdetailsResponseNode> GetcustomerdetailsResponse = new List<GetcustomerdetailsResponseNode>();
        
        protected override void registerXML() 
        {
            //system.debug'IN SoapBodyNode');
            registerChildren(GetcustomerdetailsResponse, 'GetcustomerdetailsResponse', NAMESPACE, PREFIX);
        }
    }   
    
    public class GetcustomerdetailsResponseNode extends XmlNode
    {
        public list<CustomerdetailsNode> Customerdetails = new list<CustomerdetailsNode>();
        public list<ErrorsNode> Errors = new list<ErrorsNode>();
        public String result;
        
        protected override void registerXML() 
        {
            //system.debug'IN GetcustomerdetailsResponseNode');
            registerChildren(Customerdetails, 'Customerdetails', NAMESPACE, PREFIX);
            registerChildren(Errors, 'Errors', NAMESPACE, PREFIX);
            this.result = (String) registerTextNode(String.class, 'result', NAMESPACE, PREFIX, result);
        }
    }
    
    public class ErrorsNode extends XmlNode 
    {        
        public list<ErrorNode> Error = new list<ErrorNode>();
        
        protected override void registerXML() 
        {			            
            registerChildren(Error, 'Error', NAMESPACE, PREFIX);
        }
    }
    
    public class ErrorNode extends XmlNode 
    {        
        public String description;
        public String code;
        
        protected override void registerXML() 
        {			            
            this.description = (String) registerTextNode(String.class, 'description', NAMESPACE, PREFIX, description);
            this.code = (String) registerTextNode(String.class, 'code', NAMESPACE, PREFIX, code);
        }
    }
    
    public class CustomerdetailsNode extends XmlNode
    {
		public String position;
        public String customerversionnumber;
        public String premisesowner;
        public String sitecontactname;
        //public String alternativedetailsname;
        //public String premisesownername;
        public List<CustaddressNode> Custaddress = new list<CustaddressNode>();
        public List<MpanlistNode> Mpanlist = new list<MpanlistNode>();
        public List<PremisesownaddressNode> Premisesownaddress = new list<PremisesownaddressNode>();
        public string surname;
        //public String ownphonelist;
        //public String sitephonelist;
       	public String password;
        public List<SitecontactaddressNode> Sitecontactaddress = new list<SitecontactaddressNode>();
        public String premisesid;
        public String altdetailsname;
        public String initials;
        public String customertypecode;
        //public String siteemaillist;
        public List<AltdetsaddressNode> Altdetsaddress = new list<AltdetsaddressNode>();
        //public String custemaillist;
        //public String altemaillist;
        public List<PremiseaddressNode> Premiseaddress = new list<PremiseaddressNode>();
        public String forename;
        public String specialneeds;        
        //public String custphonelist;
        //public String altphonelist;
        public String passwordefd;
        //public String premisesemaillist;        
        public String company;
        public String salutation;
        public List<sitephonelistNode> sitephonelist = new List<sitephonelistNode>(); 
        //public List<CustomerPhonenumberListNode> customerPhonenumberList = new List<CustomerPhonenumberListNode>();
		public List<custphonelistNode> custphonelist = new List<custphonelistNode>();
        public List<altphonelistNode> altphonelist = new List<altphonelistNode>();
        public List<ownphonelistNode> ownphonelist = new List<ownphonelistNode>();
        //public List<SiteContEmailAddressListNode> siteContEmailAddressList = new List<SiteContEmailAddressListNode>();
		public List<siteemaillistNode> siteemaillist = new List<siteemaillistNode>();
        //public List<CustomerEmailAddressListNode> customerEmailAddressList = new List<CustomerEmailAddressListNode>();
        public List<custemaillistNode> custemaillist = new List<custemaillistNode>();
        //public List<AltDetailsEmailAddressListNode> altDetailsEmailAddressList = new List<AltDetailsEmailAddressListNode>();
        public List<altemaillistNode> altemaillist = new List<altemaillistNode>();
        public List<premisesemaillistNode> premisesemaillist = new List<premisesemaillistNode>();
        public List<PSRDetailsNode> psrDetails = new List<PSRDetailsNode>();
        
        protected override void registerXML() 
        {
            //system.debug'IN CustomerdetailsNode');
            registerChildren(Custaddress, 'Custaddress', NAMESPACE, PREFIX);
            registerChildren(Mpanlist, 'Mpanlist', NAMESPACE, PREFIX);
            registerChildren(Premisesownaddress, 'Premisesownaddress', NAMESPACE, PREFIX);
            registerChildren(Sitecontactaddress, 'Sitecontactaddress', NAMESPACE, PREFIX);
            registerChildren(Altdetsaddress, 'Altdetsaddress', NAMESPACE, PREFIX);
            registerChildren(Premiseaddress, 'Premiseaddress', NAMESPACE, PREFIX);
			registerChildren(sitephonelist, 'sitephonelist', NAMESPACE, PREFIX);
			registerChildren(custphonelist, 'custphonelist', NAMESPACE, PREFIX);
			registerChildren(altphonelist, 'altphonelist', NAMESPACE, PREFIX);
			registerChildren(ownphonelist, 'ownphonelist', NAMESPACE, PREFIX);
			registerChildren(siteemaillist, 'siteemaillist', NAMESPACE, PREFIX);
			registerChildren(custemaillist, 'custemaillist', NAMESPACE, PREFIX);
			registerChildren(altemaillist, 'altemaillist', NAMESPACE, PREFIX);
			registerChildren(premisesemaillist, 'premisesemaillist', NAMESPACE, PREFIX);
			registerChildren(psrDetails, 'psrDetails', NAMESPACE, PREFIX);
            this.position = (String) registerTextNode(String.class, 'position', NAMESPACE, PREFIX, position);
            this.customerversionnumber = (String) registerTextNode(String.class, 'customerversionnumber', NAMESPACE, PREFIX, customerversionnumber);
            this.premisesowner = (String) registerTextNode(String.class, 'premisesowner', NAMESPACE, PREFIX, premisesowner);
            this.sitecontactname = (String) registerTextNode(String.class, 'sitecontactname', NAMESPACE, PREFIX, sitecontactname);
            //this.alternativedetailsname = (String) registerTextNode(String.class, 'alternativedetailsname', NAMESPACE, PREFIX, alternativedetailsname);
            //this.premisesownername = (String) registerTextNode(String.class, 'premisesownername', NAMESPACE, PREFIX, premisesownername);
            this.surname = (String) registerTextNode(String.class, 'surname', NAMESPACE, PREFIX, surname);
            //this.ownphonelist = (String) registerTextNode(String.class, 'ownphonelist', NAMESPACE, PREFIX, ownphonelist);
            //this.sitephonelist = (String) registerTextNode(String.class, 'sitephonelist', NAMESPACE, PREFIX, sitephonelist);
            this.password = (String) registerTextNode(String.class, 'password', NAMESPACE, PREFIX, password);
            this.premisesid = (String) registerTextNode(String.class, 'premisesid', NAMESPACE, PREFIX, premisesid);
            this.altdetailsname = (String) registerTextNode(String.class, 'altdetailsname', NAMESPACE, PREFIX, altdetailsname);
            this.initials = (String) registerTextNode(String.class, 'initials', NAMESPACE, PREFIX, initials);
            this.customertypecode = (String) registerTextNode(String.class, 'customertypecode', NAMESPACE, PREFIX, customertypecode);
            //this.siteemaillist = (String) registerTextNode(String.class, 'siteemaillist', NAMESPACE, PREFIX, siteemaillist);
            //this.custemaillist = (String) registerTextNode(String.class, 'custemaillist', NAMESPACE, PREFIX, custemaillist);
            //this.altemaillist = (String) registerTextNode(String.class, 'altemaillist', NAMESPACE, PREFIX, altemaillist);
            this.forename = (String) registerTextNode(String.class, 'forename', NAMESPACE, PREFIX, forename);
            this.specialneeds = (String) registerTextNode(String.class, 'specialneeds', NAMESPACE, PREFIX, specialneeds);
            //this.custphonelist = (String) registerTextNode(String.class, 'custphonelist', NAMESPACE, PREFIX, custphonelist);
            //this.altphonelist = (String) registerTextNode(String.class, 'altphonelist', NAMESPACE, PREFIX, altphonelist);
            this.passwordefd = (String) registerTextNode(String.class, 'mRID', NAMESPACE, PREFIX, position);
            //this.premisesemaillist = (String) registerTextNode(String.class, 'premisesemaillist', NAMESPACE, PREFIX, premisesemaillist);
            this.company = (String) registerTextNode(String.class, 'company', NAMESPACE, PREFIX, company);
            this.salutation = (String) registerTextNode(String.class, 'salutation', NAMESPACE, PREFIX, salutation);
            
        }
    }
    public class CustaddressNode extends XmlNode 
    {        
        public String buildingname;
        public String subbuildingnameno;
        public String county;
        public String doubledependentlocality;
        public String locality;
        public String streetname;
        public String housenumber;
        public String postcode;
        public String dependentthoroughfare;
        public String posttown;
        public String plot;
        
        protected override void registerXML() 
        {			            
            this.buildingname = (String) registerTextNode(String.class, 'buildingname', NAMESPACE, PREFIX, buildingname);
            this.subbuildingnameno = (String) registerTextNode(String.class, 'subbuildingnameno', NAMESPACE, PREFIX, subbuildingnameno);
            this.county = (String) registerTextNode(String.class, 'county', NAMESPACE, PREFIX, county);
            this.doubledependentlocality = (String) registerTextNode(String.class, 'doubledependentlocality', NAMESPACE, PREFIX, doubledependentlocality);
            this.locality = (String) registerTextNode(String.class, 'locality', NAMESPACE, PREFIX, locality);
            this.streetname = (String) registerTextNode(String.class, 'streetname', NAMESPACE, PREFIX, streetname);
            this.housenumber = (String) registerTextNode(String.class, 'housenumber', NAMESPACE, PREFIX, housenumber);
            this.postcode = (String) registerTextNode(String.class, 'postcode', NAMESPACE, PREFIX, postcode);
            this.dependentthoroughfare = (String) registerTextNode(String.class, 'dependentthoroughfare', NAMESPACE, PREFIX, dependentthoroughfare);
            this.posttown = (String) registerTextNode(String.class, 'posttown', NAMESPACE, PREFIX, posttown);
            this.plot = (String) registerTextNode(String.class, 'plot', NAMESPACE, PREFIX, plot);
        }
    }

    public class PremisesownaddressNode extends XmlNode 
    {        
        public String buildingname;
        public String subbuildingnameno;
        public String county;
        public String doubledependentlocality;
        public String locality;
        public String streetname;
        public String housenumber;
        public String postcode;
        public String dependentthoroughfare;
        public String posttown;
        public String plot;
        
        protected override void registerXML() 
        {			            
            this.buildingname = (String) registerTextNode(String.class, 'buildingname', NAMESPACE, PREFIX, buildingname);
            this.subbuildingnameno = (String) registerTextNode(String.class, 'subbuildingnameno', NAMESPACE, PREFIX, subbuildingnameno);
            this.county = (String) registerTextNode(String.class, 'county', NAMESPACE, PREFIX, county);
            this.doubledependentlocality = (String) registerTextNode(String.class, 'doubledependentlocality', NAMESPACE, PREFIX, doubledependentlocality);
            this.locality = (String) registerTextNode(String.class, 'locality', NAMESPACE, PREFIX, locality);
            this.streetname = (String) registerTextNode(String.class, 'streetname', NAMESPACE, PREFIX, streetname);
            this.housenumber = (String) registerTextNode(String.class, 'housenumber', NAMESPACE, PREFIX, housenumber);
            this.postcode = (String) registerTextNode(String.class, 'postcode', NAMESPACE, PREFIX, postcode);
            this.dependentthoroughfare = (String) registerTextNode(String.class, 'dependentthoroughfare', NAMESPACE, PREFIX, dependentthoroughfare);
            this.posttown = (String) registerTextNode(String.class, 'posttown', NAMESPACE, PREFIX, posttown);
            this.plot = (String) registerTextNode(String.class, 'plot', NAMESPACE, PREFIX, plot);
        }
    }

    public class SitecontactaddressNode extends XmlNode 
    {        
        public String buildingname;
        public String subbuildingnameno;
        public String county;
        public String doubledependentlocality;
        public String locality;
        public String streetname;
        public String housenumber;
        public String postcode;
        public String dependentthoroughfare;
        public String posttown;
        public String plot;
        
        protected override void registerXML() 
        {			            
            this.buildingname = (String) registerTextNode(String.class, 'buildingname', NAMESPACE, PREFIX, buildingname);
            this.subbuildingnameno = (String) registerTextNode(String.class, 'subbuildingnameno', NAMESPACE, PREFIX, subbuildingnameno);
            this.county = (String) registerTextNode(String.class, 'county', NAMESPACE, PREFIX, county);
            this.doubledependentlocality = (String) registerTextNode(String.class, 'doubledependentlocality', NAMESPACE, PREFIX, doubledependentlocality);
            this.locality = (String) registerTextNode(String.class, 'locality', NAMESPACE, PREFIX, locality);
            this.streetname = (String) registerTextNode(String.class, 'streetname', NAMESPACE, PREFIX, streetname);
            this.housenumber = (String) registerTextNode(String.class, 'housenumber', NAMESPACE, PREFIX, housenumber);
            this.postcode = (String) registerTextNode(String.class, 'postcode', NAMESPACE, PREFIX, postcode);
            this.dependentthoroughfare = (String) registerTextNode(String.class, 'dependentthoroughfare', NAMESPACE, PREFIX, dependentthoroughfare);
            this.posttown = (String) registerTextNode(String.class, 'posttown', NAMESPACE, PREFIX, posttown);
            this.plot = (String) registerTextNode(String.class, 'plot', NAMESPACE, PREFIX, plot);
        }
    }

    public class AltdetsaddressNode extends XmlNode 
    {        
        public String buildingname;
        public String subbuildingnameno;
        public String county;
        public String doubledependentlocality;
        public String locality;
        public String streetname;
        public String housenumber;
        public String postcode;
        public String dependentthoroughfare;
        public String posttown;
        public String plot;
        
        protected override void registerXML() 
        {			            
            this.buildingname = (String) registerTextNode(String.class, 'buildingname', NAMESPACE, PREFIX, buildingname);
            this.subbuildingnameno = (String) registerTextNode(String.class, 'subbuildingnameno', NAMESPACE, PREFIX, subbuildingnameno);
            this.county = (String) registerTextNode(String.class, 'county', NAMESPACE, PREFIX, county);
            this.doubledependentlocality = (String) registerTextNode(String.class, 'doubledependentlocality', NAMESPACE, PREFIX, doubledependentlocality);
            this.locality = (String) registerTextNode(String.class, 'locality', NAMESPACE, PREFIX, locality);
            this.streetname = (String) registerTextNode(String.class, 'streetname', NAMESPACE, PREFIX, streetname);
            this.housenumber = (String) registerTextNode(String.class, 'housenumber', NAMESPACE, PREFIX, housenumber);
            this.postcode = (String) registerTextNode(String.class, 'postcode', NAMESPACE, PREFIX, postcode);
            this.dependentthoroughfare = (String) registerTextNode(String.class, 'dependentthoroughfare', NAMESPACE, PREFIX, dependentthoroughfare);
            this.posttown = (String) registerTextNode(String.class, 'posttown', NAMESPACE, PREFIX, posttown);
            this.plot = (String) registerTextNode(String.class, 'plot', NAMESPACE, PREFIX, plot);
        }
    }

    public class PremiseaddressNode extends XmlNode 
    {        
        public String buildingname;
        public String subbuildingnameno;
        public String county;
        public String doubledependentlocality;
        public String locality;
        public String streetname;
        public String housenumber;
        public String postcode;
        public String dependentthoroughfare;
        public String posttown;
        public String plot;
        
        protected override void registerXML() 
        {			            
            this.buildingname = (String) registerTextNode(String.class, 'buildingname', NAMESPACE, PREFIX, buildingname);
            this.subbuildingnameno = (String) registerTextNode(String.class, 'subbuildingnameno', NAMESPACE, PREFIX, subbuildingnameno);
            this.county = (String) registerTextNode(String.class, 'county', NAMESPACE, PREFIX, county);
            this.doubledependentlocality = (String) registerTextNode(String.class, 'doubledependentlocality', NAMESPACE, PREFIX, doubledependentlocality);
            this.locality = (String) registerTextNode(String.class, 'locality', NAMESPACE, PREFIX, locality);
            this.streetname = (String) registerTextNode(String.class, 'streetname', NAMESPACE, PREFIX, streetname);
            this.housenumber = (String) registerTextNode(String.class, 'housenumber', NAMESPACE, PREFIX, housenumber);
            this.postcode = (String) registerTextNode(String.class, 'postcode', NAMESPACE, PREFIX, postcode);
            this.dependentthoroughfare = (String) registerTextNode(String.class, 'dependentthoroughfare', NAMESPACE, PREFIX, dependentthoroughfare);
            this.posttown = (String) registerTextNode(String.class, 'posttown', NAMESPACE, PREFIX, posttown);
            this.plot = (String) registerTextNode(String.class, 'plot', NAMESPACE, PREFIX, plot);
        }
    }
    
    public class MpanlistNode extends XmlNode 
    {        
        public list<MpandataNode> Mpandata = new list<MpandataNode>();
        
        protected override void registerXML() 
        {			            
            registerChildren(Mpandata, 'Mpandata', NAMESPACE, PREFIX);
        }
    }
    
	public class MpandataNode extends XmlNode 
    {        
        public String currentsupplier;
        public String db01pending;
        public String mpancore;
        public String usage;
        public String energisationstatus;
        public String meteringpointstatus;
        public String db02pending;
        public String supplystartdate;
        public String supplyenddate;
        public String schemeref;
        public String developmentname;
        public String meterposition;
        public String msnlist; 
        
        protected override void registerXML() 
        {			            
            this.currentsupplier = (String) registerTextNode(String.class, 'currentsupplier', NAMESPACE, PREFIX, currentsupplier);
            this.db01pending = (String) registerTextNode(String.class, 'db01pending', NAMESPACE, PREFIX, db01pending);
            this.mpancore = (String) registerTextNode(String.class, 'mpancore', NAMESPACE, PREFIX, mpancore);
            this.usage = (String) registerTextNode(String.class, 'usage', NAMESPACE, PREFIX, usage);
            this.energisationstatus = (String) registerTextNode(String.class, 'energisationstatus', NAMESPACE, PREFIX, energisationstatus);
            this.meteringpointstatus = (String) registerTextNode(String.class, 'meteringpointstatus', NAMESPACE, PREFIX, meteringpointstatus);
            this.db02pending = (String) registerTextNode(String.class, 'db02pending', NAMESPACE, PREFIX, db02pending);
            this.supplystartdate = (String) registerTextNode(String.class, 'supplystartdate', NAMESPACE, PREFIX, supplystartdate);
            this.supplyenddate = (String) registerTextNode(String.class, 'supplyenddate', NAMESPACE, PREFIX, supplyenddate);
            this.schemeref = (String) registerTextNode(String.class, 'schemeref', NAMESPACE, PREFIX, schemeref);
            this.developmentname = (String) registerTextNode(String.class, 'developmentname', NAMESPACE, PREFIX, developmentname);
            this.meterposition = (String) registerTextNode(String.class, 'meterposition', NAMESPACE, PREFIX, meterposition);
			this.msnlist = (String) registerTextNode(String.class, 'msnlist', NAMESPACE, PREFIX, msnlist);
        }
    }
    public class sitephonelistNode extends XmlNode{
        public list<phonedetailsNode> phonedetails = new list<phonedetailsNode>();
        protected override void registerXML(){			            
            registerChildren(phonedetails, 'phonedetails', NAMESPACE, PREFIX);
        }
    }
    public class custphonelistNode extends XmlNode{
        public list<phonedetailsNode> phonedetails = new list<phonedetailsNode>();
        protected override void registerXML(){			            
            registerChildren(phonedetails, 'phonedetails', NAMESPACE, PREFIX);
        }
    }
     public class altphonelistNode extends XmlNode{
        public list<phonedetailsNode> phonedetails = new list<phonedetailsNode>();
        protected override void registerXML(){			            
            registerChildren(phonedetails, 'phonedetails', NAMESPACE, PREFIX);
        }
    }
     public class ownphonelistNode extends XmlNode{
        public list<phonedetailsNode> phonedetails = new list<phonedetailsNode>();
        protected override void registerXML(){			            
            registerChildren(phonedetails, 'phonedetails', NAMESPACE, PREFIX);
        }
    }
    public class phonedetailsNode extends XmlNode{
        public String phoneno;
        public String phonetype;
        protected override void registerXML(){
            this.phoneno = (String) registerTextNode(String.class, 'phoneno', NAMESPACE, PREFIX, phoneno);
        	this.phonetype = (String) registerTextNode(String.class, 'phonetype', NAMESPACE, PREFIX, phonetype);
   		}
    }
     public class siteemaillistNode extends XmlNode{
        public list<emaildetailsNode> emaildetails = new list<emaildetailsNode>();
        protected override void registerXML(){			            
            registerChildren(emaildetails, 'emaildetails', NAMESPACE, PREFIX);
        }
    }
    public class custemaillistNode extends XmlNode{
        public list<emaildetailsNode> emaildetails = new list<emaildetailsNode>();
        protected override void registerXML(){			            
            registerChildren(emaildetails, 'emaildetails', NAMESPACE, PREFIX);
        }
    }
    public class altemaillistNode extends XmlNode{
        public list<emaildetailsNode> emaildetails = new list<emaildetailsNode>();
        protected override void registerXML(){			            
            registerChildren(emaildetails, 'emaildetails', NAMESPACE, PREFIX);
        }
    }
    public class premisesemaillistNode extends XmlNode{
        public list<emaildetailsNode> emaildetails = new list<emaildetailsNode>();
        protected override void registerXML(){			            
            registerChildren(emaildetails, 'emaildetails', NAMESPACE, PREFIX);
        }
    }
    public class emaildetailsNode extends XmlNode{
        public String emailaddress;
        public String lastupdateddate;
        protected override void registerXML(){
            this.emailaddress = (String) registerTextNode(String.class, 'emailaddress', NAMESPACE, PREFIX, emailaddress);
            this.lastupdateddate = (String) registerTextNode(String.class, 'lastupdateddate', NAMESPACE, PREFIX, lastupdateddate);
   		}
    }
    public class PSRDetailsNode extends XmlNode{
        public list<PSRCodesNode> psrCodes = new list<PSRCodesNode>();
        public list<PSRPrimaryContactNode> psrPrimaryContact = new list<PSRPrimaryContactNode>();
        public list<PSRAlternateContactNode> psrAlternateContact = new list<PSRAlternateContactNode>();
        public String consentToShareGiven;
        public String consentToShareSource;
        public String consentToShareDate;
        public String psrDetailsUpdated;
        protected override void registerXML(){			            
            registerChildren(psrCodes, 'PSRCodes', NAMESPACE, PREFIX);
			registerChildren(psrPrimaryContact, 'PSRPrimaryContact', NAMESPACE, PREFIX);
			registerChildren(psrAlternateContact, 'PSRAlternateContact', NAMESPACE, PREFIX);
            this.consentToShareGiven = (String) registerTextNode(String.class, 'ConsentToShareGiven', NAMESPACE, PREFIX, consentToShareGiven);
            this.consentToShareSource = (String) registerTextNode(String.class, 'ConsentToShareSource', NAMESPACE, PREFIX, consentToShareSource);
            this.consentToShareDate = (String) registerTextNode(String.class, 'ConsentToShareDate', NAMESPACE, PREFIX, consentToShareDate);
            this.psrDetailsUpdated = (String) registerTextNode(String.class, 'PSRDetailsUpdated', NAMESPACE, PREFIX, psrDetailsUpdated);
        }
    }
     public class PSRCodesNode extends XmlNode{
        public list<PSRCodeDetailsNode> psrCodeDetails = new list<PSRCodeDetailsNode>();
        protected override void registerXML(){
            registerChildren(psrCodeDetails, 'PSRCodeDetails', NAMESPACE, PREFIX);
   		}
    }
    public class PSRCodeDetailsNode extends XmlNode{
        public Integer psrCode;
        public String language;
        public String additionalInfo;
        public String formReceivedDate;
        public String expiryDate;
        public String source;
        public String sourcEmpId;
        public String patientName;
        public String reviewperiod;
        public String dob;
        public String reviewDate;
        public String lastConfirmedBy;
        public String lastConfirmedDate;
        public String setReviewDate;
        protected override void registerXML(){
            this.psrCode = (Integer) registerTextNode(Integer.class, 'PSRCode', NAMESPACE, PREFIX, psrCode);
            this.language = (String) registerTextNode(String.class, 'Language', NAMESPACE, PREFIX, language);
            this.additionalInfo = (String) registerTextNode(String.class, 'AdditionalInfo', NAMESPACE, PREFIX, additionalInfo);
            this.formReceivedDate = (String) registerTextNode(String.class, 'FormReceivedDate', NAMESPACE, PREFIX, formReceivedDate);
            this.expiryDate = (String) registerTextNode(String.class, 'ExpiryDate', NAMESPACE, PREFIX, expiryDate);
            this.source = (String) registerTextNode(String.class, 'Source', NAMESPACE, PREFIX, source);
            this.sourcEmpId = (String) registerTextNode(String.class, 'SourcEmpId', NAMESPACE, PREFIX, sourcEmpId);
            this.patientName = (String) registerTextNode(String.class, 'PatientName', NAMESPACE, PREFIX, patientName);
            this.reviewperiod = (String) registerTextNode(String.class, 'reviewperiod', NAMESPACE, PREFIX, reviewperiod);
            this.dob = (String) registerTextNode(String.class, 'DOB', NAMESPACE, PREFIX, dob);
            this.reviewDate = (String) registerTextNode(String.class, 'ReviewDate', NAMESPACE, PREFIX, reviewDate);
            this.lastConfirmedBy = (String) registerTextNode(String.class, 'LastConfirmedBy', NAMESPACE, PREFIX, lastConfirmedBy);
            this.lastConfirmedDate = (String) registerTextNode(String.class, 'LastConfirmedDate', NAMESPACE, PREFIX, lastConfirmedDate);
            this.setReviewDate = (String) registerTextNode(String.class, 'SetReviewDate', NAMESPACE, PREFIX, setReviewDate);
   		}
    }
    public class PSRPrimaryContactNode extends XmlNode{
        public list<ContactPhoneNumbersNode> contactPhoneNumbers = new list<ContactPhoneNumbersNode>();
        public String contactname;
      	public String contactfreetext;
     	public String contactsubbuilding;
        public String contactbuildingname;
        public String contactdepthoroughfare;
        public String contactstreet;
        public String contactvillage;
        public String contactdistrict;
        public String contacttown;
        public String contactcounty;
        public String contactpostcode;
        protected override void registerXML(){
            registerChildren(contactPhoneNumbers, 'ContactPhoneNumbers', NAMESPACE, PREFIX);
            this.contactname = (String) registerTextNode(String.class, 'contactname', NAMESPACE, PREFIX, contactname);
            this.contactfreetext = (String) registerTextNode(String.class, 'contactfreetext', NAMESPACE, PREFIX, contactfreetext);
            this.contactsubbuilding = (String) registerTextNode(String.class, 'contactsubbuilding', NAMESPACE, PREFIX, contactsubbuilding);
            this.contactbuildingname = (String) registerTextNode(String.class, 'contactbuildingname', NAMESPACE, PREFIX, contactbuildingname);
            this.contactdepthoroughfare = (String) registerTextNode(String.class, 'contactdepthoroughfare', NAMESPACE, PREFIX, contactdepthoroughfare);
            this.contactstreet = (String) registerTextNode(String.class, 'contactstreet', NAMESPACE, PREFIX, contactstreet);
            this.contactvillage = (String) registerTextNode(String.class, 'contactvillage', NAMESPACE, PREFIX, contactvillage);
            this.contactdistrict = (String) registerTextNode(String.class, 'contactdistrict', NAMESPACE, PREFIX, contactdistrict);
            this.contacttown = (String) registerTextNode(String.class, 'contacttown', NAMESPACE, PREFIX, contacttown);
            this.contactcounty = (String) registerTextNode(String.class, 'contactcounty', NAMESPACE, PREFIX, contactcounty);
            this.contactpostcode = (String) registerTextNode(String.class, 'contactpostcode', NAMESPACE, PREFIX, contactpostcode);
   		}
    }
	 public class PSRAlternateContactNode extends XmlNode{
        public list<ContactPhoneNumbersNode> contactPhoneNumbers = new list<ContactPhoneNumbersNode>();
        public String contactname;
      	public String contactFreetExt;
     	public String contactSubbuilding;
        public String contactBuildingName;
        public String contactDepThoroughFare;
        public String contactStreet;
        public String contactVillage;
        public String contactDistrict;
        public String contactTown;
        public String contactCounty;
        public String contactPostCode;
        protected override void registerXML(){
            registerChildren(contactPhoneNumbers, 'ContactPhoneNumbers', NAMESPACE, PREFIX);
            this.contactname = (String) registerTextNode(String.class, 'contactname', NAMESPACE, PREFIX, contactname);
            this.contactFreetExt = (String) registerTextNode(String.class, 'ContactFreetExt', NAMESPACE, PREFIX, contactFreetExt);
            this.contactSubbuilding = (String) registerTextNode(String.class, 'ContactSubbuilding', NAMESPACE, PREFIX, contactSubbuilding);
            this.contactBuildingName = (String) registerTextNode(String.class, 'ContactBuildingName', NAMESPACE, PREFIX, contactBuildingName);
            this.contactDepThoroughFare = (String) registerTextNode(String.class, 'ContactDepThoroughFare', NAMESPACE, PREFIX, contactDepThoroughFare);
            this.contactStreet = (String) registerTextNode(String.class, 'ContactStreet', NAMESPACE, PREFIX, contactStreet);
            this.contactVillage = (String) registerTextNode(String.class, 'ContactVillage', NAMESPACE, PREFIX, contactVillage);
            this.contactDistrict = (String) registerTextNode(String.class, 'ContactDistrict', NAMESPACE, PREFIX, contactDistrict);
            this.contactTown = (String) registerTextNode(String.class, 'ContactTown', NAMESPACE, PREFIX, contactTown);
            this.contactCounty = (String) registerTextNode(String.class, 'ContactCounty', NAMESPACE, PREFIX, contactCounty);
            this.contactPostCode = (String) registerTextNode(String.class, 'ContactPostCode', NAMESPACE, PREFIX, contactPostCode);
   		}
    }
    public class ContactPhoneNumbersNode extends XmlNode{
        public list<PSRConPhoneDetsNode> psrConPhoneDets = new list<PSRConPhoneDetsNode>();
        protected override void registerXML(){
            registerChildren(psrConPhoneDets, 'PSRConPhoneDets', NAMESPACE, PREFIX);
   		}
    }
    public class PSRConPhoneDetsNode extends XmlNode{
        public String phonenumber;
      	public String phonetype;
        protected override void registerXML(){
            this.phonenumber = (String) registerTextNode(String.class, 'phonenumber', NAMESPACE, PREFIX, phonenumber);
            this.phonetype = (String) registerTextNode(String.class, 'phonetype', NAMESPACE, PREFIX, phonetype);
   		}
    }
}
public with sharing class SPEN_ContactPSRWrapper 
{
    public List<GetcustomerdetailsResponse> getcustomerdetailsResponse;	
   // public List<RequestBody> reqBody;
   /* public class RequestBody
    {
        public List<GetcustomerdetailsResponse> getcustomerdetailsResponse;
    }*/
    public class GetcustomerdetailsResponse
    {
        public List<Customerdetails> customerdetails;
        public String result;
        public List<Errors> errors;
    }
    public class CustomerDetails
    {
        public String position;
        public String customerversionnumber;
        public String premisesowner;
        public String sitecontactname;
        //public String alternativedetailsname;
        public String premisesownername;
        public List<Custaddress> custaddress;
        public List<Mpanlist> mpanlist;
        public List<Premisesownaddress> premisesownaddress;
        public string surname;
        //public String ownphonelist;
        //public String sitephonelist;
       	public String password;
        public List<Sitecontactaddress> sitecontactaddress;
        public String premisesid;
        public String altdetailsname;
        public String initials;
        public String customertypecode;
        //public String siteemaillist;
        public List<Altdetsaddress> altdetsaddress;
        //public String custemaillist;
        //public String altemaillist;
        public List<Premiseaddress> premiseaddress;
        public String forename;
        public String specialneeds;        
        //public String custphonelist;
        //public String altphonelist;
        public String passwordefd;
        //public String premisesemaillist;        
        public String company;
        public String salutation;
        public List<sitephonelist> sitephonelist;
        public List<custphonelist> custphonelist;
        public List<altphonelist> altphonelist;
        public List<ownphonelist> ownphonelist;
        //public List<SiteContEmailAddressList> siteContEmailAddressList;
        public List<siteemaillist> siteemaillist;
        //public List<CustomerEmailAddressList> customerEmailAddressList;
        public List<custemaillist> custemaillist;
        //public List<AltDetailsEmailAddressList> altDetailsEmailAddressList;
        public List<altemaillist> altemaillist;
        public List<premisesemaillist> premisesemaillist;
        public List<PSRDetails> psrDetails;
    }
    public class sitephonelist{
        public List<phonedetails> phonedetails;
    }
    public class custphonelist{
        public List<phonedetails> phonedetails;
    }
    public class altphonelist{
        public List<phonedetails> phonedetails;
    }
    public class ownphonelist{
        public List<phonedetails> phonedetails;
    }
    public class phonedetails{
        public String phoneno;
        public String phonetype;
    }
    public class siteemaillist{
        public List<emaildetails> emaildetails;
    }
    public class custemaillist{
        public List<emaildetails> emaildetails;
    }
    public class altemaillist{
        public List<emaildetails> emaildetails;
    }
     public class premisesemaillist{
        public List<emaildetails> emaildetails;
    }
    public class emaildetails{
        public String emailaddress;
        public String lastupdateddate;
    }
     public class PSRDetails{
        public List<PSRCodes> psrCodes;
        public List<PSRPrimaryContact> psrPrimaryContact;
        public List<PSRAlternateContact> psrAlternateContact;
        public String consentToShareGiven;
        public String consentToShareSource;
        public String consentToShareDate;
        public String psrDetailsUpdated;
    }
    public class PSRCodes{
        public List<PSRCodeDetails> psrCodeDetails;
    }
    public class PSRCodeDetails{
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
    }
    public class PSRPrimaryContact{
      public List<ContactPhoneNumbers> contactPhoneNumbers;
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
    }
    public class PSRAlternateContact{
      public List<ContactPhoneNumbers> contactPhoneNumbers;
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
    }
    public class ContactPhoneNumbers{
      public List<PSRConPhoneDets> psrConPhoneDets;
    }
    public class PSRConPhoneDets{
      public String phonenumber;
      public String phonetype;
    }
    public class Mpanlist
    {
        public List<Mpandata> mpandata;
    }    
    public class Mpandata
    {
        public String supplyenddate;
        public String currentsupplier;
        public String db01pending;
        public String schemeref;
        public String mpancore;
        public String developmentname;
        public String usage;
        public String meterposition;
        public String msnlist; 
        public String energisationstatus;
        public String meteringpointstatus;
        public String db02pending;
        public String supplystartdate;
                  
    }
    
    public class Custaddress
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
    }

    public class Premisesownaddress
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
    }  

    public class Sitecontactaddress
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
    }  

     public class Altdetsaddress
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
    }

    public class Premiseaddress
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
    }
    
    public class Errors
    {
        public List<Error> error;
    }
    
    public class Error
    {
        public String description;
        public String code;
    } 
    
    public static void test(){
       //System.debug('testing');
       Boolean isTest=true;
 	}  
}
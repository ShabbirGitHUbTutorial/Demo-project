public class SPEN_SAPVendorDOMClass{      
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String vendorNumber;        
    	@AuraEnabled
        public String businessPartner;
    	@AuraEnabled
        public String postCode;
    	@AuraEnabled
        public String telephone;
    	@AuraEnabled
        public String email;
    	@AuraEnabled
        public String address;
    	@AuraEnabled
        public String street;
    	@AuraEnabled
        public String street2;
    	@AuraEnabled
        public String street3;
    	@AuraEnabled
        public String city;
    	@AuraEnabled
        public String state;
   		@AuraEnabled
        public String country;
    	@AuraEnabled
    	public String emailprefrence;
    	@AuraEnabled
    	public String telephoneprefrence;
    	@AuraEnabled
        public String companyCode;
          
		public SPEN_SAPVendorDOMClass(SPEN_SAPGetVendorResponse.SPEN_SAPVendor vObj, String addressStr, String companyCode) {            
            this.name = vObj.nombre;
            this.vendorNumber = vObj.proveedor;  
            this.businessPartner = vObj.bussinessPartner;
            this.postCode = vObj.codigoPostal;
            this.telephone = vObj.telefCom;
            this.email = vObj.mailCom ;
            this.address = addressStr;
            this.companyCode = companyCode;
            this.street = vObj.calle;
            this.street2 = vObj.calle2;
            this.street3 = vObj.calle3;
            this.city = vObj.ciudad;
            this.state = vObj.region;
            this.country = vObj.pais;
            this.emailprefrence = vObj.mailPers;
            this.telephoneprefrence = vObj.telefPers;
        } 
		public SPEN_SAPVendorDOMClass() {}        
    
}
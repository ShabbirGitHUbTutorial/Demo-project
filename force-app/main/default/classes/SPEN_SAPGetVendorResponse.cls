/* File Name: SPEN_SAPGetVendorResponse
 * Description: This class will have structure DOM for get vendor call response
 * Author: ajay.chandraferi
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-26-2024     Ajay Chandraferi    Initial version
 *
 */
public class SPEN_SAPGetVendorResponse {  
    public SPEN_VendorSetResult d;             
 
    public class SPEN_VendorSetResult{        
        public List<SPEN_SAPVendorsWrap> results;
        public  SPEN_VendorSetResult(){
            results = new List<SPEN_SAPVendorsWrap>();
        }       
    }  
    public class SPEN_SAPVendorsWrap{    
        public SPEN_SAPVendorMetaData metadata; 
        public String state;
        public String country;
        public String city;
        public String zipcode;
        public String street;
        public String street2;
        public String street3;
        public String name;
        public String bp;
        public String vendor;
        public String origin;        
        public SPEN_SAPCompanyCodeSet companycode;
        public SPEN_SAPErrorResultSet results;
        public SPEN_SAPVendorSet vendors;
    } 

    public class SPEN_SAPCompanyCodeSet{
        public list<SPEN_SAPCompanyCode> results;
        public  SPEN_SAPCompanyCodeSet(){
            results = new List<SPEN_SAPCompanyCode>();
        } 
    }

     public class SPEN_SAPErrorResultSet{
        public list<SPEN_SAPErrorResult> results;
        public  SPEN_SAPErrorResultSet(){
            results = new List<SPEN_SAPErrorResult>();
        } 
    }

     public class SPEN_SAPVendorSet{
        public list<SPEN_SAPVendor> results;
        public  SPEN_SAPVendorSet(){
            results = new List<SPEN_SAPVendor>();
        } 
    }


    public class SPEN_SAPErrorResult{        
        public String codError;
        public String errorTxt;
        public SPEN_SAPVendorMetaData metadata;        
    } 
   
    public class SPEN_SAPCompanyCode{        
        public String proveedor;
        public String sociedad;
        public String bloqueo;
        public SPEN_SAPVendorMetaData metadata;        
    } 
    public class SPEN_SAPVendor{        
        public String proveedor;
        public String bussinessPartner;
        public String nombre;
        public String calle;
        public String calle2;
        public String calle3;
        public String codigoPostal;
        public String ciudad;
        public String pais;
        public String region;
        public String telefCom;
        public String mailCom;
        public String telefPers;
        public String mailPers;
        public String bloqueo;
        public SPEN_SAPVendorMetaData metadata;        
    } 
    public class SPEN_SAPVendorMetaData{
        public String id;
        public String uri;
        public String type;
    }
}
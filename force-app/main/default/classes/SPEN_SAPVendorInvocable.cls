/* File Name: SPEN_SAPVendorInvocable
 * Description: This class will be called to get SAP vendors from SAP RE
 * Author: ajay.chandraferi
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-26-2024     Ajay Chandraferi    Initial version
 *
 */
global class SPEN_SAPVendorInvocable{
    global class SPEN_SAPVendorRequest{        
        @InvocableVariable(required = false)
        global String vendorName;
        @InvocableVariable(required = false)
        global String vendorZipCode;  
        @InvocableVariable(required = false)
        global String vendorStreet;  
        @InvocableVariable(required = false)
        global String vendorStreet2;  
        @InvocableVariable(required = false)
        global String vendorStreet3;  
        @InvocableVariable(required = false)
        global String vendorCity;
        @InvocableVariable(required = false)
        global String vendorCountry;  
        @InvocableVariable(required = false)
        global String vendorState; 
        @InvocableVariable(required = false)
        global String vendorNumber;
        @InvocableVariable(required = false)
        global String vendorBP;
    }
    global class SPEN_SAPVendorResult{        
        @InvocableVariable (required = true)
        global List<SPEN_SAPVendorDOMClass>  vendorList;
       
    }   
    global static SPEN_SAPVendorRequest req;
    global static SPEN_SAPVendorResult res;
    @InvocableMethod(label='Get SAP Vendors' description='')
    global static List<SPEN_SAPVendorResult> getSAPVendors(List<SPEN_SAPVendorRequest> requests) {        
        List<SPEN_SAPVendorResult> responses = new List<SPEN_SAPVendorResult>();
        if(!requests.isEmpty()) {
            req = requests[0];
            res = new SPEN_SAPVendorResult ();
            prepareVendorRequest(); 
            responses.add(res);
        }
        return responses;    
    }
    
    global static void prepareVendorRequest(){          
        if(req != null){
            HttpRequest reqStatus = new HttpRequest();           
            reqStatus.setEndpoint(Label.SPEN_LnP_SAPCallout+'/provSalesforceSet?$expand=vendors,companycode,results&$format=json');
            reqStatus.setMethod('GET');
            String reqLogBody = String.valueof(reqStatus);
            reqStatus.setHeader('origin', 'RESF');  
            if(req.vendorName != null && req.vendorName!= ''){
              reqStatus.setHeader('name', req.vendorName);    
            }
            if(req.vendorZipCode != null && req.vendorZipCode!= ''){
              reqStatus.setHeader('zipcode', req.vendorZipCode);    
            }
            if(req.vendorStreet != null && req.vendorStreet!= ''){
              reqStatus.setHeader('street', req.vendorStreet);    
            }
            if(req.vendorStreet2 != null && req.vendorStreet2!= ''){
              reqStatus.setHeader('street2', req.vendorStreet2);    
            }
            if(req.vendorStreet3 != null && req.vendorStreet3!= ''){
              reqStatus.setHeader('street3', req.vendorStreet3);    
            }
            if(req.vendorCity != null && req.vendorCity!= ''){
              reqStatus.setHeader('city', req.vendorCity);    
            }
            if(req.vendorCountry != null && req.vendorCountry!= ''){
              reqStatus.setHeader('country', req.vendorCountry);    
            }
            if(req.vendorState != null && req.vendorState!= ''){
              reqStatus.setHeader('state', req.vendorState);    
            }
            if(req.vendorNumber != null && req.vendorNumber!= ''){
              reqStatus.setHeader('vendor', req.vendorNumber);    
            }
            if(req.vendorBP != null && req.vendorBP!= ''){
              reqStatus.setHeader('bp', req.vendorBP);    
            }            
            
            Http httpStatus = new Http();
            HTTPResponse resStatus = httpStatus.send(reqStatus);                        
            if(resStatus.getStatusCode() == 200){                                            	                
                try{
                    SPEN_SAPGetVendorResponse vResponse = (SPEN_SAPGetVendorResponse)JSON.deserialize(resStatus.getBody(), SPEN_SAPGetVendorResponse.class);                
                    if(vResponse != null){ 
                        List<SPEN_SAPGetVendorResponse.SPEN_SAPVendorsWrap> vwrapList = vResponse.d.results;
                        if(vwrapList != null && vwrapList.size() > 0){
                            map<String,String> vendorCompanyCodeMap = new map<String,String>();
                            for(SPEN_SAPGetVendorResponse.SPEN_SAPCompanyCode cCodeObj : vwrapList[0].companycode.results){
                                String companycodeStr = vendorCompanyCodeMap.get(cCodeObj.proveedor);
                                if(companycodeStr != null && companycodeStr != ''){                                                                       
                                   companycodeStr += '/'+cCodeObj.sociedad; 
                                    
                                }else{
                                    companycodeStr = cCodeObj.sociedad;
                                }
                                vendorCompanyCodeMap.put(cCodeObj.proveedor,companycodeStr);                                
                            }
                            List<SPEN_SAPVendorDOMClass> lstDOM;
                            for(SPEN_SAPGetVendorResponse.SPEN_SAPVendor vObj : vwrapList[0].vendors.results){
                                
                                String addressStr  = vObj.calle + ', '+vObj.calle2 + ', '+vObj.calle3 + ', '+vObj.ciudad +', '+vObj.region;                                 
                                String companycodes = vendorCompanyCodeMap.get(String.valueOf(Integer.valueOf(vObj.proveedor)));
                                if(lstDOM == null){
                                    lstDOM = new List<SPEN_SAPVendorDOMClass>();
                                }
                                lstDOM.add(new SPEN_SAPVendorDOMClass(vObj,addressStr, companycodes));  
                            }
                          res.vendorList =  lstDOM;
                        } 
                    }                      
                }catch(exception e){                      
                }
                system.debug('=========RESPONSE======'+res);
            }
        }
    }        
}
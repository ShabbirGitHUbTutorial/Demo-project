/* File Name: SPEN_SAPContractStatusInvocable
 * Description: This class will be called to get contract status from SAP RE
 * Author: ajay.chandraferi
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-13-2024     Ajay Chandraferi    Initial version
 *
 */
global class SPEN_SAPContractStatusInvocable{
    global class SPEN_ContractStatusRequest{        
        @InvocableVariable(required = true)
        global SPEN_Land_Interest__c landRightObj;        
    }
    global class SPEN_ContractStatusResult{        
        @InvocableVariable (required = false)
        global String sapNumber;
        @InvocableVariable (required = false)
        global String sapStatus;
        @InvocableVariable (required = false)
        global String errorMessage;
    }   
    global static SPEN_ContractStatusRequest req;
    global static SPEN_ContractStatusResult res;
    @InvocableMethod(label='Get SAP Contract Status' description='')
    global static List<SPEN_ContractStatusResult> getSAPContractStatus(List<SPEN_ContractStatusRequest> requests) {        
        List<SPEN_ContractStatusResult> responses = new List<SPEN_ContractStatusResult>();
        if(!requests.isEmpty()) {
            req = requests[0];
            res = new SPEN_ContractStatusResult ();
            prepareContractStatusRequest(req.landRightObj); 
            responses.add(res);
        }
        return responses;    
    }
    
    global static void prepareContractStatusRequest(SPEN_Land_Interest__c landRightIns){          
        if(landRightIns != null && landRightIns.Id != null && landRightIns.SPEN_Licence_Area_Code__c != ''){
            HttpRequest reqStatus = new HttpRequest();           
            reqStatus.setEndpoint(Label.SPEN_LnP_SAPCallout+'/GetStatusSet?$format=json');
            reqStatus.setMethod('GET');                            
            reqStatus.setHeader('contractnumber', landRightIns.Id);                        
            reqStatus.setHeader('licensearea', landRightIns.SPEN_Licence_Area_Code__c);             
            Http httpStatus = new Http();
            HTTPResponse resStatus = httpStatus.send(reqStatus);                                              
            if(resStatus.getStatusCode() == 200){                                            	                
                try{
                    SPEN_SAPGetStatusSetResponse statusResponse = (SPEN_SAPGetStatusSetResponse)JSON.deserialize(resStatus.getBody(), SPEN_SAPGetStatusSetResponse.class);                
                    if(statusResponse != null){ 
                        String errorMessage = '';
                        SPEN_SAPGetStatusSetResponse.SPEN_SAPStatusSet statuSet = statusResponse.d;
                        for(SPEN_SAPGetStatusSetResponse.SPEN_SAPStatus conStatus : statuSet.results){
                            if(conStatus.Sapnumber != null && conStatus.Sapnumber != ''){                            
                                res.sapNumber = conStatus.Sapnumber; 
                                res.sapStatus = conStatus.Status;
                                break;
                            }else{
                                if(errorMessage != ''){
                                    errorMessage += '\n';
                                }
                                errorMessage += conStatus.Msgtxt;
                            }
                        }
                        res.errorMessage = errorMessage ;                        
                    }                    
                }catch(exception e){  
                    res.errorMessage = 'Get contract Status failed. Please retry' ;
                }                
            }
        }
    }       
}
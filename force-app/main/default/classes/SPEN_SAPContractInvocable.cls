/* File Name: SPEN_SAPContractInvocable
 * Description: This class will be called to create draft contract in to SAP RE
 * Author: ajay.chandraferi
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-04-2024     Ajay Chandraferi    Initial version
 *
 */
global class SPEN_SAPContractInvocable{
    global class SPEN_CreateContractRequest{        
        @InvocableVariable(required = true)
        global SPEN_Land_Interest__c landRightObj;        
    }
    global class SPEN_CreateContractResult{
        @InvocableVariable (required = true)
        global Boolean hasContractInitiated;
        @InvocableVariable (required = false)
        global String errorMessage;
    }   
    global static SPEN_CreateContractRequest req;
    global static SPEN_CreateContractResult res;
    global static User currentUser;
    @InvocableMethod(label='create SAP contract' description='')
    global static List<SPEN_CreateContractResult> createSAPContract(List<SPEN_CreateContractRequest> requests) {        
        List<SPEN_CreateContractResult> responses = new List<SPEN_CreateContractResult>();
        if(!requests.isEmpty()) {
            req = requests[0];
            res = new SPEN_CreateContractResult ();
            prepareContractPayload(req.landRightObj); 
            responses.add(res);
        }
        return responses;    
    }
    
    global static List<SPEN_Condition__c> getSAPConditions(SPEN_Land_Interest__c landRightIns){
        List<SPEN_Condition__c> lstConditions = [SELECT ID, SPEN_LandInterest__c, SPEN_Auto_Invoice__c,SPEN_Planner_Group__c,SPEN_Payment_Form__c,
                SPEN_Type__c, SPEN_Posting_Type__c, SPEN_Unit__c, SPEN_Condition_Currency__c, SPEN_Measurement_Type__c, SPEN_Order__c,SPEN_Object__c, 
				SPEN_Wind_Farm_Stage__c, SPEN_Payment_Method__c, SPEN_Payment_Term__c, SPEN_Bank_Details__c, SPEN_Tax_Type__c, SPEN_Frequency__c,                                                 
                SPEN_Contracting_With__c
                FROM SPEN_Condition__c WHERE SPEN_LandInterest__c =: landRightIns.Id];
        return lstConditions;       
    } 
    global static SPEN_Land_Interest__c getLandRight(SPEN_Land_Interest__c landRightIns){        
        SPEN_Land_Interest__c landRight ;
        List<SPEN_Land_Interest__c> lstLandRight = [SELECT ID, Name, SPEN_ConsentType__c,SPEN_Licence_Area_Code__c, SPEN_Contract_Type__c, SPEN_Contract_Start_Date__c, 
                                                    SPEN_Contract_First_End_Date__c, SPEN_Contract_Valid_From__c, SPEN_Annual_Wayleave_Payment_Payable__c, SPEN_Land__r.Name,
                                                    SPEN_Land__r.SPEN_Title__c,(SELECT ID, Name,SPEN_Is_Associated_Type_Person__c,SPEN_Partner__r.SPEN_BusinessPartnerNumber__c from Partner_Associations__r where
                                                    SPEN_Is_Associated_Type_Person__c=true )
                                               FROM SPEN_Land_Interest__c WHERE Id =: landRightIns.Id];
        if(lstLandRight!= null && lstLandRight.size() > 0 ){
            landRight = lstLandRight[0];
        }
        return landRight;
    } 
        
    global static void getCurrentUserDetails()
    {	
        currentUser=[SELECT Id, SPEN_SAPId__c FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        
    }
    
    global static void prepareContractPayload(SPEN_Land_Interest__c landRightObj){        
        res.hasContractInitiated =false;
        String bodyStr = '';        
        SPEN_Land_Interest__c landRightIns = getLandRight(landRightObj);        
        List<SPEN_Condition__c> conditions = getSAPConditions(landRightIns);
        getCurrentUserDetails();
        
        SPEN_SAPContract sapContractObj = new SPEN_SAPContract();
        if(conditions != null && conditions.size() > 0 ){
            Integer rowNumber = 0;
            for(SPEN_Condition__c conditn : conditions){
                rowNumber++;                
            	sapContractObj.addSAPCondition(landRightIns, conditn, rowNumber);                
        	}
            if(rowNumber < 2){
               sapContractObj.addExtraNoticeRow(landRightIns,conditions[0]);
            }
            bodyStr = JSON.serialize(sapContractObj);
        }        
        if(bodyStr != ''){
            //Get SAP Token
            HttpRequest req = new HttpRequest();
            req.setEndpoint(Label.SPEN_LnP_SAPCallout+'/TokenSet(\'\')?');
            req.setMethod('GET');
            req.setHeader('content-type','application/json');             
            req.setHeader('x-csrf-token','fetch');
            Http httpGet = new Http();
            HTTPResponse resToken = httpGet.send(req);
            String csrfToken = resToken.getHeader('x-csrf-token');
            String cookie = resToken.getHeader('set-cookie');
            if(Test.isRunningTest()){
                 csrfToken = '22436';
            	 cookie ='cookie';
            }
            // Contract POST call
            HttpRequest reqPOST = new HttpRequest();            
            reqPOST.setEndpoint(Label.SPEN_LnP_SAPRE+ '/ContractSet');
            reqPOST.setMethod('POST');
            reqPOST.setHeader('Content-Type', 'application/json');
			reqPOST.setheader('x-csrf-token',csrfToken);
			reqPOST.setheader('Cookie', cookie);           
            reqPOST.setBody(bodyStr); 
            reqPOST.setTimeout(Integer.valueOf(System.Label.SPEN_LnP_SAPTimeout));
            Http httpPOST = new Http();
            HTTPResponse resPOST = httpPOST.send(reqPOST);
           
            if(resPOST.getStatusCode() == 201) {
                res.hasContractInitiated =true;                           
            }else{
                res.hasContractInitiated =false;  
                String error =  resPOST.getBody();  
                Integer errormessageStart = error.indexof('<message>');
                if(errormessageStart != -1){
                    error = error.substring(errormessageStart, error.indexof('</message'));
                    error = error.replace('<message>','');
                    Integer maxSize = 4950;
                    if(error.length()  > maxsize ){
                        error = error.substring(0, maxSize);
                    }
                } else{
                   error = 'ERROR';                
                }               
                res.ErrorMessage = error;               
                                
            }                                  
        }
    } 
}
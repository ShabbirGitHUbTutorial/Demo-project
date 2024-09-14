/* File Name: SPEN_SAPContract
 * Description: This class will be create draft contract payload structure to be send to SAP RE via POST Call
 * Author: ajay.chandraferi
 * Version: 1.0
 * History:
 * Date            Author              Comment
 * Mar-04-2024     Ajay Chandraferi    Initial version
 *
 */
public class SPEN_SAPContract {
    list<SPEN_SAPCondition> ContractSet {get;set;}
    public SPEN_SAPContract(){
        this.ContractSet = new list<SPEN_SAPCondition>();
    }
    public void addSAPCondition(SPEN_Land_Interest__c landRight, SPEN_Condition__c sapCondition, Integer rowNumber){
        SPEN_SAPCondition newCondition = new SPEN_SAPCondition(landRight, sapCondition, false);
        if(rowNumber == 1){
            newCondition.addRenewalParameter();
        	newCondition.addNoticeParameter('1', landRight.SPEN_ConsentType__c);
        }else if(rowNumber == 2){
            newCondition.addNoticeParameter('2', landRight.SPEN_ConsentType__c);
        }
        ContractSet.add(newCondition);
    }
    public void addExtraNoticeRow(SPEN_Land_Interest__c landRight, SPEN_Condition__c sapCondition){
        SPEN_SAPCondition newCondition = new SPEN_SAPCondition(landRight, sapCondition, true);
        newCondition.addNoticeParameter('2', landRight.SPEN_ConsentType__c);
        ContractSet.add(newCondition);
    }
    
    
    public class SPEN_SAPCondition{
        String BukrsDg = '';
        String RecntxtoldDg = '';
        String RecntxtDg = '';
        String RecntypeDg = '';
        String ZzsistemaorigenDg = 'SF';
        String RecncncurrDg = '';
        String ZzautofacturaDg = '';
        String RecnbegDg = '';
        String Recnend1stDg = '';
        String CfpostingfromDg = '';
        String ZzformjurCi = '';
        String ZzgruplaCi = '';
        String ObjnrCd = '';
        String CondvalidfromCd = '';
        String CondvalidtoCd = '';
        String CondtypeCd = '';
        String CondpurposeextCd = '';
        String UnitpriceCd = '';
        String CondcurrCd = '';
        String Calcrulepara1Cd = '';
        String Distrulepara1Cd = '';
        String ZzfaseparCd = '';
        String PartnerPy = '';
        String PymtmethPy = '';
        String PymttermPy = '';
        String BankdetailidPy = '';
        String TaxtypePy = '';
        String FrequencyRh = '';
        String PaymentformrhRh = '';
        String CondvaluereferRh = '';
        String MonthfromRh = '';
        String RhythmbeginRh = '';
        String DuedatecorrruleRh = '';
        String DuedatecorrdayRh = '';
        String AdjmruleAj = '';
        String RhythmAj = '';
        String AdjmfirstdateAj = '';
        String FirstindexdateAj = '';
        String DelaybaseAj = '';
        String GradperiodCd = '';
        String GradmonthCd = '';
        String GradpercentCd = '';
        String NtruletypeNt = '';
        String NtprocprtyNt = '';
        String Ntnotdate1Nt = '';
        String NtrhythmtypeNt = '';
        String NtpermonthsNt = '';
        String RnruletypeRn = '';
        String RnextcountRn = '';
        String RnextyearsRn = '';
        String RnextmonthsRn = '';
        String RnnotmonthsRn = '';
        String ZzsujetoprorrogaRn = '';
        String RnauttypeRn = '';
        String SrrelevantDg = '';
        String TermnoVn = '';
        String RptermnoVnCalc = '';
        String PriceperunitVnCalc = '';
        String FrequencyVnRhytm = '';
        String ZzrentpercentVnCalc = '';
        String SalestypeSr = ''; 
        String ResponsibleDg='';
    
        public SPEN_SAPCondition(SPEN_Land_Interest__c landRightObj, SPEN_Condition__c sapConditionObj, Boolean isExtraNoticeRow){
            //SPEN Land Right record parameter
            if(landRightObj != null){
                if(landRightObj.SPEN_ConsentType__c != null){
                    this.ZzformjurCi = getLegalForm(landRightObj.SPEN_ConsentType__c);
                }
                if(landRightObj.SPEN_Licence_Area_Code__c != null){
                    this.BukrsDg = landRightObj.SPEN_Licence_Area_Code__c;
                }                
                if(landRightObj.Id != null){
                    this.RecntxtoldDg = landRightObj.Id;
                }                
                if(landRightObj.SPEN_Contract_Type__c != null){
                    this.RecntypeDg = landRightObj.SPEN_Contract_Type__c;
                }                
                if(landRightObj.SPEN_Contract_Start_Date__c != null){
                    this.RecnbegDg = convertDate(landRightObj.SPEN_Contract_Start_Date__c);
                }                
                if(landRightObj.SPEN_Contract_First_End_Date__c != null){
                    this.Recnend1stDg = convertDate(landRightObj.SPEN_Contract_First_End_Date__c);
                }                
                if(landRightObj.SPEN_Contract_Valid_From__c != null){
                    this.CfpostingfromDg = convertDate(landRightObj.SPEN_Contract_Valid_From__c);
                    if(!isExtraNoticeRow){
                        this.CondvalidfromCd = convertDate(landRightObj.SPEN_Contract_Valid_From__c);
                    }
                    
                }                
                if(landRightObj.SPEN_Annual_Wayleave_Payment_Payable__c != null && !isExtraNoticeRow){
                    this.RhythmbeginRh  = convertDate(landRightObj.SPEN_Annual_Wayleave_Payment_Payable__c);
                }               
                if(landRightObj.SPEN_Land__r.Name != null){
                    this.RecntxtDg = landRightObj.SPEN_Land__r.Name;   
                }
                if(!isExtraNoticeRow && landRightObj.Partner_Associations__r!=null && landRightObj.Partner_Associations__r.size() > 0){
                    if(landRightObj.Partner_Associations__r[0].SPEN_Partner__c!=null && landRightObj.Partner_Associations__r[0].SPEN_Partner__r.SPEN_BusinessPartnerNumber__c!=null ){
                    	this.PartnerPy = landRightObj.Partner_Associations__r[0].SPEN_Partner__r.SPEN_BusinessPartnerNumber__c;
                    }
                }
            }
            //SPEN Condition record parameter
            if(sapConditionObj != null){                
                
                if(sapConditionObj.SPEN_Auto_Invoice__c != null){  
                    this.ZzautofacturaDg = sapConditionObj.SPEN_Auto_Invoice__c; 
                }
                if(sapConditionObj.SPEN_Planner_Group__c != null){  
                     this.ZzgruplaCi = sapConditionObj.SPEN_Planner_Group__c;
                }
                if(sapConditionObj.SPEN_Condition_Currency__c != null){  
                        this.RecncncurrDg = sapConditionObj.SPEN_Condition_Currency__c;
                    }
                if(!isExtraNoticeRow){
                    this.TaxtypePy = 'SW';
                    this.MonthfromRh = '40';
                    this.CondvaluereferRh = '1';
                    if(sapConditionObj.SPEN_Object__c != null){  
                    	this.ObjnrCd = sapConditionObj.SPEN_Object__c;  
                	}
                    if(sapConditionObj.SPEN_Type__c != null){  
                        this.CondtypeCd = sapConditionObj.SPEN_Type__c;
                    }
                    if(sapConditionObj.SPEN_Posting_Type__c != null){  
                        this.CondpurposeextCd =sapConditionObj.SPEN_Posting_Type__c;
                    }
                    if(sapConditionObj.SPEN_Unit__c != null){  
                        this.UnitpriceCd =String.ValueOf(sapConditionObj.SPEN_Unit__c) ;
                    } 
                    if(sapConditionObj.SPEN_Condition_Currency__c != null){  
                        this.CondcurrCd = sapConditionObj.SPEN_Condition_Currency__c;
                    } 
                    if(sapConditionObj.SPEN_Order__c != null){  
                        this.Distrulepara1Cd = sapConditionObj.SPEN_Order__c;
                    } 
                    if(sapConditionObj.SPEN_Measurement_Type__c != null){
                        this.Calcrulepara1Cd = sapConditionObj.SPEN_Measurement_Type__c;
                    }
                    if(sapConditionObj.SPEN_Wind_Farm_Stage__c != null){  
                        this.ZzfaseparCd = sapConditionObj.SPEN_Wind_Farm_Stage__c;
                    } 
                    if(sapConditionObj.SPEN_Payment_Method__c != null){  
                        this.PymtmethPy = sapConditionObj.SPEN_Payment_Method__c;
                    }
                    if(sapConditionObj.SPEN_Payment_Term__c != null){  
                       this.PymttermPy = sapConditionObj.SPEN_Payment_Term__c;
                    }
                    if(sapConditionObj.SPEN_Bank_Details__c != null){  
                       this.BankdetailidPy = sapConditionObj.SPEN_Bank_Details__c;
                    }
                    
                    if(sapConditionObj.SPEN_Tax_Type__c != null){  
                       this.TaxtypePy = sapConditionObj.SPEN_Tax_Type__c;
                    } 
                    if(sapConditionObj.SPEN_Frequency__c != null){  
                       this.FrequencyRh = sapConditionObj.SPEN_Frequency__c;
                    }
                    if(sapConditionObj.SPEN_Payment_Form__c != null){  
                       this.PaymentformrhRh = sapConditionObj.SPEN_Payment_Form__c;            
                    }                    
                }
        	}
            
            if(SPEN_SAPContractInvocable.currentUser!=null && !String.isBlank(SPEN_SAPContractInvocable.currentUser.SPEN_SAPId__c))
            {
                this.ResponsibleDg=SPEN_SAPContractInvocable.currentUser.SPEN_SAPId__c;
            }
        }
        public void addRenewalParameter(){
            this.RnruletypeRn = 'AUTOMATIC';
            this.RnextcountRn = '2';
            this.RnextyearsRn = '1';
            this.RnextmonthsRn = '1';
            this.RnnotmonthsRn = '1';
            this.ZzsujetoprorrogaRn = '1';
            this.RnauttypeRn = 'R';            
        }
        
        public void addNoticeParameter(String rowNum, String consentType){
            this.NtruletypeNt = 'No restrictions';
            this.NtprocprtyNt = rowNum;
            if(rowNum == '1'){
                if(consentType == 'Lease' || consentType == 'Close Couple Lead'){
                     this.NtpermonthsNt = '6';
                }else{
                    this.NtpermonthsNt = '1';
                }
            }if(rowNum == '2'){                
                this.NtpermonthsNt = '12';
            }              
        }
        
        String convertDate(Date inputDate){ 
            if(inputDate != null){
                Datetime inputDateTime = Date.Valueof(inputDate);                
            	return inputDateTime.format('dd.MM.yyyy');
            }
            return '';
        }
        String getLegalForm(String concentType){
            String sapLegalForm ;
            SWITCH on concentType {
               when 'Easement' {
                   sapLegalForm = '34';
               }
               when 'Servitude' {
                   sapLegalForm = '18';
               }
               when 'Wayleave' {
                  sapLegalForm = '16';
               }
               when 'Lease' {
                   sapLegalForm = '01';
               }
               when 'NWL' {
                   sapLegalForm = '17';
               }
               when 'Close Coupled Lease' {
                   sapLegalForm = '19';
               }
               when else {
                   sapLegalForm = '';
               }
            }
            return sapLegalForm;
        }
        
        
    }
}
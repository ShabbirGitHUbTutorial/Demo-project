import { LightningElement, api, track,wire } from "lwc";
import getQuestionnaire from "@salesforce/apex/SFBG_DynamicCallWizardService.getQuestionnaire";
import getNextQuesFromAns from "@salesforce/apex/SFBG_DynamicCallWizardService.getNextQuesFromAns";
import createCasefromCallWizard from "@salesforce/apex/SFBG_DynamicCallWizardService.createCasefromCallWizard";
import getPrevQuestion from "@salesforce/apex/SFBG_DynamicCallWizardService.getPrevQuestion";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import SPEN_ThirdPartyCause__c from "@salesforce/schema/Case.SPEN_ThirdPartyCause__c";
import SPEN_ThirdPartyDescription__c from "@salesforce/schema/Case.SPEN_ThirdPartyDescription__c";
import SPEN_ThirdPartyMobile__c from "@salesforce/schema/Case.SPEN_ThirdPartyMobile__c";
import SPEN_ThirdPartyTelephone__c from "@salesforce/schema/Case.SPEN_ThirdPartyTelephone__c";
import ThirdPartyAddress__c from "@salesforce/schema/Case.SPEN_ThirdPartyAddress__c";
import SPEN_ThirdPartyName__c from "@salesforce/schema/Case.SPEN_ThirdPartyName__c";
import getOutageETR from "@salesforce/apex/SPEN_CaseService.getOutageETR";
import getCommonOutageETR from "@salesforce/apex/SPEN_CaseService.getCommonOutageETR";
import getContact from "@salesforce/apex/SFBG_CommonDynamicWizardService.getPreferredContactMethod";
import getCaseCnsts from "@salesforce/apex/SFBG_DynamicCallWizardService.getAllConstants";
import getPremiseDetails from "@salesforce/apex/SFBG_DynamicCallWizardService.getPremiseDetails";
import updateVoiceCall from "@salesforce/apex/SFBG_DynamicCallWizardService.updateVoiceCall";
import LightningConfirm from 'lightning/confirm';

export default class SPEN_DynamicCallWizard extends NavigationMixin(
  LightningElement
) {
  @api premiseId;
  @api contactId;
  @api issueCategory;
  @api isBypass;
  @api caseNumber;
  @api recordId;
  @api caseId;
  @api incidentId;
  //@track recordId;
  @track questionLabel;
  @track question;
  @track questionId;
  @track questionType;
  @track firstQuestionId;
  @track questionnaireId;
  @track questionnaire;
  @track questionnaireName;
  @track checkboxAnswerOptions = [];
  @track radioAnswerOptions = [];
  @track questionnaireData;
  @track answers = [];
  @track radioQuestion = false;
  @track checkboxQuestion = false;
  @track infoQuestion = false;
  @track textQuestion = false;
  answerSelected = [];
  @track nextFinishLabel = "Next";
  @track textAnswerValue;
  @track showSummaryPage = false;
  @track showCasenotCreatedInfo=false;
  @track caseRemarks;
  @track caseCriticalInfo;
  @track checkboxValue = [];
  @track infoStyle = "slds-var-m-around_large slds-wrap";
  @track callOutcome;
  @track show3PDFields = false;
  @track newCaseId;
  @track CaseThirdPartyCause = SPEN_ThirdPartyCause__c;
  @track CaseThirdPartyDescription = SPEN_ThirdPartyDescription__c;
  @track CaseThirdPartyMobile = SPEN_ThirdPartyMobile__c;
  @track CaseThirdPartyTelephone = SPEN_ThirdPartyTelephone__c;
  @track CaseThirdPartyAddress = ThirdPartyAddress__c;
  @track CaseThirdPartyName = SPEN_ThirdPartyName__c;
  @track callSummary = "";
  @track caseStatus;
  @track showContactPref = false;
  @track caseContactId;
  @track prefContactMethod;
  @track isDisabled = false;
  @track isRadioRequired=false;
  @track isCIDisabled = false;
  @track isRemarksReqd = false;
  @track answerValueSelected;

  @track radioOptionSelected;

  @track selectedAnsQuestionId;
  @track showEndGreetings = false;
  @track outageETR;
  @track currentStep = "1";
  @track contactName;
  @track contactMailingAddress;
  @track previousAnswer;
  @track keyMeterRemarks;
  @track infoIcon;
  @track infoIconVariant;
  @track questionnaireMap = [];
  @track qMapKey = 0;
  @track questionnaireCritInfo;
  @track noSupply = false;
  @track caseNum; 
  @track navigateUrl;
  @track navigateVCUrl;
  @track noSupplyNet = false;
  @track spSupply = false;
  
  @track NSNetworkConstant; 
  @track NSSinglePremiseConstant; 

  //value;


  @wire(getCaseCnsts) 
  allConstants ({error, data}) {
      if (data) {
        this.NSNetworkConstant = data.WIZNOSUPPLYNETW;

        this.NSSinglePremiseConstant = data.WIZNOSUPPLYSP;
      } else {
          this.error = error;
      }
  }
  setQuestionnaireMap(question, ansId)
  {
    return {
      Question : {
        id: question.Id,
        questionObj: question,
        answerSelectedId:ansId, 
        answerObj: question.answers
      }
    }
  }
 
  connectedCallback() {
    console.log('VC>>'+this.recordId);
    if (this.isBypass && this.caseId !== null && this.caseId !== undefined) {
      this.callOutcome = "Bypass Case";
      this.showSummaryPage = true;
      this.newCaseId = this.caseId;
      this.caseNum = this.caseNumber;
      updateVoiceCall({voiceCallId: this.recordId,caseId: this.newCaseId});
    }
    getQuestionnaire({ launchVal: this.issueCategory })
      .then((result) => {
        this.questionnaire = result;
        this.questionnaire.forEach((question) => {
          this.questionnaireName = question.questionnaireName;
          this.questionnaireId = question.questionnaireId;          
          this.questionnaireCritInfo = question.questionnaireCriticalInfo;
          this.questionnaireMap = this.setQuestionnaireMap(question.firstquestion,'');
          //console.log('setQuestionnaireMap>>'+JSON.stringify(this.setQuestionnaireMap(question.firstquestion,'')));
          //console.log('questionnaireMap>>'+JSON.stringify(this.questionnaireMap));          
          this.caseCriticalInfo = this.questionnaireCritInfo;
          this.caseRemarks = question.questionnaireRemarks;
          this.confirgureQuestion(question.firstquestion);
        });
      })
      .catch((error) => {
        let errorToast = new ShowToastEvent({
          title: "Error getting questionnaire!",
          message: error.body,
          variant: "error",
          mode: "pester"
        });
        this.dispatchEvent(errorToast);
      });
      getPremiseDetails({premiseId : this.premiseId})
      .then((prem)=>{this.contactMailingAddress = prem.SPEN_FullAddress__c;}).catch((er)=>{console.log(er.body.message);});
  }
//added to retain the radio button selection on click of next
  renderedCallback() {
    //console.log('functiona called');
    /*const radioList = this.template.querySelectorAll(
        '[data-id^="radiobutton"]'
      );
      for (const radioElement of radioList) {

        if(radioElement.value == this.radioOptionSelected) {
          radioElement.checked = true;
        }
      }*/
}

  handleSelection(event) {
    let answer = JSON.parse(event.detail.value);
    this.answerIdSelected = answer.answerId;

    //console.log('answer'+answer);
    //console.log('answerId'+this.answerIdSelected);

    this.answerValueSelected = answer.answerValue;
    //console.log('answervalue'+this.answerValueSelected);
    this.selectedAnsQuestionId=answer.currentQuestionId;
    //answerSelected.push(answer.answerValue);

    
    this.isDisabled=false;
    //console.log('answer value handle event:'+ this.answerValueSelected);

    if (
      this.question.questionLabelToDisplay ===
      "<p> Agent: Capture phase affected details.</p>"
    ) {
      this.caseRemarks = this.answerValueSelected;
    }
    console.log('Remarks Entered:'+this.caseRemarks);

    console.log('Last question'+this.question.isLastQuestion);
    console.log('call outcome--->>>'+this.callOutcome);
    console.log(this.NSSinglePremiseConstant);
     if((this.callOutcome == this.NSSinglePremiseConstant) || (this.callOutcome == this.NSNetworkConstant) && this.question.isLastQuestion==true){

      if(this.answerValueSelected =='No' && this.caseRemarks==undefined){        
          this.isRemarksReqd = true;
          this.isCIDisabled = false;
          this.isDisabled = true;
       } else if(this.answerValueSelected == 'Yes' && this.caseRemarks==undefined){       
          this.isRemarksReqd = true;
          this.isCIDisabled = false;
          this.isDisabled = true;
       }
         
      } else {        
          //this.isRemarksReqd = true;
          this.isCIDisabled = false;
          //this.isDisabled = true;
      }
  }

  handleNextQuestionType(questionType) {
    switch (questionType) {
      case "Checkbox":
        this.checkboxQuestion = true;
        this.radioQuestion = false;
        this.infoQuestion = false;
        this.textQuestion = false;
        this.handleCheckboxOptions(this.answers);
        break;
      case "Radio":
        this.checkboxQuestion = false;
        this.radioQuestion = true;
        this.infoQuestion = false;
        this.textQuestion = false;
        this.handleRadioOptions(this.answers);
        break;
      case "Information":
        this.checkboxQuestion = false;
        this.radioQuestion = false;
        this.infoQuestion = true;
        console.log('Info Type');
        this.textQuestion = false;
        break;
      case "Textbox":
        this.checkboxQuestion = false;
        this.radioQuestion = false;
        this.infoQuestion = false;
        this.textQuestion = true;
        break;
      default:
        this.checkboxQuestion = false;
        this.radioQuestion = false;
        this.infoQuestion = false;
        this.textQuestion = false;
        break;
    }
  }

  handleRadioOptions(answer) {
    this.radioAnswerOptions = [];
    answer.forEach((option) => {
      this.radioAnswerOptions.push({
        label: option.answerValue,
        value: JSON.stringify(option)
      });
    });
  }

  handleCheckboxOptions(answer) {
    this.checkboxAnswerOptions = [];
    answer.forEach((options) => {
      this.checkboxAnswerOptions.push({
        label: options.answerValue,
        value: options.answerId
      });
    });
  }

  handleNextQuestion() {

   // console.log('Enter next--->>'+this.answerValueSelected);
   
    //this.previousAnswer = this.answerValueSelected;
    /*this.answerSelected.push({
      Id: this.answerIdSelected,
      value:this.answerValueSelected,
      questionId:this.selectedAnsQuestionId,
      isChecked:true
    });*/
    

    //console.log('next answer'+ JSON.stringify(this.answerSelected));

   
   /*if (this.answerValueSelected.includes("faulty")) {

      this.keyMeterRemarks = "faulty";
    } else if (this.answerValueSelected.includes("lost")) {
      this.keyMeterRemarks = "lost";
    }
    if (this.answerValueSelected=="faulty") {

      this.keyMeterRemarks = "faulty";
    } else if (this.answerValueSelected=="lost") {
      this.keyMeterRemarks = "lost";
    }*/
    //console.log('label23'+this.nextFinishLabel);
    if (this.questionType === "Information") {
      this.callSummary +=
        "<p>Question: " + this.question.questionLabelToDisplay + "</p>";
    } else if(this.answerValueSelected !== '') {
      this.callSummary +=
        "<p>Question: " +
        this.question.questionLabelToDisplay +
        "</p><p>Answer: " +
        this.answerValueSelected +
        "<br/><br/>";
    } else{
      this.callSummary +=
        "<p>Question: " + this.question.questionLabelToDisplay + "</p>";
    }
    //console.log('label33'+this.nextFinishLabel);
    if (this.nextFinishLabel === "Next") {
      //console.log('answerId--->>'+this.answerIdSelected);
      //console.log('quesId--->>'+this.question.questionId);
      getNextQuesFromAns({
        answerId: this.answerIdSelected,
        quesId: this.question.questionId
      })
        .then((res) => {
          //this.answerValueSelected = "";
          this.confirgureQuestion(res);
          /*this.answerSelected.forEach(element => {
           
            if(element.questionId==this.question.questionId){
              this.answerValueSelected=element.value;
              //console.log('nextselectedanswerfound---->>'+this.answerValueSelected);
            }
          });*/
          
       
        })
        .catch((err) => {
          let errorToast = new ShowToastEvent({
            title: "Error fetching next Question!",
            message: err,
            variant: "error",
            mode: "pester"
          });
          this.dispatchEvent(errorToast);
        });
    } else if (this.nextFinishLabel === "Finish") {
      this.infoStyle = "slds-var-m-around_large slds-wrap";
      this.isRemarksReqd=true;
      //console.log('Enter remarks');
      //console.log('Remarks:'+this.caseRemarks);
   
      if(this.caseRemarks==undefined || this.caseRemarks=='' || this.caseRemarks=='undefined')
      {
        console.log('Remarks if:'+this.caseRemarks);
        this.isRemarksReqd=true;
        this.isDisabled=true;
      }
      else if(this.caseRemarks!=undefined || this.caseRemarks!='' || this.caseRemarks!='undefined'){
        if (
          !this.isBypass &&
          this.caseId == null &&
          this.caseId === undefined &&
          this.contactId !== undefined &&
          this.contactId !== null &&
          this.contactId !== "" && this.callOutcome!==undefined &&  this.callOutcome!==null
        ) {

          this.showContactPref = true;

                    

        } 
        
        else {
          this.handleCreateCase();
          this.isDisabled=true;
        }
      }
      
    }
  }

  handlePrevoiusQuestion() {
    
    //this.value=this.answerValueSelected;
    console.log('selected value:'+ this.answerValueSelected+'-'+this.value);
    this.nextFinishLabel = "Next";
    this.show3PDFields = false;
    this.isCIDisabled = false;
    this.isRemarksReqd = false;
    this.isDisabled=false;
    this.isLastQuestion=false;
    this.answerValueSelected='';
    this.value='';
    getPrevQuestion({
      questionnaireId: this.questionnaireId,
      quesId: this.previousQuestion
    })
      .then((response) => {
        this.confirgureQuestion(response);
        //this.isRemarksReqd = false;
       /*this.answerSelected.forEach(element => {
          
          if(element.questionId==this.question.questionId){
            this.answerValueSelected=element.value;
            //console.log('previousselectedanswer---->>'+this.answerValueSelected);
          }
        });*/

        //console.log('previous answer'+ this.answerValueSelected);

      
      })
      .catch((err) => {
        let errorToast = new ShowToastEvent({
          title: "Error fetching Previous Question!",
          message: err.body.message,
          variant: "error",
          mode: "pester"
        });
        this.dispatchEvent(errorToast);
      });
  }

  navigateToCasePage() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        objectApiName: "Case",
        recordId: this.newCaseId,
        actionName: "view"
      }
    });
  }

  navigateToVoiceCallPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        objectApiName: "VoiceCall",
        recordId: this.recordId,
        actionName: "view"
      }
    });
  }
  confirgureQuestion(questionData) {

    //console.log('Previous Remarks'+this.caseRemarks);
    //console.log('questiondata-->>'+questionData);

    console.log('selected value:'+ this.answerValueSelected+'-'+this.value);
    this.infoStyle = "slds-var-m-around_large slds-wrap";
    this.question = questionData;
    

    //console.log('Last question1'+this.question.isLastQuestion);

    if (this.question.isLastQuestion) {
      this.nextFinishLabel = "Finish";
      this.isRemarksReqd=true;
      this.isDisabled=true;
      this.callOutcome = this.question.questionOutcome;
      console.log('call outcome-->>'+this.callOutcome);
      if(this.callOutcome == this.NSSinglePremiseConstant){
      //console.log("callOutcome1>>"+this.callOutcome);
        this.noSupplyNet = false;
        this.spSupply = true;
      //console.log(" 1 this.spSupply>>"+this.spSupply+ "  this.noSupplyNet>>"+this.noSupplyNet);
      } else if (this.callOutcome == this.NSNetworkConstant){
        //console.log("callOutcome2>>"+this.callOutcome);
        this.spSupply = false;
        this.noSupplyNet =true;
        //console.log(" 2 this.spSupply>>"+this.spSupply+ "  this.noSupplyNet>>"+this.noSupplyNet);
      } else {
        //console.log("callOutcome3>>"+this.callOutcome);
        this.noSupplyNet = false;
        this.spSupply = false;
      }
      //change added on 02/02/23
      /*if(this.caseRemarks!="" || this.caseRemarks != undefined || this.caseRemarks != null){        
      this.isDisabled = false;
      }
       else if (this.caseRemarks === undefined || this.caseRemarks == null || this.caseRemarks == "" ){
        this.isDisabled = true;
      }*/
    }
    this.previousQuestion = this.question.previousQuestionId;
    console.log('Previous question-->>'+this.previousQuestion);
    this.answers = this.question.answers;
    this.questionLabel = this.question.questionLabelToDisplay;
    if (this.questionLabel.toLowerCase().includes("Critical") && this.questionLabel.toLowerCase().includes("Remarks")) {
      //this.isRemarksReqd = true;
      //this.isCIDisabled = true;
    } else if (this.questionLabel.toLowerCase().includes("Critical")) {
      //console.log('critical reqd else  If config');
      //this.isRemarksReqd = false;
      //this.isCIDisabled = true;
    } else if (this.questionLabel.toLowerCase().includes("Remarks")) {      
      //console.log('remarks config else If');
      //this.isCIDisabled = false;
      //this.isRemarksReqd = true;
    }

    if (this.callOutcome === "Shocks From Equipment (Internal)") {
      this.isCIDisabled = true;
      this.isDisabled = true;
    }
    this.questionType = this.question.questionRecType;
    if (this.questionType === "Information") {      
      this.infoQuestion = true;
      this.infoStyle = "slds-var-m-around_large slds-box slds-wrap";
      switch (this.question.informationQuestionType) {
        case "Information":
          this.infoStyle = "slds-var-m-around_large slds-box info-msg slds-wrap";
          this.infoIcon = 'utility:info_alt';
          this.infoIconVariant = '';
          break;
        case "Critical":
          this.infoStyle = "slds-var-m-around_large slds-box critical-msg slds-wrap";
          this.infoIcon = 'utility:reminder';
          this.infoIconVariant = 'error';
          break;
        case "Warning":
          this.infoStyle = "slds-var-m-around_large slds-box warning-msg slds-wrap";
          this.infoIcon = 'utility:warning';
          this.infoIconVariant = 'warning';
          break;
        case "Success":
          this.infoStyle = "slds-var-m-around_large slds-box success-msg slds-wrap";
          this.infoIcon = 'utility:success';
          this.infoIconVariant = 'success';
          break;
        default:
          this.infoStyle = "slds-var-m-around_large slds-box slds-wrap";
          break;
      }
    }    

    if (this.questionType === "Radio" ) {

      console.log('type:'+this.questionType);
      this.isRadioRequired=true;
      this.isDisabled=true;
      console.log('disabled:'+this.isDisabled);

    }

    this.handleDisableNext();
    //this.questionnaireMap.push({value: "", key:this.question.questionId});
    this.handleNextQuestionType(this.questionType);
  }

  handle3PDFields() {
    this.show3PDFields = false;
    this.showSummaryPage = true;
  }

  handleRemarks(event) {
    this.caseRemarks = event.detail.value;
    //console.log('Remarks'+this.caseRemarks);
    if (
      this.caseRemarks &&
      this.questionLabel.includes("MOP") &&
      this.isLastQuestion
    ) {
      this.isRemarksReqd = false;
      this.isDisabled = false;
    } else if (this.caseRemarks) {
      //this.isRemarksReqd = true;
      this.isDisabled = false;
    }
    
    if((this.caseCriticalInfo || this.caseRemarks) && !this.answerValueSelected && !(this.questionType === "Information" || this.questionType === "Textbox")){      
      this.isDisabled = true;
    }
  }

  handleCriticalInfo(event) {
    this.caseCriticalInfo = event.detail.value;
    if (
      this.caseCriticalInfo &&
      (this.questionLabel.toLowerCase().includes("Critical"))) {
      //console.log('critical reqd nd there If');
      this.isCIDisabled = false;
      this.isDisabled = false;
    } else if (
      !this.caseCriticalInfo && this.questionLabel.toLowerCase().includes("Critical")
    ) {
      //this.isDisabled = true;
      //console.log('critical reqd but empty else if');
      this.isCIDisabled = true;
    } else if (this.caseCriticalInfo && this.caseRemarks==undefined) {


      this.isCIDisabled = false;
      //console.log('critical  theree else1');
      //this.isDisabled = true;

    }
    
    if(this.nextFinishLabel == "Finish" && ((this.caseRemarks === undefined || this.caseRemarks == null || this.caseRemarks == "") && this.isRemarksReqd)){
      this.isDisabled = true;      
    } else{
      this.isDisabled = false;
    }    
    if((this.caseCriticalInfo || this.caseRemarks) && !this.answerValueSelected && !(this.questionType === "Information" || this.questionType === "Textbox")){      
      this.isDisabled = true;
    }
  }

  handleTextSelection(event) {
    this.answerValueSelected = event.detail.value;
    if (this.answerValueSelected) {
      this.isDisabled = false;
    }
  }

  handlePrefContact(event) {
    
    if(this.questionnaireName == "No Supply"){
      this.noSupply =true;
    }
    this.showContactPref = event.detail.showPref;
    this.caseContactId = event.detail.contactRecId;
    this.prefContactMethod = event.detail.contactMethod;
    this.showEndGreetings = true;
    getContact({ recordId: this.caseContactId })
      .then((result) => {this.contactName = result.Name;}).catch((er) => {console.log(er.body.message);});
    // getOutageETR({ caseCategory: this.callOutcome })
    //   .then((res) => {this.outageETR = res;}).catch((err) => {console.log(err.body.message);});
    getCommonOutageETR({caseCategory : this.callOutcome, incidentRecId : this.incidentId}).then(result=>{
      this.outageETR = result;
    }).catch(error=>{
      console.log(error.body.message);
    });
  }

  async handleCreateCase() {
    if (this.callOutcome) {
      this.caseStatus = "Open";
      
    } /* //commented  not to create a closed case else {
      this.caseStatus = "Closed";
    }*/
    /*if (this.caseRemarks === undefined || this.caseRemarks == null) {
      this.caseRemarks = "";
    }*/
    //Added by smita 18/10/22
    if (this.caseCriticalInfo === undefined || this.caseCriticalInfo == null) {
      this.caseCriticalInfo = "";
    }
    console.log('case status'+ this.caseStatus);
    if (this.caseStatus ===undefined || this.caseStatus==null){
      const result = await LightningConfirm.open({
        message: "The case won't be created based on the answers to the wizard questions, please press cancel if you want to go back and change the answers.",
        variant: 'headerless',
        label: 'Case Info',
        theme: 'warning'
    });
    console.log('Result: '+ result);
    if(result){
      this.showCasenotCreatedInfo = true;
    }else{
      console.log('False:'+result);
    }
    //Confirm has been closed
    }
    else{
      let caseData = {
        caseSubject: this.questionnaireName + " Wizard Case",
        caseStatus: this.caseStatus,
        caseOrigin: "Phone",
        caseCategoryOutcome: this.callOutcome, //SPEN_CaseCategoryOutcome__c
        caseProblemCategory: this.questionnaireName, //SPEN_CaseProblemCategory__c
        caseRemarks: this.caseRemarks,
        caseCriticalInformation: this.caseCriticalInfo,
        caseHistory: JSON.stringify(this.callSummary),
        caseContactId: this.caseContactId,
        contPrefMethod: this.prefContactMethod,
        casePremiseId: this.premiseId,
        keyMeterRemarks: this.keyMeterRemarks,
        caseRelatedIncident : this.incidentId
      };
      createCasefromCallWizard({
        caseData: JSON.stringify(caseData),
        isBypassCase: this.isBypass
      })
        .then((res) => {
          if (res) {
            this.newCaseId = res.Id;
            this.caseNum = res.CaseNumber;
            this.navigateUrl='/lightning/r/Case/'+this.newCaseId+'/view';
            this.show3PDFields = false;
            if (this.callOutcome === "Damaged Equip/ 3rd Party Dam") {
              this.show3PDFields = true;
              this.showSummaryPage = false;
            } else {
              this.showSummaryPage = true;
              
              this.showEndGreetings = false;
              let successToast = new ShowToastEvent({
                title: "Success",
                message: "Case was created successfully!",
                variant: "success",
                mode: "dismissible"
              });
              this.dispatchEvent(successToast);
            }          
          updateVoiceCall({voiceCallId: this.recordId,caseId: this.newCaseId});
          }
        })
        .catch((error) => {
          let errorToast = new ShowToastEvent({
            title: "Oops, there is some error! The case was not created!",
            message: error.body.message,
            variant: "error",
            mode: "pester"
          });
          this.dispatchEvent(errorToast);
        });
    }
    
  }
  

  handleDisableNext() {

    //&& (this.answerValueSelected==undefined || this.answerValueSelected=='undefined' || this.answerValueSelected=='')
    if (this.questionType != "Information" ) {

      this.isDisabled = true;
    } else if(this.questionType == "Information" && this.question.isLastQuestion==true){
      this.isDisabled = true;
    }
    else{
      this.isDisabled = false;
    }
  }

  handleOnStepClick(event) {
    this.currentStep = event.target.value;
  }

  get isStepOne() {
    return this.currentStep === "1";
  }
  get isStepTwo() {
    return this.currentStep === "2";
  }
  get isStepThree() {
    return this.currentStep === "3";
  }
  get isStepFour() {
    return this.currentStep === "4";
  }
  get isStepFive() {
    return this.currentStep === "5";
  }
  get isEnableNext() {
    return this.currentStep !== "5";
  }
  get isEnablePrev() {
    return this.currentStep !== "1";
  }
  get isEnableFinish() {
    return this.currentStep === "5";
  }

  handleGreetingNext() {
    if (this.currentStep === "1") {
      this.currentStep = "2";
    } else if (this.currentStep === "2") {
      this.currentStep = "3";
    } else if (this.currentStep === "3"  && (!this.spSupply || !this.noSupplyNet)) {      
      this.currentStep = "4";
    }  else if ((this.currentStep === "3" && (this.spSupply || this.noSupplyNet) ) || this.currentStep === "4") {
      this.currentStep = "5";
    } else if (this.currentStep === "5") {
      this.handleGreetingFinish();
    }
  }

  handleGreetingPrev() {
    if (this.currentStep === "2") {
      this.currentStep = "1";
    }
    if (this.currentStep === "3") {
      this.currentStep = "2";
    }
    if (this.currentStep === "4") {
      this.currentStep = "3";
    }
    if (this.currentStep === "5") {
      this.currentStep = "4";
    }
    if((this.currentStep === "5" && (this.spSupply || this.noSupplyNet))){      
      this.currentStep = "3";
    }
  }

  handleGreetingFinish() {
    //21/03/23 commented for the wizard not to navigate to the previous screen 
    //this.showEndGreetings = false;
    this.isDisabled=true;
    this.handleCreateCase();
  }
}
import { LightningElement, track, wire, api} from 'lwc';
import getPSRVulnerabilityList from '@salesforce/apex/SPEN_PSRVulnerabilityService.getPSRVulnerabilityList';
import createPSRRecord from '@salesforce/apex/SPEN_PSRVulnerabilityService.createPSRRecord';
import removePSRRecords from '@salesforce/apex/SPEN_PSRVulnerabilityService.removePSRRecords';
import getPSRRecordForTheContact from '@salesforce/apex/SPEN_PSRVulnerabilityService.getPSRRecordForTheContact';
import getPickValue from '@salesforce/apex/SPEN_PSRVulnerabilityService.getPickValue';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createPSRWithFirstLangOrEffectiveToDate from '@salesforce/apex/SPEN_PSRVulnerabilityService.createPSRWithFirstLangOrEffectiveToDate';
import { refreshApex } from '@salesforce/apex';                         //added today
import { CloseActionScreenEvent } from 'lightning/actions';
//import { CloseActionScreenEvent2 } from 'lightning/actions';
const psrcols = [
    { 
        fieldName: "recLink", 
        label: "Name",
        type: "url",
        typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name" }
    },
    /*{ 
        fieldName: "SPEN_Code__c", 
        label: "Code" 
    },*/
    { 
        fieldName: "SPEN_Description__c", 
        label: "Description" 
    },
    { 
        fieldName: "SPEN_SpecificVulnerability__c", 
        label: "Specific Vulnerability", 
        type: "boolean" 
    }
];
export default class SPEN_ContactPsrSelection extends LightningElement 
{
    @track psrVulList =[];
    @track recorddata = [];
    @track psrlist = [];
    @track psrListDataToShow=[];
    @track psrcols = psrcols;
    @track selectRows;
    @api recordId;
    isShowFirstLangPicklist = false;
    isShowEffectiveDate = false;
    isShowModel = false;
    effectiveDate='';
    @api custpassword = false; //SFAMS-649
    @api additinalInfo; //SFAMS-649
    showOtherPartnerCorrespondence;

    @track options = [];
    @track pSRDetailsValidatedOptions = [];
    @track customerHappyOptions = [];
    @track sourceOfPSRoptions = [];
    value = '';
    pSRDetailsValidatedValue = '';
    customerHappyValue = '';
    sourceOfPSRValue = '';
    @track psrResult;
    @track psrVulnerabilityRes;
    @track isShowSocialObligations = [];
    isShowSocialObligationsValue='';
    isShowSocialObligationsSource = false;
    OtherPartner;



    @track cols = 
    [
        {
            fieldName: "recordLink",
            label: "Name",
            type: "url",
            displayReadOnlyIcon: true,
            typeAttributes: { label: { fieldName: "Name" }, tooltip:"Name" }
        },
        {
            fieldName: "rlink", 
            label: "PSR and Vulnerability Type"
        },
        {
            fieldName: "SPEN_SpecificVulnerability__c", 
            label: "Specific Vulnerability", 
            type: "boolean", 
            displayReadOnlyIcon: true
        }
    ];

    //added by ramesh.c.singh@accenture.com
    handleOtherPartnerChange(event)
    {
        this.OtherPartner = event.target.value;
        console.log('OtherPartner>>>' +  this.OtherPartner);


    }


    connectedCallback() {
        getPickValue({objectName: 'SPEN_PSR__c', fieldName :'SPEN_FirstLanguage__c'})
            .then(result => {
                for (var i = 0; i < result.length; i++) {
                    this.options.push({label: result[i], value: result[i]});
                }
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
           
            getPickValue({objectName: 'SPEN_PSR__c', fieldName :'SPEN_IsPSRDetailsValidated__c'})
            .then(result => {
                for (var i = 0; i < result.length; i++) {
                    this.pSRDetailsValidatedOptions.push({label: result[i], value: result[i]});
                }
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
           
            getPickValue({objectName: 'SPEN_PSR__c', fieldName :'SPEN_IsCustomerHappy__c'})
            .then(result => {
                for (var i = 0; i < result.length; i++) {
                    this.customerHappyOptions.push({label: result[i], value: result[i]});
                }
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
            
            getPickValue({objectName: 'SPEN_PSR__c', fieldName :'SPEN_SourceofPSRUpdate__c'})
            .then(result => {
                for (var i = 0; i < result.length; i++) {
                    this.sourceOfPSRoptions.push({label: result[i], value: result[i]});
                }
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });
            getPickValue({objectName: 'SPEN_PSR__c', fieldName :'SPEN_SocialObligationsSource__c'})
            .then(result => {
                for (var i = 0; i < result.length; i++) {
                    this.isShowSocialObligations.push({label: result[i], value: result[i]});
                }
            })
            .catch(error => {
                console.log(JSON.stringify(error));
            });


    }

    handleChange(event) {
        this.value = event.detail.value;
    }
    //end here added by ramesh.c.singh@accenture.com

    @wire(getPSRRecordForTheContact,{recordId: '$recordId'})
    PSRs(result)
    {
        this.psrResult=result;
        console.log('PSR in wire'+result.data);
        if(result.data)
        {
            var temprecorddata = [];
            for (var i = 0; i < result.data.length; i++) 
            {  
                let tempRec = Object.assign({}, result.data[i]);   
                tempRec.recordLink = "/" + tempRec.Id;
                tempRec.rlink = tempRec.SPEN_PSRVulnerabilityType__r.Name;
                temprecorddata.push(tempRec);  
            }
            this.recorddata = temprecorddata;
        
        }
        else if(result.error)
        {
            console.log(error);
        }
    }
 
    @wire(getPSRVulnerabilityList,{recordId: '$recordId'}) 
    vulnerabilities(result) 
    {
        this.psrVulnerabilityRes=result;
        //console.log('vulnerabilities inwire'+result.data);
        if (result.data) 
        {   
            var tempRecData = [];
            for (var i = 0; i < result.data.length; i++) 
            {  
                if(result.data[i].Name != '21-Other medical dependancy on electricity'){
                //console.log('=====data'+data[i].Name);
                let tempRecord = Object.assign({}, result.data[i]);   
                tempRecord.recLink = "/" + tempRecord.Id;
                tempRecData.push(tempRecord);  
                }
            }       
            this.psrListDataToShow = tempRecData;
        }
        else if (result.error) 
        {
            console.log(result.error);
        }
    }
    //performed the changes in this method ramesh.c.singh@accenture.com 
    handlePSRAdd(event) 
    {
        console.log('====handlePSRAdd:');
        var selected = this.template.querySelector('[data-id="vulList"]').getSelectedRows();
        console.log('====selected:'+JSON.stringify(selected));
        for(var i = 0; i < selected.length; i++){
            if(selected[i].Name === '17-Unable to communicate in English'){
                console.log('17-Unable to communicate in English');
                this.isShowFirstLangPicklist = true;
            }
            if(selected[i].Name === '29-Families with young children 5 or under'){
                console.log('29-Families with young children 5 or under');
                this.isShowEffectiveDate = true;
            }
            //SFAMS-649: added the condition
            if(selected[i].Name === '99-Cust Password'){
                this.custpassword = true;
            }
        }
        this.isShowModel =  true;
        console.log('====isShowModel:'+this.isShowModel);
    } 
    
    
    removePSRfromContact()
    {
        console.log('refreshlwc');
        var selectedrecords = this.template.querySelector('[data-id="PSR"]').getSelectedRows();
        console.log('selectedrecords'+selectedrecords);
        removePSRRecords({removeRec: selectedrecords})
        .then(result => 
        {    
            console.log('result'+result);
            //this.recorddata=result;
            if(result!=null)
            {
                //
               //window.location.reload();
               console.log('result inside if'+result);
               refreshApex(this.psrResult);         //added today
               refreshApex(this.psrVulnerabilityRes); 
               console.log('psrResult'+this.psrResult);
               console.log('psrVulnerabilityRes'+this.psrVulnerabilityRes); 
               this.dispatchEvent(new CloseActionScreenEvent());
               eval("$A.get('e.force:refreshView').fire()");
            }
            this.error = undefined;
        })
        .catch(error => 
        {
            console.log(error);
        });
    }

    // start here added by ramesh.c.singh@accenture.com
    handlePsrDetailsChange(){
        this.pSRDetailsValidatedValue = this.template.querySelector('.PsrDetailsValidated').value;
        console.log('=====effectiveDate:'+this.pSRDetailsValidatedValue)
    }

    handleSourceOfPsrChange(){
        this.sourceOfPSRValue = this.template.querySelector('.SourcePsrUpdate').value;
        console.log('=====effectiveDate:'+this.sourceOfPSRValue)
       if (this.sourceOfPSRValue == 'Social Obligations') {
        this.isShowSocialObligationsSource = true;
    } else {
        this.isShowSocialObligationsSource = false;
    }
    }
    handleisShowSocialObligationsChange(){
        this.isShowSocialObligationsValue = this.template.querySelector('.isShowSocialObligations').value;
        console.log('=====effectiveDate:'+this.isShowSocialObligationsValue)
        if(this.isShowSocialObligationsValue== 'Other Partner' || this.isShowSocialObligationsValue== 'Other leaflet/correspondence')
        {
            this.showOtherPartnerCorrespondence= true;
        }else{
            this.showOtherPartnerCorrespondence= false;
        }
    }
    handleCustomeHappyChange(){
        this.customerHappyValue = this.template.querySelector('.CustomerHappy').value;
        console.log('=====effectiveDate:'+this.customerHappyValue)
    }


    showModalBox() {  
        this.isShowModel = true;
    }

    hideModalBox() {  
        this.isShowModel = false;
    }

    getEffectiveDate(){
        this.effectiveDate = this.template.querySelector('.EffectiveDate').value;
        console.log('=====effectiveDate:'+this.effectiveDate)
    }

    createPSRWithFirstLangOrEffectiveToDate(){
        try{
        console.log('====createPSRWithFirstLangOrEffectiveToDate:');
        var selected = this.template.querySelector('[data-id="vulList"]').getSelectedRows();
        console.log('==== createPSRWithFirstLangOrEffectiveToDate selected:'+JSON.stringify(selected));
        console.log('=====this.value:'+this.value);
        console.log('=====this.isShowModel:'+this.isShowModel);
        console.log('====isShowFirstLangPicklist:'+this.isShowFirstLangPicklist);
        console.log('====isShowEffectiveDate:'+this.isShowEffectiveDate);
        if(this.pSRDetailsValidatedValue  == ''){
            this.template.querySelector('.PsrDetailsErrorMessage').style.display = 'block';;
            //return;
        }
        if(this.sourceOfPSRValue  == ''){
            this.template.querySelector('.SourcePsrUpdateErrorMessage').style.display = 'block';;
            //return;
        }
        if(this.isShowSocialObligationsValue  == '' && this.isShowSocialObligationsSource){
            this.template.querySelector('.isShowSocialObligationsErrorMessage').style.display = 'block';;
            //return;
        }

        if(this.customerHappyValue  == ''){
            this.template.querySelector('.CustomerHappyErrorMessage').style.display = 'block';;
            //return;
        }
        if( this.isShowFirstLangPicklist == true && this.value  == ''){
            this.template.querySelector('.FirstLanguageErrorMessage').style.display = 'block';;
            //return;
        }
        if( this.isShowEffectiveDate == true && this.effectiveDate  == ''){
            this.template.querySelector('.EffectiveDateErrorMessage').style.display = 'block';;
            //return;
        }
        //SFAMS-649 : Added the Condition
        if( this.custpassword == true && (this.additinalInfo  == ''|| this.additinalInfo == undefined)){
            this.template.querySelector('.AdditinalInfoErrorMessage').style.display = 'block';;
            //return;
        }
        //SFAMS-649: Added the Or Condition ( this.custpassword == true && (this.additinalInfo  == ''|| this.additinalInfo == undefined)
        if( this.pSRDetailsValidatedValue  == '' || this.sourceOfPSRValue  == '' || 
        this.customerHappyValue  == '' || (this.isShowFirstLangPicklist == true && this.value  == '') || (this.isShowSocialObligationsSource && this.isShowSocialObligationsValue == '') ||
        (this.isShowEffectiveDate == true && this.effectiveDate  == '') || ( this.custpassword == true && (this.additinalInfo  == ''|| this.additinalInfo == undefined) )){
            console.log('=====return');
            return;
        }
        var pSRDetails =
        {
            contactId:this.recordId,
            firstLang: this.value,
            pSRDetailsValidatedvalue: this.pSRDetailsValidatedValue,
            customerHappyvalue: this.customerHappyValue,
            sourceOfPSRvalue: this.sourceOfPSRValue,
            effectiveDate: this.effectiveDate,
            additinalInfo : this.additinalInfo, //SFAMS-649
            otherPartnerCorrespondence : this.OtherPartner,
            isShowSocialObligationsValue : this.isShowSocialObligationsValue
        };

        console.log('====pSRDetails:'+JSON.stringify(pSRDetails));
        if(this.isShowModel ){
            this.isShowModel = false;
            console.log('=====createPSRWithFirstLangOrEffectiveToDate');
            createPSRWithFirstLangOrEffectiveToDate({psrRecord: selected, pSRDetails :JSON.stringify(pSRDetails)})
            .then(result => 
            {  
                console.log('=====createPSRWithFirstLangOrEffectiveToDate:'+result);  
                if(result)
                {
                    //this.openCode17Model = true;
                    console.log('=====result:'+result);
                    refreshApex(this.psrResult);         //added today
                    refreshApex(this.psrVulnerabilityRes);  
                    //console.log('PSRs'+this.PSRs);  
                    //console.log('vulnerabilities'+this.vulnerabilities);  
                    this.dispatchEvent(new CloseActionScreenEvent());
                    eval("$A.get('e.force:refreshView').fire()");
                    
                    //window.parent.location.reload();
                }
                this.error = undefined;
            })
            .catch(error => 
                {
                    console.log('within error block in createPSRWithFirstLangOrEffectiveToDate:',error);
                    console.log('within:',error.body.message);
                    const evt = new ShowToastEvent({
                        title: 'error',
                        message: error.body.message,//'Some error has occurred!',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                        eval("$A.get('e.force:refreshView').fire()");
                });
        }
        }catch(ex)
        {
            console.error('Error occured in createPSRWithFirstLangOrEffectiveToDate :' + ex);
        }
    }
    //SFAMS-649 Added function: handleAdditinalInfoChange
    handleAdditinalInfoChange(){
        this.additinalInfo = this.template.querySelector('.additinalDetailsInfo').value;
        console.log(this.template.querySelector('.additinalDetailsInfo').value);
    }
    // end here added by ramesh.c.singh@accenture.com
}
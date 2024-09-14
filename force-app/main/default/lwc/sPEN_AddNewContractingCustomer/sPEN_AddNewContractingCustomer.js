import { LightningElement,api,wire,track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue,updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CASE_OBJECT from '@salesforce/schema/Case';
import CUSTOMER_TYPE from '@salesforce/schema/Case.SPEN_CPCustomerType__c';
import CUSTOMER_CLASS from '@salesforce/schema/Case.SPEN_CPCustomerClass__c';
import TITLE_FIELD from '@salesforce/schema/Case.SPEN_CPTitle__c';
import COMPANYID_FIELD from '@salesforce/schema/Case.SPEN_CompanyID__c';
import createSDCustomerSAP from '@salesforce/apex/SPEN_SearchContractingCustomerController.createSDCustomerSAP'
const fields = [COMPANYID_FIELD];


export default class SPEN_AddNewContractingCustomer extends LightningElement {
    @api caseRecordId;
    customerTypeValues = [];
    customerClassValues = [];
    titleValues = [];
    customerType = '';
    customerClass = '';
    title = '';
    companyName = '';
    flat = '';
    street = '';
    town = '';
    postcode = '';
    country = '';
    phone = '';
    mobile = '';
    fax = '';
    email = '';
    crn = '';
    vat = '';
    ukc1 = '';
    ukc2 = '';
    wrapperResult;
    companyId = '';

    @track showLoading = false;

    countryValues = [
        {label:'United Kingdom', value:'GB'}
    ];
    
    postcodePattern = '^([A-PR-UWYZ](([0-9](([0-9]|[A-HJKSTUW])?)?)|([A-HK-Y][0-9]([0-9]|[ABEHMNPRVWXY])?)) [0-9][ABD-HJLNP-UW-Z]{2})|([a-pr-uwyz](([0-9](([0-9]|[a-hjkstuw])?)?)|([a-hk-y][0-9]([0-9]|[abehmnprvwxy])?)) [0-9][abd-hjlnp-uw-z]{2})|null';

    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseInfo;

    @wire(getPicklistValues,
        {
            recordTypeId: '$caseInfo.data.defaultRecordTypeId',
            fieldApiName: CUSTOMER_TYPE
        }
    ) 
    wiredCustomerTypeValues({data,error}){
        if(data){
            this.customerTypeValues = data.values;
        }
    }

    @wire(getPicklistValues,
        {
            recordTypeId: '$caseInfo.data.defaultRecordTypeId',
            fieldApiName: CUSTOMER_CLASS
        }
    )
    wiredCustomerClassValues({data,error}){
        if(data){
            this.customerClassValues = data.values;
        }
    }
    //Title Values
    @wire(getPicklistValues,
        {
            recordTypeId: '$caseInfo.data.defaultRecordTypeId',
            fieldApiName: TITLE_FIELD
        }
    )
    wiredTitleValues({data,error}){
        if(data){
            this.titleValues = data.values;
        }
    }

    @wire(getRecord, { recordId: '$caseRecordId', fields })
    wiredCaseDetail({data,error}){
        if (data) {
            this.companyId = getFieldValue(data, COMPANYID_FIELD);
        } else if (error) {
            console.log('Error Occurred:--'+JSON.stringify(error));
        }
    }

    handleCustomerTypeChange(event){
        this.customerType = event.detail.value;
    }

    handleCustomerClassChange(event){
        this.customerClass = event.detail.value;
    }

    handleTitleChange(event){
        this.title = event.detail.value;
    }

    handleCompanyNameChange(event){
        this.companyName = event.detail.value;
    }

    handleFlatChange(event){
        this.flat = event.detail.value;
    }

    handleStreetChange(event){
        this.street = event.detail.value;
    }

    handleTownChange(event){
        this.town = event.detail.value;
    }

    handlePostCodeChange(event){
        this.postcode = event.detail.value;
    }

    handleCountryChange(event){
        this.country = event.detail.value;
    } 

    handlePhoneChange(event){
        this.phone = event.detail.value;
    }

    handleMobileChange(event){
        this.mobile = event.detail.value;
    }

    handleFaxChange(event){
         this.fax = event.detail.value;
    }

    handleEmailChange(event){
        this.email = event.detail.value;
    }

    handleCRNChange(event){
        this.crn = event.detail.value;
    }

    handleVATChange(event){
        this.vat = event.detail.value;
    }

    handleCancel(){
        this.dispatchEvent(new CustomEvent('handleaddnewcancel',{}));
    }

    handleConfirm(){
        const allinputFieldValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        const allComboBoxValid = [...this.template.querySelectorAll('lightning-combobox')]
        .reduce((validSoFar, inputFields) => {
            inputFields.reportValidity();
            return validSoFar && inputFields.checkValidity();
        }, true);    

        if(this.crn && this.crn.length !== 8){
            this.showToast('Error!!', 'CRN Number should be 8 digits only', 'error', 'dismissable');
            return;
        }

        if(this.vat && ((this.vat.startsWith('GB') && this.vat.length !== 11) 
        || !this.vat.startsWith('GB'))){
            this.showToast('Error!!', 'VAT should start with GB followed by 9 digits', 'error', 'dismissable');
            return;
        }

        if (allinputFieldValid && allComboBoxValid) {
            if(this.phone || this.mobile || this.email){
                this.showLoading = true;

                var caseFields = {  'Id':this.caseRecordId,
                                'spenCustomerType': this.customerType,
                                'spenCustomerClass': this.customerClass,
                                'spenTitle': this.title,
                                'spenCompanyPersonName': this.companyName,
                                'spenBuildingNameFlatNumber': this.flat,
                                'spenBuildingNumberStreet': this.street,
                                'spenTownCity': this.town,
                                'spenPostCode': this.postcode,
                                'spenCountry': this.country,
                                'spenPhoneNumber': this.phone,
                                'spenMobileNumber': this.mobile,
                                'spenFAXNumber': this.fax,
                                'spenEmailAddress': this.email,
                                'spenCRN': this.crn,
                                'spenVAT': this.vat,
                                'spenCompanyId':this.companyId 
                            };
                            console.log('caseFieldsObj---'+JSON.stringify(caseFields));
                createSDCustomerSAP({fields:caseFields})
                    .then(result=>{
                        console.log('Result208---',JSON.stringify(result));
                        var calloutResponse ='';
                        if(result){
                            this.showLoading = false;
                            this.wrapperResult = result;
                        
                            if(this.wrapperResult){
                                this.wrapperResult.forEach(wrapObj =>{
                                    if(wrapObj.ukc1 && wrapObj.ukc1 =='ERROR'){
                                        this.showToast('Error!!', wrapObj.ukc2, 'error', 'sticky');
                                        calloutResponse = 'ERROR';
                                    } else if(wrapObj.ukc1){
                                    this.ukc1 = wrapObj.ukc1;
                                    this.ukc2 = wrapObj.ukc2;
                                    calloutResponse = 'SUCCESS';
                                    }
                                });
                            }
                        
                        if(calloutResponse == 'SUCCESS'){
                            const fieldsToUpdate = {  'Id':this.caseRecordId,
                            'SPEN_CPCustomerType__c': this.customerType,
                            'SPEN_CPCustomerClass__c': this.customerClass,
                            'SPEN_CPTitle__c': this.title,
                            'SPEN_CPCompanyPersonName__c': this.companyName,
                            'SPEN_CPBuildingNameFlatNumber__c': this.flat,
                            'SPEN_CPBuildingNumberStreet__c': this.street,
                            'SPEN_CPTownCity__c': this.town,
                            'SPEN_CPPostCode__c': this.postcode,
                            'SPEN_CPCountry__c': this.country,
                            'SPEN_CPPhoneNumber__c': this.phone,
                            'SPEN_CPMobileNumber__c': this.mobile,
                            'SPEN_CPFaxNumber__c': this.fax,
                            'SPEN_CPEmailAddress__c': this.email,
                            'SPEN_CRN__c': this.crn,
                            'SPEN_VAT__c': this.vat,
                            'SPEN_UKC1ID__c': this.ukc1,
                            'SPEN_UKC2ID__c': this.ukc2 
                            };

                            const recordInput = { fields:fieldsToUpdate };
                            updateRecord(recordInput)
                            .then(() => {
                                this.showToast('Success!!', 'Contracting Customer Details updated successfully!!', 'success', 'dismissable');
                                this.showLoading = false;
                                this.dispatchEvent(new CustomEvent('handleaddconfirm',{}));
                            })
                            .catch(error => {
                                console.log('Error Occurred Update Record:--'+JSON.stringify(error));
                                this.showLoading = false;
                                this.showToast('Error!!', error.body.message, 'error', 'dismissable');
                            });
                        }
                        }
                    }).catch(error=>{
                    console.log('error=='+JSON.stringify(error)+'Error Obj--'+error);
                    this.showLoading = false;
                    this.showToast('Error!!', error, 'error', 'dismissable');
                    });
            }else {
                this.showToast('Error!!', 'Please update either a Phone Number, Mobile Number or an Email Address', 'error', 'dismissable');
            }
        }else {
        // The form is not valid
        this.showToast('Error!!', 'Check your input and try again.', 'error', 'dismissable');
        }
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }   
}
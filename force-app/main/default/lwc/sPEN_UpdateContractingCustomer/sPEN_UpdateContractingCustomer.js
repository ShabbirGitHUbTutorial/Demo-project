import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import BLOCKED_FIELD from '@salesforce/schema/Case.SPEN_CPBlocked__c';
import UKC1_FIELD from '@salesforce/schema/Case.SPEN_UKC1ID__c';
import UKC2_FIELD from '@salesforce/schema/Case.SPEN_UKC2ID__c';
import CUSTOMERCLASS_FIELD from '@salesforce/schema/Case.SPEN_CPCustomerClass__c';
import COMPANYNAME_FIELD from '@salesforce/schema/Case.SPEN_CPCompanyPersonName__c';
import FLATNUMBER_FIELD from '@salesforce/schema/Case.SPEN_CPBuildingNameFlatNumber__c';
import STREET_FIELD from '@salesforce/schema/Case.SPEN_CPBuildingNumberStreet__c';
import CITY_FIELD from '@salesforce/schema/Case.SPEN_CPTownCity__c';
import COUNTRY_FIELD from '@salesforce/schema/Case.SPEN_CPCountry__c';
import PHONENUMBER_FIELD from '@salesforce/schema/Case.SPEN_CPPhoneNumber__c';
import MOBILENUMBER_FIELD from '@salesforce/schema/Case.SPEN_CPMobileNumber__c';
import FAXNUMBER_FIELD from '@salesforce/schema/Case.SPEN_CPFaxNumber__c';
import EMAIL_FIELD from '@salesforce/schema/Case.SPEN_CPEmailAddress__c';
import CRN_FIELD from '@salesforce/schema/Case.SPEN_CRN__c';
import VAT_FIELD from '@salesforce/schema/Case.SPEN_VAT__c';
import POSTCODE_FIELD from '@salesforce/schema/Case.SPEN_CPPostCode__c';
import CUSTOMERTYPE_FIELD from '@salesforce/schema/Case.SPEN_CPCustomerType__c';
import TITLE_FIELD from '@salesforce/schema/Case.SPEN_CPTitle__c';
import COMPANYID_FIELD from '@salesforce/schema/Case.SPEN_CompanyID__c';

import updateSDCustomerSAP from '@salesforce/apex/SPEN_SearchContractingCustomerController.updateSDCustomerSAP'
const fields = [BLOCKED_FIELD,UKC1_FIELD,UKC2_FIELD,CUSTOMERCLASS_FIELD,COMPANYNAME_FIELD,FLATNUMBER_FIELD,STREET_FIELD,CITY_FIELD,COUNTRY_FIELD,PHONENUMBER_FIELD,MOBILENUMBER_FIELD,FAXNUMBER_FIELD,EMAIL_FIELD,CRN_FIELD,VAT_FIELD,POSTCODE_FIELD,CUSTOMERTYPE_FIELD,TITLE_FIELD,COMPANYID_FIELD];

export default class SPEN_UpdateContractingCustomer extends LightningElement {

    @api recordId;
    @api objectApiName;
    @track isLocked = false;
    @track blockfieldValue;
    @track showLoading = false;
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
    companyId = '';


    postcodePattern = '^([A-PR-UWYZ](([0-9](([0-9]|[A-HJKSTUW])?)?)|([A-HK-Y][0-9]([0-9]|[ABEHMNPRVWXY])?)) [0-9][ABD-HJLNP-UW-Z]{2})|([a-pr-uwyz](([0-9](([0-9]|[a-hjkstuw])?)?)|([a-hk-y][0-9]([0-9]|[abehmnprvwxy])?)) [0-9][abd-hjlnp-uw-z]{2})|null';
    phonePattern = '^0[1238][0-9]{9}$';
    mobilePattern = '[07]{2}[0-9]{9}';


    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCaseDetail({data,error}){
        if (data) {
            this.blockfieldValue = getFieldValue(data, BLOCKED_FIELD);
            if(this.blockfieldValue && this.blockfieldValue === 'Y' ){
                this.isLocked = true
            }
            this.ukc1 = getFieldValue(data, UKC1_FIELD);
            this.ukc2 = getFieldValue(data, UKC2_FIELD);
            this.customerType = getFieldValue(data, CUSTOMERTYPE_FIELD);
            this.customerClass = getFieldValue(data, CUSTOMERCLASS_FIELD);
            this.title = getFieldValue(data, TITLE_FIELD);
            this.companyName = getFieldValue(data, COMPANYNAME_FIELD);
            this.flat = getFieldValue(data, FLATNUMBER_FIELD);
            this.street = getFieldValue(data, STREET_FIELD);
            this.town = getFieldValue(data, CITY_FIELD);
            this.postcode = getFieldValue(data, POSTCODE_FIELD);
            this.country = getFieldValue(data, COUNTRY_FIELD);
            this.phone = getFieldValue(data, PHONENUMBER_FIELD);
            this.mobile = getFieldValue(data, MOBILENUMBER_FIELD);
            this.fax = getFieldValue(data, FAXNUMBER_FIELD);
            this.email = getFieldValue(data, EMAIL_FIELD);
            this.crn = getFieldValue(data, CRN_FIELD);
            this.vat = getFieldValue(data, VAT_FIELD);
            this.companyId = getFieldValue(data, COMPANYID_FIELD);
        } else if (error) {
            console.log('Update Contracting Customer Wire Error-->'+JSON.stringify(error));
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

    handleSuccess(event){
        this.showToast('Success!!', 'Contracting Customer Details  updated successfully!!', 'success', 'dismissable');
    }

    handleSubmit(event){
        // stop the form from submitting
        event.preventDefault();
        if(this.postcode && !this.postcode.match(this.postcodePattern)){
            this.showToast('Error!!', 'The post code you entered was not recognised. Please ensure you have used the correct formatting with capital letters and appropriate spacing.', 'error', 'dismissable');
            return;
        }

        if(this.phone && !this.phone.match(this.phonePattern)){
            this.showToast('Error!!', 'Phone Number should always be 11 digits long and starts with 01 or 02 or 03 or 08.', 'error', 'dismissable');
            return;
        }

        if(this.mobile && !this.mobile.match(this.mobilePattern)){
            this.showToast('Error!!', 'Mobile Number should always be 11 digits long and starts with 07.', 'error', 'dismissable');
            return;
        }

        if(this.crn && this.crn.length !== 8){
            this.showToast('Error!!', 'CRN Number should be 8 digits only', 'error', 'dismissable');
            return;
        }

        if(this.vat && ((this.vat.startsWith('GB') && this.vat.length !== 11) 
        || !this.vat.startsWith('GB'))){
            this.showToast('Error!!', 'VAT should start with GB followed by 9 digits', 'error', 'dismissable');
            return;
        }
        if(this.phone || this.mobile || this.email){
        this.showLoading = true;
        
        //get all the fields
        const fields = event.detail.fields;
        
        var caseFields = {  'Id':this.recordId,
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
                            'spenUKC1':this.ukc1,
                            'spenUKC2':this.ukc2,
                            'spenCompanyId':this.companyId
                        };
                        console.log('---Update Contract caseFields--'+JSON.stringify(caseFields));
                        
        updateSDCustomerSAP({caseInfoFields:caseFields})
            .then(result=>{
                this.showLoading = false;
                console.log('updateSDCustomerSAP Result---'+JSON.stringify(result));
                if(result == 'Success' || result.includes('Warning')){
                    if(result.includes('Warning')){
                        let warnString = result.split(':');
                        warnString = warnString[1];
                        this.showToast('Warning!!', warnString, 'warning', 'pester');
                    }
                    //submit the form
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                }else{
                    console.log('updateSDCustomerSAP ERRR---'+JSON.stringify(result));
                    this.showToast('Error!!', result, 'error', 'sticky');
                }
            }).catch(error=>{
                this.showLoading = false;
                console.log('updateSDCustomerSAP Catch error=='+JSON.stringify(error));
                this.showToast('Error!!', 'Contracting Customer Details did not updated!!', 'error', 'dismissable');
            });
        }else {
            this.showToast('Error!!', 'Please update either a Phone Number, Mobile Number or an Email Address', 'error', 'dismissable');
        }
    }      

    handleError(event){
        this.showToast('Error!!', event.detail.message, 'error', 'dismissable');
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
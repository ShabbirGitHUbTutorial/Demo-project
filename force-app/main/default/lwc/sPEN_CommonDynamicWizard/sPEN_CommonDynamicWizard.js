import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import preferredMethodofContact from '@salesforce/schema/Contact.SPEN_PreferredMethodofContact__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import getPreferredContactMethod from '@salesforce/apex/SFBG_CommonDynamicWizardService.getPreferredContactMethod';
import updatePreferredContactMethod from '@salesforce/apex/SFBG_CommonDynamicWizardService.updatePreferredContactMethod';
export default class SPEN_CommonDynamicWizard extends NavigationMixin(LightningElement) {
    @api contactId;
    selectedValueforstep1;
   
    selectedPicklistval;
    @track infoStyle = 'slds-var-m-around_large slds-wrap';
    @track currentStep;
    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactInfo;
    @track contactRecord;
    @track error;
    @track prefContactMethod;
    @track registerContactMethod;



    @wire(getPicklistValues,
        {
            recordTypeId: '$contactInfo.data.defaultRecordTypeId',
            fieldApiName: preferredMethodofContact
        }
    )
    preferredMethodValues;
    connectedCallback() {
        getPreferredContactMethod({ recordId: this.contactId })
            .then(result => {
                this.contactRecord = result;
                this.prefContactMethod = this.contactRecord.SPEN_PreferredMethodofContact__c;
                if(!this.prefContactMethod){
                    this.currentStep = '2';
                   
                }
                else{
                    this.currentStep='1';
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.contactRecord = undefined;
            });
    }

    handleOnStepClick(event) {
        this.currentStep = event.target.value;
    }

    get isStepOne() {
        console.log('this.currentstep**'+this.currentStep);
        if( this.currentStep === "1"){
            this.handleFinish();
            return true;
        }else{
            return false;
        }
    }

    get isStepTwo() {
        return this.currentStep === "2";
    }

    get isEnableNext() {
        return this.currentStep !== "2";
    }

    get isEnableFinish() {
        return this.currentStep === "2";
    }

    handleNext() {
        this.handleFinish();
    }


    handleFinish() {
        console.log('this.contactId'+ this.contactId);
        updatePreferredContactMethod({ recordId: this.contactId, selectedMethod: this.prefContactMethod })
            .then(result => {
                console.log('result'+ result);
                this.contactRecord = result;
                this.error = undefined;
                const sendContactMethodToCase = new CustomEvent("sendcontact",{
                    detail: {
                    contactRecId: this.contactRecord.Id,
                    contactMethod: this.prefContactMethod,
                    showPref : false           
                }});
                this.dispatchEvent(sendContactMethodToCase);
            })
            .catch(error => {
                this.contactRecord = undefined;
                var errormessage = JSON.stringify(error.body.message);
                this.contactRecord = undefined; 
                const event = new ShowToastEvent({
                    title: 'error',
                    message: errormessage,
                    variant: 'error',
                });
                this.dispatchEvent(event);
            });
        
    }

    get checkboxOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' },
        ];
    }

    handleSelectedVal(event) {
        this.prefContactMethod = event.detail.value;
    }
}
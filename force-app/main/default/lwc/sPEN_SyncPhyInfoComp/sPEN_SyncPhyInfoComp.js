import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendSoapCallout from '@salesforce/apex/SPEN_SAPQASCallout.sendSoapCallout';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CASE_ID from '@salesforce/schema/SPEN_PhysicalInformation__c.SPEN_Case__c';
import CASE_COMPETENT from '@salesforce/schema/SPEN_PhysicalInformation__c.SPEN_Case__r.SPEN_IsCaseCompetentInSAP__c';
const phyFields = [CASE_ID,CASE_COMPETENT];

export default class SPEN_SyncPhyInfoComp extends LightningElement {
    @api recordId;
    @track caseRecordCompetent;
    @track caseRecordId; 

    @wire(getRecord, { recordId: '$recordId', fields:phyFields })
    wiredCaseDetail({data,error}){
        if (data) {
            this.caseRecordId = getFieldValue(data, CASE_ID);
            this.caseRecordCompetent = getFieldValue(data, CASE_COMPETENT);
            
        }else if(error){
            this.showToast('Error!!', json.stringify(error), 'error', 'dismissable');
        }
    }

    @api async invoke() {
        
        if(this.caseRecordId && this.caseRecordCompetent ){
            console.log('Inside If');
            sendSoapCallout({operation:this.recordId,lstCase:this.caseRecordId})
            .then(result=>{
                this.showToast('Success!!', 'Your call has been invoked...', 'success', 'dismissable');
            }).catch(error=>{
                console.log(error);
                this.showToast('Error!!', json.stringify(error), 'error', 'dismissable');
            });
        }
        else{
            this.showToast('Error!!', 'The Case is not competent in SAP', 'error', 'dismissable');
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
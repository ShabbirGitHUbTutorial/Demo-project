import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendSoapCallout from '@salesforce/apex/SPEN_SAPGetQASCallout.sendSoapCallout';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SAP_ID from '@salesforce/schema/Case.SPEN_SAPReference__c';

const caseFields = [SAP_ID];

export default class SPEN_GetQAS extends LightningElement {
    @api recordId;
    @track sapId;
    @track error;

    @wire(getRecord, { recordId: '$recordId', fields : caseFields })
    wiredCaseDetail({data,error}){
        if (data) {
            console.log('Update Sap Wired Data----'+JSON.stringify(data));
            this.sapId = getFieldValue(data, SAP_ID);
        }else{
            this.showToast('Error!!', JSON.stringify(error), 'error', 'dismissable');
        }
    }

    @api async invoke() {
        if(!this.sapId){
            this.showToast('Error!!', 'Cannot do the callout as SAP Reference is null.', 'error', 'dismissable');
            return;
        }

        if(this.sapId){
            sendSoapCallout({sapReference : this.sapId})
            .then(result=>{
                this.showToast('Success!!', 'Your call has been invoked...', 'success', 'dismissable');
            }).catch(error=>{
                console.log('Get QAS Error---'+JSON.stringify(error));
                this.showToast('Error!!', JSON.stringify(error), 'error', 'dismissable');
            });
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
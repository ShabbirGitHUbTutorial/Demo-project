import { LightningElement,api,wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import PARENT_CASE from '@salesforce/schema/Case.ParentId';
import TRANSMISSIONSCRIPT from '@salesforce/label/c.SPEN_TransmissionScript';

const fields = [PARENT_CASE];

export default class SPEN_TransmissionScripts extends LightningElement {
    @api recordId;
    @track isParentCase = false;
    @track parentCaseId;

    infoLabel = {
        TRANSMISSIONSCRIPT
    };

    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCaseDetail({data,error}){
        if (data) {
            
            this.parentCaseId = getFieldValue(data, PARENT_CASE);
            console.log('parentCaseId--'+JSON.stringify(this.parentCaseId));

            if(this.parentCaseId){
                this.isParentCase = true;
            }else{
                this.isParentCase = false;
            }
        }else{
            console.log('Transmission Script Error-->'+JSON.stringify(error));
        }
    }


}
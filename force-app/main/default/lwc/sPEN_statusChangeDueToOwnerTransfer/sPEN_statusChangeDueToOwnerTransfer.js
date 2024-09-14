import { LightningElement, wire, api, track } from 'lwc';
import { getRecord ,updateRecord } from 'lightning/uiRecordApi';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import STATUS_FIELD from "@salesforce/schema/SPEN_MessagingTask__c.SPEN_Status__c";
import ID_FIELD from '@salesforce/schema/SPEN_MessagingTask__c.Id';
import MESSAGING_TASK_QUEUE from '@salesforce/label/c.SPEN_MessagingTaskQueue';
const FIELDS = ['SPEN_MessagingTask__c.OwnerId', 'SPEN_MessagingTask__c.SPEN_Status__c','SPEN_MessagingTask__c.Owner.Name'];
export default class SPEN_statusChangeDueToOwnerTransfer extends LightningElement {
    @api recordId;
    @track ownerChanged;
    @track statusChange;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ data, error }) {
        if (data) {
            this.ownerChanged = data.fields.Owner.displayValue;
            this.statusChange = data.fields.SPEN_Status__c.value;
            if(!MESSAGING_TASK_QUEUE.includes(this.ownerChanged) && this.statusChange === 'New'){
                 const fields = {};
                fields[STATUS_FIELD.fieldApiName] = 'In Progress';
                fields[ID_FIELD.fieldApiName] = this.recordId;
                const recordInput = { fields };
              
                  updateRecord(recordInput).then(result=>{
                   
                    }).catch(error=>{
                        this.showToastMsg("Error", error.body.message, 'error');
                    })
            }
            else if(this.ownerChanged === "Dropped Outbound Task User" && this.statusChange === "Completed"){
                this.showToastMsg("Error", 'The Requested Messaging Task got superseded by some other Messaging Task.', 'error');
            }
        }
         else if(error && error.status === 404){
             this.showToastMsg("Error", 'The Requested Messaging Task got superseded by some other Messaging Task.', 'error');
         }
         else if(error){
             this.showToastMsg("Error", error.body.message, 'error');
         }
    }

    showToastMsg(title, msg, variant){
        this.dispatchEvent(new ShowToastEvent({
            "title": title,
            "message" : msg,
            "variant" : variant
        }))
    }
}
import { LightningElement, api, wire, track } from 'lwc';
import getcallsynctoADQM from '@salesforce/apex/SPEN_SynctoADQMCallout.GetCustomerDetails';
import getContactSynctoADQMVal  from '@salesforce/apex/SPEN_SynctoADQMCallout.getContactSynctoADQMVal';
import getLastIntegrationStatus  from '@salesforce/apex/SPEN_SynctoADQMCallout.getLastIntegrationStatus';
export default class sPEN_SynctoADQM extends LightningElement {
    @api recordId;
    isDisabled = false;
    @track intRequestRecord;
    @track statusMessage;
    @track status;
    connectedCallback() {
        //console.log('in connectedCallback');
        this.statusMessage='All field values are not synced with ADQM. So kindly click on Sync ADQM button';
        getLastIntegrationStatus({
            recId: this.recordId
            })
            .then(result => {
                console.log('result : '+JSON.stringify(result));
                this.status=result;
                console.log('Status-->>'+this.status);
                if(this.status == 'Sync To ADQM Failed'){
                    this.statusMessage='Sync to ADQM failed, kindly retry the process or get in touch with Admin team for help';
                }
               /* else if(this.intRequestRecord.SPEN_Status__c == 'Sync To ADQM is Successful'){
                    this.statusMessage='All field values are not synced with ADQM. So kindly click on Sync ADQM button';
                    
                } */
                
            })
            .catch(_error => {
                console.log('error: '+JSON.stringify(_error));
            })
        
    }
    handleClick(event) {
        this.isDisabled = true;
        this.handleStatusMessage();
        console.log('in handleClick, recId : '+this.recordId);
        getcallsynctoADQM({
            recId: this.recordId
            })
            .then(result => {
                console.log('result : '+JSON.stringify(result));
                
                this.refreshComponent(event);
                
            })
            .catch(_error => {
                console.log('error: '+JSON.stringify(_error));
            })
            
    }
    refreshComponent(event){
        eval("$A.get('e.force:refreshView').fire();");
    }
    handleStatusMessage(){
        getContactSynctoADQMVal({
            recId: this.recordId
            })
            .then(result => {
                console.log('result : '+JSON.stringify(result));
                this.intRequestRecord=result;
                console.log('Status-->>'+this.intRequestRecord.SPEN_Status__c);
                if(this.intRequestRecord.SPEN_Status__c == 'Sent'){
                    this.statusMessage='Sync Process started';
                }
                else if(this.intRequestRecord.SPEN_Status__c =='Completed'){
                    this.isDisabled = true;
                } 
                else{
                    this.statusMessage='Sync to ADQM failed, kindly retry the process or get in touch with Admin team for help';
                } 
            })
            .catch(_error => {
                console.log('error: '+JSON.stringify(_error));
            })
    }
}
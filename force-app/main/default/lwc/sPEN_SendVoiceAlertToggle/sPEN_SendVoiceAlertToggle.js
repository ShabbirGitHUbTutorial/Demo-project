import { LightningElement,api, wire, track } from 'lwc';
import getDetailsForInc from '@salesforce/apex/SPEN_SendVoiceAlertCallServiceToggle.alertServiceToggle';
import getBatchJobStatus from '@salesforce/apex/SPEN_SendVoiceAlertCallService.getBatchJobStatus';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {FlowNavigationNextEvent} from 'lightning/flowSupport';//AP
export default class SPEN_SendVoiceAlert extends LightningElement {
@api availableActions = [];//AP
@api recordId;
@api template;
isBatchProcess = false;
isDisabled = false;
@api apexJob;
//@api jobStatusFlag;
@api statusFlag;
@api progress;
@api isLoaded = false;
@api isSuccessMsg;
@api isErrorMsg;
@api isErrorFlag = false;
@api IncPSRCheck;
@api IncCaseCheck;
@api IncAllCustCheck;

handleClick(event) {
    //this.isDisabled = true;
    console.log('handle click');
        //try{
            this.isDisabled = true;
            getDetailsForInc({recId: this.recordId,vcAlertTemplt: this.template,IncPSRCheckbox: this.IncPSRCheck,IncCaseCheckbox: this.IncCaseCheck,IncAllCustCheckbox: this.IncAllCustCheck})
            .then(result => {
                if(result){
                    console.log('JobId***********'+ result);
                    this.isBatchProcess = true;
                    //this.isLoaded = !this.isLoaded;
                    this._interval = setInterval(() => { 
                    getBatchJobStatus({batchJobId:  result})
                            .then(asynchrounusData => { 
                                    if(asynchrounusData){
                                        console.log('asynchrounusData***********'+ JSON.stringify(asynchrounusData));
                                        this.apexJob = asynchrounusData;
                                       // this.jobStatusFlag = (this.apexJob.JobItemsProcessed != this.apexJob.TotalJobItems)? true : false;
                                        this.statusFlag = (this.apexJob.Status  = 'Completed')?  true : false;
                                        if(this.statusFlag){
                                            this.isSuccessMsg = 'Voice Alert Sent Successfully.';
                                        }
                                        console.log('apexJob***********'+ JSON.stringify(this.apexJob));
                                        //console.log('this.jobStatusFlag***********'+  this.jobStatusFlag);
                                        console.log(' this.statusFlag***********'+   this.statusFlag);
                                        var processedPercent = 0;
                                        if(asynchrounusData.JobItemsProcessed != 0){
                                            processedPercent = (asynchrounusData.JobItemsProcessed / asynchrounusData.TotalJobItems) * 100;
                                        }
                                        this.progress === 100 ? clearInterval(this._interval) :  processedPercent;
                                    }
                            })
                            .catch(error => {
                                console.log('inner error');
                                this.isErrorFlag = true;
                                this.isErrorMsg = error;
                                this.error = error;
                            }); 
                    }, 2000); 
                } 
            })
            .catch(error => {
                console.log('Outer Error');
                this.isErrorFlag = true;
                this.isErrorMsg = error;
                this.error = error;
            });
}

handleGoNext() {
    // check if NEXT is allowed on this screen
    if (this.availableActions.find((action) => action === 'NEXT')) {
        // navigate to the next screen
        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }
}

    

}
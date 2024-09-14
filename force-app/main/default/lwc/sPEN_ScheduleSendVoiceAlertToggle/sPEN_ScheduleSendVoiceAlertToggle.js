import { LightningElement,api, wire, track } from 'lwc';
import getDetailsForIncSchedule from '@salesforce/apex/SPEN_SendVoiceAlertCallServiceToggle.scheduleAlertServiceToggle';
import PoDate from '@salesforce/schema/Order.PoDate';
import {FlowNavigationNextEvent} from 'lightning/flowSupport';//AP
export default class SPEN_ScheduleSendVoiceAlert extends LightningElement {
    @api availableActions = [];//AP
    @api recordId;
    @api template;
    @api scheduleDate;
    @api isSuccessMsg;
    @api isErrorMsg;
    @api isErrorFlag = false;
    @api isSuccessFlag = false;
    @track isDisabled = false;
    @api IncPSRCheck;
    @api IncCaseCheck;
    @api IncAllCustCheck;

    handleChange(event) {
        let dte = event.target.value;
        //this.scheduleDateForPSRs = dte.replace('T', ' ');
        this.scheduleDateForInc = dte;
    }

    handleClick(event) {
        this.isDisabled = true;
        console.log('handle click');
        console.log('scheduleDateForInc'+this.scheduleDateForInc);
        //let replacedDte = this.scheduleDateForPSRs.replace('T', ' ');
        //console.log('replacedDte: '+this.replacedDte);

        //let selectedDte = new Date(this.scheduleDateForPSRs);
        //console.log('Today: '+selectedDte);
        //scheduleDate = new Date(this.scheduleDate);
        //console.log('Converted: '+new Date(this.scheduleDateForPSRs));
        //let dd = String(selectedDte.getDate()).padStart(2, '0');
        //let mm = String(selectedDte.getMonth()+1).padStart(2, '0');
        //let yyyy = selectedDte.getFullYear();

        //selectedDte = dd + '-' +mm + '-'+yyyy;
        //console.log('selectedDte: '+selectedDte);

                getDetailsForIncSchedule({recId: this.recordId,
                                           vcAlertTemplt: this.template, 
                                           scTime: this.scheduleDateForInc,
                                           IncPSRCheckbox: this.IncPSRCheck,
                                           IncCaseCheckbox: this.IncCaseCheck,
                                           IncAllCustCheckbox: this.IncAllCustCheck})
                    .then(scheduleFlag => { 
                        console.log('scheduleFlag*****'+ scheduleFlag);
                            if(scheduleFlag){
                                this.isSuccessFlag = true;
                                this.isSuccessMsg = 'Voice Alert Scheduled Successfully';
                            }
                    })
                    .catch(error => {
                        console.log('Outer Error'+ JSON.stringify(error.body));
                        this.isErrorFlag = true;
                        this.isErrorMsg = JSON.stringify(error.body.message);
                        this.error = error;
                    });

               // console.log('recordids: '+this.recordIds);
               // console.log('template: '+this.template);
                //console.log('selectedDte: '+JSON.stringify(JSON.parse(selectedDte)));
                //console.log('selectedDte: '+selectedDte);
            
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
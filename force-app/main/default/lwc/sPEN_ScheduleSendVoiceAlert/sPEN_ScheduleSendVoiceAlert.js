import { LightningElement,api, wire, track } from 'lwc';
import getDetailsForPSRsSchedule from '@salesforce/apex/SPEN_SendVoiceAlertCallService.scheduleAlertService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PoDate from '@salesforce/schema/Order.PoDate';
export default class SPEN_ScheduleSendVoiceAlert extends LightningElement {
    @api recordIds;
    @api template;
    @api scheduleDate;
    @track dateErrorMsg;
    @track isDisabled = false; 

    handleChange(event) {
        let dte = event.target.value;
        this.scheduleDateForPSRs = dte;
    }

    handleClick(event) 
    {

        console.log('handle click');
        console.log('scheduleDateForPSRs'+this.scheduleDateForPSRs);

        getDetailsForPSRsSchedule({recId: this.recordIds,vcAlertTemplt: this.template,scTime: this.scheduleDateForPSRs})
        .then(result => 
            { 
                console.log(result);   
                if(result)
                {
                    const errorToast = new ShowToastEvent
                    ({
                        title: "Error getting questionnaire!",
                        message: "Schedule time is not within Defined outbound contact hours",
                        variant: "error",
                        mode: "pester"
                    });
                    this.dispatchEvent(errorToast);
                    console.log('recordids: '+this.recordIds);
                    console.log('template: '+this.template);
                }
            })
            .catch(error => 
            {
                console.log(error);
                console.log(error.body.message);
            });

    }
    
}
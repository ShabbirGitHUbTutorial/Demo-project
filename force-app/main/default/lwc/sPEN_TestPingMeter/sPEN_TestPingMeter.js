import { LightningElement,api, wire, track } from 'lwc';
import getDetailsForMPAN from '@salesforce/apex/SPEN_TestSmartMeterConnService.getMPANDetails';
import getPingTimedOut from '@salesforce/apex/SPEN_TestSmartMeterConnService.getPingValue';
import getMeterDetails from '@salesforce/apex/SPEN_TestSmartMeterConnService.fetchMpanDetails';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class SPEN_TestPingMeter extends LightningElement {
    @api recordId;
    @track isDisabled = false;
    @track mpanRecord;
    @track pingValue;
    @track error;
    @track isLoading = false;
    progress = 0;
    isProgressing = false;
    count = 0;

    connectedCallback(){
        this.getButtonVisibility();
    }
    
	handleClickForDetails(){
        getMeterDetails({ recId: this.recordId }).then(result=>{
			setTimeout(()=>{
                eval("$A.get('e.force:refreshView').fire();");
                this.getButtonVisibility();
																		
            }, 2000);

        }).catch(error=>{
            this.showToastMsg("Error", error.body.message, 'error');
        });
    }

    handleClick(){
        this.isDisabled = true;
        getDetailsForMPAN({ recId: this.recordId });
        let interval = setInterval(()=>{
            this.count++;
            if(this.count === 61){
                this.count = 0;
                getPingTimedOut({recId : this.recordId}).then(result=>{
                    this.isDisabled = false;
					eval("$A.get('e.force:refreshView').fire();");
                    
                    if(result && (result.SPEN_PingResultFormula__c === 'Timed-Out')){
                        clearInterval(interval);
                        this.showToastMsg("Timeout", "Ping meter Timeout!!", 'success');
                    }
                    else{
                        clearInterval(interval);
                    }
                }).catch(error=>{
                    this.showToastMsg("Error", error.body.message, 'error');
                });
            }
        },1000);
    }
    
    // to check the button visibility based on condition
	
    getButtonVisibility(){
        getPingTimedOut({recId : this.recordId}).then(result=>{
            if(result && (result.SPEN_DCCServiceFlag__c === 'A')){
                this.isDisabled = false;
            }
            else{
                this.isDisabled = true;
            }
        }).catch(error=>{
            this.showToastMsg("Error", error.body.message, 'error');
        })
    }
    showToastMsg(title, msg, variant){
        this.dispatchEvent(new ShowToastEvent({
            "title": title,
            "message" : msg,
            "variant" : variant
        }))
    }

}
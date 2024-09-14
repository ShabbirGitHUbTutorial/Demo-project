import { LightningElement,api, wire, track } from 'lwc';
import CheckIncident from '@salesforce/apex/SPEN_ActiveIncidentCheck.fetchIncidentRecValue';
import IntegrationReuestrecord from '@salesforce/apex/SPEN_ActiveIncidentCheck.GetIntegrationRequestRecord';
import CustomSetTimeOut from '@salesforce/label/c.SPEN_IncidentCheckCustomSetTimeOut';
import { ShowToastEvent } from "lightning/platformShowToastEvent";             

export default class SPEN_IncidentCheck extends LightningElement {
    @api recordId;
    @track isDisabled = false;
    @track error;
    @track resultjson = [];
    IntRecID ='';
    VoicecallRec = [];

    handleClickForDetails(){
        console.log('Record ID Check', this.recordId);
        this.isDisabled = true;
        CheckIncident({ recId: this.recordId }).then(result=>{
                console.log('Record ID' ,JSON.stringify(result));
            for(let key in result){
                console.log('mapKey Key',key);
                this.IntRecID = key;
                console.log('mapKey value',result[key]);
                this.VoicecallRec = result[key];
                this.resultjson.push({value:result[key]})
            }
            
                        
        }).catch(error=>{
            if(error){
           this.showToastMsg("Error", error.body.message, 'error');
        
            }

        });
         
    setTimeout(()=>{
        if(this.IntRecID!='')
        {
            IntegrationReuestrecord ({ IntRecID: this.IntRecID,VoicecallRec:this.VoicecallRec}).then(result=>{
                console.log('Record ID---->' ,result);
                this.showToastMsg("Incident Check has been Completed, Please check the Related Incident value for any available incident",result,'success');
                eval("$A.get('e.force:refreshView').fire();");
            }).catch(error=>{
                if(error){
                this.showToastMsg("Error", error.body.message, 'error');
                }
            });
        }
        else
        {
            this.showToastMsg("Incident Check has been Completed, Please check the Related Incident value for any available incident","",'success');
            eval("$A.get('e.force:refreshView').fire();");
        }
    }, CustomSetTimeOut);         
}
    showToastMsg(title, msg, variant){
        this.dispatchEvent(new ShowToastEvent({
            "title": title,
            "message" : msg,
            "variant" : variant
        }))
    }
}
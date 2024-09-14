import { CurrentPageReference } from 'lightning/navigation';
import { LightningElement, api,wire } from 'lwc';
import getListViewFilterQuery from '@salesforce/apex/SPEN_PremiseCommunicationFlowHandler.getListViewFilterQuery';
import getListViewDetails from '@salesforce/apex/SPEN_PremiseCommunicationFlowHandler.getListViewDetails';
import PlannedOutageErrorMessage from '@salesforce/label/c.SPEN_PlannedOutageErrorMessage';
import PremiseListViewNames from '@salesforce/label/c.SPEN_PremiseListViewNames';
export default class SPEN_InvokePremiseCommunicationFlow extends LightningElement {
    filterId;
    launchFlow = false;
    errorMsg;
    isSpinner=false;
    get flowInputVariables() {
        return [
		{
			name: "SPEN_ListViewFilterQuery",
			type: "String",
			value: this.listViewQuery
		}];
    }
	@api initFunction(){
        this.isSpinner =true;
        this.filterId = window.location.toString().split('=')[1];
        if(typeof this.filterId != 'undefined' && this.filterId != 'undefined' && this.filterId != null){
            if(this.filterId == 'Recent'){
                this.errorMsg = PlannedOutageErrorMessage;
                this.launchFlow = false;
                this.isSpinner = false;
            }else
                this.checkValidations();
        }else{
            this.isSpinner = false;
            this.errorMsg = PlannedOutageErrorMessage;
            this.launchFlow = false;
        }
        
    }
    connectedCallback() {
       
    }
    renderedCallBack(){

    }
    checkValidations(){
        if(typeof this.filterId != 'undefined' && this.filterId != 'undefined' && this.filterId != null){
            eval("$A.get('e.force:refreshView').fire();");
            var listViewNames = PremiseListViewNames.split(',');
            getListViewDetails({
                'filterId': this.filterId
            }).then((response) =>{
                if(response.SobjectType == 'SPEN_Premise__c' && listViewNames.indexOf(response.Name ) != -1){
                    this.getListViewFilterQuery();
                    
                }else{
                    this.isSpinner = false;
                    this.errorMsg = PlannedOutageErrorMessage;
                    this.launchFlow = false;
                }
            })
        }else{
            this.isSpinner = false;
            this.errorMsg = PlannedOutageErrorMessage;
            this.launchFlow = false;
        }
       
    }
    getListViewFilterQuery() {
        getListViewFilterQuery({
            'filterId': this.filterId
        }).then((response) => {
            var temp = response.split('ORDER BY')[0];
            temp = temp.split('WHERE')[1];

            this.listViewQuery = temp;
            this.isSpinner = false;
            this.launchFlow = true;
        }).catch(error => {
            this.isSpinner = false;
            console.error('error in getListViewFilterQuery', error);
        });
    }
    handleFlowStatusChange(event) {
		if(event.detail.status == 'FINISHED')
            location.reload();
        
	}
}
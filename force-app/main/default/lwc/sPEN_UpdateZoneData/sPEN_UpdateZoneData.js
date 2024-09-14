import { LightningElement, track } from 'lwc';
import getZoneDetails from '@salesforce/apex/SPEN_UpdateZoneDataController.updateZoneRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
export default class SPEN_UpdateZoneData extends NavigationMixin(LightningElement) {

    isSuccess = false;
    isDefaultMessage = true;
    isDisabled = false;
    isBack = false;

    handleClick(event) {
        console.log('handle click');
        getZoneDetails({})
        .then(result => {
            console.log('result:',result);
            if(result){
                console.log('within true block');
                this.isSuccess = true;
                this.isDefaultMessage = false;
                this.isDisabled = true;
                this.isBack = true;
            }else{
                console.log('within false block');
                this.isSuccess = false;
                this.isDefaultMessage = false;
                this.isBack = true;
            }
        })
        .catch(error => {
            console.log('within error block');
            const evt = new ShowToastEvent({
                title: 'error',
                message: 'Some error has occurred!',
                variant: 'Info',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
        });
        console.log('get Zone Details method is called');      
    }

    // Navigation to Zone List view(recent)
    navigateToAccountListView() {
        console.log('navigateToAccountListView');
        window.history.back();
        /*this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'SPEN_Zone__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            },
        });*/
    }
    
}
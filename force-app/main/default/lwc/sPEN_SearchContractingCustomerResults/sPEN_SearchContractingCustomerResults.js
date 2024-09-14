import { LightningElement, api, track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSearchbyUKC from '@salesforce/apex/SPEN_SearchContractingCustomerController.getSearchbyUKC';

export default class SPEN_SearchContractingCustomerResults extends LightningElement {
    @api caseRecordId;
    @api searchResult;

    @track searchResultColumns = [
        { label: 'UKC1', fieldName: 'ukc1',sortable: false},
        { label: 'UKC2', fieldName: 'ukc2',sortable: false},
        { label: 'BLOCKED', fieldName: 'block',sortable: false},
        { label: 'COMPANY NAME', fieldName: 'companyName',sortable: false},
        { label: 'ADDRESS', fieldName: 'address',sortable: false },
        { label: 'PHONE NUMBER', fieldName: 'phoneNumber', type: 'phone',sortable: false},
        { label: 'EMAIL ADDRESS', fieldName: 'email', type: 'email',sortable: false },
        { label: 'VAT', fieldName: 'vat',sortable: false },
        { label: 'CRN', fieldName: 'crn',sortable: false}
    ];

    @track error;
    @track data ;
    @track disableCheckBox = false;
    @track addNewButton = false;
    @track submitButton = true;
    @track showResultScreen = true;
    @track addNewButtonStyle = 'addNewEnable';
    @track submitButtonStyle = 'submitDisable';
    @track caseWrapperObj;
    @track showLoading = false;
    @track matchedUKC;

    
    getSelectedName(event) {
        const selectedRows = event.detail.selectedRows;
        if(selectedRows && selectedRows.length > 1){
            this.addNewButton = true;
            this.submitButton = true;
            this.showToast('Error!!', 'You can only select one row at a time.', 'error', 'dismissable');
            return;
        }else if(selectedRows && selectedRows.length == 1){
            this.addNewButton = true;
            this.submitButton = false;
            this.addNewButtonStyle = 'addNewDisable';
            this.submitButtonStyle = 'submitEnable';
            
            // Display that fieldName of the selected rows
            for (let i = 0; i < selectedRows.length; i++) {
                console.log('You selected Row: ' + JSON.stringify(selectedRows));
                this.matchedUKC = selectedRows[i].ukc1;
                var caseWrapper = {
                    caseRecordId: this.caseRecordId,
                    ukc1: selectedRows[i].ukc1,
                    ukc2: selectedRows[i].ukc2,
                    block: selectedRows[i].block,
                    companyName: selectedRows[i].companyName,
                    address: selectedRows[i].address,
                    phoneNumber: selectedRows[i].phoneNumber,
                    email: selectedRows[i].email,
                    vat: selectedRows[i].vat,
                    crn: selectedRows[i].crn,
                    postcode: selectedRows[i].postcode
                };
                this.caseWrapperObj = JSON.stringify(caseWrapper);
            }
        }
    }

    handleAddNew(event){
        this.showResultScreen = false;
        this.dispatchEvent(new CustomEvent('handleaddnew',{}));
    }

    handleSubmit(event){
        this.showLoading = true;
        getSearchbyUKC({caseRecord:this.caseWrapperObj})
        .then(()=>{
            console.log('getSearchbyUKC---');
            this.showToast('Success!!', 'Contracting Customer Details updated successfully!!', 'success', 'dismissable');
            this.showLoading = false;
            this.dispatchEvent(new CustomEvent('handlesubmitclick',{}));
            
        }).catch(error=>{
            console.log('Search Contracting Result error =='+JSON.stringify(error));
            this.showToast('Error!!Contracting Customer Details did not updated!!', error.body.message, 'error', 'dismissable');
            this.showLoading = false;
        });

    }

    handleCancel(event){
        this.dispatchEvent(new CustomEvent('handlecancelclick',{}));
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }   
}
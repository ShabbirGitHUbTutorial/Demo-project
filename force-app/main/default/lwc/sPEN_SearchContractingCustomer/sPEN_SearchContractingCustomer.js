import { LightningElement,track,api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import getSearchData from '@salesforce/apex/SPEN_SearchContractingCustomerController.getSearchData';
import getSearchbyQAS from '@salesforce/apex/SPEN_SearchContractingCustomerController.getSearchbyQAS';
import checkQASValue from '@salesforce/apex/SPEN_SearchContractingCustomerController.checkQASValue';
import updateCase from '@salesforce/apex/SPEN_SearchContractingCustomerController.updateCase';
let i = 0;
export default class SPEN_SearchContractingCustomer extends LightningElement {
    @api recordId;
    @track companyName = '';
    @track phone = '';
    @track building = '';
    @track mobile = '';
    @track vat = '';
    @track postcode = '';
    @track email = '';
    @track street = '';
    @track fax = '';
    @track crn = '';
    @track showSearchResult = false;
    @track showSearchScreen = true;
    @track showAddNewCustomer = false;
    activeSections = ['searchBody'];
    @track searchParam;
    @track searchResult;
    @track showLoading = false;
    disableValue = true;
    holderText = 'Press the refresh button';
    @track items = [];
    
    //getter property from statusOptions wich return the items array
    get statusOptions() {
        this.items = JSON.parse(JSON.stringify(this.items));
        return this.items;
    }

    handleCustomerSelection(event) {
        this.showLoading = true;
        var foundCustomer = event.detail.value;
        var holdSearchResult = this.searchResult;
        this.selectedCustomer = holdSearchResult.find(element => element.ukc1 === foundCustomer);
        var caseWrapper = {
            caseRecordId: this.recordId,
            ukc1: this.selectedCustomer.ukc1,
            ukc2: this.selectedCustomer.ukc2,
            block: this.selectedCustomer.block,
            companyName: this.selectedCustomer.companyName,
            address: this.selectedCustomer.address,
            phoneNumber: this.selectedCustomer.phoneNumber,
            email: this.selectedCustomer.email,
            vat: this.selectedCustomer.vat,
            crn: this.selectedCustomer.crn,
            postcode: this.selectedCustomer.postcode,
            mobileNumber: this.selectedCustomer.mobileNumber,
            faxNumber: this.selectedCustomer.faxNumber,
            country: this.selectedCustomer.country,
            customerClass: this.selectedCustomer.customerClass,
            customerType: this.selectedCustomer.customerType,
            title: this.selectedCustomer.title,
            city: this.selectedCustomer.city,
            flatNumber: this.selectedCustomer.flatNumber
        };
        var caseWrapperObj = JSON.stringify(caseWrapper);

        updateCase({caseRecord: caseWrapperObj})
        .then(()=>{
            this.showLoading = false;
            notifyRecordUpdateAvailable([{recordId: this.recordId}]);
            this.showToast('Success!!', 'Contracting Customer Details updated successfully!!', 'success', 'dismissable');
            
        }).catch(error=>{
            this.showToast('Error!!', 'Contracting Customer Details did not updated!!', 'error', 'dismissable');
            this.showLoading = false;
        });
    }

    handleClickSearch() {
        this.showLoading = true;
        this.items = [];
        
        checkQASValue({caseRecordId:this.recordId})
        .then(result=>{
            console.log('Search Result-->'+JSON.stringify(result));
            if(result == 'ACCEXISTWITHSAP'){
                
                getSearchbyQAS({caseRecordId:this.recordId})
                .then(result=>{
                    console.log('getSearchbyQAS---'+JSON.stringify(result));
                    this.showLoading = false;
                    this.searchResult =result;
                    if(result.length == 0){
                        this.disableValue = true;
                        this.holderText = 'No records for this Account from SAP';
                    }
                    else{
                        for (i = 0; i < result.length; i++) {
                            var selectingLabel = result[i].companyName + ' - ' + result[i].address;
                            this.items = [...this.items, { value: result[i].ukc1, label: selectingLabel }];
                        }
                        this.disableValue = false;
                        this.holderText = 'Please select a record';
                    }
                }).catch(error=>{
                    console.log('GetSearch error=='+JSON.stringify(error));
                    this.showLoading = false;
                    this.showToast('Error!!', error, 'error', 'dismissable');
                });
            }
            else{
                if(result == 'NOACCEXIST'){
                    this.showLoading = false;
                    this.disableValue = true;
                    this.holderText = 'Please select an Account on Case';
                    this.showToast('Error!!', 'Please select an Account on Case', 'error', 'dismissable');
                }
                else{
                    this.showLoading = false;
                    this.disableValue = true;
                    this.holderText = 'No QAS Exist under Account';
                    this.showToast('Error!!', 'No QAS Exist for any Cases under Selected Account', 'error', 'dismissable');
                }
            }
        }).catch(error=>{
            console.log('Check QAS error==>'+JSON.stringify(error));
            this.showLoading = false;
            this.showToast('Error!!', error, 'error', 'dismissable');
        });        
    }

    handleNameChange(event){
        this.companyName = event.detail.value;
    }

    handlePhoneChange(event){
        this.phone = event.detail.value;
    }

    handleBuildingChange(event){
        this.building = event.detail.value;
    }

    handleMobileChange(event){
        this.mobile = event.detail.value;
    }

    handleVATChange(event){
        this.vat = event.detail.value;
    }

    handlePostCodeChange(event){
        this.postcode = event.detail.value;
    }

    handleEmailChange(event){
        this.email = event.detail.value;
    }

    handleStreetChange(event){
        this.street = event.detail.value;
    }

    handleFAXChange(event){
        this.fax = event.detail.value;
    }

    handleCRNChange(event){
        this.crn = event.detail.value;
    }

    handleClear(event){
        this.companyName = '';
        this.phone = '';
        this.building = '';
        this.mobile = '';
        this.vat = '';
        this.postcode = '';
        this.email = '';
        this.street = '';
        this.fax = '';
        this.crn = '';
    }

    handleSearch(event){
        this.showLoading = true;
        const allinputFieldValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        if (allinputFieldValid) {
            this.searchParam = {
                'companyName' : this.companyName,
                'phone' : this.phone,
                'building' : this.building,
                'mobile' : this.mobile,
                'vat' : this.vat,
                'postcode' : this.postcode,
                'email' : this.email,
                'street' : this.street,
                'fax' : this.fax,
                'crn' : this.crn
            }
            
            getSearchData({searchParam:this.searchParam})
            .then(result=>{
                console.log('GetSearch Data---'+JSON.stringify(result));
                this.searchResult = result;
                this.showLoading = false;
                const accordion = this.template.querySelector('.searchAccordion');
                accordion.activeSectionName = '';
                this.showSearchResult = true;
            }).catch(error=>{
                console.log('error=='+JSON.stringify(error));
                this.showLoading = false;
                this.showToast('Error!!', error.body.message, 'error', 'dismissable');
            });
        }else{
            this.showLoading = false;
            this.showToast('Error!!', 'Check your input and try again.', 'error', 'dismissable');
        }
    }
    
    hideSearchScreen(event){
        this.showSearchScreen = false;
        this.showAddNewCustomer = true;
    }

    handleshowSearchScreen(event){
        this.showSearchResult = false;
        this.showAddNewCustomer = false;
        this.showSearchScreen = true;
        notifyRecordUpdateAvailable([{recordId: this.recordId}]);
    }

    hideAddNewSearch(event){
        
        this.showSearchResult = false;
        this.showAddNewCustomer = false;
        this.showSearchScreen = true;
    }

    hideSearchResults(event){
        
        this.showSearchResult = false;
        this.showAddNewCustomer = false;
        this.showSearchScreen = true;
        const accordion = this.template.querySelector('.searchAccordion');
        accordion.activeSectionName = ['searchBody'];
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
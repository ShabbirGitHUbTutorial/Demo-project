/* File Name: sPEN_DesignChecklistlwc 
 * Description: Component for Design Checklist
 * Author: Rajat Kumar Mishra
 * Version: 1.0
 * History:
 * Date            Author                 Comment
 * Oct-26-2023     Rajat Kumar Mishra     Initial version
 *
 */
import { LightningElement, api, wire, track } from 'lwc';
import getDCRList from '@salesforce/apex/SPEN_DesignChecklistController.getDCRList';
import getDCR from '@salesforce/apex/SPEN_DesignChecklistController.getDCR';
import getDIListRelatedToDCR from '@salesforce/apex/SPEN_DesignChecklistController.getDesignInformationsRelatedToDCR';
import getIsExternalUser from '@salesforce/apex/SPEN_DesignChecklistController.isExternalUser';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import { updateRecord } from "lightning/uiRecordApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import WORK_CATEGORYID from "@salesforce/schema/SPEN_Job__c.SPEN_WorkCategory__c";
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import SPEN_DESIGN_INFO from "@salesforce/schema/SPEN_DesignInformation__c";
import COMPLETED_STATUS from '@salesforce/schema/SPEN_DesignInformation__c.SPEN_CompletedStatus__c';

let i=0;

const columns=[
    {label: 'Group', fieldName: 'SPEN_DesignCategory__c', editable:false},
    {label: 'Design Information Detail', fieldName: 'SPEN_DesignInformationDetail__c', editable:false,wrapText:true},
    {label: 'Business Area Owner', fieldName: 'SPEN_BusinessAreaOwner__c', editable:true},  
    {label: 'Completed Status', fieldName: 'SPEN_CompletedStatus__c', type: 'picklistColumn', editable: true, typeAttributes: {
        placeholder: 'Choose Type', options: { fieldName: 'pickListOptions' }, 
        value: { fieldName: 'SPEN_CompletedStatus__c' } // default value for picklist
    }},
    {label: 'Completion Date', fieldName: 'SPEN_CompletionDate__c',editable:true, type: "date-local",
    typeAttributes:{
        month: "2-digit",
        day: "2-digit"
    }},
    {label: 'Comments', fieldName:'SPEN_Comments__c', editable:true}
  ];

  const fields = [WORK_CATEGORYID];

export default class SPEN_DesignChecklistlwc extends LightningElement {
    @api recordId;
    draftValues = [];
    columns = columns;
    @track selectedDCRId;
    @track selectedCategory;
    @track items = [];
    @track dCatagoryOptions = [];
    @track totalDesignInformation;
    @track completedDesignInformation;
    @track designCompletion;
    @track designChecklistRequestId;
    @track error;
    @track columns = columns;
    @track dIlist;
    @track dIlistdraft;
    @track record;
    @track workCategoryId;
    @track isDisableChecklist = false;
    @track renderFlow = false;
    clickedButtonLabel;
    @track statuspickListOptions=[];
 
    @wire(getObjectInfo, { objectApiName: SPEN_DESIGN_INFO })
    objectInfo;
 
    //fetch picklist options
    @wire(getPicklistValues, {
        recordTypeId: "$objectInfo.data.defaultRecordTypeId",
        fieldApiName: COMPLETED_STATUS
    })
 
    wirePickList({ error, data }) {
        if (data) {
            this.statuspickListOptions = data.values;
            this.fetchDesignInfo();
    }
}
    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
 
        //write changes back to original data
        this.data = [...copyData];
    }
 
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
 
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }
 
    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        //this.updateDraftValues(event.detail.draftValues[0]);
        let draftValues = event.detail.draftValues;
        draftValues.forEach(ele=>{
            this.updateDraftValues(ele);
        })
    }
 
    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;
 
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            console.log('fields', fields);
            return { fields };
        });
        if(fields.SPEN_CompletedStatus__c != 'Yes' || (fields.SPEN_CompletedStatus__c === 'Yes' && fields.SPEN_CompletionDate__c != null )){
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.draftValues = [];
            this.refreshRecordView();
           
        }).catch(error => {
            console.log(error);
            this.showToast('Error', 'Completion Date should be provided while making design information completion status Yes', 'error', 'dismissable');
        }).finally(() => {
            //this.draftValues = [];
            this.showSpinner = false;
        });
    }
    }
 
    handleCancel(event) {
        //remove draftValues & revert data changes
        this.lastSavedData = JSON.parse(JSON.stringify(this.dIlist));
        this.draftValues = [];
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
    @wire(getRecord, {
        recordId: "$recordId",
        fields
      })
      job;

    get workCategory(){
        return getFieldValue(this.job.data, WORK_CATEGORYID);
        
    }

    connectedCallback(){
        getIsExternalUser()
        .then(result => {
            this.isDisableChecklist = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.contacts = undefined;
        });
    }

    @wire(getDCRList, { jobId: '$recordId'})
    wiredDesignChecklistRequest({ error, data }) {
        if (data) {
            for(i=0; i<data.length; i++) {
                this.items = [...this.items ,{value: data[i].Id , label: data[i].Name}];  
                this.isDisableChecklist = true;  
            }   
            this.selectedDCRId = data[0].Id;
           
        getDCR({dcrId: this.selectedDCRId })
		.then(result => {
			this.record = result;
            this.totalDesignInformation = this.record.SPEN_TotalDesignInformation__c;
            this.completedDesignInformation = this.record.SPEN_CompletedDesignInformation__c;
            if(this.record.SPEN_DesignCompletion__c != null){
            this.designCompletion = this.record.SPEN_DesignCompletion__c + '%';
            }else
            this.designCompletion = this.record.SPEN_DesignCompletion__c;
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			this.record = undefined;
		}) 
        this.selectedCategory = ''; 
        this.fetchDesignInfo();             
        } else if (error) {
            this.error = error;
            this.designChecklistRequest = undefined;
        }
    }
    
    handleEnableChecklist(event) {
        this.clickedButtonLabel = event.target.label;
    }

    get designChecklistRequestoptions() {
        return this.items;
    }

    get designCatagoryoptions() {
        return this.dCatagoryOptions;
    }

    handleChangeDCR(event) {
        // Get the string of the "value" attribute on the selected option
        const selectedOption = event.detail.value;
        this.selectedDCRId= selectedOption;       
        getDCR({dcrId: this.selectedDCRId })
		.then(result => {
			this.record = result;
            this.totalDesignInformation = this.record.SPEN_TotalDesignInformation__c;
            this.completedDesignInformation = this.record.SPEN_CompletedDesignInformation__c;
            if(this.record.SPEN_DesignCompletion__c != null){
                this.designCompletion = this.record.SPEN_DesignCompletion__c + '%';
                }else
                this.designCompletion = this.record.SPEN_DesignCompletion__c;
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			this.record = undefined;
		})
        this.selectedCategory = ''; 
        this.fetchDesignInfo();         
       
    }

    handleChangeCategory(event) {
        // Get the string of the "value" attribute on the selected option
        const selectedOption = event.detail.value;
        this.selectedCategory= selectedOption;                       
        this.fetchDesignInfo();
        this.handleCancel();
    }

    @track inputVariables = [];
    handleEnableChecklist(event){

        this.inputVariables = [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            },{
                name: 'SPEN_WorkCategoryId',
                type: 'String',
                value: this.workCategory
            },
        ];
        this.renderFlow = true;
    }

    handleStatusChange(event){
        if (event.detail.status === 'FINISHED_SCREEN') {
            const outputVariables = event.detail.outputVariables;
            for (let i = 0; i < outputVariables.length; i++) {
            const outputVar = outputVariables[i];
                if (outputVar.name == 'SPEN_DesignChecklistCreatedRecord') {
                    if (outputVar.value != null) {
                        this.fireSuccessToast();
                        } else {
                        this.fireWarningToast();
                    }
                    
                    } 
                }
            //Hide the Flow again
            this.renderFlow = false;
        }
    }

    fireSuccessToast(){
        const evt = new ShowToastEvent({
            title: "Success",
            message: 'Record created successfully!!!',
            variant: "success",
        });
        this.dispatchEvent(evt);
        this.refreshRecordView();
    }

    fireWarningToast(){
        const evt = new ShowToastEvent({
            title: "Warning",
            message: 'Design checklist cannot be created as there is no Design Information associated with Work Category!!',
            variant: "warning",
        });
        this.dispatchEvent(evt);
    }
    
    refreshRecordView() {
        setTimeout(() => {
            window.location.reload(); 
        }, 1000); 
     }

     fetchDesignInfo(){
        getDIListRelatedToDCR({ designChecklistRecId: this.selectedDCRId, designCategory: this.selectedCategory})
        .then(result => {
            let options = [];
            if(this.selectedCategory == null || this.selectedCategory == ''){
                this.dCatagoryOptions =[{value: '' , label: 'All', selected: true}]; 
            }
            for(var key in this.statuspickListOptions){
                options.push( {label: this.statuspickListOptions[key].label, value:this.statuspickListOptions[key].value});
            }
            this.dIlist = result.map((record )=>{ 
               if(this.selectedCategory == null || this.selectedCategory == ''){                   
                        this.addCategoryOption(record.SPEN_DesignCategory__c);
                }                              
                return{
                    ...record,
                    'pickListOptions': options
                }
            });            
            return refreshApex(this.dIlist); 
            this.error = undefined;
            
        })
        .catch(error => {
			this.error = error;
			this.dIlist = undefined;
		})
     }  

     addCategoryOption(categoryStr){
        let newCategory = true;
            for(var key in this.dCatagoryOptions){
                if( this.dCatagoryOptions[key].label == categoryStr){
                    newCategory = false;
                }                
            }
            if(newCategory){
                this.dCatagoryOptions = [...this.dCatagoryOptions ,{value: categoryStr , label: categoryStr}];     
            }
     }
}
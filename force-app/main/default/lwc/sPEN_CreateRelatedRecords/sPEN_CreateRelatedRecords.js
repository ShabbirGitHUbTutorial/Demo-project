import { LightningElement,track,api,wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import CASE_NUMBER from '@salesforce/schema/Case.CaseNumber';
import RELATED_PROJECT from '@salesforce/schema/SPEN_RelatedProject__c';
import RELATED_STAGE from '@salesforce/schema/SPEN_RelatedProject__c.SPEN_Stage__c';
import RELATED_TYPE from '@salesforce/schema/SPEN_RelatedProject__c.SPEN_Type__c';
import RELATED_QUEUE from '@salesforce/schema/SPEN_RelatedProject__c.SPEN_QueuePosition__c';
import RELATED_RELATION from '@salesforce/schema/SPEN_RelatedProject__c.SPEN_Relationship__c';
import findRecords from '@salesforce/apex/SPEN_CaseSelector.findRecords';
import insertRelatedRecord from '@salesforce/apex/SPEN_CreateRelatedRecordsController.insertRelatedProject';
const caseFields = [CASE_NUMBER];
export default class SPEN_CreateRelatedRecords extends LightningElement {

    @api recordId;
    @track records;
    @track errors;
    @track caseWrapperObj;
    @track showLoading = false;
    searchVal = '';
    parentCaseNumber;
    searchResult = [];
    stageValues = [];
    typeValues = [];
    queueValues = [];
    relationshipValues = [];
    stageVal = '';
    typeVal = '';
    queueVal = '';
    relationVal = '';
    queueEnable = true;
    noResult = false;

    @track searchResultColumns = [
        { label: 'Case Number', fieldName: 'CaseNumber',sortable: false},
        { label: 'Contract Reference Number', fieldName: 'SPEN_ContractReferenceNumberFormula__c',sortable: false},
        { label: 'Status', fieldName: 'Status',sortable: false},
        { label: 'Account Name', fieldName: 'Account_Name',sortable: false},
        { label: 'Project Name', fieldName: 'SPEN_ProjectName__c',sortable: false}
    ];

    @wire(getObjectInfo, { objectApiName: RELATED_PROJECT })
    relatedProjectInfo;
    //Queue Position
    @wire(getPicklistValues,
        {
            recordTypeId: '$relatedProjectInfo.data.defaultRecordTypeId',
            fieldApiName: RELATED_QUEUE
        }
    )
    wiredQueueValues({data,error}){
        if(data){
            this.queueValues = data.values;
        }
    }
    //Stage
    @wire(getPicklistValues,
        {
            recordTypeId: '$relatedProjectInfo.data.defaultRecordTypeId',
            fieldApiName: RELATED_STAGE
        }
    )
    wiredStageValues({data,error}){
        if(data){
            this.stageValues = data.values;
        }
    }
    //Type
    @wire(getPicklistValues,
        {
            recordTypeId: '$relatedProjectInfo.data.defaultRecordTypeId',
            fieldApiName: RELATED_TYPE
        }
    )
    wiredTypeValues({data,error}){
        if(data){
            this.typeValues = data.values;
        }
    }
    //Relationship
    @wire(getPicklistValues,
        {
            recordTypeId: '$relatedProjectInfo.data.defaultRecordTypeId',
            fieldApiName: RELATED_RELATION
        }
    )
    wiredRelationValues({data,error}){
        if(data){
            this.relationshipValues = data.values;
        }
    }


    @wire(getRecord, { recordId: '$recordId', fields : caseFields })
    wiredCaseDetail({data,error}){
        if (data) {
            this.parentCaseNumber = getFieldValue(data, CASE_NUMBER);
        } else if (error) {
            console.log('Error Occurred:--'+JSON.stringify(error));
        }
    }

    handleSearch(event){
        const allinputFieldValid = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputFields) => {
                inputFields.reportValidity();
                return validSoFar && inputFields.checkValidity();
            }, true);

        this.showLoading = true;

        if(allinputFieldValid && this.searchVal && this.searchVal.toString().length > 3){
            findRecords({
                searchValue : this.searchVal
            })
            .then(result => {
                this.showLoading = false;
                if(result.length == 0){
                    this.noResult = true;
                }else{
                    let caseParsedData=JSON.parse(JSON.stringify(result));
                    caseParsedData.forEach(cse => {
                        if(cse.AccountId){
                            cse.Account_Name=cse.Account.Name;
                        }
                    });
                    this.records = caseParsedData;
                    this.errors = undefined;
                    this.noResult = false;
                }
            })
            .catch(error => {
                this.records = undefined;
                this.errors = error;
                this.showLoading = false;
            })
        }else{
            this.errors = undefined;
            this.records = undefined;
            this.noResult = false;
            this.showLoading = false;
            this.showToast('Error!!', 'Please input more than 3 characters in Case Lookup!!', 'error', 'dismissable');
        } 
    }

    handleSearchChange(event){
        this.searchVal = event.detail.value;
    }

    handleStageChange(event){
        this.stageVal = event.detail.value;
    }

    handleTypeChange(event){
        this.typeVal = event.detail.value;
    }

    handleRelationChange(event){
        this.relationVal = event.detail.value;
        if(this.relationVal === 'Interactive'){
            this.queueEnable = false;
        }else if(this.relationVal === 'Related'){
            this.queueEnable = true;
            this.queueVal = '';
        }
    }

    handleQueueChange(event){
        this.queueVal = event.detail.value;
    }

    getSelectedRows(event){
        const selectedRows = event.detail.selectedRows;
        this.caseWrapperObj = [];
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            let caseWrapper = {
                parentCase: this.recordId,
                relatedCaseId: selectedRows[i].Id,
                relatedStage: this.stageVal,
                relatedType: this.typeVal,
                relatedQueue: this.queueVal,
                relatedRelationship: this.relationVal
            };
            
            if(this.caseWrapperObj){
                this.caseWrapperObj = [ ...this.caseWrapperObj, caseWrapper ];
            }else{
                this.caseWrapperObj = [ caseWrapper ];
            }
        }
    }

    handleFinish(event){
        this.showLoading = true;
        console.log('caseWrapperObj---'+JSON.stringify(this.caseWrapperObj));
        console.log('caseWrapperObjLength---'+this.caseWrapperObj.length);
        insertRelatedRecord({relatedProject:JSON.stringify(this.caseWrapperObj)})
            .then(result=>{
                this.showLoading = false;
                this.showToast('Success!!', 'Related Project records inserted successfully!!', 'success', 'dismissable');
                this.dispatchEvent(new CloseActionScreenEvent());
            }).catch(error=>{
                this.showLoading = false;
                this.showToast('Error!!', 'Related Project records did not get inserted!!', 'error', 'dismissable');
            });
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
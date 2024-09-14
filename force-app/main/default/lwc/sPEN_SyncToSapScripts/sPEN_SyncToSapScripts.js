import { LightningElement,api,wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SAPNullErrorLabel from '@salesforce/label/c.SPEN_SyncToSAPErrorMessage';
import SAPReadyLabel from '@salesforce/label/c.SPEN_SyncToSAPReadyMessage';
import SAPSuccessLabel from '@salesforce/label/c.SPEN_SyncToSAPSuccessMessage';
import SAPChangeLabel from '@salesforce/label/c.SPEN_SyncToSAPChangeMessage';
import SAP_ID from '@salesforce/schema/Case.SPEN_SAPReference__c';
import UKC1_FIELD from '@salesforce/schema/Case.SPEN_UKC1ID__c';
import UKC2_FIELD from '@salesforce/schema/Case.SPEN_UKC2ID__c';
import OMS_DETAILS from '@salesforce/schema/Case.SPEN_OfgemMarketSegment__c';
import STATUS_DETAIL from '@salesforce/schema/Case.Status';
import LASTMODIFIED_DATE from '@salesforce/schema/Case.LastModifiedDate';
import SYNC_DATE from '@salesforce/schema/Case.SPEN_SyncToSAPDate__c';
import CALLOUTDEATILS_FIELD from '@salesforce/schema/Case.SPEN_SAPErrorDetails__c';
import SAPCallOUTDETAILSERRORLabel from '@salesforce/label/c.SPEN_SAPErrorCalloutDeatils';

const fields = [SAP_ID,UKC1_FIELD,UKC2_FIELD,OMS_DETAILS,STATUS_DETAIL,LASTMODIFIED_DATE,SYNC_DATE,CALLOUTDEATILS_FIELD];

export default class SPEN_SyncToSapScripts extends LightningElement {
    @api recordId;
    @track sapNullError = false;
    @track sapSuccess = false;
    @track sapReadyError = false;
    @track caseModifiedSyncError = false;
    @track sapId;
    @track ukc1;
    @track ukc2;
    @track omsValue;
    @track caseStatus;
    @track caseLastModifiedDate;
    @track syncToSapDate;
    @track sapCalloutDetails;
    @track sapCalloutDeatilsError = false;

    infoLabel = {
        SAPNullErrorLabel,
        SAPReadyLabel,
        SAPSuccessLabel,
        SAPChangeLabel,
        SAPCallOUTDETAILSERRORLabel
    };
    
    @wire(getRecord, { recordId: '$recordId', fields })
    wiredCaseDetail({data,error}){
        if (data) {
            this.sapId = getFieldValue(data, SAP_ID);
            this.ukc1 = getFieldValue(data, UKC1_FIELD);
            this.ukc2 = getFieldValue(data, UKC2_FIELD);
            this.omsValue = getFieldValue(data, OMS_DETAILS);
            this.caseStatus = getFieldValue(data, STATUS_DETAIL);
            this.caseLastModifiedDate = getFieldValue(data, LASTMODIFIED_DATE);
            this.syncToSapDate = getFieldValue(data, SYNC_DATE);
            this.sapCalloutDetails = getFieldValue(data, CALLOUTDEATILS_FIELD);
            
            var lastModifiedTime = new Date( this.caseLastModifiedDate ).getTime();
            
            var syncToSapTime = lastModifiedTime-70000;
            if(this.syncToSapDate){
                syncToSapTime = new Date( this.syncToSapDate ).getTime();
            }
                        
            var timeDiffForDates = (lastModifiedTime - syncToSapTime);

            var sapCalloutErrorStatus = false;

            if(this.sapCalloutDetails != null && !this.sapCalloutDetails.includes('QAS Customer Req.') &&
            this.sapCalloutDetails != '.Physical Information saved successfully.' && 
            this.sapCalloutDetails != '.Cancel QAS saved successfully.' && 
            this.sapCalloutDetails != 'PM update success.'
            ){
                sapCalloutErrorStatus = true;
            }
            console.log('SAP Ref**' + this.sapId);
            if(this.sapId){
                if(this.caseStatus && (this.caseStatus === 'Design' || this.caseStatus === 'Budget Design')){
                    if(timeDiffForDates && timeDiffForDates > 60000){
                        if(sapCalloutErrorStatus){
                            this.sapCalloutDeatilsError = true;
                            this.sapReadyError = false;
                            this.sapNullError = false;
                            this.caseModifiedSyncError = false;
                            this.sapSuccess = false;
                        }else{
                        this.caseModifiedSyncError = true;
                        this.sapNullError = false;
                        this.sapSuccess = false;
                        this.sapReadyError = false;
                        this.sapCalloutDeatilsError = false;
                        }
                    }else{
                        if(sapCalloutErrorStatus){
                            this.sapCalloutDeatilsError = true;
                            this.sapReadyError = false;
                            this.sapNullError = false;
                            this.caseModifiedSyncError = false;
                            this.sapSuccess = false;
                        }else{
                            this.sapSuccess = true;
                            this.sapNullError = false;
                            this.caseModifiedSyncError = false;
                            this.sapReadyError = false;
                            this.sapCalloutDeatilsError = false;
                        }
                    }
                }else{
                    if(sapCalloutErrorStatus){
                        this.sapCalloutDeatilsError = true;
                        this.sapReadyError = false;
                        this.sapNullError = false;
                        this.caseModifiedSyncError = false;
                        this.sapSuccess = false;
                    }else{
                    this.sapSuccess = true;
                    this.sapNullError = false;
                    this.caseModifiedSyncError = false;
                    this.sapReadyError = false;
                    this.sapCalloutDeatilsError = false;
                    }
                }
            }else{
                if(this.caseStatus && (this.caseStatus === 'Formal Enquiry' || this.caseStatus === 'Budget Enquiry')){
                    if(sapCalloutErrorStatus){
                        this.sapCalloutDeatilsError = true;
                        this.sapReadyError = false;
                        this.sapNullError = false;
                        this.caseModifiedSyncError = false;
                        this.sapSuccess = false;
                    }else{
                    this.sapReadyError = true;
                    this.sapNullError = false;
                    this.caseModifiedSyncError = false;
                    this.sapSuccess = false;
                    this.sapCalloutDeatilsError = false;
                    }
                }else{
                    if(sapCalloutErrorStatus){
                        this.sapCalloutDeatilsError = true;
                        this.sapReadyError = false;
                        this.sapNullError = false;
                        this.caseModifiedSyncError = false;
                        this.sapSuccess = false;
                    }else{
                    this.sapNullError = true;
                    this.caseModifiedSyncError = false;
                    this.sapSuccess = false;
                    this.sapReadyError = false;
                    }
                }
            }
        }else{
            console.log('Sync To Script Error-->'+JSON.stringify(error));
        }
    }
}
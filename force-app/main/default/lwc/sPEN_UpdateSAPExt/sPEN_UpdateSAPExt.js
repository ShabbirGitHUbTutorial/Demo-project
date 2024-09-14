import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendSoapCallout from '@salesforce/apex/SPEN_SAPQASCallout.sendSoapCallout';
import plotCountDetails from '@salesforce/apex/SPEN_PlotSelector.getActivePlotsCountFromCase';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import SAP_ID from '@salesforce/schema/Case.SPEN_SAPReference__c';
import SAP_CALLOUT_DETAILS from '@salesforce/schema/Case.SPEN_SAPErrorDetails__c';
import PLOT_DETAILS from '@salesforce/schema/Case.SPEN_Plots__c';
import SUB_STATUS from '@salesforce/schema/Case.SPEN_SubStatus__c';
import STATUS_DETAIL from '@salesforce/schema/Case.Status';
import SITE_FIRSTNAME from '@salesforce/schema/Case.SPEN_SiteContactFirstName__c';
import SITE_LASTNAME from '@salesforce/schema/Case.SPEN_SiteContactLastName__c';
import SITE_COMPANY from '@salesforce/schema/Case.SPEN_SiteContactCompanyName__c';
import SITE_MOBILE from '@salesforce/schema/Case.SPEN_SiteContactMobile__c';
import SITE_PHONE from '@salesforce/schema/Case.SPEN_SiteContactPhone__c';
import SITE_STREET from '@salesforce/schema/Case.SPEN_SiteContactStreet__c';
import SITE_TOWN from '@salesforce/schema/Case.SPEN_SiteContactTownCity__c';
import SITE_POSTCODE from '@salesforce/schema/Case.SPEN_SiteContactPostCode__c';
import SITE_COUNTRY from '@salesforce/schema/Case.SPEN_SiteContactCountry__c';
import SITE_COUNTY from '@salesforce/schema/Case.SPEN_SiteContactCounty__c';
import CUSTOMER_CLASS from '@salesforce/schema/Case.SPEN_CustomerClass__c';
import PAYMENT_DECISION from '@salesforce/schema/Case.SPEN_PaymentDecision__c';
import REQUEST_RELEASE from '@salesforce/schema/Case.SPEN_RequestedtoRelease__c';
import UKC1_FIELD from '@salesforce/schema/Case.SPEN_UKC1ID__c';
import UKC2_FIELD from '@salesforce/schema/Case.SPEN_UKC2ID__c';
import OMS_DETAIL from '@salesforce/schema/Case.SPEN_OfgemMarketSegment__c';

const caseFields = [SAP_ID,SAP_CALLOUT_DETAILS,PLOT_DETAILS,SUB_STATUS,STATUS_DETAIL,
                SITE_FIRSTNAME,SITE_LASTNAME,SITE_COMPANY,SITE_MOBILE,SITE_PHONE,SITE_STREET,
                SITE_TOWN,SITE_POSTCODE,SITE_COUNTRY,SITE_COUNTY,CUSTOMER_CLASS,PAYMENT_DECISION,
                REQUEST_RELEASE,UKC1_FIELD,UKC2_FIELD,OMS_DETAIL];

export default class SPEN_UpdateSAPExt extends LightningElement {
    @api recordId;
    @track operationModify='MODIFY_QAS';
    @track operationCreate='CREATE_QAS';
    @track operationTransfer='TRANSFER_QAS';
    @track operationCancel='CANCEL_QAS';
    @track sapId;
    @track sapCalloutDetails;
    @track subStatus;
    @track statusField;
    @track siteFirstName;
    @track siteLastName;
    @track siteCompany;
    @track siteMobile;
    @track sitePhone;
    @track siteStreet;
    @track siteTown;
    @track sitePostCode;
    @track siteCountry;
    @track siteCounty;
    @track customerClass;
    @track paymentDecision;
    @track requestToRelease;
    @track ukc1;
    @track ukc2;
    @track omsDetail;
    @track plotDetails;
    @track plotCount;
    @track error;

    @wire(getRecord, { recordId: '$recordId', fields : caseFields })
    wiredCaseDetail({data,error}){
        if (data) {
            console.log('Update Sap Wired Data----'+JSON.stringify(data));
            this.sapId = getFieldValue(data, SAP_ID);
            this.sapCalloutDetails = getFieldValue(data, SAP_CALLOUT_DETAILS);
            this.plotDetails = getFieldValue(data, PLOT_DETAILS);
            this.subStatus = getFieldValue(data, SUB_STATUS);
            this.statusField = getFieldValue(data, STATUS_DETAIL);
            this.siteFirstName = getFieldValue(data, SITE_FIRSTNAME);
            this.siteLastName = getFieldValue(data, SITE_LASTNAME);
            this.siteCompany = getFieldValue(data, SITE_COMPANY);
            this.siteMobile = getFieldValue(data, SITE_MOBILE);
            this.sitePhone = getFieldValue(data, SITE_PHONE);
            this.siteStreet = getFieldValue(data, SITE_STREET);
            this.siteTown = getFieldValue(data, SITE_TOWN);
            this.sitePostCode = getFieldValue(data, SITE_POSTCODE);
            this.siteCountry = getFieldValue(data, SITE_COUNTRY);
            this.siteCounty = getFieldValue(data, SITE_COUNTY);
            this.customerClass = getFieldValue(data, CUSTOMER_CLASS);
            this.paymentDecision = getFieldValue(data, PAYMENT_DECISION);
            this.requestToRelease = getFieldValue(data, REQUEST_RELEASE);
            this.ukc1 = getFieldValue(data, UKC1_FIELD);
            this.ukc2 = getFieldValue(data, UKC2_FIELD);
            this.omsDetail = getFieldValue(data, OMS_DETAIL);
        }else{
            this.showToast('Error!!', JSON.stringify(error), 'error', 'dismissable');
        }
    }

    
    @api async invoke() {
        
        if(!this.siteFirstName || !this.siteLastName || !this.siteStreet || !this.siteTown
            || !this.sitePostCode || !this.siteCounty || !this.siteCountry
            || !this.paymentDecision || (!this.requestToRelease && this.requestToRelease !== 0)){
            
            let errorFields = 'Please provide following values: \r\n';
            errorFields += this.siteFirstName ? '' : 'Site Contact First Name, ';
            errorFields += this.siteLastName ? '' : '  Site Contact Last Name,';
            errorFields += this.siteStreet ? '' : 'Site Contact Street, ';
            errorFields += this.siteTown ? '' : 'Site Contact Town / City, ';
            errorFields += this.sitePostCode ? '' : 'Site Contact Post Code, ';
            errorFields += this.siteCounty ? '' : 'Site Contact County, ';
            errorFields += this.siteCountry ? '' : 'Site Contact Country, ';
            errorFields += this.paymentDecision ? '' : 'Payment Decision, ';
            errorFields += this.requestToRelease ? '' : '% Requested to Release';

            this.showToast('Error!!', errorFields, 'error', 'dismissable');
            return;
        }

        if(this.siteCountry && this.siteCountry !== 'GB'){
            this.showToast('Error!!', 'Site Contact Country value should be GB.', 'error', 'dismissable');
            return;
        }

        if(this.customerClass && (this.customerClass === 'CO' || this.customerClass === 'MX') && !this.siteCompany){
            this.showToast('Error!!', 'Please provide Site Contact Company Name.', 'error', 'dismissable');
            return;
        }

        if((!this.siteMobile && !this.sitePhone)){
            let errorFields = 'Please provide one of the following values: \r\n';
            errorFields += this.siteMobile ? '' : 'Site Contact Mobile, ';
            errorFields += this.sitePhone ? '' : 'Site Contact Phone ';
            this.showToast('Error!!', errorFields, 'error', 'dismissable');
            return;
        }

        if(this.statusField && (this.statusField === 'Formal Enquiry' || this.statusField === 'Budget Enquiry')){
            if((!this.ukc1 && !this.ukc2)){
                let errorFields = 'Please provide one of the following values: \r\n';
                errorFields += this.ukc1 ? '' : 'UKC1 ID, ';
                errorFields += this.ukc2 ? '' : 'UKC2 ID ';
                this.showToast('Error!!', errorFields, 'error', 'dismissable');
                return;
            }
            if(!this.omsDetail){
                this.showToast('Error!!', 'Please provide Ofgem Market Segment (OMS) value.', 'error', 'dismissable');
                return;
            }
        }
        
        if(this.statusField && this.statusField === 'Cancelled'){
            sendSoapCallout({operation:this.operationCancel,lstCase:this.recordId})
            .then(result=>{
                this.showToast('Success!!', 'Your call has been invoked...', 'success', 'dismissable');
                eval("$A.get('e.force:refreshView').fire();");
            }).catch(error=>{
                console.log('Cancelled Error---'+JSON.stringify(error));
                this.showToast('Error!!', JSON.stringify(error.body.message), 'error', 'dismissable');
            });
        }else if(this.subStatus && this.subStatus === 'Competent'){
            sendSoapCallout({operation:this.operationTransfer,lstCase:this.recordId})
            .then(result=>{
                this.showToast('Success!!', 'Your call has been invoked...', 'success', 'dismissable');
                eval("$A.get('e.force:refreshView').fire();");
            }).catch(error=>{
                console.log('Competent Error---'+JSON.stringify(error));
                this.showToast('Error!!', JSON.stringify(error.body.message), 'error', 'dismissable');
            });
        }else{
            plotCountDetails({caseId:this.recordId})
            .then(result=>{
            this.plotCount = result;

            if(this.plotDetails && ((this.plotCount && this.plotDetails === 'Y' && this.plotCount > 0) || this.plotDetails === 'N')){
                if(this.sapId){
                    sendSoapCallout({operation:this.operationModify,lstCase:this.recordId})
                    .then(result=>{
                        this.showToast('Success!!', 'Your call has been invoked...', 'success', 'dismissable');
                        eval("$A.get('e.force:refreshView').fire();");
                    }).catch(error=>{
                        console.log('Modify Error--'+JSON.stringify(error));
                        let errorMessage;
                        for (let fieldName in error.body.fieldErrors) {
                            errorMessage = error.body.fieldErrors[fieldName][0].message;
                        }
                        if(errorMessage != null && errorMessage != undefined){
                            this.showToast('Error!!', errorMessage , 'error', 'dismissable');
                        }else{
                            this.showToast('Error!!', JSON.stringify(error.body.message), 'error', 'dismissable');
                        }
                    });
                }else {
                    sendSoapCallout({operation:this.operationCreate,lstCase:this.recordId})
                    .then(result=>{
                        this.showToast('Success!!', 'Your call has been invoked...', 'success', 'dismissable');
                        eval("$A.get('e.force:refreshView').fire();");
                    }).catch(error=>{
                        console.log('Create Error--'+JSON.stringify(error));
                        this.showToast('Error!!', JSON.stringify(error.body.message), 'error', 'dismissable');
                    });
                }
            }else{
                this.showToast('Error!!', 'Cannot make a callout as there are no No exist Plots and the indicator plots is Y.', 'error', 'dismissable');
            }
            }).catch(error=>{
                console.log('Plot Count Method Error--'+JSON.stringify(error));
                this.error = JSON.stringify(error);
                this.showToast('Error!!', JSON.stringify(error.body.message), 'error', 'dismissable');
            });
        }
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
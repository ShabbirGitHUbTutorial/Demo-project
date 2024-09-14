import { LightningElement,wire,api,track } from 'lwc';
import getVendorAccount from '@salesforce/apex/SPEN_RefreshSAPVendorInvocable.getVendorAccount';
import syncVendorRequest from '@salesforce/apex/SPEN_RefreshSAPVendorInvocable.syncVendorRequest';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import LAND_ID from '@salesforce/schema/SPEN_Land_Interest__c.SPEN_Land__c';
const fields = [LAND_ID];

export default class SPEN_RefreshSAPVendorInvocableLWC extends LightningElement {

    @api recordId;
    landId;

    @wire(getRecord, { recordId: '$recordId', fields })
    getLandDetail({data,error}){
        if (data) {
            this.landId = getFieldValue(data, LAND_ID);
        }
    }
   
    @wire(getVendorAccount,{land:'$landId'})
    getVendorAccountHandler({data,error})
    {
        if(data)
        {
            this.accountList=data;
            if(this.accountList!=null && this.accountList.length>0)
            {
                this.syncAccountDetails();
            }
            
        }
        else{
        }
    }

    async syncAccountDetails()
    {
        try{
            await syncVendorRequest({vendorAccount:this.accountList});
            
        }catch(error)
        {
        }
    }

}
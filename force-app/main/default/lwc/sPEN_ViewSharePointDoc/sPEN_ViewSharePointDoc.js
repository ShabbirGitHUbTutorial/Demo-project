import { LightningElement,api } from 'lwc';
import viewDocs from '@salesforce/apex/SPEN_FileUploaderConnClass.fetchSPDocuments';
import openFolder from '@salesforce/apex/SPEN_FileUploaderConnClass.getCaseNumber';
 
const columns = [
    { label: 'DocumentName',fieldName: 'DocName', type: 'text'  },
    { label: 'TimeStamp',fieldName: 'DocDate', type: 'date'  },
    { label: 'View',fieldName: 'DocViewLink', type: 'url'  }
];

export default class SPEN_ViewSharePointDoc extends LightningElement {
    @api recordId;
    url = '';
    data = [];
    columns = columns;

    ShowDocs() {
        console.log('111DD>>'+this.recordId);
        let caseRecordId = this.recordId;
        console.log('222DD>>'+caseRecordId);
        viewDocs({ caseRecordId }).then(result=>{
            const data = result;
            console.log(data);
            console.log(JSON.stringify(data));
            this.data = data;
        });
        
    }

    connectedCallback(){
        let caseRecordId = this.recordId;
        openFolder({ caseRecordId : this.recordId }).then(result=>{
            
            const data = result;
            if(data.createdYear != null && data.createdYear != undefined){
                let parts = data.sharePointPath.split('/');
                parts[4] = parts[4] + '-'+ data.createdYear;
                this.url = parts.join('/');
                this.url = this.url + data.salesforceId;
            }else{
                this.url = data.sharePointPath + data.salesforceId;
            }
           
        });
    }
}
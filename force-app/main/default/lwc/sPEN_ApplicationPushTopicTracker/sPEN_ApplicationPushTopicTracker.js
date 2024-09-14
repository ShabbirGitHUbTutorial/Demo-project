import { LightningElement, wire, track } from 'lwc';
import getPushTopics from '@salesforce/apex/SPEN_PushTopicController.getPushTopics';
const columns = [ { label: 'Name', fieldName: 'Name', sortable: "true"},
                  { label: 'Query', fieldName: 'Query', sortable: "true"},
                  { label: 'ApiVersion', fieldName: 'ApiVersion', sortable: "true"},
                  { label: 'NotifyForOperationCreate', fieldName: 'NotifyForOperationCreate', sortable: "true" },
                  { label: 'NotifyForOperationUpdate', fieldName: 'NotifyForOperationUpdate', sortable: "true"},
                  { label: 'NotifyForFields', fieldName: 'NotifyForFields', sortable: "true"},];
export default class SPEN_ApplicationPushTopicTracker extends LightningElement {
    @track data;
    @track columns = columns;
    @wire(getPushTopics,{})
    pushtopics(result) {
        if (result.data) {
            this.data = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }

}
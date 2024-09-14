import { LightningElement, wire, api, track } from 'lwc';
import getSurveyResponses from '@salesforce/apex/SPEN_SurveyHandler.getSurveyResponses';

export default class SPEN_SurveyQuestionResponse extends LightningElement {
    @api recordId; // Current case record Id
    surveyResponses;
    @track checkQuestionList = true;

    @wire(getSurveyResponses, { caseId: '$recordId' })
    wiredSurveyResponses({ error, data }) {
        if (data) {
            this.surveyResponses = data;
            //console.log('surveyResponses 2:'+this.surveyResponses);
        } else if (error) {
            // Handle error
        }
        console.log('test surveyResponses:'+this.surveyResponses);
        if(this.surveyResponses==''){
            this.checkQuestionList = false;
        }
        console.log('testtest :'+this.checkQuestionList);
    }
}
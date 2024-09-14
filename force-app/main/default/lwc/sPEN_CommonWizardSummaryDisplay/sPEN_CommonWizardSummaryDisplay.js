import { LightningElement,api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class SPEN_CommonWizardSummaryDisplay extends NavigationMixin(LightningElement) {
    @api recordId;
}
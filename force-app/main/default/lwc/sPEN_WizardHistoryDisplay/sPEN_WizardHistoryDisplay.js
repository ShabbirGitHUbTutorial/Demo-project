import { LightningElement,api } from 'lwc';
import { NavigationMixin } from "lightning/navigation";

export default class SPEN_WizardHistoryDisplay extends NavigationMixin(LightningElement) {
    @api recordId;
}
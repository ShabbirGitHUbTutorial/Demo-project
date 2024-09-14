import { LightningElement,api } from 'lwc';

export default class SPEN_CommonWizLaunchCallWiz extends LightningElement {
@api contactId;
@api premiseId;
@api wizardRedirect;

get inputVariables() {
    return [
        {
            name: 'SPEN_ContactIdSelectedForWizard',
            type: 'String',
            value: this.contactId
        },
        {
            name: 'SPEN_PremiseIdSelectedLookup',
            type: 'String',
            value: this.premiseId
        }
    ];
}
    handleLaunchCallWizard(){
        this.wizardRedirect = true;
    }
}
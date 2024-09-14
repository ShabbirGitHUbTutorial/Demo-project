import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

export default class SpenGlobalLWC extends LightningElement {

    isGS6Visible;
    woliId;

    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference){
        this.isGS6Visible = currentPageReference.state.lwcName === 'GS6' ? true : false;
        this.woliId = currentPageReference.state.woliId;
    }
}
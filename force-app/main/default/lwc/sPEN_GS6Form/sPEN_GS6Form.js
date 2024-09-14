import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { createRecord, getRecord, updateRecord } from 'lightning/uiRecordApi';
import WORKORDERLINEITEM_ID from "@salesforce/schema/WorkStep.WorkOrderLineItemId";
import STATUS from "@salesforce/schema/WorkStep.Status";
import WORKSTEP_ID from "@salesforce/schema/WorkStep.Id";
import SPEN_SAFETYFORM from "@salesforce/schema/SPEN_SafetyForm__c";
import LOGO from "@salesforce/contentAssetUrl/unknown_content_asset";
import GS6FORM from "@salesforce/contentAssetUrl/unknown_content_asset";
import GS6GUIDE from "@salesforce/contentAssetUrl/unknown_content_asset";
import STREET from "@salesforce/schema/WorkOrderLineItem.Street";
import CITY from "@salesforce/schema/WorkOrderLineItem.City";
import POSTALCODE from "@salesforce/schema/WorkOrderLineItem.PostalCode";
import EXTERNALID from "@salesforce/schema/WorkOrderLineItem.SPEN_ExternalId__c";
import SYSTEM_VOLTAGE_FIELD from '@salesforce/schema/SPEN_SafetyForm__c.SPEN_SystemVoltage__c';
import getDistrict from '@salesforce/apex/SPEN_GS6FormController.getDistrict';
import Id from "@salesforce/user/Id";
import proj4_library from '@salesforce/resourceUrl/proj4_library';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import {CurrentPageReference} from 'lightning/navigation';

// Import to Picklist SPEN_SystemVoltage__c from SPEN_SafetyForm__c object.
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';


// Map to handle all css classes that the div element needs in order to be upon the diagram image and hightlight the correct spot in the image.
const cssClassMap = new Map();
cssClassMap.set('polePylonNumber', 'first-pole-number');
cssClassMap.set('safetyClearance', 'safety-clearance');
cssClassMap.set('heightOfGoalPost', 'height-of-goal-post');
cssClassMap.set('heightOfLowestConductor', 'height-of-lowest-conductor');
cssClassMap.set('polePylonNumber2', 'second-pole-number');

export default class Spen_GS6Form extends LightningElement {
	@api userId = Id;
	formRecord = {};
	@api recordId;
	@api objectApiName;
	disableSubmission = false;
	imgURL = '';
	imgURL_client = '';
	formVisible = true;
	@track latitude;
	@track longitude;
	formRecordId = ''
	imgURLBase64 = '';
	imgURLBase64_client = '';
	@track pageIntro = true;
	@track page1 = false;
	@track page2 = false;
	@track page3 = false;
	@track gs6Guide = false;
	@track getStreetFlag = true;
	@track getCityFlag = true;
	@track getPostalcodeFlag = true;
	@track getJobNumberFlag = true;
	@track getDistrictFlag = true;
	@track systemVoltageOptions = [];
	@track optionSelected;
	coordinatesTransformed = '';
	coordinateX = '';
	coordinateY = '';
	@track contentDocumentIds = [];
	GS6RecordId = '';

	//Variables to handle diagram images feature
	@track polePylonNumberImgContainer = false;
	@track safetyClearanceImgContainer = false;
	@track heightOfGoalPostImgContainer = false;
	@track heightOfLowestConductorImgContainer = false;
	@track secondPolePylonImgContainer = false;
	@track imgContainer = true ;

	connectedCallback(){
		loadScript(this,proj4_library)
		.then(() => {

			this.transformCoordinates();
		});
		
	}
	

	@wire(getDistrict, {
		userId: '$userId'
	})
	district;

	get districtName() {
		if(this.getDistrictFlag){
			this.getDistrictFlag = false;
			let district = this.district?.data?.ServiceTerritory?.Name ?? "";
			this.formRecord['SPEN_District__c'] = district;
			return district;
		} else {
			return this.formRecord['SPEN_District__c'];
		}
	}

	get logoUrl() {
		return LOGO;
	}

	get gs6formUrl() {
		return GS6FORM;
	}  

	get gs6guideUrl() {
		return GS6GUIDE;
	}

	//Updated to represent WOLI fields
	get woliFields() {
		return [STREET, CITY, POSTALCODE, EXTERNALID];
	}

	get fields() {
		return [WORKORDERLINEITEM_ID, STATUS];
	}

	@wire(getRecord, {
		recordId: "$recordId",
		fields: "$fields"
	})
	workstep;

	@wire(CurrentPageReference)
		setCurrentPageReference(currentPageReference) {
		if(currentPageReference.state.latitude != null && currentPageReference.state.longitude != null){
			this.latitude = Math.round(currentPageReference.state.latitude*1000000)/1000000;
			this.longitude = Math.round(currentPageReference.state.longitude*1000000)/1000000;
		}
		else{
			this.latitude = '';
			this.longitude = '';
		}
	}

	get woliId(){
		return this.workstep?.data?.fields?.WorkOrderLineItemId?.value ?? "";
	}

	@wire(getRecord, {
		recordId: "$woliId",
		fields: "$woliFields"
	})
	woli;

	get street(){
		if(this.getStreetFlag){
			this.getStreetFlag = false;
			let street = this.woli?.data?.fields?.Street?.value ?? "";
			this.formRecord['SPEN_Street__c'] = street;
			return street;
		} else {
			return this.formRecord['SPEN_Street__c'];
		}
	}

	get city(){
		if(this.getCityFlag){
			this.getCityFlag = false;
			let city = this.woli?.data?.fields?.City?.value ?? "";
			this.formRecord['SPEN_City__c'] = city;
			return city;
		} else {
			return this.formRecord['SPEN_City__c'];
		}
	}

	get postalCode(){
		if(this.getPostalcodeFlag){
			this.getPostalcodeFlag = false;
			let postalCode = this.woli?.data?.fields?.PostalCode?.value ?? "";
			this.formRecord['SPEN_ZipPostalCode__c'] = postalCode;
			return postalCode;
		} else{
			return this.formRecord['SPEN_ZipPostalCode__c'];
		}
	}

	get address(){
		return this.street + ", " + this.postalCode;
	}
	
	get jobNumber(){
		if(this.getJobNumberFlag){
			this.getJobNumberFlag = false;
			let externalIdFromWoli = this.woli?.data?.fields?.SPEN_ExternalId__c?.value ?? "";
			this.formRecord['SPEN_JobNumber__c'] = externalIdFromWoli;
			return externalIdFromWoli;
		} else {
			return this.formRecord['SPEN_JobNumber__c'];
		}
	}

	handleChange(event) { 
		this.formRecord[event.target.name] = event.target.value;
	}

	createForm(event){
		event.preventDefault();
		const isValid = this.peformValidation();
		const checkEmail = this.emailValidation(this.formRecord['SPEN_CustomerEmail__c']);
		this.handleSignatures();
		// In case no geolocation values was pre set (E.g: Standalone form).
		this.formRecord['SPEN_Geolocation__Latitude__s'] = this.latitude;
		this.formRecord['SPEN_Geolocation__Longitude__s'] = this.longitude;
		this.formRecord.SPEN_WorkOrderLineItem__c = this.woliId;
		this.formRecord.SPEN_RecordTypeDevName__c = 'SPEN_GS6Form';
		this.formRecord.SPEN_Signature__c = '<img src=\'' + this.imgURL + ' \'></img>';
		this.formRecord.SPEN_ClientSignature__c = '<img src=\'' + this.imgURL_client + ' \'></img>';
		this.formRecord.SPEN_FieldOperativeSignatureBase64__c = '<img width="100" height="40" src=\"data:image/png;base64,' + this.imgURLBase64 + ' \"></img>';
		this.formRecord.SPEN_ClientSignatureBase64__c = '<img width="100" height="40" src=\"data:image/png;base64,' + this.imgURLBase64_client + ' \"></img>';
		const fields = this.formRecord;
		const fieldStatus = {};
		fieldStatus[WORKSTEP_ID.fieldApiName] = this.recordId;
		fieldStatus[STATUS.fieldApiName] = 'Completed';
		const recordInput = {apiName: SPEN_SAFETYFORM.objectApiName, fields}
		const recordInput2 = {fields: fieldStatus}
		
		if(checkEmail){
		if (isValid && this.imgURL != "" && this.imgURL_client != "") {
			createRecord(recordInput)
			.then(result => {
					this.GS6RecordId = result.id;
				this.disableSubmission = true;
				this.formVisible = false;
					this.contentDocumentIds.forEach(contentDocument => {
						createRecord({
						  apiName: "ContentDocumentLink",
						  fields: {
							LinkedEntityId: this.GS6RecordId,
							ContentDocumentId: contentDocument,
							ShareType: "V"
						  }
						});
					  })
			})
			.catch(error => {
			this.dispatchEvent(
				new ShowToastEvent({
				title: "Error creating record",
				message: error.body.message,
				variant: "error",
				}),
			);
			});
			updateRecord(recordInput2)
			.then(() => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Success",
						message: "Work Step Status updated",
						variant: "success"
					})
				);
			})
			.catch((error) => {
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error updating Work Step Status",
						message: error.body.message,
						variant: "error"
					})
				);
			});
		} else {
			this.dispatchEvent(
				new ShowToastEvent({
				message: "A signature is required before submitting.",
					variant: "error",
					}),
				);
			} 
		} else {
			this.dispatchEvent(
				new ShowToastEvent({
				message: "A valid email is required before submitting.",
				variant: "error",
				}),
			);
		} 
	} 

	 handleSignatures() {
		const clientSignature = this.template.querySelector('c-s-p-e-n_-signature-component[data-id="client"]').saveSignature();
		const fieldOperativesignature = this.template.querySelector('c-s-p-e-n_-signature-component[data-id="fieldOperative"]').saveSignature();
	 }

	updateSignature(event){
		this.imgURL = event.detail.message;
		this.imgURLBase64 = event.detail.message2;	
	}

	updateClientSignature(event){
		this.imgURL_client = event.detail.message;
		this.imgURLBase64_client = event.detail.message2;
	}
		
	removeSignature(event){
		this.imgURL = "";
		}

	removeClientSignature(event){
		this.imgURL_client = "";
	}

	transformCoordinates(){
		
		loadScript(this,proj4_library)
		.then(() => {

			proj4.defs([
				[
					'EPSG:4326',
					'+title=WGS 84 (long/lat) +proj=longlat +ellps=WGS84 +datum=WGS84 +units=degrees'],
				[
					'EPSG:27700',
					'+proj=tmerc +lat_0=49 +lon_0=-2 +k=0.9996012717 +x_0=400000 +y_0=-100000 +ellps=airy +towgs84=446.448,-125.157,542.06,0.15,0.247,0.842,-20.489 +units=m +no_defs +type=crs',
				],
			]);

			this.coordinatesTransformed = proj4('EPSG:4326', 'EPSG:27700', [this.longitude , this.latitude]);
			this.coordinateX = Math.trunc(this.coordinatesTransformed[0]);
			this.formRecord['SPEN_CoordinateX__c']  = this.coordinateX.toString();
			this.coordinateY = Math.trunc(this.coordinatesTransformed[1]);
			this.formRecord['SPEN_CoordinateY__c']  = this.coordinateY.toString();

		})

		.catch(error => {

			alert('failed.....'+error);

		});
	}

	updateGeolocation(event){
		this.latitude = Math.round(event.detail.message.coords.latitude*1000000)/1000000;
		this.formRecord['SPEN_Geolocation__Latitude__s'] = this.latitude;
		this.longitude = Math.round(event.detail.message.coords.longitude*1000000)/1000000;
		this.formRecord['SPEN_Geolocation__Longitude__s'] = this.longitude;
		this.transformCoordinates();
	}

	peformValidation() {
		try {
			const isValid = [...this.template.querySelectorAll("lightning-input-field")].filter((field) => field.required).every((field) => field.required && field.value) && 
			[...this.template.querySelectorAll("lightning-input")].filter((field) => field.required).every((field) => field.required && field.value) && [...this.template.querySelectorAll("lightning-input")].every((field) =>field.checkValidity());
			
		if (!isValid) {
			throw new Error("Please fill in the required fields and make sure there are no values with more than one decimal place.");
			}
		} 
		catch (error) {
			this.dispatchEvent(
				new ShowToastEvent({
				title: "Please fill in the required fields and make sure there are no values with more than one decimal place.",
				message: error,//error.body.message,
				variant: "error",
				}),
			);
			return false;
		}
		return true;
    }

	emailValidation(email){
        const emailExpression = /([0-9a-z\-_.]+@((?:[a-z0-9-]+\.)*[a-z0-9-]+)\.([a-z]+),?)([0-9a-z\-_.]+@((?:[a-z0-9-]+\.)*[a-z0-9-]+)\.([a-z]+),?)*/gi;
        const matchExpression = email.match(emailExpression);
 
        // Check if inserted email matches email syntax requirements
        if(email === '' || (matchExpression && email.length === matchExpression[0].length)){
            return true;
        }
        return false;
    }

	handleUploadFinished(event){
		const contentDocumentId = event.detail.message;
		this.contentDocumentIds.push(contentDocumentId);
		
	}

	handlePreviousPage(){
		if (this.page1){
			this.page1 = false;
			this.pageIntro = true;
		} else if (this.page2) {
            this.page1 = true;
            this.page2 = false;
        } else if (this.page3) {
            this.page2 = true;
            this.page3 = false;
        } else if (this.page4) {
            this.page3 = true;
            this.page4 = false;
        }
       }
	
	handleNextPage(){
		const isValid = this.peformValidation();
		if(isValid){
			if (this.pageIntro){
				this.page1 = true;
				this.pageIntro = false;
			} else if (this.page1) {		
				const checkEmail = this.emailValidation(this.formRecord['SPEN_CustomerEmail__c']);
				if(checkEmail){
				this.page2 = true;
				this.page1 = false;  
				} else { 
					this.dispatchEvent(
					new ShowToastEvent({
					message: "A valid email is required before submitting.",
					variant: "error",
					}),
					);
				}		  
			} else if (this.page2) {
				this.page3 = true;
				this.page2 = false;
			} else if (this.page3) {
				this.page4 = true;
				this.page3 = false;
			}
		}
    }

	handleGS6Guide(){
		this.gs6Guide = true;
	}

	closeGS6Guide(){
		this.gs6Guide = false;
	}


	// This function adds the correct div element upon the diagram image based on the input that has the focus.
	handleFocusOnMeasurementFields(event) {	
		const inputName = event.target.dataset.measurement;

		this.imgContainer = false;		
		this.swapGS6Image(inputName, true);

		if(!this.template.querySelector(`.${inputName}`).classList.contains(cssClassMap.get(inputName))) {
			this.template.querySelector(`.${inputName}`).classList.add(cssClassMap.get(inputName));
		}

	}

	// This function removes the correct div element upon the diagram image based on the input that has the focus.
	handleBlurOnMeasurementFields(event) {
		const inputName = event.target.dataset.measurement;

		this.swapGS6Image(inputName, false);
		if(this.template.querySelector(`.${inputName}`).classList.contains(cssClassMap.get(inputName))) {
			this.template.querySelector(`.${inputName}`).classList.remove(cssClassMap.get(inputName));
		}

		this.enableDefaultImage();
	}

	//This function handles the default image enablement if there is no input with focus.
	enableDefaultImage() {
		if(!(this.polePylonNumberImgContainer || this.safetyClearanceImgContainer || this.heightOfGoalPostImgContainer ||
			this.heightOfLowestConductorImgContainer ||  this.secondPolePylonImgContainer)) {
				this.imgContainer = true;
		}
	}

	//Wire to fetch GS6 Form Picklist Values
	@wire(getObjectInfo, { objectApiName: 'SPEN_SafetyForm__c'})
	spenSafetyFormInfo;

	// This wire function fetches the System Voltage picklist from GS6 Form so it can be displayed in lightning-radio-group element.
	@wire(getPicklistValues, {recordTypeId: '$spenSafetyFormInfo.data.defaultRecordTypeId', fieldApiName: SYSTEM_VOLTAGE_FIELD })
	systemVoltagePicklistValues({ error, data }) {
		if(data) {
			this.systemVoltageOptions = data.values.map(picklistValue => ({
				label: picklistValue.label,
				value: picklistValue.value
			}));
		}else if(error) {
			console.log('Error on loading System Voltage values ', error);
		}
	}

	handleSystemVoltageChange(event) {
		this.optionSelected = event.detail.value;
		this.formRecord["SPEN_SystemVoltage__c"] = this.optionSelected;
		
	}

	// This function handles the image that needs to be displayed according to the button that has the current focus.
	swapGS6Image(inputName, activateImage ) {
		
		switch (inputName) {
			case 'polePylonNumber2':
				this.secondPolePylonImgContainer = activateImage;
				break;
			case 'polePylonNumber':
				this.polePylonNumberImgContainer = activateImage;
				break;
			case 'safetyClearance':
				this.safetyClearanceImgContainer = activateImage;
				break;
			case 'heightOfGoalPost':
				this.heightOfGoalPostImgContainer = activateImage;
				break;
			case 'heightOfLowestConductor':
				this.heightOfLowestConductorImgContainer = activateImage;
				break;
			default:
				this.secondPolePylonImgContainer = false;
				this.polePylonNumberImgContainer = false;
				this.safetyClearanceImgContainer = false;
				this.heightOfGoalPostImgContainer = false;
				this.heightOfLowestConductorImgContainer = false;
				this.imgContainer = true;
				break;
		}
	}
}
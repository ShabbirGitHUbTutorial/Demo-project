import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getLocationService } from 'lightning/mobileCapabilities';
import { gql, graphql } from "lightning/uiGraphQLApi";
import { refreshApex } from '@salesforce/apex';
import Id from "@salesforce/user/Id";
import getData from '@salesforce/apex/SPEN_FieldServiceMobileAppController.getNonWorkRelatedForms';
import getDeepLink from '@salesforce/apex/SPEN_FieldServiceMobileAppController.getDeepLink';

export default class SPEN_MobileNonWorkRelatedForms extends NavigationMixin(LightningElement){
    
    @api userId = Id;
    @api latitude = 0;
    @api longitude = 0;

    // screens
    @track screenMenu = true;
	@track screenSearchPremise = false;

    urlToSplit = '';

    // Data variables
    mobileFormSettings;
    signedDeepLinks;
    errorSignedDeepLinks;
    unsignedDeepLinks;
    errorUnsignedDeepLinks;

    // Location service variables
    dataWithoutLocation;
    locationServiceError;
    locationServiceAvailable;

    // Search premise variables
    premiseId;
    offlineWarning = 'I am working offline and cannot use address search right now';
    premiseIdValue = '';
    @track graphqlPremiseQueryErrors;
    @track premiseChanged = false;
    @track premiseAddress = '';
    @track premisePostcode = '';
    @track premiseCity = '';

    // Auto-refreshed forced every 30sec
    timerId = setInterval(()=>refreshApex(this.connectedCallback()), 10e3);

    // Premise search
    matchingInfo = {
        primaryField: { fieldPath: 'SPEN_FullAddress__c' },
        additionalFields: [{ fieldPath: 'Name' }],
    };

    // graphql results
    resourceGraphqlQueryResult;
    mobileSettingsGraphqlQueryResult;
    premiseGraphqlQueryResult;

    @wire(getData, {userId: '$userId', latitude: '$latitude', longitude: '$longitude'}) 
    records({data, error}){
        if(data) { 
            this.signedDeepLinks = data;
        }
        if(error) {
            this.errorSignedDeepLinks = error;
            this.signedDeepLinks = undefined;
        }
    }

    // BEST PRACTICE
    // This GQL query can be primed
    // eslint-disable-next-line @salesforce/lwc-graph-analyzer/no-wire-config-property-uses-getter-function-returning-non-literal
    @wire(graphql, {
        query: '$serviceResourceQuery',
        variables: '$serviceResourceVariables'
    }) 
    wiredServiceResource(result) {
        // We hold a direct reference to the graphQL query result
        // so that we can refresh it with refreshGraphQL
        this.resourceGraphqlQueryResult = result;
        const { errors, data } = result;
        if (data) {
            this.serviceResourceId = data.uiapi.query.ServiceResource.edges[0].node.Id;
        }
        if (errors) {
            this.dataError = errors;
        }
    }  
    
    get serviceResourceVariables() { return { userId: this.userId } }

    // eslint-disable-next-line @salesforce/lwc-graph-analyzer/no-getter-contains-more-than-return-statement
    get serviceResourceQuery() {
        return gql`
        query searchServiceResource($userId: ID) {
            uiapi {
                query {
                    ServiceResource(
                        where: { RelatedRecordId: { eq: $userId } }
                    ) {
                        edges {
                            node {
                                Id
                                Name {
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }
    `
    }

    // BEST PRACTICE
    // This GQL query can be primed
    @wire(graphql, {
        query: '$mobileFormSettingsQuery',
        variables: '$coordinateVariables'
    }) 
    wiredMobileFormSettings(result) {
        // We hold a direct reference to the graphQL query result
        // so that we can refresh it with refreshGraphQL
        this.mobileSettingsGraphqlQueryResult = result;
        const { errors, data } = result;
        if (data) {
            this.mobileFormSettings = data.uiapi.query.SPEN_MobileFormSetting__mdt.edges.map(edge => edge.node);

            this.unsignedDeepLinks = [];
            this.mobileFormSettings.forEach(mobileFormSetting => {
                this.unsignedDeepLinks.push(
                    {
                        "Id": mobileFormSetting.Id,
                        "MasterLabel": mobileFormSetting.MasterLabel.value,
                        "SPEN_FormDeepLink__c": this.getURL(mobileFormSetting),
                        "SPEN_Type__c": mobileFormSetting.SPEN_Type__c.displayValue,
                    }
                );
            });
        }
        if (errors) {
            this.errorUnsignedDeepLinks = errors;
            this.unsignedDeepLinks = undefined
        }
    }

    get coordinateVariables() { return { latitude: this.latitude, longitude: this.longitude } }

    // eslint-disable-next-line @salesforce/lwc-graph-analyzer/no-getter-contains-more-than-return-statement
    get mobileFormSettingsQuery() {
        return gql`
            query searchMobileFormSettings {
                uiapi {
                    query {
                        SPEN_MobileFormSetting__mdt( orderBy: { MasterLabel: { order: ASC}}, first: 100) {
                            edges {
                                node {
                                    Id
                                    MasterLabel {
                                        value
                                    }
                                    SPEN_FormDeepLink__c {
                                        value
                                    }
                                    SPEN_Type__c {
                                        displayValue
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `
    }

    @wire(graphql, {
        query: '$premiseQuery',
        variables: '$premiseVariables'
    }) 
    wiredPremise(result) {
        // We hold a direct reference to the graphQL query result
        // so that we can refresh it with refreshGraphQL
        this.premiseGraphqlQueryResult = result;
        const { errors, data } = result;
        
        if (data) {
            let premise = data.uiapi.query.SPEN_Premise__c.edges[0];
            this.premiseIdValue = premise.node.Id;
            this.premiseAddress = premise.node.SPEN_FullAddress__c.value;
            this.premisePostcode = premise.node.SPEN_PostCode__c.value;
            this.premiseCity = premise.node.SPEN_Town__c.value;
            this.premiseChanged = true;
        }
        if (errors) {
            this.graphqlPremiseQueryErrors = errors;
        }
    }  
    
    get premiseVariables() { 
        return { 
            premiseId: this.premiseId 
        } 
    }

    // eslint-disable-next-line @salesforce/lwc-graph-analyzer/no-getter-contains-more-than-return-statement
    get premiseQuery() {
        if (this.premiseId != undefined) {
            return gql`
            query searchPremise($premiseId: ID) {
                uiapi {
                    query {
                        SPEN_Premise__c(
                            where: { Id: { eq: $premiseId } }
                        ) {
                            edges {
                                node {
                                    Id
                                    Name {
                                        value
                                    }
                                    SPEN_PostCode__c {
                                        value
                                    }
                                    SPEN_FullAddress__c {
                                        value
                                    }
                                    SPEN_Town__c {
                                        value
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `
        }
    }

    connectedCallback(){
        this.getLocationService();
    }

    disconnectedCallback() {
        clearInterval(this.timerId);
    }

    handleNavigate(e){
        e.preventDefault();

        if(e.currentTarget.value.includes('SPEN_LVServiceTermination')) {
            this.screenMenu = false;
            this.screenSearchPremise = true;
            this.urlToSplit = e.currentTarget.value;
        } else {
            this[NavigationMixin.Navigate]({
                "type": "standard__webPage",
                "attributes": {
                    "url": e.currentTarget.value
                    }
                });
        }
    }

    // Get current location through mobile device location service
    getLocationService() {
        const myLocationService = getLocationService();
        myLocationService.getCurrentPosition({ enableHighAccuracy: true })
        .then((result) => {
            this.latitude = result.coords.latitude;
            this.longitude = result.coords.longitude;
            this.locationServiceError = undefined;     
            this.locationServiceAvailable = true;
        })
        .catch((error) => {
            this.locationServiceAvailable = false;
            switch (error.code) {
                case "LOCATION_SERVICE_DISABLED":
                this.locationServiceError = "Location service on the device is disabled."; // Android only
                break;
                case "USER_DENIED_PERMISSION":
                this.locationServiceError =
                    "User denied permission to use location service on the device.";
                break;
                case "USER_DISABLED_PERMISSION":
                this.locationServiceError =
                    "Toggle permission to use location service on the device from Settings.";
                break;
                case "SERVICE_NOT_ENABLED":
                this.locationServiceError =
                    "Location service on the device is not enabled.";
                break;
                case "UNKNOWN_REASON":
                default:
                this.locationServiceError = error.message;
                break;
            }
        });
    }

    // Build the deep link url based on the flow or lwc that can be 
    // invoked while including the lat and long as params
    getURL(mobileFormSetting) {
        if(mobileFormSetting.SPEN_Type__c.displayValue === 'LWC'){
            return 'com.salesforce.fieldservice://v1/globalaction/SPEN_GlobalLWC?lwcName=' + mobileFormSetting.SPEN_FormDeepLink__c.value + 
                    '&latitude=' + this.latitude+ 
                    '&longitude=' + this.longitude;
        } 

        return 'com.salesforce.fieldservice://v1/sObject/' + this.serviceResourceId + 
                    '/flow/' + mobileFormSetting.SPEN_FormDeepLink__c.value + 
                    '?latitude=' + this.latitude + 
                    '&longitude=' + this.longitude;
    }

    handleNext() {
        if (this.urlToSplit.includes("/flow/")) {
            let splitUrl1 = this.urlToSplit.split("/flow/");
            let splitUrl2 = splitUrl1[0].split("/sObject/");
            let splitUrl3 = splitUrl1[1].split("?");
            let serviceResourceId = splitUrl2[1];
            let targetForLinked = splitUrl3[0];
            let typeForLinked = "Flow";


            getDeepLink({serviceResourceId: serviceResourceId, target: targetForLinked, type: typeForLinked, latitude: this.latitude, longitude: this.longitude, premiseId: this.premiseIdValue}) 
            .then(url => {               
                let navigateTo = url;
                
                // Navigate to deeplink
                this[NavigationMixin.Navigate]({
                    "type": "standard__webPage",
                    "attributes": {
                        "url": navigateTo
                        }
                    });

                // Set screen state to Forms Menu
                this.screenMenu = true;
                this.screenSearchPremise = false;
                this.clearSearchPremiseFields();
            })
            .catch(error => {
                this.errorSignedDeepLinks = error;
                this.signedDeepLinks = undefined;
            })
        }
    }

    handleBack() {
        this.screenMenu = true;
        this.screenSearchPremise = false;
        this.clearSearchPremiseFields();
    }

    handleOfflineLinkClick() {
        let navigateTo = this.urlToSplit;

        // Navigate to deeplink
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": navigateTo
                }
            });

        // Set screen state to Forms Menu
        this.screenMenu = true;
        this.screenSearchPremise = false;
        this.clearSearchPremiseFields();
    }

    onPremiseChange(event) {
        if (event.detail.recordId == null) {
            this.clearSearchPremiseFields();
        }
        this.premiseId = event.detail.recordId;
    }

    clearSearchPremiseFields() {
        this.premiseAddress = this.premisePostcode = this.premiseCity = '';
        this.premiseChanged = false;
        this.premiseIdValue = '';
        this.premiseId = null;
    }
}
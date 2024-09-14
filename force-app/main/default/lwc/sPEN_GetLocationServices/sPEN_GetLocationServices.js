// locationServiceExample.js
import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getLocationService } from 'lightning/mobileCapabilities';
 
export default class LocationServiceExample extends LightningElement {
 
   // Internal component state
   myLocationService;
   currentLocation;
   locationButtonDisabled = false;
   requestInProgress = false;
 
   // When component is initialized, detect whether to enable Location button
   connectedCallback() {
       this.myLocationService = getLocationService();
       if (this.myLocationService == null || !this.myLocationService.isAvailable()) {
           this.locationButtonDisabled = true;
       }
   }
  
   handleGetCurrentLocationClick(event) {
       // Reset current location
       this.currentLocation = null;
 
       if(this.myLocationService != null && this.myLocationService.isAvailable()) {
 
           // Configure options for location request
           const locationOptions = {
               enableHighAccuracy: true
           }
 
           // Show an "indeterminate progress" spinner before we start the request
           this.requestInProgress = true;
 
           // Make the request
           // Uses anonymous function to handle results or errors
           this.myLocationService
               .getCurrentPosition(locationOptions)
               .then((result)  => {
                   this.currentLocation = result;
 
                   // result is a Location object
                   console.log(JSON.stringify(result));

                   this.dispatchEvent(new CustomEvent('savelocation', {
                    detail: {
                        message: this.currentLocation
                    }
                  }));
 
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'Location Detected',
                           message: 'Location determined successfully.',
                           variant: 'success'
                       })
                   );
               })
               .catch((error) => {
                   // Handle errors here
                   console.error(error);
 
                   // Inform the user we ran into something unexpected
                   this.dispatchEvent(
                       new ShowToastEvent({
                           title: 'LocationService Error',
                           message:
                               'There was a problem locating you: ' +
                               JSON.stringify(error) +
                               ' Please try again.',
                           variant: 'error',
                           mode: 'sticky'
                       })
                   );
               })
               .finally(() => {
                   console.log('#finally');
                   // Remove the spinner
                   this.requestInProgress = false;
               });
       } else {
           // LocationService is not available
           // Not running on hardware with GPS, or some other context issue
           console.log('Get Location button should be disabled and unclickable. ');
           console.log('Somehow it got clicked: ');
           console.log(event);
 
           // Let user know they need to use a mobile phone with a GPS
           this.dispatchEvent(
               new ShowToastEvent({
                   title: 'LocationService Is Not Available',
                   message: 'Try again from the Salesforce app on a mobile device.',
                   variant: 'error'
               })
           );
       }
   }
 
   // Format LocationService result Location object as a simple string
   get currentLocationAsString() {
       return `Lat: ${this.currentLocation.coords.latitude}, Long: ${this.currentLocation.coords.longitude}`;
   }
 
   // Format Location object for use with lightning-map base component
   get currentLocationAsMarker() {
       return [{
           location: {
               Latitude: this.currentLocation.coords.latitude,
               Longitude: this.currentLocation.coords.longitude
           },
           title: 'My Location'
       }]
   }
}
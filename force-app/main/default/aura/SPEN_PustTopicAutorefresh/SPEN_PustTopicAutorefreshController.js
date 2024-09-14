({
    // Sets an empApi error handler on component initialization
    onInit : function(component, event, helper) {
        var action1 = component.get("c.getChannel");
        action1.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {
                component.set('v.channel', response.getReturnValue());
                console.log('channel', component.get('v.channel'));
                // Get the empApi component
                const empApi = component.find('empApi');
                
                // Register error listener and pass in the error handler function
                empApi.onError($A.getCallback(error => {
                    // Error can be any type of error (subscribe, unsubscribe...)
                    console.error('EMP API error: ', JSON.stringify(error));
                }));
                    var action = component.get('c.subscribe');
                    $A.enqueueAction(action);
            }
        });
       
       $A.enqueueAction(action1);
    },

    // Invokes the subscribe method on the empApi component
    subscribe : function(component, event, helper) {
        // Get the empApi component
        const empApi = component.find('empApi');
        // Get the channel from the input box
        //const channel = "/topic/IncidentInsertAndUpdates";//component.find('channel').get('v.value');
        const channel = "/topic/"+component.get('v.channel');
        // Replay option to get new events
        const replayId = -1;
		console.log('channel'+channel);
        // Subscribe to an event
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            // Process event (this is called each time we receive an event)
            console.log('Received event ', JSON.stringify(eventReceived));
            console.log(JSON.stringify(eventReceived));
            let navigationItemAPI = component.find("navigationItemAPI");
            navigationItemAPI.getSelectedNavigationItem()
            .then((response) => {
                //navigationItemAPI.refreshNavigationItem()
            // Only refresh if viewing an object-page
            console.log('---ResponsePageRef-->'+JSON.stringify(response.pageReference));
            console.log('---ResponseType-->'+response.pageReference.type);
            const objPage = 'standard__objectPage';
            if (response.pageReference && 
            response.pageReference.type === objPage) {
            // Do the refresh
            console.log('--Attributes--'+response.pageReference.attributes.objectApiName);
            navigationItemAPI.refreshNavigationItem()
            .catch(function(error) {
            console.log('Error in auto-refresh', error);
            });
            }
            });
        }))
        .then(subscription => {
            // Subscription response received.
            // We haven't received an event yet.
            console.log('Subscription request sent to: ', subscription.channel);
            // Save subscription to unsubscribe later
            component.set('v.subscription', subscription);
        });
    },

    // Invokes the unsubscribe method on the empApi component
   /* unsubscribe : function(component, event, helper) {
        // Get the empApi component
        const empApi = component.find('empApi');
        // Get the subscription that we saved when subscribing
        const subscription = component.get('v.subscription');

        // Unsubscribe from event
        empApi.unsubscribe(subscription, $A.getCallback(unsubscribed => {
          // Confirm that we have unsubscribed from the event channel
          console.log('Unsubscribed from channel '+ unsubscribed.subscription);
          component.set('v.subscription', null);
        }));
    }*/
})
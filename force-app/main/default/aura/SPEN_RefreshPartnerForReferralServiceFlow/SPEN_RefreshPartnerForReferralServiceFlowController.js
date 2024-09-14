({
    doInit : function( component, event, helper ) {
        helper.startFlow( component );
        
    },
    handleRecordUpdated : function( component, event, helper ) {
        helper.startFlow( component );
        
    },
    handleFlowStatusChange : function( component, event, helper ) {
        
        console.log( event.getParams() );
        if ( event.getParam( 'status' ) === 'FINISHED' ) {
            $A.get( 'e.force:refreshView' ).fire();
        }
        
    }
    
    
})
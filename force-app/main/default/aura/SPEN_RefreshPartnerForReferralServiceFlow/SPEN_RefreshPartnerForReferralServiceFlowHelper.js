({
    startFlow : function( component ) {
        var flowName = component.get( 'v.flowName' );
        if ( $A.util.isEmpty( flowName ) ) {
            return;
        }
        var p = new Promise( function( resolve, reject ) {
            $A.createComponent(
                'lightning:flow',
                {
                    'aura:id' : 'flow',
                    'onstatuschange' : component.getReference( 'c.handleFlowStatusChange' )
                },
                function( newCmp, status, errorMessage ) {
                    if ( status === 'SUCCESS' ) {
                        resolve( newCmp );
                    } else {
                        reject( errorMessage || status );
                    }
                }
            );
            
        }).then( $A.getCallback( function( newFlowCmp ) {
            
            var flowContainer = component.find( 'flowContainer' );
            flowContainer.get( 'v.body' ).forEach( function( cmp, idx ) {
                cmp.destroy();
            });
            
            flowContainer.set( 'v.body', newFlowCmp );
            var inputVariables = [
                {
                    name : 'recordId',
                    type : 'String',
                    value : component.get( 'v.recordId' )
                }
            ];
            
            newFlowCmp.startFlow( flowName, inputVariables );
            
        })).catch( $A.getCallback( function( err ) {
            
            console.error( 'Error creating flow component' );
            console.error( err );
            
        }));
        
    }
})
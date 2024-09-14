({
      handleUtilityClick : function(cmp, response) {
        console.log(response);
        if (response.panelVisible) {
            this.invokeLWC(cmp);
        }
    },
    invokeLWC : function(cmp) {
        //cmp.set('v.showLWC', true);
        cmp.find('lwcComp').initFunction();
        
    }

})
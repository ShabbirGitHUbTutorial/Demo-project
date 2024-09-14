({
    refreshDash : function(component, event, helper) {
        var dashboard = component.find('OmniDashboard');
//		optional parameter to refresh a single component only
//        var config = {
//            "step": "Total_Calls_1"
//        }
//        dashboard.refresh(config); 
	dashboard.refresh();
    }
})
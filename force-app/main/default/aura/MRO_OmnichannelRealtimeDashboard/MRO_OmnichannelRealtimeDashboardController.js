({
    doInit : function(component, event, helper) {
        setInterval(function(){helper.refreshDash(component, event, helper);}, component.get("v.refreshinterval"));
    }
})
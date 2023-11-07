({
    doInit : function(component, event, helper) {
        debugger;
       
        component.set("v.recordId", component.get("v.recordId"));
       
    },
    handleEvent : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
	}
})
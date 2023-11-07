({
    navigateToMyComponent : function(component, event, helper) {
        debugger;
        var recId = component.get("v.recordId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:DesignManagedProductCmp",
            componentAttributes: {
                quoteId : recId
            }
        });
        evt.fire();
    }
})
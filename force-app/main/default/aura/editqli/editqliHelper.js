({
    helperMethod: function (component) {
        debugger;
        var bundleQLI = component.get("v.bundleQLI");
        var action = component.get("c.editLineItems");

        action.setParams({
            bundleQLI : bundleQLI
        })

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                debugger;
                component.set("v.bundleParentQLIList", response.getReturnValue().availableQuoteLineList);
                //console.log()
            }
        })

        $A.enqueueAction(action);
    }
})
({
    doInit : function(component, event, helper) {
        var action = component.get("c.submitForApproval");
        action.setParams({
            "recordId": component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");    
                toastEvent.setParams({
                    "title": "Success!",
                    "message": " Your Lead have been Sent for Approval successfully!!"
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }else{
                var errorMessage = response.getError()[0].message;
                console.log(errorMessage);
                debugger;
                var toastEvent = $A.get("e.force:showToast");    
                toastEvent.setParams({
                    "title": "Error!",
                    "message": errorMessage
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
})
({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.convertLeadMethod");
        action.setParams({
            "recordId": component.get("v.recordId")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var recId = response.getReturnValue();
                if(recId.length == 15 || recId.length == 18){
                    var toastEvent = $A.get("e.force:showToast");    
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": " Your Lead have been Converted successfully!!"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recId,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                    dismissActionPanel.fire();  
                }else{
                    //var errorMessage = response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");    
                    toastEvent.setParams({
                        "title": "Error",
                        "type": "error",
                        "message": recId
                    });
                    toastEvent.fire();
                    // Close the action panel
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    dismissActionPanel.fire();
                }
                
            }else{
                var errorMessage = response.getError()[0].message;
                var toastEvent = $A.get("e.force:showToast");    
                toastEvent.setParams({
                    "title": "Error!",
                    "message": errorMessage
                });
                toastEvent.fire();
                // Close the action panel
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
            
        });
        $A.enqueueAction(action);
    },
    
})
({
    doInit : function(component) {        
        var pickvar = component.get("c.getPickListValuesIntoList");
        pickvar.setParams({recordId : component.get('v.recordId')});
        pickvar.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                var list = response.getReturnValue();
                component.set("v.picvalue", list);
            }
            else if(state === 'ERROR'){
                //var list = response.getReturnValue();
                //component.set("v.picvalue", list);
                alert('ERROR OCCURED.');
            }
        })
        $A.enqueueAction(pickvar);
    },
    
    
    handleSubmit : function(component){
        debugger;
        var recordId = component.get("v.recordId");
        var leadRec = component.get("v.LeadRec");
        var action = component.get("c.updateLeadStatus");
        action.setParams({
            leadRec: leadRec,
            recordId:recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                if(response.getReturnValue() == 'Success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "The record has been updated successfully."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();    
                }else if(response.getReturnValue().length == 15 || response.getReturnValue().length == 18){
                    var toastEvent = $A.get("e.force:showToast");    
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": " Your Lead have been Converted successfully!!"
                    });
                    toastEvent.fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
                    
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response.getReturnValue(),
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                    dismissActionPanel.fire();  
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title" : 'Error',
                        "type": 'error',
                        "message": response.getReturnValue()
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();    
                    $A.get("e.force:closeQuickAction").fire();
                }
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();    
                $A.get("e.force:closeQuickAction").fire();
            }
        })
        $A.enqueueAction(action);
    },
    
    
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire()
        
    }
})
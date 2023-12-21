({
    handleSubmit : function(component, event, helper) {
        debugger;
        var action = component.get("c.docApproval");
        action.setParams({
            "oppId" : component.get("v.recordId"),
            "comment" : component.find("comnt").get("v.value"),
        });
        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var resp = response.getReturnValue();
                if(resp === 'Quote not approved'){
                    var errors= response.getError();
                    console.log("ERROR: ", errors);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Quote is not Accepted yet',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'sticky'
                    });
                }
                else if(resp === 'Success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Record is submitted for Document Verfication',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                }
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            }
            else{
                var errors= response.getError();
                console.log("ERROR: ", errors);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error in Submitting',
                    message: errors[0].message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'sticky'
                });
                toastEvent.fire();
            }
            
        }, 'ALL' );
        $A.enqueueAction(action);
    },
    
    CloseQuickAction : function(Component, helper, event){
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})
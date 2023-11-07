({
    doInit : function(component, event, helper) {
        debugger;       
        var action = component.get("c.getData");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var State = response.getState();
            if(State === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.WrapperRecord", result);
            }
        });
        $A.enqueueAction(action);	
    },
    
    doSave : function(component,event,helper){
        debugger;
        var oppRec = component.get("v.WrapperRecord").opp;
        var accRec = component.get("v.WrapperRecord").acc;
        
        var action = component.get("c.updateData");
        action.setParams({
            "acc": accRec,
            "opp" : oppRec
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Need Amendment Done Successfully!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            } 
            else{
                var errors= response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:errors[0].message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    doCancel : function(component, helper, event){
        debugger;        
        $A.get("e.force:closeQuickAction").fire();   
    } 
})
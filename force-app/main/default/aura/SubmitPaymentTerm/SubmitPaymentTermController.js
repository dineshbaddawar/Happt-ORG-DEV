({
	doInit : function(component, event, helper) {
		debugger;
        var action = component.get("c.paymentTermApproverLogic");
        action.setParams({
            quoteId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'SUCCESS',
            message: 'Payment Term Submitted Successfully  !',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
	}
})
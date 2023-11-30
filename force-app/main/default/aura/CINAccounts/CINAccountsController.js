({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.getAccount");
        
        action.setParams({
            "recordId" : component.get('v.recordId')
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result= response.getReturnValue();
                if(result != null && result != undefined){
                    component.set("v.accListWithsimCIN", result[0].SimCINAccountList);
                    component.set("v.accListWithsimDomain", result[0].SimDomAccountList);
                    component.set("v.leadListWithsimDomain", result[0].SimDomLeadList);
                }
                else{
                    component.set("v.showImage", true);
                }
            }
            
        });      
        $A.enqueueAction(action);
    },
    tagAccount : function(component, event, helper) {
        debugger;
        var field = event.getSource();
        var recordId = field.get("v.value");
        var action = component.get("c.tagAccountToLead");
        action.setParams({
            "leadId" : component.get('v.recordId'),
            "accId" : recordId,
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The Lead Has tagged successfully."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
        });      
        $A.enqueueAction(action);
    }
})
({
	getChildQLI : function(component) {
        debugger;
		var quoteId = component.get("v.quoteId");
        var action = component.get("c.getChildqli");
        
        action.setParams({
            qliId : quoteId
        })
        
        action.setCallback(this,function(response){
            var state = response.getState();
            var response = response.getReturnValue();
            if(state == 'SUCCESS') {
                debugger;
                    component.set("v.childqlilist", response);
                
            }
        });
        $A.enqueueAction(action);
	}
})
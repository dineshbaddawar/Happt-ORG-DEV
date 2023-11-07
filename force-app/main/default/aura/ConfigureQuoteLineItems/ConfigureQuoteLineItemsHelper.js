({
	getQuoteDetails : function(component) {
		var recId='0Q0C20000001iILKAY';
        
        var action = component.get('c.getQuoteDetails');
        action.setParams({"quoteId" : recId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                    var responseValue = response.getReturnValue();
                    component.set("v.quoteDetails",responseValue);
              }
        });
        
        $A.enqueueAction(action);
	},
    getQuoteLineItems : function(component){
        var recId='0Q0C20000001iILKAY';
        var action = component.get("c.getQuoteLineItems");
        action.setParams({"QuoteId":recId});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state==='SUCCESS'){
                
            }
        })
    }
})
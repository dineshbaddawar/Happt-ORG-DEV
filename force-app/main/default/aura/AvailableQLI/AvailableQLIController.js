({
    HandleDelete:function(component,event,helper){
        debugger;
         var spinner=component.get("v.show");
         component.set("v.show",true);
        var recId = event.currentTarget.dataset.id;
         var action = component.get("c.deleteQliLineItems");
          action.setParams({ 
            "recordId" : recId 
          });
        action.setCallback(this, function(response) {
            var state = response.getState();
              if(state==='SUCCESS'){
                   component.set("v.show",false);
                    $A.get('e.force:refreshView').fire();
              }   
        });
        $A.enqueueAction(action); 
    },
    HandleLineItems:function(component,event,helper){
        debugger;
        var recId = event.currentTarget.dataset.id;
        var action = component.get("c.ConfigureLineItem1");
          action.setParams({ 
            "qliId" : recId 
          });
        action.setCallback(this, function(response) {
            var state = response.getState();
              if(state==='SUCCESS'){
                    //$A.get('e.force:refreshView').fire();
                    var responseValue = response.getReturnValue();
                    console.log('responseValue--',JSON.stringify(responseValue));
                  
                 
                  var QuoteComponentEvent = component.getEvent('ConfiguredProdId');
                  // Setting the attribute of event using setParams()
                  // 
                  QuoteComponentEvent.setParams({
                      SelectedOptions: responseValue,
                      SelectedQLiId:recId
                  });
                  // Firing the event
                  QuoteComponentEvent.fire();
              }   
        });
        $A.enqueueAction(action); 
        
    },
   
})
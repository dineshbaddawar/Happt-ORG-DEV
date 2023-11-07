({
    inlineEditDescription : function(component,event,helper){   
        debugger;
        component.set("v.EditMode", true); 
        setTimeout(function(){ 
            component.find("inputId").focus();
        }, 100);
    },
    
    inlineEditQuantity : function(component,event,helper){   
        debugger;
        component.set("v.EditEmail", true); 
        setTimeout(function(){ 
            component.find("inputId1").focus();
        }, 100);
    },
    
    inlineEditDiscount : function(component,event,helper){   
        debugger;
        component.set("v.EditDescription", true); 
        setTimeout(function(){ 
            component.find("Descriptioninput").focus();
        }, 100);
    },
    
    onDescriptionChange : function(component,event,helper){ 
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        debugger;
       // if(event.getSource().get("v.value") != undefined && event.getSource().get("v.value").trim() != ''){ 
            //component.set("v.showSaveCancelBtn",true);
       // }
    },
    
    
    closeDescriptionBox : function (component, event, helper) {
        debugger;
        // on focus out, close the input section by setting the 'nameEditMode' att. as false   
        component.set("v.EditMode", false); 
        // check if change/update Name field is blank, then add error class to column -
        // by setting the 'showErrorClass' att. as True , else remove error class by setting it False   
        if(event.getSource().get("v.value") != undefined && event.getSource().get("v.value").trim() == ''){
            component.set("v.showErrorClass",true);
        }else{
            component.set("v.showErrorClass",false);
        }
    },
    
    closeQuantityBox : function (component, event, helper) {
        debugger;
        component.set("v.EditEmail", false); 
        if(event.getSource().get("v.value") != undefined && event.getSource().get("v.value").trim() == ''){
            component.set("v.showErrorClass",true);
        }else{
            component.set("v.showErrorClass",false);
        }
    },
    
    onQuantityChange : function(component,event,helper){ 
        debugger;
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        if(event.getSource().get("v.value") != undefined && event.getSource().get("v.value").trim() != ''){ 
            //component.set("v.showSaveCancelBtn",true);
        }
    },
    
    closeDiscountBox : function (component, event, helper) {
        debugger;
        component.set("v.EditDescription", false); 
        if(event.getSource().get("v.value") != undefined && event.getSource().get("v.value").trim() == ''){
            component.set("v.showErrorClass",true);
        }else{
            component.set("v.showErrorClass",false);
        }
    },
    
    onDiscountChange : function(component,event,helper){ 
         debugger;
        // if edit field value changed and field not equal to blank,
        // then show save and cancel button by set attribute to true
        if(event.getSource().get("v.value") != undefined &&  event.getSource().get("v.value").trim() != ''){ 
           // component.set("v.showSaveCancelBtn",true);
        }
    },
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
        //var existingqli = component.get("c.QuoteLineItemlist");
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
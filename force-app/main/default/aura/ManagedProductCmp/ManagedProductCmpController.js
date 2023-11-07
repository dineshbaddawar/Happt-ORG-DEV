({
    doInit : function(component, event, helper) {
        debugger;
        var quoteId = component.get("v.quoteId");
        var action = component.get("c.fetchQuoteDetailsAndQLIs");
        action.setParams({ 
            QuoteId : quoteId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var response = response.getReturnValue();
            if(state == 'SUCCESS') {
                if(response.QuoteLineItemList.length > 0){
                    component.set("v.quoteItemList", response.QuoteLineItemList);
                }
                component.set("v.AccountName", response.quoteRecDetails.Account.Name);
                component.set("v.QuoteName", response.quoteRecDetails.Name);
                component.set("v.OpportunityName", response.quoteRecDetails.Opportunity.Name);
            }
            
        });
        $A.enqueueAction(action);
    },
    
    selectedValue : function(component, event, helper) {
        var selValue = component.get("v.productType");
        if(selValue=='Travel'){
            component.set("v.selectedprodType", true);
        }
        else if (selValue=='Expense'){
            component.set("v.selectedprodType", false);
        }
    },
    
    calculateCommitment : function(component, event, helper) {
        helper.calculateCommitment(component, event, helper);
    },
    
    getAllProducts : function(component, event, helper) {
        debugger;
        helper.getAllProducts(component, event, helper);
    },
    
    getAccountType : function (component, event, helper) {
        debugger;
        helper.getAccountType(component, event, helper);
        var a = component.get('c.getAllProducts');
        $A.enqueueAction(a);
        
    },
    
    handleSectionToggle: function (component, event, helper) {
        debugger;
        var keyList = component.get("v.activeSections");
        var openSections = event.getParam('openSections');
        
    },
    
    addProductsAgain: function (component, event, helper) {
        debugger;
        component.set("v.selectedprodType", 'Expense');
    },
    
    computeTax: function (component, event, helper) {
        debugger;
        helper.computeTax(component, event, helper);
    },
    
    SaveQLI: function (component, event, helper) {
        debugger;
        helper.SaveQLI(component, event, helper);
    },
    
    navigateBackToQuote  : function(component, event, helper) {
        debugger;
        var quoteId = component.get("v.quoteId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": quoteId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    
})
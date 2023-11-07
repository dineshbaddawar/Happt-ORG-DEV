({
    doInit : function(component, event, helper) {
        debugger;
        var quoteId = component.get("v.quoteId");
        
        /*var bundleAction = component.get("c.getBundleProducts");
        bundleAction.setParams({
            quoteId :quoteId
        })
        bundleAction.setCallback(this,function(response){
            var bundleState = response.getState();
            var bundleResponse = response.getReturnValue();
            if(bundleState == 'SUCCESS'){
                component.set("v.bundleList",response.bundleQLI)
            }
        })*/
        var action = component.get("c.fetchQuoteDetailsAndQLIs");
        action.setParams({ 
            QuoteId : quoteId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            var response = response.getReturnValue();
            if(state == 'SUCCESS') {
                debugger;
                if(response.availableQuoteLineList.length > 0){
                    component.set("v.bundleList",response.bundleQLIList);
                    component.set("v.bundleQLI",response.bundleQLI);
                    component.set("v.quoteItemList", response.availableQuoteLineList);
                    component.set("v.childMap",response.mapOfNestedProdIdByListOfPLDTobeReturn);
                    
                }
                debugger;
                component.set("v.AccountName", response.quoteRecDetails.Account.Name);
                component.set("v.QuoteName", response.quoteRecDetails.Name);
                component.set("v.OpportunityName", response.quoteRecDetails.Opportunity.Name);
                component.set("v.SaasDiscount", response.quoteRecDetails.SAAS_Discount__c);
                component.set("v.OTIDiscount", response.quoteRecDetails.OTI_Discount__c);
                component.set("v.TotalOTI", response.quoteRecDetails.SAAS_Discount__c);
                component.set("v.TotalSAAS", response.quoteRecDetails.OTI_Discount__c);
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
    handleClickAddProduct: function(component, event, helper) {
        debugger;
        component.set("v.ShowQuoteLineItems", false);
        var ProdScreen= component.get("v.ShowProducts");
        component.set("v.ShowProducts", true);
       
        if(component.get("v.selectedofferingType")!=null || component.get("v.selectedofferingType")!=undefined){
            component.set("v.selectedofferingType",'');
        }
        if(component.get("v.selectedpricingType")!=null || component.get("v.selectedpricingType")!=undefined){
            component.set("v.selectedpricingType",'');
        }
        if(component.get("v.numberOfBookings")!=null || component.get("v.numberOfBookings")!=undefined){
            component.set("v.numberOfBookings",0);
        }
        if(component.get("v.minimumCommitment")!=null || component.get("v.minimumCommitment")!=undefined){
            component.set("v.minimumCommitment",0);
        }
        
        //component.set("v.showProductListCmp", false);
    },
    NavigateBackToQuotelineItem:function(component, event, helper) {
         debugger;
        component.set("v.ShowQuoteLineItems", true);
       // component.set("v.ShowProducts", false);
        component.set("v.showProductListCmp", false);
    },
    navigateToQuoteLine:function(component, event, helper) {
        component.set("v.ShowQuoteLineItems", true);
        component.set("v.ShowProducts", false);
    },
    handleEdit:function(component, event, helper) {
        debugger;
         //helper.getAllProducts(component, event, helper);
    },
    editProduct: function (component, event, helper) {
        debugger;
        
        helper.editQLI(component, event, helper);
        
    }
    
})
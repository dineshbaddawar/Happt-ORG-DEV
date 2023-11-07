({
    calculateCommitment : function(component, event, helper) {
        debugger;
        var offType = component.get("v.selectedofferingType");
        var pricingType = component.get("v.selectedpricingType");
        var numOfBookings = parseInt(component.get("v.numberOfBookings"));
        var commitment = '';
        if(pricingType == 'Per Trip'){
            if(numOfBookings != null && ((numOfBookings * 35)/100 < 4000)){
                commitment = 4000;
            }else{
                commitment = (numOfBookings * 35)/100;
            }
        }else if(pricingType == 'Per Booking'){
            if(numOfBookings != null && ((numOfBookings * 30)/100 < 5000)){
                commitment = 5000;
            }else{
                commitment = (numOfBookings * 30)/100;
            }
        }else if(pricingType == 'Non SBT Per Trip'){
            if(numOfBookings != null && ((numOfBookings * 35)/100 < 4000)){
                commitment = 4000;
            }else{
                commitment = (numOfBookings * 35)/100;
            }
        }else if(pricingType == 'Per Report'){
            if(numOfBookings != null && numOfBookings < 10000){
                commitment = 10000;
            }else{
                commitment = numOfBookings;
            }
        }
        component.set("v.minimumCommitment", commitment);
    },
    
    getAllProducts : function(component, event, helper) {
        debugger;
        var accType = component.get("v.accTypeCalculated");
        var prodID = component.get("v.selected")[0].Id;
        var offType = component.get("v.selectedofferingType");
        var pricingType = component.get("v.selectedpricingType");
        var numOfBookings = parseInt(component.get("v.numberOfBookings"));
        var minCommitment = parseInt(component.get("v.minimumCommitment"));
        let bundleQLI = [];
        if(component.get("v.bundleQLI") != undefined){
            bundleQLI.push(component.get("v.bundleQLI"));
        }
        
        var qliInst = component.get("v.quoteItemInstance");
        qliInst.Travel_Offering_Type__c = offType;
        qliInst.Travel_Pricing_Type__c = pricingType;
        qliInst.Account_Type__c = accType;
        var action = component.get("c.fetchProductAndProductBundle");
        action.setParams({ 
            productId : prodID,
            sampleQuoteLineItem : qliInst
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state == 'SUCCESS') {
                //Travel Flow
                if(prodID == '01tC20000008E4DIAU'){//remoce product hardcode maintain the product type at product level Travel/
                    bundleQLI.push(response.getReturnValue().bundleQLI);
                    component.set('v.bundleQLI',response.getReturnValue().bundleQLI);
                    component.set('v.mapOfNestedProdIdByListOfPLDTobeReturn', response.getReturnValue().mapOfNestedProdIdByListOfPLDTobeReturn);
                    component.set('v.mapOfProdIdbyListOfPLDTobeReturn', response.getReturnValue().mapOfProdIdbyListOfPLDTobeReturn);
                    
                    var arrayMapKeys = [];
                    for (var key in response.getReturnValue().mapOfProdIdbyListOfPLDTobeReturn) {
                        arrayMapKeys.push(key);
                    }
                    //Set the list of keys.     
                    component.set('v.keyList', arrayMapKeys);
                    component.set('v.activeSections', arrayMapKeys);
                    
                    component.set('v.showProductListCmp',true);
                    component.set('v.isTravelProduct', true);
                }
                //Expense Flow 
                if(prodID == '01tC20000007Z5tIAE'){ //remoce product hardcode
                    bundleQLI.push(response.getReturnValue().bundleQLI);
                    component.set("v.finalBundleProdList",bundleQLI);
                    component.set('v.expenseBundleQLI',response.getReturnValue().bundleQLI);
                    component.set('v.expensemapOfNestedProdIdByListOfPLDTobeReturn', response.getReturnValue().mapOfNestedProdIdByListOfPLDTobeReturn);
                    component.set('v.expensemapOfProdIdbyListOfPLDTobeReturn', response.getReturnValue().mapOfProdIdbyListOfPLDTobeReturn);
                    
                    var arrayMapKeys = [];
                    for (var key in response.getReturnValue().mapOfProdIdbyListOfPLDTobeReturn) {
                        arrayMapKeys.push(key);
                    }
                    //Set the list of keys.     
                    component.set('v.expensekeyList', arrayMapKeys);
                    //component.set('v.activeSections', arrayMapKeys);
                    component.set('v.showProductListCmp',true);
                    component.set('v.isExpenseProduct', true);
                }
            }
        });
            component.set("v.finalBundleProdList",bundleQLI);
            component.set("v.ShowProducts", false);
            component.set("v.ShowQuoteLineItems", false);
        $A.enqueueAction(action);
    },
    
    getAccountType : function(component, event, helper) {
        var prodID = component.get("v.selected")[0].Id;
        var offType = component.get("v.selectedofferingType");
        var pricingType = component.get("v.selectedpricingType");
        var numOfBookings = parseInt(component.get("v.numberOfBookings"));
        var minCommitment = parseInt(component.get("v.minimumCommitment"));
        var accountType = '';
        if(prodID != '01tC20000007Z5tIAE' && (offType == '' || offType == undefined)){
            alert('Kindly select offering type to proceed');
            return;
        }
        
        if(pricingType == '' || offType == pricingType){
            alert('Kindly select Pricing type to proceed');
            return;
        }
        
        if(minCommitment == '' || minCommitment == undefined){
            alert('Kindly fill minimum commitment to proceed');
            return;
        }
        
        if(numOfBookings == '' || numOfBookings == undefined){
            alert('Kindly fill number of booking to proceed');
            return;
        }
        
        //If (expense || Travel)
        
        if(pricingType == 'Per Booking'){
            if(numOfBookings > 36000){
                accountType = 'Large';
            }else if (numOfBookings > 20000 && numOfBookings < 36000){
                accountType = 'Medium Large';
            }else if(numOfBookings > 12000 && numOfBookings < 20000){
                accountType = 'Medium';
            }else if(numOfBookings > 0 && numOfBookings < 12000){
                accountType = 'Small';
            }
        }else if(pricingType == 'Per Trip'){
            if(numOfBookings > 12000){
                accountType = 'Large';
            }else if (numOfBookings > 7000 && numOfBookings < 12000){
                accountType = 'Medium Large';
            }else if(numOfBookings > 4000 && numOfBookings < 7000){
                accountType = 'Medium';
            }else if(numOfBookings > 0 && numOfBookings < 4000){
                accountType = 'Small';
            }
        }else if(pricingType == 'Per Report'){
            if(numOfBookings > 50400){
                accountType = 'Large';
            }else if (numOfBookings > 36000 && numOfBookings < 50400){
                accountType = 'Medium Large';
            }else if(numOfBookings > 15000 && numOfBookings < 36000){
                accountType = 'Medium';
            }else if(numOfBookings > 0 && numOfBookings < 15000){
                accountType = 'Small';
            }
        }else if(pricingType == 'Non SBT Per Trip'){
            if(numOfBookings > 12000){
                accountType = 'Large';
            }else if (numOfBookings > 7000 && numOfBookings < 12000){
                accountType = 'Medium Large';
            }else if(numOfBookings > 4000 && numOfBookings < 7000){
                accountType = 'Medium';
            }else if(numOfBookings > 0 && numOfBookings < 4000){
                accountType = 'Small';
            }
        }
        component.set("v.accTypeCalculated", accountType);
        component.set("v.selectedprodType", '-None-');
    },
    
    computeTax : function(component, event, helper) {
        debugger;
        /*var qliList = component.get("v.qliList");
        var relatedList = component.get("v.relatedList");*/
      //Copied The Code From Save Qli  
        var quoteId = component.get("v.quoteId");
        var expenseQliList = component.get("v.expenseQliList");
        var expenseChildQliList = component.get("v.expenseChildQliList");
        var allExpenseQli = [];
        
        if(expenseQliList.length > 0){
            for (let i = 0; i < expenseQliList.length; i++) {
                allExpenseQli.push( expenseQliList[i]) ;
            }
        }
        if(expenseChildQliList.length > 0){
            for (let i = 0; i < expenseChildQliList.length; i++) {
                var abc = JSON.parse(JSON.stringify(expenseChildQliList[i]));
                allExpenseQli.push(abc) ;
            }
        }
        
        var qliList = component.get("v.qliList");
        var childQliList = component.get("v.childQliList");
        //var allTravelQli = qliList.concat(childQliList);
        
        var allTravelQli = [];
        
        if(qliList.length > 0){
            for (let i = 0; i < qliList.length; i++) {
                allTravelQli.push( qliList[i]) ;
            }
        }
        if(childQliList.length > 0){
            for (let i = 0; i < childQliList.length; i++) {
                var abc = JSON.parse(JSON.stringify(childQliList[i]));
                allTravelQli.push(abc) ;
            }
        }
        
        var allQli = allExpenseQli.concat(allTravelQli);
        
        for (let i = 0; i < allQli.length; i++) {
            allQli[i].QuoteId = quoteId;
        }
        
        var action = component.get("c.calculateTravelQuoteLineItems");
        action.setParams({ 
            quoteLineItemList : allQli,
            saveFunction : false
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state == 'SUCCESS') {
                var abc = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The tax has been calculated succesfully!!"
                });
                toastEvent.fire();
            }
            
        });
        $A.enqueueAction(action);
    },
    
    SaveQLI : function(component, event, helper){
        debugger;
        var quoteId = component.get("v.quoteId");
        var expenseQliList = component.get("v.expenseQliList");
        var expenseChildQliList = component.get("v.expenseChildQliList");
        var bundleQLI = component.get("v.finalBundleProdList");
        
        for(let i=0;i<bundleQLI.length;i++){
            bundleQLI[i].QuoteId = quoteId;
        }
        //bundleQLI.QuoteId = quoteId;
        var allExpenseQli = [];
        
        if(expenseQliList.length > 0){
            for (let i = 0; i < expenseQliList.length; i++) {
                allExpenseQli.push( expenseQliList[i]) ;
            }
        }
        if(expenseChildQliList.length > 0){
            for (let i = 0; i < expenseChildQliList.length; i++) {
                var abc = JSON.parse(JSON.stringify(expenseChildQliList[i]));
                allExpenseQli.push(abc) ;
            }
        }
        
        var qliList = component.get("v.qliList");
        var childQliList = component.get("v.childQliList");
        //var allTravelQli = qliList.concat(childQliList);
        
        var allTravelQli = [];
        
        if(qliList.length > 0){
            for (let i = 0; i < qliList.length; i++) {
                allTravelQli.push( qliList[i]) ;
            }
        }
        if(childQliList.length > 0){
            for (let i = 0; i < childQliList.length; i++) {
                var abc = JSON.parse(JSON.stringify(childQliList[i]));
                allTravelQli.push(abc) ;
            }
        }
        
        var allQli = allExpenseQli.concat(allTravelQli);
        
        for (let i = 0; i < allQli.length; i++) {
            allQli[i].QuoteId = quoteId;
        }
        var action = component.get("c.calculateTravelQuoteLineItems");
        action.setParams({ 
            quoteLineItemList : allQli,
            saveFunction : true,
            bundleQLI : bundleQLI
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state == 'SUCCESS') {
                var abc = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
            }
        });
        component.set("v.showProductListCmp", false);
        component.set("v.ShowProducts", false);
        component.set("v.ShowQuoteLineItems", true);
        
        $A.enqueueAction(action);
    },

    editQLI: function (component, event, helper) {
        debugger;
        var allBundleList = component.get("v.bundleList");
        var bundleQLIID = event.target.id;

        for (let i = 0; i < allBundleList.length;i++){
            if (bundleQLIID == allBundleList[i].Id) {
                component.set("v.editBundleQLI", allBundleList[i]);
            }
        }
        /*var action = component.get("c.editLineItems");

        action.setParams({
            bundleQLI : bundleQLI
        })

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state == 'SUCCESS') {
                debugger;
                component.set("v.bundleParentQLIList", response.getReturnValue().availableQuoteLineList);
                //console.log()
            }
        })*/
        component.set("v.editProdct", true);
        $A.enqueueAction(action);
        
    }
    
    
})
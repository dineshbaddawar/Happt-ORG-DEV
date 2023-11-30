({
    getFeatureList: function (component) {
        debugger;
        var action = component.get("c.getAllFeaturesFromProduct");
        var self = this;
        action.setParams({ ProductIdsList : component.get("v.productIds") });
        action.setCallback(this, function (actionResult) {
            var state = actionResult.getState();
            if (component.isValid() && state === "SUCCESS") {
                console.log('Data::' + actionResult.getReturnValue());
                let featureList = actionResult.getReturnValue();
                const letters = [];
                for (var i = 0; i < featureList.length;i++){
                    if (!letters.includes(featureList[i].Category__c)) {
                        letters.push(featureList[i].Category__c);
                    }
                }
                component.set("v.Categories", letters);
                component.set("v.contacts", actionResult.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    handleClickSelect:function(component, event, helper) {
        debugger;
        var spinner=component.get("v.show");
        var selectedqli = component.get('v.QuoteLineItemRelatedToXQuote');
        var commitment=0;
        var ValueOfConfigureProduct=true;
        var ValueOfProductTableScreen=false;
        var Tempvariable=true;
        var offType=component.get("v.SelectedOffering");
        var pricingType=component.get("v.SelectedPricing");
        var accountType=component.get("v.AccountType");
        
        var proIds = component.get("v.productIds");
        
        var action = component.get("c.ShowAllOptions");
        action.setParams({ 
            'ProductIds' : component.get("v.productIds"),
            'travelOfferingType' :offType,
            'travelPricingType' : pricingType,
            'accountType':accountType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                console.log('responseValue In AllMaps--',JSON.stringify(responseValue));
                var OptionList=responseValue;
                
                for(let j=0;j<OptionList.length;j++){
                    for(let i=0;i<selectedqli.length;i++){
                        if((OptionList[j].Product__c==selectedqli[i].Product2Id) && (OptionList[j].Pricing_Type__c == selectedqli[i].Travel_Pricing_Type__c) && (OptionList[j].Travel_Offering_Type__c == selectedqli[i].Travel_Offering_Type__c)){
                            OptionList[j].Selected__c = true;
                            OptionList[j].Id			= selectedqli[i].Id;
                            OptionList[j].SAAS_Quantity__c = selectedqli[i].SAAS_Quantity__c;
                            OptionList[j].OTI_Quantity__c = selectedqli[i].OTI_Quantity__c;
                            OptionList[j].checkbox=true;
                            OptionList[j].Sub_Type__c = selectedqli[i].Sub_Type__c;
                            if(selectedqli[i].Sub_Type__c!=null || selectedqli[i].Sub_Type__c!=undefined){
                                if(selectedqli[i].Sub_Type__c=='Pro'){
                                    OptionList[j].SAAS_Price__c=OptionList[j].SAAS_Pro_Pricing__c;
                                    OptionList[j].OTI_Price__c=OptionList[j].OTI_Pro_Pricing__c;
                                }else if(selectedqli[i].Sub_Type__c=='Custom API'){
                                    OptionList[j].SAAS_Price__c=OptionList[j].SAAS_Custome_API_Pricing__c;
                                    OptionList[j].OTI_Price__c=OptionList[j].OTI_Custome_API_Price__c;
                                }else if(selectedqli[i].Sub_Type__c=='API'){
                                    OptionList[j].SAAS_Price__c=OptionList[j].SAAS_API_Pricing__c;
                                    OptionList[j].OTI_Price__c=OptionList[j].OTI_API_Pricing__c;
                                }else if(selectedqli[i].Sub_Type__c=='SFTP'){
                                    OptionList[j].SAAS_Price__c=OptionList[j].SAAS_SFTP_Pricing__c;
                                    OptionList[j].OTI_Price__c=OptionList[j].OTI_SFTP_Pricing__c;
                                }else if(selectedqli[i].Sub_Type__c=='Elite'){
                                    OptionList[j].SAAS_Price__c=OptionList[j].SAAS_Elite_Pricing__c;
                                    OptionList[j].OTI_Price__c=OptionList[j].OTI_Elite_Pricing__c;
                                }else if(selectedqli[i].Sub_Type__c=='Premium'){
                                    OptionList[j].SAAS_Price__c=OptionList[j].SAAS_Premium_Pricing__c;
                                    OptionList[j].OTI_Price__c=OptionList[j].OTI_Premium_Pricing__c;
                                }else if(selectedqli[i].Sub_Type__c=='Google Maps'){
                                    if(selectedqli[i].SAAS_Quantity__c <= 20000){
                                        OptionList[j].SAAS_Price__c=OptionList[j].Google_Maps_SAAS__c;
                                    }else if(selectedqli[i].SAAS_Quantity__c > 20000 && selectedqli[i].SAAS_Quantity__c < 50000){
                                        OptionList[j].SAAS_Price__c=7;
                                    }else if(selectedqli[i].SAAS_Quantity__c > 50000){
                                        OptionList[j].SAAS_Price__c=6;
                                    }
                                    OptionList[j].OTI_Price__c=OptionList[j].Google_Maps_OTI__c; 
                                }else if(selectedqli[i].Sub_Type__c=='Map My India'){
                                    if(selectedqli[i].SAAS_Quantity__c <= 20000){
                                        OptionList[j].SAAS_Price__c=OptionList[j].Map_My_India_SAAS__c;
                                    }else if(selectedqli[i].SAAS_Quantity__c > 20000 && selectedqli[i].SAAS_Quantity__c < 50000){
                                        OptionList[j].SAAS_Price__c=1.75;
                                    }else if(selectedqli[i].SAAS_Quantity__c > 50000){
                                        OptionList[j].SAAS_Price__c=1.5;
                                    }
                                    OptionList[j].OTI_Price__c=OptionList[j].Map_My_India_OTI__c;
                                }
                            }else{
                                if(selectedqli[i].Product2.Name=='Offline TMC (Cab/Train/Bus)' || selectedqli[i].Product2.Name=='Offline TMC'){
                                    if(selectedqli[i].OTI_Quantity__c > 2){
                                        OptionList[j].OTI_Price__c=25000*(selectedqli[i].OTI_Quantity__c-2); 
                                    }else if(selectedqli[i].OTI_Quantity__c <= 2){
                                        OptionList[j].OTI_Price__c=0; 
                                    }
                                    OptionList[j].SAAS_Price__c=OptionList[j].SAAS_Price__c;
                                }else {
                                    
                                    OptionList[j].IsOtiPriceEditable__c==true ? (selectedqli[i].OTI_Price__c!=0 && selectedqli[i].OTI_Price__c >0) ? OptionList[j].OTI_Price__c=(selectedqli[i].OTI_Price__c/selectedqli[i].OTI_Quantity__c) : OptionList[j].OTI_Price__c=OptionList[j].OTI_Price__c:OptionList[j].OTI_Price__c=OptionList[j].OTI_Price__c;
                            		OptionList[j].IsSaasPriceEditable__c==true ? (selectedqli[i].SAAS_Price__c!=0 && selectedqli[i].SAAS_Price__c >0) ? OptionList[j].SAAS_Price__c=(selectedqli[i].SAAS_Price__c/selectedqli[i].SAAS_Quantity__c) : OptionList[j].SAAS_Price__c=OptionList[j].SAAS_Price__c:OptionList[j].SAAS_Price__c=OptionList[j].SAAS_Price__c; 
                                }
                            }
                            commitment=selectedqli[i].Minimum_Commitment__c;
                            break;
                        } else{
                            OptionList[j].checkbox=false 
                        } 
                    }
                    
                }
                component.set("v.show", false);
                component.set("v.SelectedProductOptions",OptionList);
                
            }   
        });
        $A.enqueueAction(action);
        
    },
    handleSaveProduct:function(component, event, helper) {
        debugger;
        var allOption = component.get("v.SelectedProductOptions");
        var Temprec=component.get("v.selectedQLI");
        var QliId=component.get("v.deleteqliId");
        var finalSelected = [];
        var QuoteComponentEvent = component.getEvent('featuresXOptions');
        
        
        if(Temprec.length !=0){
            for(var i=0;i<Temprec.length;i++){
                if(!Temprec[i].checkbox && Temprec[i].checkbox!=undefined){
                    if(finalSelected.find(item=>item.Id==Temprec[i].Id)){
                        console.log('This Id Exists') 
                    }else{
                        finalSelected.push(Temprec[i]);
                    } 
                    
                    console.log('Temprec::'+finalSelected);
                }
            }
        }
        if(allOption.length != 0){
            for(var i=0;i<allOption.length;i++){
                if(allOption[i].Selected__c){
                    if(finalSelected.find(item=>item.Id==allOption[i].Id)){
                        console.log('This Id Exists') 
                    }else{
                        finalSelected.push(allOption[i]);
                    }   
                }
            }
        }
        
        QuoteComponentEvent.setParams({
            SelectedOptions: finalSelected,
            DeleteQLiId:QliId
        });
        // Firing the event
        QuoteComponentEvent.fire();
        
        
    }
});
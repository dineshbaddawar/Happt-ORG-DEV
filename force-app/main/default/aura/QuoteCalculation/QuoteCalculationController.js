({
    doInit : function(component, event, helper){
        debugger;
        var spinner=component.get("v.show");
        component.set("v.show",true);
        component.set("v.NumberOfBookingLabel","Number of Bookings");
        var ValueOfQuoteScreen=true;
        var ValueOfTableScreen=false;
        var NotNestedQuoteLineItme=[];
        var action = component.get("c.QuoteLineItemRecs");
        action.setParams({ 
            "recordId" : component.get("v.QuoterecordId")
            
        });
        //component.get("v.recordId")
        //var quoteRecId=component.get("v.recordId");
        //console.log('quoteRecId',JSON.stringify(quoteRecId));
        //component.set("v.QuoterecordId",quoteRecId);
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                
                var responseValue = response.getReturnValue();
                var QuoteLineItemList=responseValue;
                component.set("v.QuoteLineItemRelatedToXQuote",QuoteLineItemList);
                component.set("v.AllQuoteLineItemlist",QuoteLineItemList);
                
                for(let i=0;i<QuoteLineItemList.length;i++){
                    if(QuoteLineItemList[i].Nested_Parent_Product__c==null){
                        NotNestedQuoteLineItme.push(QuoteLineItemList[i]);
                    }
                }
                component.set("v.QuoteLineItemlist",NotNestedQuoteLineItme);
                
            } 
            
        }); 
        component.set("v.ProductTableScreen",ValueOfTableScreen);
        component.set("v.QuoteTableScreen",ValueOfQuoteScreen);
        component.set("v.show",false);
        //$A.get('e.force:refreshView').fire();
        
        var quote = component.get('c.FetchQuote');
        $A.enqueueAction(quote);
        
        var message = component.get('c.ErrorMessage');
        $A.enqueueAction(message);
        
        $A.enqueueAction(action);
        
    },
    FetchQuote:function(component, event, helper){
        debugger;
        var action = component.get("c.QuoteRec");
        action.setParams({ 
            "QuoteId" : component.get("v.QuoterecordId")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                console.log('responseValue Quote--',responseValue);
                component.set("v.QuoteObject", responseValue);
                
                component.set("v.AccountName", responseValue.Account.Name);
                console.log('responseValue Quote--',responseValue.Account.Name);
                component.set("v.QuoteName", responseValue.Name);
                console.log('responseValue Quote--',responseValue.Name);
                component.set("v.TotalOTI", responseValue.Total_OTI_Price__c);
                console.log('responseValue Quote--',responseValue.Total_OTI_Price__c);
                component.set("v.TotalSAAS", responseValue.Total_SAAS_Price__c);
                console.log('responseValue Quote--',responseValue.Total_SAAS_Price__c);
                
                component.set("v.ExpenseTotalOTI", responseValue.Expense_Total_OTI__c);
                component.set("v.ExpenseTotalSAAS", responseValue.Expense_Total_SAAS__c);
                component.set("v.TravelTotalSAAS", responseValue.Travel_Total_SAAS__c);
                component.set("v.TravelTotalOTI", responseValue.Travel_Total_OTI__c);
                
                component.set("v.TravelDiscount", responseValue.Travel_Discount__c);
                component.set("v.ExpenseDiscount", responseValue.Expense_Discount__c);
            }   
        });
        $A.enqueueAction(action);
    },
    ErrorMessage:function(component, event, helper) {
        var action = component.get("c.returnMessage");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                component.set("v.QuantityError", responseValue.quantityerrorMessage);
                console.log('responseValue QuantityError--',responseValue.quantityerrorMessage);
                component.set("v.ProductError", responseValue.ProductErrorMessage);
                console.log('responseValue ProductError--',responseValue.ProductErrorMessage);
                
            }   
        });
        $A.enqueueAction(action);
    },
    handleClickAddProduct : function(component, event, helper) {
        debugger;
        var emptyArray=[];
        var  ValueOfQuoteScreen=false;
        var ValueOfProductTableScreen=true;
        component.set("v.QuoteTableScreen",ValueOfQuoteScreen);
        component.set("v.ProductTableScreen",ValueOfProductTableScreen);
        
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
        if(component.get("v.prodId")!=null || component.get("v.prodId")!=undefined){
            component.set("v.prodId",'');
        }
        if(component.get("v.SelectedProduct")!=null || component.get("v.SelectedProduct")!=undefined){
            component.set("v.SelectedProduct",'');
        }
        // $A.enqueueAction(action);
    },
    
    selectSinglerec: function(component, event, helper){
        debugger;
        var TempProducts=[];
        var SelectedProductIds=component.get("v.AllProductIds");
        var SelectedProducts=component.get("v.selectedProductList");
        
        var recId = event.currentTarget.dataset.id;
        
        component.set("v.AllProductIds",recId)
        
        TempProducts = component.get("v.Productlist");
        
        console.log('TempProducts--',JSON.stringify(TempProducts));
        
        if(event.target.checked){
            if(SelectedProducts.find(item=>item.Id==recId)){
                console.log('This Id Exists')
            }
            else{
                SelectedProducts.push(TempProducts.find(record => record.Id === recId));
                SelectedProductIds.push(recId);
            }    
        }else{
            SelectedProducts = SelectedProducts.filter(record => record.Id !== recId);
            SelectedProductIds=SelectedProductIds.filter(record => record !== recId);
        }
        component.set("v.selectedProductList", SelectedProducts);
        
        component.set("v.AllProductIds", SelectedProductIds);
        
        console.log('SelectedProducts--',JSON.stringify(SelectedProducts));
        console.log('SelectedProductIds--',JSON.stringify(SelectedProductIds));
        
    },
    
    //This Save Button Will Be Used Configurable Product
    handleClickSaveProduct:function(component, event, helper) {
        debugger;
        var TempEmptyArray=[];
        var  ValueOfQuoteScreen=true; 
        var ValueOfConfigureProduct=false;
        component.set("v.QuoteTableScreen",ValueOfQuoteScreen);
        component.set("v.ProductOptionScreen",ValueOfConfigureProduct);
        
        var action = component.get("c.InsertQuoteLineItem");
        action.setParams({
            "ProductList":component.get("v.selectedProductList"),
            "quoteId" : component.get("v.QuoterecordId"),
            "productOptionlist":component.get("v.SelectedOptionlist")
            
        });
        //component.get("v.recordId")
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                component.set("v.QuoteLineItemlist",responseValue);
                component.set("v.SelectedOptionlist",TempEmptyArray);
            }   
        });
        
        
        $A.enqueueAction(action);
    },
    handleEdit:function(component, event, helper) {
        debugger;
        //var recId = event.currentTarget.dataset.id;
        component.set("v.showinputfield", true);
    },
    
    handleClickSelect:function(component, event, helper) {
        debugger;
        var ValueOfConfigureProduct=true;
        var ValueOfProductTableScreen=false;
        var Tempvariable=true;
        component.set("v.ProductOptionScreen",ValueOfConfigureProduct);
        component.set("v.ProductTableScreen",ValueOfProductTableScreen);
        var proIds = component.get("v.AllProductIds");
        
        var action = component.get("c.ShowAllOptions");
        action.setParams({ 
            'ProductIds' : proIds,
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                console.log('responseValue In AllMaps--',JSON.stringify(responseValue));
                component.set("v.SelectedProductOptions",responseValue);
            }   
        });
        /*if(Tempvariable==true){
           
        var action = component.get("c.AllMaps");
        action.setCallback(this, function(response) {
            var state = response.getState();
              if(state==='SUCCESS'){
                    var responseValue = response.getReturnValue();
                    console.log('responseValue In AllMaps--',JSON.stringify(responseValue));
                    //component.set("v.SelectedProductOptions",responseValue);
              }   
        });
     }*/
        $A.enqueueAction(action);
        
    },
    selectSingleOptionRec:function(component, event, helper) {
        debugger;
        var OptionrecId = event.currentTarget.dataset.id;
        
        var TempProductOptions=[];
        
        var SelectedProductOptions=component.get("v.SelectedOptionlist");
        
        var recId = event.currentTarget.dataset.id;
        
        TempProductOptions = component.get("v.SelectedProductOptions");
        console.log('TempProductOptions--',JSON.stringify(TempProductOptions));
        
        if(event.target.checked){
            if(SelectedProductOptions.find(item=>item.Id==recId)){
                console.log('This Id Exists')
            }
            else{
                SelectedProductOptions.push(TempProductOptions.find(record => record.Id === recId));  
            }    
        }else{
            SelectedProductOptions = SelectedProductOptions.filter(record => record.Id !== recId);
        }
        component.set("v.SelectedOptionlist", SelectedProductOptions); 
        console.log('SelectedProductOptions--',JSON.stringify(SelectedProductOptions));
        
    },
    handleClickPrevious:function(component, event, helper) {
        var ValueOfConfigureProduct=false;
        var ValueOfProductTableScreen=true;       
        component.set("v.ProductOptionScreen",ValueOfConfigureProduct);
        component.set("v.ProductTableScreen",ValueOfProductTableScreen); 
    },
    handleClickCalculate:function(component, event, helper) {
        debugger;
        var TempQuoteLineItem=[];
        var TempItem=[];
        var TempQuoteLineItem=component.get("v.QuoteLineItemlist");
        
        var action = component.get("c.GetQuotelineItemlist1");
        action.setParams({ 
            "quoteLineItemRec" : TempQuoteLineItem,
            "Isinsertable":false
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                console.log('responseValue---',JSON.stringify(responseValue));
                TempItem=responseValue;
                console.log('TempItem---',JSON.stringify(TempItem));
                
            }
            for(var i=0;i<TempItem.length;i++){
                if(TempItem[i].Discount==null ){
                    TempItem[i]['NetTotal']=TempItem[i].Quantity*TempItem[i].UnitPrice;  
                }else{
                    console.log('TempItem[i].Discount---',JSON.stringify(TempItem[i].Discount));
                    let Discount=(TempItem[i].Discount/100)*TempItem[i].UnitPrice;
                    console.log('Discount---',JSON.stringify(Discount));
                    let DiscountedPrice=TempItem[i].UnitPrice-Discount;
                    console.log('DiscountedPrice---',JSON.stringify(DiscountedPrice));
                    if(DiscountedPrice!=null){
                        TempItem[i]['NetTotal']=TempItem[i].Quantity*DiscountedPrice; 
                    }  
                }
                
            }
            component.set("v.QuoteLineItemlist",TempItem);
            console.log('TempItem After Net Total---',JSON.stringify(TempItem));
        });
        $A.enqueueAction(action);
    },
    handleClickSave:function(component, event, helper) {
        debugger;
        var TempQuoteLineItem=[];
        var TempItem=[];
        var TempQuoteLineItem=component.get("v.QuoteLineItemlist");
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        
        var action = component.get("c.GetQuotelineItemlist");
        action.setParams({ 
            "quoteLineItemRec" : TempQuoteLineItem,
            "Isinsertable":true
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                console.log('responseValue---',JSON.stringify(responseValue));
                dismissActionPanel.fire(); 
                let secondAction = component.get('c.navigateBackToQuote');
                $A.enqueueAction(secondAction);
            }
            
        });
        
        $A.enqueueAction(action);
    },
    navigateBackToQuote  : function(component, event, helper) {
        debugger;
        var quoteId = component.get("v.QuoterecordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": quoteId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    handleComponentEvent : function(component, event, helper) {
        debugger;
        var spinner=component.get("v.show");
        component.set("v.show", true);
        var QuantityError= component.get("v.QuantityError");
        var DeletingId = event.getParam('DeleteQLiId');
        var totalOptions = event.getParam('SelectedOptions');
        console.log('totalIncome',JSON.stringify(totalOptions));
        
        var TempOTIQuantity=0;
        var TempSAASQuantity=0;
        var TotalQuantity=0;
        var IsTravelProd;
        for(let i=0;i<totalOptions.length;i++){
            IsTravelProd=totalOptions[i].Is_Travel_Product__c
            if(totalOptions[i].OTI_Quantity__c!=0){
                if(totalOptions[i].OTI_Quantity__c < 0 || totalOptions[i].OTI_Quantity__c==undefined){
                    totalOptions[i].OTI_Quantity__c=0;
                }
                TempOTIQuantity=parseInt(TempOTIQuantity) + parseInt(totalOptions[i].OTI_Quantity__c);
            }
            if(totalOptions[i].SAAS_Quantity__c!=0){
                if(totalOptions[i].SAAS_Quantity__c < 0 || totalOptions[i].SAAS_Quantity__c==undefined || totalOptions[i].SAAS_Quantity__c==null || totalOptions[i].SAAS_Quantity__c==NaN){
                    totalOptions[i].SAAS_Quantity__c=0;
                }
                if(totalOptions[i].SAAS_Quantity__c!='NaN'){
                    TempSAASQuantity=parseInt(TempSAASQuantity) + parseInt(totalOptions[i].SAAS_Quantity__c);
                }
                    
            }
        }
        console.log('TempOTIQuantity--',TempOTIQuantity);
        console.log('TempSAASQuantity--',TempSAASQuantity);
        TotalQuantity=TempOTIQuantity+TempSAASQuantity;
        console.log('TotalQuantity--',TotalQuantity);
        var commitment= component.get("v.Commitment");
        var NumberOfBooking= component.get("v.NumberOfBooking");
        console.log('commitment--',commitment);
        component.set("v.minimumCommitment",commitment);
        
        
        if((NumberOfBooking !=0 && (TotalQuantity < NumberOfBooking ) && IsTravelProd==true)){
            component.set("v.show", false);
            component.set("v.showalert", true);
            component.set("v.ProductOptionScreen",true);
            component.set("v.ProductTableScreen",false);
            component.set("v.QuoteTableScreen",false);
            
            component.find('notifyId').showNotice({
                "variant": "error",
                "header": "Quantity Should not Less Than No Of Bookings!",
                "message": QuantityError,
            });
        }else {
            
            component.set("v.ProductOptionScreen",false);
            component.set("v.ProductTableScreen",false);
            component.set("v.QuoteTableScreen",true);
            
            var action = component.get("c.InsertQuoteLineItem");
            action.setParams({
                "ProductId":component.get("v.prodId"),
                "quoteId" :component.get("v.QuoterecordId"),
                "productOptionlist":totalOptions,
                "ParentQliId":component.get("v.ParentQliId"),
                "qliIdList":DeletingId,
                "offeringType":component.get("v.selectedofferingType"),
                "pricingType":component.get("v.selectedpricingType"),
                "accountType":component.get("v.accTypeCalculated"),
                "Commitment":NumberOfBooking
            });
            //component.get("v.recordId")
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state==='SUCCESS'){
                    var quote = component.get('c.FetchQuote');
                    $A.enqueueAction(quote);
                    
                    $A.get('e.force:refreshView').fire();
                    
                    var responseValue = response.getReturnValue();
                    var QLIList=responseValue;
                    component.set('v.QuoteLineItemRelatedToXQuote',responseValue);
                    component.set("v.AllQuoteLineItemlist",QLIList);
                    component.set("v.show", false);
                    var NotNestedQuoteLineItme=[];
                    for(let i=0;i<QLIList.length;i++){
                        if(QLIList[i].Nested_Parent_Product__c==null){
                            NotNestedQuoteLineItme.push(QLIList[i]);
                        }
                    }
                    component.set("v.QuoteLineItemlist",NotNestedQuoteLineItme);
                    
                    //component.set("v.QuoteLineItemlist",responseValue);
                    
                    //$A.get('e.force:refreshView').fire();
                    
                    //component.set("v.SelectedOptionlist",TempEmptyArray);
                    
                }
                
                
            });
            $A.enqueueAction(action); 
        }
        
    },
    handleConfigureEvent:function(component, event, helper) {
        debugger;
        var spinner=component.get("v.show");
        component.set("v.show", true);
        
        var selectedqli = component.get('v.QuoteLineItemRelatedToXQuote');
        var selectedId = event.getParam('SelectedOptions');
        var ParentId = event.getParam('SelectedQLiId');
        var accountType = '';
        var pricingType = '';
        var offType = '';
        var commitment=0;
        console.log('selectedId',JSON.stringify(selectedId));
        console.log('ParentId',JSON.stringify(ParentId));
        if(selectedId!=undefined){
            component.set("v.AllProductIds",selectedId); 
            component.set("v.prodId",selectedId);
            
            for(var i=0;i<selectedqli.length;i++){
                if(selectedqli[i].Parent_Quote_Line_Item__c != undefined && selectedqli[i].Parent_Quote_Line_Item__c == ParentId){
                    if(selectedqli[i].Account_Type__c != undefined){
                        accountType = selectedqli[i].Account_Type__c;
                    }
                    if(selectedqli[i].Travel_Pricing_Type__c != undefined){
                        pricingType = selectedqli[i].Travel_Pricing_Type__c;
                    }
                    if(selectedqli[i].Travel_Offering_Type__c != undefined){
                        offType = selectedqli[i].Travel_Offering_Type__c;
                    }
                }
                
            }   
        }
        
        component.set("v.AccountType", accountType);
        component.set("v.SelectedOffering", offType);
        component.set("v.SelectedPricing", pricingType);
        component.set("v.accTypeCalculated",accountType);
        component.set("v.selectedpricingType",pricingType);     
        
        if(ParentId!=undefined){
            component.set("v.ParentQliId",ParentId);   
        }
        var ValueOfConfigureProduct=true;
        var ValueOfProductTableScreen=false;
        var ValueOfProductQuoteLineScreen=false;
        var Tempvariable=true;
        component.set("v.ProductOptionScreen",ValueOfConfigureProduct);
        component.set("v.ProductTableScreen",ValueOfProductTableScreen);
        component.set("v.QuoteTableScreen",ValueOfProductQuoteLineScreen);
        var proIds = component.get("v.AllProductIds");
        component.set("v.prodId",selectedId); 
        
        
        var action = component.get("c.ShowAllOptions");
        action.setParams({ 
            'ProductIds' : component.get("v.prodId"),
            'travelOfferingType' :offType,
            'travelPricingType' : pricingType,
            'accountType':accountType
            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                console.log('responseValue In AllMaps in event--',JSON.stringify(responseValue));
                var OptionList=responseValue; 
                for(let j=0;j<OptionList.length;j++){
                    for(let i=0;i<selectedqli.length;i++){
                        if(OptionList[j].Product__c==selectedqli[i].Product2Id){
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
                                    OtionList[j].SAAS_Price__c=OptionList[j].SAAS_API_Pricing__c;
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
                                }
                            }else{
                               OptionList[j].SAAS_Price__c=OptionList[j].SAAS_Price__c; 
                               OptionList[j].OTI_Price__c=OptionList[j].OTI_Price__c; 
                            }
                            commitment=selectedqli[i].Minimum_Commitment__c;
                            break;
                        } else{
                            OptionList[j].checkbox=false
                        } 
                    }
                    
                }
                console.log('OptionList--',JSON.stringify(OptionList)); 
                component.set("v.SelectedProductOptions",OptionList);
                component.set("v.show", false);
            }
            component.set("v.NumberOfBooking", commitment);
            
        });
        $A.enqueueAction(action);
    },
    calculateCommitment : function(component, event, helper) {
        helper.calculateCommitment(component, event, helper);
    },
    getAccountType : function (component, event, helper) {
        debugger;
        var spinner=component.get("v.show");
        component.set("v.show", true);
        var selectedProductName=component.get("v.SelectedProductName");
        console.log('selectedProductName--',JSON.stringify(selectedProductName));
        //var prodID = component.get("v.selected")[0].Id;
        //var ValueOfProductTableScreen=false;
        //component.set("v.ProductTableScreen",ValueOfProductTableScreen);
        var prodID =component.get("v.SelectedProduct");
        //var IsTravelProd=component.get("v.selected")[0].Is_Travel_Product__c;
        //var ProdName=component.get("v.selected")[0].Name;
        //console.log('IsTravelProd--',IsTravelProd)
        component.set("v.prodId",prodID);
        var offType = component.get("v.selectedofferingType");
        var pricingType = component.get("v.selectedpricingType");
        var numOfBookings = parseInt(component.get("v.numberOfBookings"));
        var minCommitment = parseInt(component.get("v.minimumCommitment"));
        var accountType = '';
        if(prodID != '01tC20000008eBZIAY' && (offType == '' || offType == undefined)){
            alert('Kindly select offering type to proceed');
            return;
        }
        //01tC20000007Z5tIAE
        
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
            if(numOfBookings >= 36000){
                accountType = 'Large';
            }else if (numOfBookings >= 20000 && numOfBookings < 36000){
                accountType = 'Medium Large';
            }else if(numOfBookings >= 12000 && numOfBookings < 20000){
                accountType = 'Medium';
            }else if(numOfBookings > 0 && numOfBookings < 12000){
                accountType = 'Small';
            }
        }else if(pricingType == 'Per Trip'){
            if(numOfBookings >= 12000){
                accountType = 'Large';
            }else if (numOfBookings >= 7000 && numOfBookings < 12000){
                accountType = 'Medium Large';
            }else if(numOfBookings >= 4000 && numOfBookings < 7000){
                accountType = 'Medium';
            }else if(numOfBookings > 0 && numOfBookings < 4000){
                accountType = 'Small';
            }
        }else if(pricingType == 'Per Report' || pricingType == 'Per User' ){
            if(selectedProductName=='Expense Bundle'){
                if(numOfBookings >= 50400){
                    accountType = 'Large';
                }else if (numOfBookings >= 36000 && numOfBookings < 50400){
                    accountType = 'Medium Large';
                }else if(numOfBookings >= 25000 && numOfBookings < 36000){
                    accountType = 'Medium';
                }else if(numOfBookings >= 15000 && numOfBookings < 25000){
                    accountType = 'Small Medium';
                }else if(numOfBookings > 0 && numOfBookings < 15000){
                    accountType = 'Small';
                }
            }else{
                if(numOfBookings >= 50400){
                    accountType = 'Large';
                }else if (numOfBookings >= 36000 && numOfBookings < 50400){
                    accountType = 'Medium Large';
                }else if(numOfBookings >= 15000 && numOfBookings < 36000){
                    accountType = 'Medium';
                }else if(numOfBookings > 0 && numOfBookings < 15000){
                    accountType = 'Small';
                }
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
        // helper.getAccountType(component, event, helper);
        //var a = component.get('c.getAllProducts');
        //$A.enqueueAction(a);
        //component.set("v.ProductName", ProdName);
        component.set("v.AccountType", accountType);
        component.set("v.SelectedOffering", offType);
        component.set("v.SelectedPricing", pricingType);
        component.set("v.Commitment", minCommitment);
        component.set("v.NumberOfBooking", numOfBookings);
        
        
        
        var quoteLineItems= component.get("v.QuoteLineItemlist");
        for(let i=0;i<quoteLineItems.length;i++){
            if(quoteLineItems[i].Product2Id==prodID && quoteLineItems[i].Travel_Offering_Type__c==offType){
                var NextScreen=false;
                component.set("v.showalert", true);
                var alert=component.get('c.showNotice');
                $A.enqueueAction(alert);
                
                break;
            } else{
                var NextScreen=true;
            } 
            
        }
        if(NextScreen==false){
            var spinner=component.get("v.show");
            component.set("v.show", false);
        }
        console.log('NextScreen--',NextScreen);
        if(quoteLineItems.length==0){
            NextScreen=true;
        }
        if(NextScreen==true){
            var ValueOfProductTableScreen=false;
            component.set("v.ProductTableScreen",ValueOfProductTableScreen);
            var ValueOfConfigureProduct=true;
            var Tempvariable=true;
            component.set("v.ProductOptionScreen",ValueOfConfigureProduct);
            var proIds = component.get("v.AllProductIds");
            
            var action = component.get("c.ShowAllOptions");
            action.setParams({ 
                'ProductIds' : component.get("v.SelectedProduct"),
                'travelOfferingType' :offType,
                'travelPricingType' : pricingType,
                'accountType':accountType
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state==='SUCCESS'){
                    component.set("v.show", false);
                    var responseValue = response.getReturnValue();
                    var TempData=responseValue;
                    component.set("v.SelectedProductOptions",responseValue);
                    console.log('responseValue In AllMaps--',JSON.stringify(responseValue)); 
                    if(TempData.length==0){                       
                        var ValueOfProductTableScreen=true;
                        component.set("v.ProductTableScreen",ValueOfProductTableScreen);
                        var ValueOfConfigureProduct=false;
                        component.set("v.ProductOptionScreen",ValueOfConfigureProduct); 
                        component.set("v.showalert", true);
                        component.find('notifyId').showNotice({
                            "variant": "error",
                            "header": "No Products Found!!!!",
                            "message": "No Products Found!!!!.",
                        });
                    }
                }   
            });
        }
        
        $A.enqueueAction(action);
        
    },
    showNotice : function(component, event, helper) {
        var ProdError= component.get("v.ProductError");
        component.find('notifyId').showNotice({
            "variant": "error",
            "header": "This product is already available in Quote!",
            "message": ProdError,
        });
    },
    navigateToQuoteLine:function(component, event, helper) {
        component.set("v.QuoteTableScreen", true);
        component.set("v.ProductTableScreen", false);
    },
    navigateBackToQuote  : function(component, event, helper) {
        debugger;
        var quoteId = component.get("v.QuoterecordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": quoteId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },
    NavigateBackToQuotelineItem:function(component, event, helper) {
        debugger;
        component.set("v.QuoteTableScreen", true);
        // component.set("v.ShowProducts", false);
        component.set("v.ProductOptionScreen", false);
    },
    doSomething:function(component, event, helper) {
        debugger;
        var OfferingValue = component.get("v.selectedofferingType");
        if(OfferingValue=="SBT"){
            var SBTPricingType=['-None-','Per Booking','Per Trip','Per Report'];
            component.set("v.pricingType", SBTPricingType);
        }else if(OfferingValue=="TRF"){
            var SBTPricingType=['-None-','Per Trip','Per Report'];
            component.set("v.pricingType", SBTPricingType);
        }    
    },
    HandleBookingLabel:function(component, event, helper) {
        debugger;
        var OfferingValue = component.get("v.selectedpricingType");
        var LabelValue=component.get("v.NumberOfBookingLabel");
        if(OfferingValue=='Per User'){
            //LabelValue="Number of Bookings"+'/'+OfferingValue;
            LabelValue=" Number of Bookings/# of Users";
        }else if(OfferingValue=='Per Report'){
            LabelValue=" Number of Bookings/# of Reports (Monthly)"
        }else if(OfferingValue=='-None-'){
            LabelValue="Number of Bookings"
        }else if(OfferingValue=='Per Booking'){
            LabelValue=" Number of Bookings/# of Bookings (Monthly)"
        }else if(OfferingValue=='Per Trip'){
            LabelValue=" Number of Bookings/# of Trips (Monthly)"
        }
        //LabelValue=LabelValue.toString();
        component.set("v.NumberOfBookingLabel",LabelValue);
    },
    handleClickCalculateDiscount:function(component, event, helper) {
        debugger;
        component.set("v.showCalculateModal",false); 
        var spinner=component.get("v.show");
        component.set("v.show", true);
        var action = component.get("c.QuoteRecList");
        action.setParams({ 
            "getQuoteRec" : component.get("v.QuoteObject")
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state==='SUCCESS'){
                var responseValue = response.getReturnValue();
                component.set("v.show", false);
                component.set("v.QuoteObject",responseValue);
                location.reload();
            }   
        });
        $A.enqueueAction(action);        
    },
    calculateExpenseARR:function(component, event, helper) {
        debugger;
        var ExpenseARR = event.getSource().get("v.value");    
    },
    calculateExpenseOTI:function(component, event, helper) {
        debugger;
        var ExpenseOTI = event.getSource().get("v.value");    
    },
    calculateTravelARR:function(component, event, helper) {
        debugger;
        var TravelARR = event.getSource().get("v.value");    
    },
    calculateTravelOTI:function(component, event, helper) {
        debugger;
        var TravelOTI = event.getSource().get("v.value");    
    },
    CalculateDiscount:function(component, event, helper) {
        debugger;
        component.set("v.showCalculateModal",true); 
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.showCalculateModal", false);
    },
    handleChange:function(component, event, helper) {
        debugger;
        let selectedProductName;
        var selectedOptionValue = event.getParam("value");
        if(selectedOptionValue){
            var ProuctOption=component.get("v.ProuctOption");
            selectedProductName=ProuctOption.find(item=>item.value==selectedOptionValue).label;
            component.set("v.SelectedProductName",selectedProductName);
        }
        component.set("v.SelectedProduct", selectedOptionValue);
        if(selectedProductName=='Expense Bundle'){
            var SBTPricingType=['-None-','Per Report','Per User'];
            component.set("v.pricingType", SBTPricingType);
        }
    }
})
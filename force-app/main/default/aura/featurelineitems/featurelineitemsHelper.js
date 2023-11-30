({
    helperMethod : function(component) {
        debugger;
        var pricing=component.get('v.SelectedPricing');
        var IsExpenseProd;
        const featureList = component.get('v.SelectedProductOptions');
        var featureName = component.get('v.FeatureName');
        const tempList = [];
        for (let index = 0; index < featureList.length; index++) {
            if (featureList[index].FeatureId__r.Name == featureName) {
                tempList.push(featureList[index]);
                component.set('v.tempList',tempList);
           }
            
        }
         
        for (let index = 0; index < tempList.length; index++) {
            if(tempList[index].Is_Travel_Product__c==true){
                var IsTravelProd=tempList[index].Is_Travel_Product__c;
            }else{
                IsExpenseProd=tempList[index].Is_Travel_Product__c;
            }
        }
       
        
        console.log('IsTravelProd--',JSON.stringify(IsTravelProd));
         component.set('v.IsTrvaelProduct',IsTravelProd);
         component.set('v.IsExpenseProduct',IsExpenseProd);
        console.log('Temp List Feature--',JSON.stringify(tempList));
        var tempPricing;
        if(pricing=='Per User'){
            //LabelValue="Number of Bookings"+'/'+OfferingValue;
            tempPricing=" Number of Bookings/# of Users";
        }else if(pricing=='Per Report'){
            tempPricing=" Number of Bookings/# of Reports (Monthly)"
        }else if(pricing=='-None-'){
            tempPricing="Number of Bookings"
        }else if(pricing=='Per Booking'){
            tempPricing=" Number of Bookings/# of Bookings (Monthly)"
        }else if(pricing=='Per Trip'){
            tempPricing=" Number of Bookings/# of Trips (Monthly)"
        }
        component.set('v.NumberOfBookingLabel',tempPricing);
    },
    selectSingleOption: function(component,event,TempTempList){
        debugger;
        var TempFeatureList= TempTempList 
        var ExAppEvent = $A.get("e.c:ParentSelectedOptionId");
        ExAppEvent.setParams({
            SelectedparentRecords:TempFeatureList,
        });                                               
        ExAppEvent.fire();
    },
    ChangeOTIPrice:function(component, event,helper,option_id,Option_quantity) {
        debugger;
         var Option_Record;
         var OptionId=option_id;
         var tempList=component.get("v.tempList")
         var quantity=Option_quantity;
         if(option_id!=null || option_id!=undefined){
            Option_Record=tempList.find(record => record.Product__c === OptionId);
            console.log('OptionRec--',Option_Record);
        }
        var index=tempList.indexOf(Option_Record);
         console.log('index--',index);
         
        if(Option_Record.Product_Name__c=='Offline TMC (Cab/Train/Bus)' || Option_Record.Product_Name__c=='Offline TMC'){
            if(quantity > 2){
                tempList[index].OTI_Price__c=25000*(quantity-2);
                
            }else if(quantity <= 2){
                tempList[index].OTI_Price__c=quantity*0;
            }
        }
        component.set("v.tempList",tempList);
        
    }
    
    
})
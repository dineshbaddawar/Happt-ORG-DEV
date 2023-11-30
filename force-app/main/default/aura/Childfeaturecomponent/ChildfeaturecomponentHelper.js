({
	helperMethod : function(component, event,tempListLatest) {
		var allOptionValue=tempListLatest;
		
        var arr=[];
        var TempChildOption=[];
       var selectedTrueValue=[];
         var ParentId=component.get("v.ParentProductId");
         var AccountType=component.get("v.AccountType");
             AccountType=AccountType.toUpperCase();
         var PricingType=component.get("v.SelectedPricing");
       
       
       
       for(let i=0;i<allOptionValue.length;i++){
           if(allOptionValue[i].Account_Type__c==AccountType && allOptionValue[i].Pricing_Type__c==PricingType && allOptionValue[i].Parent_Product__c==ParentId){
               arr.push(allOptionValue[i]);
               console.log('arr child Option--',JSON.stringify(arr)); 
               component.set('v.tempList',arr);
               
               if(allOptionValue[i].Account_Type__c==AccountType && allOptionValue[i].Pricing_Type__c==PricingType && allOptionValue[i].Parent_Product__c==ParentId && allOptionValue[i].Selected__c==true){
                   selectedTrueValue.push(allOptionValue[i]);
                   component.set('v.selectedQLI',selectedTrueValue);
               }
               
               
           }
           console.log('arr child Option--',JSON.stringify(arr)); 
       } 
        console.log('allOptionValue--',JSON.stringify(allOptionValue));
        console.log('selectedTrueValue--',JSON.stringify(selectedTrueValue));
	},
    ChangeSAASPrice:function(component, event,helper,option_id,Option_quantity) {
        debugger;
         var Option_Record;
         var OptionId=option_id;
         var TempFeatureList=component.get("v.tempListLatest")
         var quantity=Option_quantity;
         if(option_id!=null || option_id!=undefined){
            Option_Record=TempFeatureList.find(record => record.Product__c === OptionId);
            console.log('OptionRec--',Option_Record);
        }
        var index=TempFeatureList.indexOf(Option_Record);
         console.log('index--',index);
         
         if(Option_Record.Sub_Type__c=='Google Maps'){
             if(quantity <= 20000){
                 TempFeatureList[index].SAAS_Price__c=8;
                  TempFeatureList[index].SAAS_Quantity__c=quantity;
             }else if( quantity > 20000 && quantity <= 50000){
                 TempFeatureList[index].SAAS_Price__c=7;
                 TempFeatureList[index].SAAS_Quantity__c=quantity;
             }else if(quantity > 50000){
                 TempFeatureList[index].SAAS_Price__c=6;
                 TempFeatureList[index].SAAS_Quantity__c=quantity;
            }
             
         }else if(Option_Record.Sub_Type__c=='Map My India'){
             if(quantity <= 20000){
                 TempFeatureList[index].SAAS_Price__c=2;
                 TempFeatureList[index].SAAS_Quantity__c=quantity;
             }else if( quantity > 20000 && quantity <= 50000){
                 TempFeatureList[index].SAAS_Price__c=1.75;
                 TempFeatureList[index].SAAS_Quantity__c=quantity;
             }else if(quantity > 50000){
                 TempFeatureList[index].SAAS_Price__c=1.5;
                 TempFeatureList[index].SAAS_Quantity__c=quantity;
            }
         }
         console.log('TempFeatureList',TempFeatureList);
         component.set("v.tempListLatest",TempFeatureList);
         this.helperMethod(component, event,TempFeatureList); 
    },
    setPrice_Quantity:function(component, event,helper,option_id,Option_Price,value_Price) {
        debugger;
         var Option_Record;
         var OptionId=option_id;
         var TempFeatureList=component.get("v.tempListLatest")
         var Price=value_Price;
         var Option_Price=Option_Price;
         if(option_id!=null || option_id!=undefined){
            Option_Record=TempFeatureList.find(record => record.Product__c === OptionId);
            console.log('OptionRec--',Option_Record);
        }
        var index=TempFeatureList.indexOf(Option_Record);
         console.log('index--',index);
        if(Option_Price=='SAAS_PRICE'){
            TempFeatureList[index].SAAS_Price__c=parseInt(Price);
        }else if(Option_Price=='OTI_PRICE'){
            TempFeatureList[index].OTI_Price__c=parseInt(Price);
        }
        console.log('TempFeatureList',TempFeatureList);
        component.set("v.tempListLatest",TempFeatureList);
        this.helperMethod(component, event,TempFeatureList); 
   }, 
})
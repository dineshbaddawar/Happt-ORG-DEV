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
          //var spinner=component.get("v.show");
           /*window.setTimeout(
                $A.getCallback(function() {
                     component.set("v.show",false);
                }),10
            );*/
	}
})
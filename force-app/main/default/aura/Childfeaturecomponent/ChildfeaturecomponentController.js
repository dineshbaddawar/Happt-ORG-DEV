({
   MyAction:function(component, event, helper) {
        debugger;
         //var spinner=component.get("v.show");
         //component.set("v.show",true);       
       var tempListLatest=component.get("v.tempListLatest");
       helper.helperMethod(component, event,tempListLatest);
        /*var arr=[];
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
        console.log('selectedTrueValue--',JSON.stringify(selectedTrueValue));*/
        
    },
    selectSingleOptionRec: function(component,event,helper){
        debugger;
        //var TempProducts=[];
        var checkbox = event.getSource();
        console.log(checkbox.get("v.value"));
        var selIdx = event.getSource().get("v.text");
       
        
        //var checkCmp = component.find("checkContact");
        //console.log("value : " + checkCmp.get("v.text"))
        
        var SelectedOptionRec=component.get("v.selectedQLI");
        //var SelectedProducts=component.get("v.selectedProductList");
        
        var TempFeatureList = component.get("v.tempListLatest");
        
        
        
        var selectedContacts = [];
        var checkvalue = component.find("checkContact");
        
        if(checkbox.get("v.value")==true){
            
            var deleteId=component.get('v.deleteqliId');
            if(deleteId.find(item=>item==selIdx)){
                deleteId = deleteId.filter(item => item !== selIdx);
                component.set('v.deleteqliId',deleteId);
            }else{
               console.log('This Id Does not Exists') 
            }
            
            
            
            if(SelectedOptionRec.find(item=>item.Id==selIdx)){
                console.log('This Id Exists')
            }
            else{
                SelectedOptionRec.push(TempFeatureList.find(record => record.Id === selIdx)); 
            }
            
             var OptionRec=TempFeatureList.find(record => record.Id === selIdx);
                 console.log('OptionRec--',OptionRec);
                 
                 var index=TempFeatureList.indexOf(OptionRec);
                 console.log('index--',index);
                 TempFeatureList[index].Selected__c=true;
            
           /* if(!Array.isArray(checkvalue)){
                if (checkvalue.get("v.value") == true) {
                    selectedContacts.push(checkvalue.get("v.text"));
                    if(SelectedOptionRec.find(item=>item.Id==selIdx)){
                        console.log('This Id Exists')
                    }
                    else{
                        SelectedOptionRec.push(TempFeatureList.find(record => record.Id === selIdx)); 
                    }
                    //SelectedOptionRec = SelectedOptionRec.filter(record => record.Id !== checkvalue[i].get("v.text"));
                }
            }else{
                for (var i = 0; i < checkvalue.length; i++) {
                    if (checkvalue[i].get("v.value") == true) {
                        selectedContacts.push(checkvalue[i].get("v.text"));
                        if(SelectedOptionRec.find(item=>item.Id==checkvalue[i].get("v.text"))){
                            console.log('This Id Exists')
                        }
                        else{
                            SelectedOptionRec.push(TempFeatureList.find(record => record.Id === checkvalue[i].get("v.text"))); 
                        }
                        
                    }
                }
            } */ 
        } else if(checkbox.get("v.value")==false){
             var selIdx = event.getSource().get("v.text");
            var deleteId=component.get('v.deleteqliId');
              deleteId.push(selIdx);
              component.set('v.deleteqliId',deleteId);
            // console.log(JSON.stringify(component.get('v.deleteqliId'));
             console.log('selIdx--',selIdx);
            
              var OptionRec=TempFeatureList.find(record => record.Id === selIdx);
                 console.log('OptionRec--',OptionRec);
                 
                 var index=TempFeatureList.indexOf(OptionRec);
                 console.log('index--',index);
                 TempFeatureList[index].Selected__c=false;
            
            if(SelectedOptionRec.find(item=>item.Id==selIdx)){
               SelectedOptionRec = SelectedOptionRec.filter(item => item.Id !== selIdx);
            }else{
                console.log('This record Does not Exists')
            }
        }
        
        
        
       
        component.set("v.selectedQLI", SelectedOptionRec);
        component.set("v.tempListLatest",TempFeatureList);
        
        component.set("v.SelectedProductOptions",TempFeatureList);
        // component.set("v.AllProductIds", selectedContacts);
        console.log('SelectedProductOptions--',JSON.stringify(SelectedOptionRec));
        //console.log('SelectedProductIds--',JSON.stringify(SelectedProductIds));
    },
     HandleSAASquantity: function(component, event, helper) {
        debugger;
        if(event.target.value=="0"){
            //alert('Quantity Should More Than 0');
            //event.target.value="1";
        }else{
           var cur_quantity = event.target.value;
           console.log('cur_quantity--',cur_quantity);
        }
        var option_id	 = event.target.dataset.id
		var selectedOption = component.get('v.tempListLatest');
        var selected_option = component.get('v.SelectedOptions');
        for(var i =0;i<selectedOption.length;i++){
            if(selectedOption[i].Product__c == option_id && selectedOption[i].Selected__c){
                selectedOption[i].SAAS_Quantity__c = parseInt(cur_quantity);
            }
        }
        
        for(var i=0;i<selected_option.length;i++){
            if(selected_option[i].Product__c == option_id){
                selected_option[i].SAAS_Quantity__c = parseInt(cur_quantity);
            }
        }
        
        component.set('v.ChildProductLookUpData',selectedOption);
        component.set('v.SelectedOptions',selectedOption);
        
        
        // ...
    },
     HandleOTIquantity: function(component, event, helper) {
        debugger;
        if(event.target.value=="0"){
            //alert('Quantity Should More Than 0');
            //event.target.value="1";
        }else{
           var cur_quantity = event.target.value;
           console.log('cur_quantity--',cur_quantity);
        }
        var option_id	 = event.target.dataset.id
		var selectedOption = component.get('v.tempListLatest');
        var selected_option = component.get('v.SelectedOptions');
        for(var i =0;i<selectedOption.length;i++){
            if(selectedOption[i].Product__c == option_id && selectedOption[i].Selected__c){
                selectedOption[i].OTI_Quantity__c = parseInt(cur_quantity);
            }
        }
        
        for(var i=0;i<selected_option.length;i++){
            if(selected_option[i].Product__c == option_id){
                selected_option[i].OTI_Quantity__c = parseInt(cur_quantity);
            }
        }
        
        component.set('v.ChildProductLookUpData',selectedOption);
        component.set('v.SelectedOptions',selectedOption);
        
        
        // ...
    },
    SubTypechange:function(component, event, helper) {
        debugger;
        var selectedId = event.target.dataset.id;
        var selectedSubType = event.getSource().get("v.value");
        console.log('selectedSubType--',selectedSubType);
        component.set('v.selectedSubtype',selectedSubType);
        var TempFeatureList=component.get("v.tempListLatest")
        if(selectedId!=null || selectedId!=undefined){
            var OptionRec=TempFeatureList.find(record => record.Id === selectedId);
            console.log('OptionRec--',OptionRec);
        }
         var index=TempFeatureList.indexOf(OptionRec);
         console.log('index--',index);
        
        if(selectedSubType=='Custom API'){
            if(OptionRec.SAAS_Custome_API_Pricing__c==null || OptionRec.SAAS_Custome_API_Pricing__c==undefined){
               TempFeatureList[index].SAAS_Price__c=0; 
            }else{
               TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Custome_API_Pricing__c; 
            }
            
            if(OptionRec.OTI_Custome_API_Price__c==null || OptionRec.OTI_Custome_API_Price__c==undefined){
               TempFeatureList[index].OTI_Price__c=0; 
            }else{
               TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Custome_API_Price__c;  
            }  
        }else if(selectedSubType=='API'){
            
            if(OptionRec.SAAS_API_Pricing__c==null || OptionRec.SAAS_API_Pricing__c==undefined){
               TempFeatureList[index].SAAS_Price__c=0; 
            }else{
               TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_API_Pricing__c;  
            }
            
            if(OptionRec.OTI_API_Pricing__c==null || OptionRec.OTI_API_Pricing__c==undefined){
               TempFeatureList[index].OTI_Price__c=0; 
            }else{
               TempFeatureList[index].OTI_Price__c=OptionRec.OTI_API_Pricing__c;  
            }
            //TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_API_Pricing__c;
            //TempFeatureList[index].OTI_Price__c=OptionRec.OTI_API_Pricing__c; 
        }else if(selectedSubType=='SFTP'){
            
            if(OptionRec.SAAS_SFTP_Pricing__c==null || OptionRec.SAAS_SFTP_Pricing__c==undefined){
               TempFeatureList[index].SAAS_Price__c=0; 
            }else{
               TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_SFTP_Pricing__c;  
            }
            
            if(OptionRec.OTI_SFTP_Pricing__c==null || OptionRec.OTI_SFTP_Pricing__c==undefined){
               TempFeatureList[index].OTI_Price__c=0; 
            }else{
               TempFeatureList[index].OTI_Price__c=OptionRec.OTI_SFTP_Pricing__c;  
            }
            
           // TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_SFTP_Pricing__c;
           // TempFeatureList[index].OTI_Price__c=OptionRec.OTI_SFTP_Pricing__c; 
        }else if(selectedSubType=='Elite'){
            
            if(OptionRec.SAAS_Elite_Pricing__c==null || OptionRec.SAAS_Elite_Pricing__c==undefined){
               TempFeatureList[index].SAAS_Price__c=0; 
            }else{
               TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Elite_Pricing__c;  
            }
            
            if(OptionRec.OTI_Elite_Pricing__c==null || OptionRec.OTI_Elite_Pricing__c==undefined){
               TempFeatureList[index].OTI_Price__c=0; 
            }else{
               TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Elite_Pricing__c;  
            }
            
            //TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Elite_Pricing__c;
            //TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Elite_Pricing__c; 
        }else if(selectedSubType=='Premium'){
            
             if(OptionRec.SAAS_Premium_Pricing__c==null || OptionRec.SAAS_Premium_Pricing__c==undefined){
               TempFeatureList[index].SAAS_Price__c=0; 
            }else{
               TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Premium_Pricing__c;  
            }
            
            if(OptionRec.OTI_Premium_Pricing__c==null || OptionRec.OTI_Premium_Pricing__c==undefined){
               TempFeatureList[index].OTI_Price__c=0; 
            }else{
               TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Premium_Pricing__c;  
            }
            
           // TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Premium_Pricing__c;
           // TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Premium_Pricing__c; 
        }else if(selectedSubType=='Pro'){
            
             if(OptionRec.SAAS_Pro_Pricing__c==null || OptionRec.SAAS_Pro_Pricing__c==undefined){
                TempFeatureList[index].SAAS_Price__c=0; 
            }else{
               TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Pro_Pricing__c;  
            }
            
            if(OptionRec.OTI_Pro_Pricing__c==null || OptionRec.OTI_Pro_Pricing__c==undefined){
               TempFeatureList[index].OTI_Price__c=0; 
            }else{
               TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Pro_Pricing__c;  
            }
            
            //TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Pro_Pricing__c;
           // TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Pro_Pricing__c; 
        }else if(selectedSubType=='Google Maps'){
            
            if(OptionRec.Google_Maps_SAAS__c==null || OptionRec.Google_Maps_SAAS__c==undefined){
                TempFeatureList[index].SAAS_Price__c=0; 
            }else{
               TempFeatureList[index].SAAS_Price__c=OptionRec.Google_Maps_SAAS__c;  
            }
            
            if(OptionRec.Google_Maps_OTI__c==null || OptionRec.Google_Maps_OTI__c==undefined){
               TempFeatureList[index].OTI_Price__c=0; 
            }else{
               TempFeatureList[index].OTI_Price__c=OptionRec.Google_Maps_OTI__c;  
            }
            
        }else if(selectedSubType=='Map My India'){
            
            if(OptionRec.Map_My_India_SAAS__c==null || OptionRec.Map_My_India_SAAS__c==undefined){
                TempFeatureList[index].SAAS_Price__c=0; 
            }else{
               TempFeatureList[index].SAAS_Price__c=OptionRec.Map_My_India_SAAS__c;  
            }
            
            if(OptionRec.Map_My_India_OTI__c==null || OptionRec.Map_My_India_OTI__c==undefined){
               TempFeatureList[index].OTI_Price__c=0; 
            }else{
               TempFeatureList[index].OTI_Price__c=OptionRec.Map_My_India_OTI__c;  
            }
            
        }else if(selectedSubType=='None'){
            
             if(OptionRec.Base_SAAS_Price__c==null || OptionRec.Base_SAAS_Price__c==undefined){
               TempFeatureList[index].SAAS_Price__c=0; 
            }else{
               TempFeatureList[index].SAAS_Price__c=OptionRec.Base_SAAS_Price__c;  
            }
            
            if(OptionRec.Base_OTI_Price__c==null || OptionRec.Base_OTI_Price__c==undefined){
               TempFeatureList[index].OTI_Price__c=0; 
            }else{
               TempFeatureList[index].OTI_Price__c=OptionRec.Base_OTI_Price__c;  
            }
            
           // TempFeatureList[index].SAAS_Price__c=OptionRec.Base_SAAS_Price__c;
           // TempFeatureList[index].OTI_Price__c=OptionRec.Base_OTI_Price__c; 
        }
        
        console.log('TempFeatureList',TempFeatureList);
         helper.helperMethod(component, event,TempFeatureList);
        //component.set("v.tempListLatest",TempFeatureList)
    },
    /*executeFunction:function(component, event, helper) {
        debugger;
        var params=event.getparam('arguments');
        console.log('params1',params.param1);
        console.log('param2',params.param2);
        console.log('ParentXChild',params.ParentXChild);
    }*/
    getEvents:function(component, event, helper) {
        
        var TempFeatureList = event.getParam("SelectedparentRecords");
       // var Loading=event.getParam("SelectedparentRecords");
           component.set("v.tempListLatest",TempFeatureList);
            var load=component.get("v.show");
           helper.helperMethod(component, event,TempFeatureList);
           //component.set("v.show",false);
           
    }
      
})
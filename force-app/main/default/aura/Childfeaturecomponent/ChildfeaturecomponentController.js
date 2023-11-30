({
   MyAction:function(component, event, helper) {
        debugger;       
       var tempListLatest=component.get("v.tempListLatest");
       helper.helperMethod(component, event,tempListLatest);
    },
    selectSingleOptionRec: function(component,event,helper){
        debugger;
        
        var checkbox = event.getSource();
        console.log(checkbox.get("v.value"));
        var selIdx = event.getSource().get("v.text");
        var SelectedOptionRec=component.get("v.selectedQLI");
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
        console.log('SelectedProductOptions--',JSON.stringify(SelectedOptionRec));
    },
     HandleSAASquantity: function(component, event, helper) {
        debugger;
        var TempFeatureList=component.get("v.tempListLatest")
        if(event.getParam('value')=="0"){
            //alert('Quantity Should More Than 0');
            //event.target.value="1";
        }else{
           var cur_quantity = event.getParam('value');
           console.log('cur_quantity--',cur_quantity);
        }
        var option_id	 = event.target.dataset.id
		var selectedOption = component.get('v.tempListLatest');
        var selected_option = component.get('v.SelectedOptions');
        var quantity=parseInt(cur_quantity); 
        for(var i =0;i<selectedOption.length;i++){
            if(selectedOption[i].Product__c == option_id && selectedOption[i].Selected__c){
                selectedOption[i].SAAS_Quantity__c = parseInt(cur_quantity);
                
                if(selectedOption[i].Sub_Type__c=='Google Maps'){
                    if(quantity <= 20000){
                        
                        selectedOption[i].Google_Maps_SAAS__c=8;
                        selectedOption[i].SAAS_Quantity__c=quantity;
                    }else if( quantity > 20000 && quantity <= 50000){
                        
                        selectedOption[i].Google_Maps_SAAS__c=7;
                        selectedOption[i].SAAS_Quantity__c=quantity;
                    }else if(quantity > 50000){
                       
                        selectedOption[i].Google_Maps_SAAS__c=6;
                        selectedOption[i].SAAS_Quantity__c=quantity;
                    }
                    
                }else if(selectedOption[i].Sub_Type__c=='Map My India'){
                    if(quantity <= 20000){
                        
                        selectedOption[i].Map_My_India_SAAS__c=2;
                        selectedOption[i].SAAS_Quantity__c=quantity;
                    }else if( quantity > 20000 && quantity <= 50000){
                        
                        selectedOption[i].Map_My_India_SAAS__c=1.75;
                        selectedOption[i].SAAS_Quantity__c=quantity;
                    }else if(quantity > 50000){
                       
                        selectedOption[i].Map_My_India_SAAS__c=1.5;
                        selectedOption[i].SAAS_Quantity__c=quantity;
                    }
                }
            }
        }
        
        for(var i=0;i<selected_option.length;i++){
            if(selected_option[i].Product__c == option_id){
                selected_option[i].SAAS_Quantity__c = parseInt(cur_quantity);
                
                if(selected_option[i].Sub_Type__c=='Google Maps'){
                    if(quantity <= 20000){
                        selected_option[i].Google_Maps_SAAS__c=8;
                        selected_option[i].SAAS_Quantity__c=quantity;
                    }else if( quantity > 20000 && quantity <= 50000){
                        selected_option[i].Google_Maps_SAAS__c=7;
                        selected_option[i].SAAS_Quantity__c=quantity;
                    }else if(quantity > 50000){
                        selected_option[i].Google_Maps_SAAS__c=6;
                        selected_option[i].SAAS_Quantity__c=quantity;
                    }
                    
                }else if(selected_option[i].Sub_Type__c=='Map My India'){
                    if(quantity <= 20000){
                        selected_option[i].Map_My_India_SAAS__c=2;
                        selected_option[i].SAAS_Quantity__c=quantity;
                    }else if( quantity > 20000 && quantity <= 50000){
                        selected_option[i].Map_My_India_SAAS__c=1.75;
                        selected_option[i].SAAS_Quantity__c=quantity;
                    }else if(quantity > 50000){
                        selected_option[i].Map_My_India_SAAS__c=1.5;
                        selected_option[i].SAAS_Quantity__c=quantity;
                    }
                }
            }
        }
        
        component.set('v.ChildProductLookUpData',selectedOption);
        component.set('v.SelectedOptions',selectedOption);
        component.set('v.SelectedProductOptions',selectedOption); 
         //component.set("v.selectedQLI", selectedOption);
        var Option_Record;
        Option_Record=TempFeatureList.find(record => record.Product__c === option_id);
         if(Option_Record.IsPrice_IsQuantity_Editable__c==true){
             helper.ChangeSAASPrice(component, event,helper,option_id,quantity);   
         }  
    },
     HandleOTIquantity: function(component, event, helper) {
        debugger;
        if(event.getParam('value')=="0"){
            //alert('Quantity Should More Than 0');
            //event.target.value="1";
        }else{
           var cur_quantity = event.getParam('value');
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
        component.set('v.SelectedProductOptions',selectedOption); 
        //component.set("v.selectedQLI", selectedOption);
        
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
        }
        
        console.log('TempFeatureList',TempFeatureList);
         helper.helperMethod(component, event,TempFeatureList);
    },
    getEvents:function(component, event, helper) {
        
        var TempFeatureList = event.getParam("SelectedparentRecords");
       // var Loading=event.getParam("SelectedparentRecords");
           component.set("v.tempListLatest",TempFeatureList);
            var load=component.get("v.show");
           helper.helperMethod(component, event,TempFeatureList);
           //component.set("v.show",false);
           
    },
    HandleSAASPrice:function(component, event, helper){
         debugger;
        var SAAS_Price;
        var TempFeatureList=component.get("v.tempListLatest")
        if(event.getParam('value')=="0"){
  
        }else{
           SAAS_Price = event.getParam('value');
           console.log('SAAS_Price--',SAAS_Price);
        }
        var option_id	 = event.target.dataset.id
		var selectedOption = component.get('v.tempListLatest');
        var selected_option = component.get('v.SelectedOptions');
        for(var i =0;i<selectedOption.length;i++){
            if(selectedOption[i].Product__c == option_id && selectedOption[i].Selected__c){
                if(selectedOption[i].IsSaasPriceEditable__c){
                   selectedOption[i].SAAS_Price__c = parseInt(SAAS_Price);  
                }  
            }
        }
        
        for(var i=0;i<selected_option.length;i++){
            if(selected_option[i].Product__c == option_id){
                if(selectedOption[i].IsSaasPriceEditable__c){
                   selected_option[i].SAAS_Price__c = parseInt(SAAS_Price); 
                }
            }
        }
        
        component.set('v.ChildProductLookUpData',selectedOption);
        component.set('v.SelectedOptions',selectedOption);
        component.set('v.SelectedProductOptions',selectedOption); 
        
        var Option_Record;
        Option_Record=TempFeatureList.find(record => record.Product__c === option_id);
         if(Option_Record.IsSaasPriceEditable__c==true){
            helper.setPrice_Quantity(component, event,helper,option_id,'SAAS_PRICE',SAAS_Price)  
         }
    },
    HandleOTIPrice:function(component, event, helper){
        debugger;
        var OTI_Price;
        var TempFeatureList=component.get("v.tempListLatest")
        if(event.getParam('value')=="0"){
  
        }else{
           OTI_Price = event.getParam('value');
           console.log('OTI_Price--',OTI_Price);
        }
        var option_id	 = event.target.dataset.id
		var selectedOption = component.get('v.tempListLatest');
        var selected_option = component.get('v.SelectedOptions');
        for(var i =0;i<selectedOption.length;i++){
            if(selectedOption[i].Product__c == option_id && selectedOption[i].Selected__c){
                if(selectedOption[i].IsOtiPriceEditable__c==true){
                   selectedOption[i].OTI_Price__c = parseInt(OTI_Price);  
                }  
            }
        }
        
        for(var i=0;i<selected_option.length;i++){
            if(selected_option[i].Product__c == option_id){
                if(selectedOption[i].IsOtiPriceEditable__c==true){
                   selected_option[i].OTI_Price__c = parseInt(OTI_Price); 
                }
            }
        }
        
        component.set('v.ChildProductLookUpData',selectedOption);
        component.set('v.SelectedOptions',selectedOption);
        component.set('v.SelectedProductOptions',selectedOption); 
        
        var Option_Record;
        Option_Record=TempFeatureList.find(record => record.Product__c === option_id);
         if(Option_Record.IsOtiPriceEditable__c==true){
              helper.setPrice_Quantity(component, event,helper,option_id,'OTI_PRICE',OTI_Price)  
         }
    }
      
})
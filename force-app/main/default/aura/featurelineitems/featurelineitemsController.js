({
    myAction : function(component, event, helper) {
        debugger;
        helper.helperMethod(component);
       
    },
    selectSingleOptionRec:function(component, event, helper) {
        debugger;
        var spinner=component.get("v.show");
        component.set("v.show",true);
        
         var checkbox = event.getSource();
          console.log(checkbox.get("v.value"));
        
          var selIdx = event.getSource().get("v.text");
       // var selIdx=SelectedId;
         var TempFeatureList = component.get("v.SelectedProductOptions");
        
        /*var SelectedRecord=TempFeatureList.find(record => record.Id === selIdx);
        console.log('SelectedRecord---',SelectedRecord);
        
        var OptionRec=TempFeatureList.find(record => record.Id === selIdx);
        console.log('OptionRec--',OptionRec);
        
        var index=TempFeatureList.indexOf(OptionRec);
        console.log('index--',index);
        TempFeatureList[index].Selected__c=true;

        component.set("v.show",true);*/
        //var checkCmp = component.find("checkContact");
        //console.log("value : " + checkCmp.get("v.text"))
        
        var SelectedOptionRec=component.get("v.selectedQLI");
        //var SelectedProducts=component.get("v.selectedProductList");
       
        
        var selectedContacts = [];
        var temptemptemp = [];
        //var checkvalue = component.find("checkContact");
        
        if(checkbox.get("v.value")==true){
            
            var deleteId=component.get('v.deleteqliId');
            if(deleteId.find(item=>item==selIdx)){
                deleteId = deleteId.filter(item => item !== selIdx);
            }else{
               console.log('This Id Does not Exists') 
            }
            
            component.set('v.deleteqliId',deleteId);
            
            if(SelectedOptionRec.find(item=>item.Id==selIdx)){
                console.log('This Id Exists');
             }else{  
                //SelectedOptionRec.push(TempFeatureList.find(record => record.Id === checkvalue[i].get("v.text"))); 
                SelectedOptionRec.push(TempFeatureList.find(record => record.Id === selIdx));
                 
                 var SelectedRecord=TempFeatureList.find(record => record.Id === selIdx);
                 console.log('SelectedRecord---',SelectedRecord);
                 
                 var OptionRec=TempFeatureList.find(record => record.Id === selIdx);
                 console.log('OptionRec--',OptionRec);
                 
                 var index=TempFeatureList.indexOf(OptionRec);
                 console.log('index--',index);
                 TempFeatureList[index].Selected__c=true;
                 
                 
                 if(SelectedRecord.Parent_Product__c==null && SelectedRecord.Product__c!=null){
                     for(let i=0;i<TempFeatureList.length;i++){
                         if(TempFeatureList[i].Parent_Product__c!=null || TempFeatureList[i].Parent_Product__c!=undefined){
                             if(TempFeatureList[i].Parent_Product__c==SelectedRecord.Product__c){
                                 TempFeatureList[i].Selected__c=true;
                                 if(SelectedOptionRec.find(item=>item.Id!=TempFeatureList[i].Id)){
                                     SelectedOptionRec.push(TempFeatureList[i]);
                                 }   
                             }
                         } 
                     } 
                 }
                 
                 console.log('SelectedOptionRec--'+SelectedOptionRec);
                 component.set('v.tempList',TempFeatureList);
            }
        } else if(checkbox.get("v.value")==false){
             var selIdx = event.getSource().get("v.text");
              var deleteId=component.get('v.deleteqliId');
              deleteId.push(selIdx);
              component.set('v.deleteqliId',deleteId);
            
             
            // console.log(JSON.stringify(component.get('v.deleteqliId'));
             console.log('selIdx--',selIdx);
            var IdsToremove=[];
            
                var OptionRec=TempFeatureList.find(record => record.Id === selIdx);
                console.log('OptionRec--',OptionRec);
                
                var index=TempFeatureList.indexOf(OptionRec);
                console.log('index--',index);
                TempFeatureList[index].Selected__c=false;
                
                for(let k=0;k<TempFeatureList.length;k++){
                    
                    if(TempFeatureList[k].Parent_Product__c!=null || TempFeatureList[k].Parent_Product__c!=undefined)
                    if(TempFeatureList[k].Parent_Product__c==OptionRec.Product__c){
                        TempFeatureList[k].Selected__c=false;
                        deleteId.push(TempFeatureList[k].Id);
                    }
                }
                component.set('v.deleteqliId',deleteId);
            
            if(SelectedOptionRec.find(item=>item.Id==selIdx)){
                var selectedRecordToremove=SelectedOptionRec.find(item=>item.Id==selIdx); 
                SelectedOptionRec = SelectedOptionRec.filter(item => item.Id !== selIdx);
                
                if(selectedRecordToremove.Parent_Product__c==null && selectedRecordToremove.Product__c!=null){
                    for(let i=0;i<SelectedOptionRec.length;i++){
                        if(SelectedOptionRec[i].Parent_Product__c!=null || SelectedOptionRec[i].Parent_Product__c!=undefined){
                            if(SelectedOptionRec[i].Parent_Product__c==selectedRecordToremove.Product__c){
                                 IdsToremove.push(SelectedOptionRec[i]);
                                  
                            } 
                        }  
                    }  
                }                
                for(let j=0;j<IdsToremove.length;j++){
                    var Idtoremove=IdsToremove[j].Id;
                    if(SelectedOptionRec.find(item=>item.Id==Idtoremove)){
                        SelectedOptionRec = SelectedOptionRec.filter(item => item.Id !== Idtoremove);
                        
                    }
                }
                
                //SelectedOptionRec=SelectedOptionRec;
                console.log('selectedRecordToremove--',selectedRecordToremove);
                
            }else{
                console.log('This record Does not Exists')
            }
            
            component.set("v.tempList",TempFeatureList);
            
        }
        
        //component.set("v.show",false);
        component.set("v.selectedQLI", SelectedOptionRec);
        console.log('SelectedProductOptions--',JSON.stringify(SelectedOptionRec));
          window.setTimeout(
                $A.getCallback(function() {
                    component.set("v.show",false);
                      helper.selectSingleOption(component, event,TempFeatureList);
                }),1000     
            );
        
       
        //helper.AuramethodPassValue(component);
    },
    onChangeSAASquantity: function(component, event, helper) {
        debugger;
        if(event.target.value=="0" || event.target.value==""){
            //alert('Quantity Should More Than 0');
            //event.target.value="1";
           var cur_quantity = 0;
           console.log('cur_quantity--',cur_quantity);
        }else{
           var cur_quantity = event.target.value;
           console.log('cur_quantity--',cur_quantity);
        }
        var option_id	 = event.target.dataset.id
		var selectedOption = component.get('v.SelectedProductOptions');
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
        
        component.set('v.SelectedProductOptions',selectedOption);
        component.set('v.SelectedOptions',selectedOption);
        
        
        // ...
    },
    onChangeOTIquantity: function(component, event, helper) {
        debugger;
        if(event.target.value=="0" || event.target.value==""){
            //alert('Quantity Should More Than 0');
            //event.target.value="1";
           var cur_quantity = 0;
           console.log('cur_quantity--',cur_quantity);
        }else{
           var cur_quantity = event.target.value;
           console.log('cur_quantity--',cur_quantity);
        }
        var option_id	 = event.target.dataset.id
		var selectedOption = component.get('v.SelectedProductOptions');
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
        
        component.set('v.SelectedProductOptions',selectedOption);
        component.set('v.SelectedOptions',selectedOption);
        
        
        // ...
    },
   /* SubTypechange:function(component, event, helper) {
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
           TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Custome_API_Pricing__c;
           TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Custome_API_Price__c; 
        }else if(selectedSubType=='API'){
            TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_API_Pricing__c;
            TempFeatureList[index].OTI_Price__c=OptionRec.OTI_API_Pricing__c; 
        }else if(selectedSubType=='SFTP'){
            TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_SFTP_Pricing__c;
            TempFeatureList[index].OTI_Price__c=OptionRec.OTI_SFTP_Pricing__c; 
        }else if(selectedSubType=='Elite'){
            TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Elite_Pricing__c;
            TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Elite_Pricing__c; 
        }else if(selectedSubType=='Premium'){
            TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Premium_Pricing__c;
            TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Premium_Pricing__c; 
        }else if(selectedSubType=='Pro'){
            TempFeatureList[index].SAAS_Price__c=OptionRec.SAAS_Pro_Pricing__c;
            TempFeatureList[index].OTI_Price__c=OptionRec.OTI_Pro_Pricing__c; 
        }else if(selectedSubType=='None'){
            TempFeatureList[index].SAAS_Price__c=OptionRec.Base_SAAS_Price__c;
            TempFeatureList[index].OTI_Price__c=OptionRec.Base_OTI_Price__c; 
        }
        
        console.log('TempFeatureList',TempFeatureList);
        // helper.helperMethod(component, event,TempFeatureList);
        //component.set("v.tempListLatest",TempFeatureList)
    }*/
    
})
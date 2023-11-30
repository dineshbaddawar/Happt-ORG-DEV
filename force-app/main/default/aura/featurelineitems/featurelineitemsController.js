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
         var TempFeatureList = component.get("v.SelectedProductOptions");
         var SelectedOptionRec=component.get("v.selectedQLI");
         var selectedContacts = [];
         var temptemptemp = [];
        if(checkbox.get("v.value")==true){
            
            var deleteId=component.get('v.deleteqliId');
            if(deleteId.length >0){
                if(deleteId.find(item=>item==selIdx)){
                    deleteId = deleteId.filter(item => item !== selIdx);
                }else{
                    console.log('This Id Does not Exists') 
                }
            }
           
            
            component.set('v.deleteqliId',deleteId);
            
            if(SelectedOptionRec.find(item=>item.Id==selIdx)){
                console.log('This Id Exists');
             }else{  
                
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
                                 if(deleteId.find(item=>item==TempFeatureList[i].Id)){
                                     deleteId = deleteId.filter(item => item!== TempFeatureList[i].Id);  
                                 }
                             }
                         } 
                     } 
                 }
                 
                 console.log('SelectedOptionRec--'+SelectedOptionRec);
                 component.set('v.tempList',TempFeatureList);
                 component.set('v.deleteqliId',deleteId);
            }
        } else if(checkbox.get("v.value")==false){
              var selIdx = event.getSource().get("v.text");
              var deleteId=component.get('v.deleteqliId');
              deleteId.push(selIdx);
              component.set('v.deleteqliId',deleteId);
              console.log('selIdx--',selIdx);
                 var IdsToremove=[];
            
                var OptionRec=TempFeatureList.find(record => record.Id === selIdx);
                console.log('OptionRec--',OptionRec);
            
                SelectedOptionRec.push(OptionRec);
            
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
                 console.log('selectedRecordToremove--',selectedRecordToremove);
                
            }else{
                console.log('This record Does not Exists')
            }
            component.set("v.tempList",TempFeatureList);
        }
        component.set("v.selectedQLI", SelectedOptionRec);
        console.log('SelectedProductOptions--',JSON.stringify(SelectedOptionRec));
         var IsExpenseProduct=component.get('v.IsExpenseProduct');
            if(IsExpenseProduct==false){
                window.setTimeout(
                    $A.getCallback(function() {
                        component.set("v.show",false);
                        helper.selectSingleOption(component, event,TempFeatureList);
                    }),1000     
                );
            }else{
                component.set("v.show",false);
            }
         
    },
    onChangeSAASquantity: function(component, event, helper) {
        debugger;
       
        if(event.getParam('value')=="0" || event.getParam('value')==""){

           var cur_quantity = 0;
           console.log('cur_quantity--',cur_quantity);
        }else{
           var cur_quantity = event.getParam('value');
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
        var tempList=component.get("v.tempList");
        if(event.getParam('value')=="0" || event.getParam('value')==""){
         
           console.log('cur_quantity--',cur_quantity);
        }else{
           var cur_quantity = event.getParam('value');
           console.log('cur_quantity--',cur_quantity);
        }
        var quantity=parseInt(cur_quantity);
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
        var Option_Record;
        Option_Record=tempList.find(record => record.Product__c === option_id);
        if(Option_Record.IsPrice_IsQuantity_Editable__c==true){
             helper.ChangeOTIPrice(component, event,helper,option_id,quantity);   
         }
    },
})
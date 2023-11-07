({
    helperMethod : function(component) {
        debugger;
        var pricing=component.get('v.SelectedPricing');
        
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
            }
        }
       
        
        console.log('IsTravelProd--',JSON.stringify(IsTravelProd));
         component.set('v.IsTrvaelProduct',IsTravelProd);
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
        //='Number Of Booking'+' / '+pricing
        
        component.set('v.NumberOfBookingLabel',tempPricing);

    },
    selectSingleOption: function(component,event,TempTempList){
        debugger;
        
        //var TempProducts=[];
        //
        // 7 var checkbox = event.getSource();
        // 8 console.log(checkbox.get("v.value"));
       // var selIdx = event.getSource().get("v.text");
        // 6 var selIdx=SelectedId;
         // 5 var TempFeatureList = component.get("v.SelectedProductOptions");
       var TempFeatureList= TempTempList
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
        
       // 2 var SelectedOptionRec=component.get("v.selectedQLI");
        //var SelectedProducts=component.get("v.selectedProductList");
       
        
       // 3 var selectedContacts = [];
      // 4  var temptemptemp = [];
        //var checkvalue = component.find("checkContact");
        
       /* if(checkbox.get("v.value")==true){//Comment-1 start
            
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
                }),500
            );*/  //Comment1--End
           
        var ExAppEvent = $A.get("e.c:ParentSelectedOptionId");
        ExAppEvent.setParams({
            SelectedparentRecords:TempFeatureList,
            //Loader:component.get("v.show")
        });                                               
        ExAppEvent.fire();
        
        /*var spinner=component.get("v.show");
        component.set("v.show",false);*/
        /*var attribute1=component.get("v.ParentParam1");
        var attribute2=component.get("v.ParentParam2");
        var attribute3=component.get("v.tempList");
        var ChildComponent=component.find('ChildComp');
        //tempList
        //component.set("v.tempList", attribute3);
        ChildComponent.myChildComponentMethod(attribute1,attribute2,attribute3)*/
    }
})
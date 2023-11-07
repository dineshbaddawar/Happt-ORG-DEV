({
    doInit: function (cmp, event, helper) {
        debugger;
        var accTypeCalculated = cmp.get('v.accTypeCalculated');
        
        var mapOfProdIdbyListOfPLDTobeReturn = cmp.get('v.mapOfProdIdbyListOfPLDTobeReturn');
        var mapOfNestedProdIdByListOfPLDTobeReturn = cmp.get('v.mapOfNestedProdIdByListOfPLDTobeReturn');
        var keyList = cmp.get('v.keyList');
        cmp.set('v.qliList',mapOfProdIdbyListOfPLDTobeReturn[keyList[0]]);
        var data = [];
        
        var nestedDataByProdId = new Map();
        var childData = [];
        
        for(let i = 0; i < keyList.length; i++){
            for (let j = 0; j < mapOfProdIdbyListOfPLDTobeReturn[keyList[i]].length; j++) {
                
                if(mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id] != undefined){
                    if(mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id].length > 0){
                        for (let k = 0; k < mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id].length; k++){
                            childData.push({
                                "name": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Product_Name__c,
                                "Parent_Quote_Line_Item__c":mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Parent_Quote_Line_Item__c,
                                "Product2Id":mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Product2Id,
                                "OTI_Price__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].OTI_Price__c,
                                "Quantity": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Quantity,
                                "SAAS_Price__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].SAAS_Price__c,
                                "Selected__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Selected__c,
                                "Travel_Offering_Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Travel_Offering_Type__c,
                                "Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Type__c,
                                "Sub_Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Quantity
                            })
                        }
                    }else{
                        childData.push({
                            "name": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Product_Name__c,
                            'Id':mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][k].Id,
                            "OTI_Price__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].OTI_Price__c,
                            "Quantity": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Quantity,
                            "SAAS_Price__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].SAAS_Price__c,
                            "Selected__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Selected__c,
                            "Travel_Offering_Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Travel_Offering_Type__c,
                            "Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Type__c,
                            "Sub_Type__c": mapOfNestedProdIdByListOfPLDTobeReturn[mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id][0].Quantity
                        });
                    }
                    nestedDataByProdId.set(mapOfProdIdbyListOfPLDTobeReturn[keyList[i]][j].Product2Id,childData); 
                }
            }
        }
        var custs = [];
        
        nestedDataByProdId.forEach((values,keys)=>{custs.push({value:values, key:keys});})
    cmp.set('v.relatedList', custs);
    
},
 deleteProduct : function (cmp, event, helper) {
    debugger;
    cmp.set('v.qliList', '');
    cmp.set('v.relatedList', '');
    
    var buttonName = event.getSource().get("v.name");    
    if(buttonName == 'Delete Travel Product'){
        cmp.set('v.isTravelProduct', false);
    }else{
        cmp.set('v.isExpenseProduct', false);
    }
},
    onCheckBoxSelection: function (cmp, event, helper) {
        debugger;
        var selectedChildItems = cmp.get('v.childQliList');
        var selIdx = event.getSource().get("v.name");
        var relatedList = cmp.get('v.relatedList')[0].value;
        selectedChildItems.push(relatedList[selIdx]);
        cmp.set('v.childQliList', selectedChildItems);
        
    },
})
({
	FetchChildQLI:function(component, event, helper) {
        debugger;
        var arr=[];
        var Counter=0;
        var QLI=component.get("v.AvailbaleQliList");
         var ParentId=component.get("v.ParentQLiId");
        
        for(let i=0;i<QLI.length;i++){
            Counter++
            if(QLI[i].Nested_Parent_Product__c!=null){
                if(QLI[i].Nested_Parent_Product__c==ParentId){
                    arr.push(QLI[i]);
                    component.set('v.tempList',arr);  
                }  
            }
            
        }
        console.log('Counter--',Counter);
        if(QLI.length==Counter){
            //location.reload();
        }
    }
})
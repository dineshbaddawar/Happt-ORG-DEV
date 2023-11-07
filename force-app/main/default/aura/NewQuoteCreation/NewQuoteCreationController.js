({
	myAction : function(component, event, helper) {
		
	},
    handleSuccess:function(component, event, helper) {
        debugger;
       var Id= event.getParam("id");
        if(Id!=null){
          window.location.href='/lightning/r/Quote/'+Id+'/view';  
        }
        console.log('Id--',Id);
    },
    onLoad:function(component, event, helper) {
        debugger;
        //var fields = event.getParam('fields');
        //fields.OpportunityId=component.get("v.recordId");
    },
    handleOnSubmit : function(component, event, helper){
        debugger;
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
        eventFields["OpportunityId"] = component.get("v.recordId");
        component.find('contactRecordCreator').submit(eventFields); //Submit Form
    }
})
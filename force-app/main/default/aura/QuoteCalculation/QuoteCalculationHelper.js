({
	calculateCommitment : function(component, event, helper) {
        debugger;
        var offType = component.get("v.selectedofferingType");
        var pricingType = component.get("v.selectedpricingType");
        var numOfBookings = parseInt(component.get("v.numberOfBookings"));
        var commitment = '';
        if(pricingType == 'Per Trip' || pricingType == 'Per User'){
            if(numOfBookings != null && ((numOfBookings * 35)/100 < 4000)){
                commitment = 4000;
                //4000
            }else{
                commitment = (numOfBookings * 35)/100;
            }
        }else if(pricingType == 'Per Booking'){
            if(numOfBookings != null && ((numOfBookings * 30)/100 < 5000)){
                commitment = 5000;
                //5000
            }else{
                commitment = (numOfBookings * 30)/100;
            }
        }else if(pricingType == 'Non SBT Per Trip'){
            if(numOfBookings != null && ((numOfBookings * 35)/100 < 4000)){
                commitment = 4000;
            }else{
                commitment = (numOfBookings * 35)/100;
            }
        }else if(pricingType == 'Per Report'){
            if(numOfBookings != null && numOfBookings < 10000){
                commitment = 10000;
                //10000
            }else{
                commitment = numOfBookings;
            }
        }
        component.set("v.minimumCommitment", commitment);
    }
})
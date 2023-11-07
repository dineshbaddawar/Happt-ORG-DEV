import { LightningElement ,api,track ,wire} from 'lwc';
import getPricingTypeDetails from '@salesforce/apex/ManageProductHandler.getPricingTypeDetails';
import  deleteProducts  from '@salesforce/apex/ManageProductHandler.deleteProducts';
export default class ProductTableRowDetails extends LightningElement {
@api itemdetails;
@api item;
@track proType;
@track priceValue;
@track subtotalValue=0;
@track totalValue=0;
@api selectedProductPricelabel='';
@api selectedProductPricerecordId='';
@track whereClausePricing='';
@api ErrorMessage;
@api index;
@track sObjectName = 'Opportunity';


connectedCallback() {
    this.item = {...this.itemdetails}
    
     if(this.item != null)
              {
                //GetSelectPricingLabelOfRecord='';
                this.whereClausePricing = ' and Product__c = \''+this.item.Product2Id+'\'';
                
                getPricingTypeDetails({proId: this.item.Product2Id})
                .then(result =>{
                    this.proType = result;
                    this.selectedProductPricelabel = this.item.Product_Pricing;
                    if(this.selectedProductPricelabel!=''&&this.selectedProductPricelabel!=null)//Already Selected
                    {
                        for(var i=0;i<this.proType.length;i++)
                        {
                            if(this.proType[i].Pricing_Type__c==this.selectedProductPricelabel)
                            {
                              
                            if(this.item.Is_Pricing_Dependent)
                            {
                            
                            this.item.ListPrice=0;
                            this.item.UnitPrice=0;
                            } 
                                this.selectedProductPricerecordId = this.proType[i].Id;
                                //
                                this.item.Subtotal = this.item.Quantity * this.item.UnitPrice;
                                  
                                this.item.TotalPrice = parseFloat( this.item.Subtotal -(this.item.Discount  * this.item.Subtotal / 100));
                                this.subtotalValue = this.item.Subtotal;
                                
                                if(this.item.TotalPrice)
                                {
                                  this.totalValue = this.item.TotalPrice;
                                }
                                else
                                {
                                  this.totalValue = this.item.Subtotal;
                                }
                            }
                        }
                    }
                    else{//Not Selected ALready
                        
                        
                            this.selectedProductPricerecordId = this.proType[0].Id;
                         //   this.priceValue = this.proType[0].List_Price__c;

                            this.item.Product_Pricing = this.proType[0].Pricing_Type__c;
                            

                           
                            if(!this.item.ListPrice)
                            {
                               this.item.ListPrice = this.proType[0].List_Price__c;
                            }
                            if(!this.item.UnitPrice)
                            {
                                this.item.UnitPrice = this.proType[0].List_Price__c;
                            }

                            if(this.item.Is_Pricing_Dependent)
                            {
                            
                            this.item.ListPrice=0;
                            this.item.UnitPrice=0;
                            } 

                            

     
                            this.item.Subtotal = this.item.UnitPrice;
                            if(!this.item.Discount)
                            {
                                this.item.Discount = 0;
                            }
                            if(!this.item.Quantity)
                            {
                               this.item.Quantity = 1;
                            }
                            
                            
                            this.item.TotalPrice = parseFloat( this.item.Subtotal -(this.item.Discount  * this.item.Subtotal / 100));
                            this.subtotalValue = this.item.Subtotal;
                            this.totalValue = this.item.TotalPrice;
                            
                    }
                    
                })
                .catch(error =>{
                    this.proType ='';
                    console.log('Error:'+error);
                })
              }
              
}
    

get isIndependent(){    
    return this.item.Is_Independent;    
}

get isDependentPricing()
{
    return this.item.Is_Pricing_Dependent;
}
handlePrice(event)
{
    if(!this.item.Discount)
    {
        this.item.Discount = 0;
    }
    this.item.UnitPrice = event.detail.value;
    this.item.Subtotal = this.item.Quantity * this.item.UnitPrice;
    this.item.TotalPrice = parseFloat( this.item.Subtotal -(this.item.Discount  * this.item.Subtotal / 100));
    this.subtotalValue = this.item.Subtotal;
    this.totalValue = this.item.TotalPrice;
    
}
handleSlideClicked(event) {   
    
    this.item.ListPrice = event.detail.value;
    this.item.UnitPrice = event.detail.value;
}

handleQuantity(event){
    if(!this.item.Discount)
    {
        this.item.Discount = 0;
    }
    this.item.Quantity = event.target.value;
    this.item.Subtotal = this.item.Quantity * this.item.UnitPrice;
    this.item.TotalPrice = parseFloat( this.item.Subtotal -(this.item.Discount  * this.item.Subtotal / 100));
    this.subtotalValue = this.item.Subtotal;
    this.totalValue = this.item.TotalPrice;

    //let item = _.find(data, ["code", "AL"]);
    //console.log('Item'+JSON.parse(JSON.stringify(this.item)));
   // console.log('productItem'+JSON.parse(JSON.stringify(this.item)));
    //console.log(JSON.stringify(this.item.Product2Id));
    //let wrapper = event.target.value; 
   // this.item.Quantity = wrapper.Quantity;
   // console.log('item.Qtn'+this.item.Quantity);
    //updateWrapper(this.item);

}

handleOtherDetails(event)
{
    this.item.Other_Details =event.target.value;
}

handleDis(event){
    this.item.Discount = (event.target.value);

    this.item.Subtotal = this.item.Quantity * this.item.UnitPrice;
    this.item.TotalPrice = parseFloat( this.item.Subtotal -(this.item.Discount  * this.item.Subtotal / 100));
    this.subtotalValue = this.item.Subtotal;
    this.totalValue = this.item.TotalPrice;
 
}

handleUpdatePricing(event){
        //alert('Selected Record Value on Parent Component is ' +  event.target.dataset.recordId);
        
        var selRows =  JSON.parse(JSON.stringify(event.detail.selectedRecord));
        this.item.Product_Pricing = selRows.Pricing_Type__c;

        if(selRows.List_Price__c!=null){
            this.item.ListPrice = selRows.List_Price__c;
            this.item.UnitPrice = selRows.List_Price__c;
        }
        else{
            this.item.ListPrice =0;
            this.item.UnitPrice = 0;
        }
        this.item.Subtotal = this.item.UnitPrice * this.item.Quantity;
        
        this.item.TotalPrice = parseFloat( this.item.Subtotal -(this.item.Discount  * this.item.Subtotal / 100));
        this.subtotalValue = this.item.Subtotal;
        this.totalValue = this.item.TotalPrice;    
        
        
      //  alert('Selected Record Value on Parent Component is ' +  JSON.stringify(event.detail.selectedRecord));
    }

    
  
        
    handleDeleteitem()
    {
        var ind = this.index;
        const deleteEvent = new CustomEvent('delete', {
                detail: { ind
            },
             bubbles: true,
             composed: true
            }   
            );
          
            // 3. Fire the custom event
             this.dispatchEvent(deleteEvent);
    }

@api showValidationMessage(){
    this.ErrorMessage=true;
}
@api hideValidationMessage()
{
    this.ErrorMessage=false;
}


    @api manageDiscount(SAAS_Discount,OTI_Discount ){
    console.log(SAAS_Discount);
    console.log(OTI_Discount);
    console.log(this.item);
    if(this.item.Product_Type == 'OTI')
    {
        this.item.Discount = OTI_Discount;
    }
    if(this.item.Product_Type == 'SAAS')
    {
        this.item.Discount = SAAS_Discount;
    }
    this.item.Subtotal = this.item.Quantity * this.item.UnitPrice;
    if(this.item.Discount)
    {
    this.item.TotalPrice = parseFloat( this.item.Subtotal -(this.item.Discount  * this.item.Subtotal / 100));
    }
    else
    {
    this.item.TotalPrice = this.item.Subtotal;
    }
    this.subtotalValue = this.item.Subtotal;
    this.totalValue = this.item.TotalPrice;
 
}

}

function updateWrapper(item){


const selectedEvent = new CustomEvent("updatedItem", {
      detail: item, bubbles:true
    });

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
}
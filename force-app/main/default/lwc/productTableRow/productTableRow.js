import { LightningElement ,api } from 'lwc';
export default class ProductTableRow extends LightningElement {
@api item;
@api index;

get PricingTypeOTI(){
    
return this.item.pricingType=='OTI';    
}

@api handleItem(){
    var rowDetail=this.template.querySelector('c-product-table-row-details');
    if(rowDetail)
        return rowDetail.item;
    else
        return null;
    //return {};
}

handleDelete(){
    
    
}


@api showValidationMessage(){
        this.template.querySelector('c-product-table-row-details').showValidationMessage();
}

@api hideValidationMessage(){
           this.template.querySelector('c-product-table-row-details').hideValidationMessage();
}
@api manageDiscount(SAAS_Discount,OTI_Discount ){
              this.template.querySelector('c-product-table-row-details').manageDiscount(SAAS_Discount,OTI_Discount);
}
}
import { LightningElement ,api ,wire,track} from 'lwc';
import  deleteProducts  from '@salesforce/apex/ManageProductHandler.deleteProducts';
export default class ProductTable extends LightningElement {

    @api itemlist = [];
    
    @api handleList()
    {
        //return [];

        var returnObj ={};
        var allDetailsValid = true;
        var listofItem = [];

        for(let i=0; i<this.template.querySelectorAll('c-product-table-row').length;i++){

                let listItem = this.template.querySelectorAll('c-product-table-row')[i].handleItem();
            
                if(listItem!=null){
                    if(!this.checkValidity(listItem))
                    {
                        this.template.querySelectorAll('c-product-table-row')[i].showValidationMessage();
                        allDetailsValid = false;
                    }
                    else{
                        this.template.querySelectorAll('c-product-table-row')[i].hideValidationMessage();
                        listofItem.push(this.template.querySelectorAll('c-product-table-row')[i].handleItem());
                    }
                }

            }
            for(let i=0; i<this.template.querySelectorAll('c-product-table-row-o-t-i').length;i++){
                    let listItem = this.template.querySelectorAll('c-product-table-row-o-t-i')[i].handleItem();
                    
                    
                    if(listItem!=null){
                        if(!this.checkValidity(listItem))
                        {
                            this.template.querySelectorAll('c-product-table-row-o-t-i')[i].showValidationMessage();
                            allDetailsValid = false;
                        }
                        else{
                            this.template.querySelectorAll('c-product-table-row-o-t-i')[i].hideValidationMessage();
                            listofItem.push(this.template.querySelectorAll('c-product-table-row-o-t-i')[i].handleItem());
                        }
                    }
            
        }
        returnObj.allDetailsValid = allDetailsValid;
        returnObj.listofItem = listofItem;
        return returnObj;
    }


    checkValidity(item){
        
        var isValid = true;
        item.Sales_Type='Cross Sell';

        if(!item.Product_Pricing&&item.Is_Generic==false)
        {
            isValid=false;
        }
        if(!item.Sales_Type)
        {
            isValid = false
        }
        console.log(isValid);
        return isValid;
    }
    handleDelete(event)
    {
        const indx = event.detail.ind;
        event.stopPropagation();

        var listofItems = [];

        for(let i=0; i<this.template.querySelectorAll('c-product-table-row').length;i++)
        {

            let listItem = this.template.querySelectorAll('c-product-table-row')[i].handleItem();
        
            if(listItem!=null){
                    listofItems.push(this.template.querySelectorAll('c-product-table-row')[i].handleItem());
             
            }

        }
        var itemtoRemove = listofItems[indx];
        listofItems.splice(indx,1);
        this.itemlist = listofItems;
        
        const deleteEvent = new CustomEvent('updatetableondelete', {
                detail: { listofItems
            },
             bubbles: true,
             composed: true
            }   
            );
          
        // 3. Fire the custom event
        this.dispatchEvent(deleteEvent);

        
        if(itemtoRemove.RecordId!=null)
        {
            //CallApexMethodtoRemove

            deleteProducts({recordId: itemtoRemove.RecordId })
                        .then(result =>{

                            const refreshQA = new CustomEvent('refresh');
                            // Dispatches the event.
                            this.dispatchEvent(refreshQA);
                        })
                        .catch(error =>{
                            console.log('Error:'+error);
                        })
        }
    }

    @api addDiscount(SAAS_Discount,OTI_Discount)
    {
            for(let i=0; i<this.template.querySelectorAll('c-product-table-row').length;i++)
            {

                    this.template.querySelectorAll('c-product-table-row')[i].manageDiscount(SAAS_Discount,OTI_Discount);

        
            }
    }
    
}
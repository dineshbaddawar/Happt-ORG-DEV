import { LightningElement ,api, track,wire} from 'lwc';
import getChildProducts from '@salesforce/apex/ManageProductHandler.getChildProducts';
import upsertProducts from '@salesforce/apex/ManageProductHandler.upsertProducts';
import fetchLineItems from '@salesforce/apex/ManageProductHandler.fetchLineItems';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ManageProductMain extends LightningElement {

    @api selectedProduct;
    @track resultWrapper;//Values from Apex Method 
    @api isValid = false;
    @api productItemsInTable=[];
    
    @api sObjectName ;
    @track productItemsToUpsert=new Map();
    @api recordId ;
    @track salesTypeSelectedValue ='';
    @track hasAccess = true;
    @track selectedProdDesciption ='';
    @track SAAS_Discount='';
    @track OTI_Discount='';
    InProcess =false;
    @track SalesTypeOption = [
                                { label : 'New Business', value : 'New Business' },
                                { label : 'Cross Sell', value : 'Cross Sell' },
                                { label : 'Upsell', value : 'Upsell' },
                                {label :'CR', value:'CR'}
                             ];
  

     connectedCallback() {
        fetchLineItems({recordId: this.recordId })
                        .then(result =>{

                            var productItemsfromApex=[];
                            this.hasAccess = result.hasAccess;
                               this.resultWrapper = result.allRecords;
                               this.SAAS_Discount = result.SAAS_Discount;
                               this.OTI_Discount = result.OTI_Discount;
                            for(let i = 0; i< this.resultWrapper.length;i++)
                            {
                                 var itemData = JSON.stringify(this.resultWrapper[i]);
                                productItemsfromApex.push(JSON.parse(itemData));
                                 
                            }
                            this.productItemsInTable = JSON.parse(JSON.stringify(productItemsfromApex));
                            this.template.querySelector('c-product-table').itemlist = JSON.parse(JSON.stringify(productItemsfromApex));
                            this.selectedProduct=null;
                            this.template.querySelector('c-custom-lookup-advanced').handleRemove()
                            
                        })
                        .catch(error =>{
                         
                            console.log('Error:'+error);
                        })
     }
    lookupRecord(event){
      
        var selectedRowsIds = [];
        var selRows =  JSON.parse(JSON.stringify(event.detail.selectedRecord));
        this.selectedProduct = selRows.Id;
        if(selRows.Product__c!=null)
        {
        console.log('selRows'+selRows.Product__r.Description);
        this.selectedProdDesciption = selRows.Product__r.Description;
        }
      
    }

    handleAdd(event){
            
            //Call Apex Method

            if(!this.InProcess){
                this.InProcess = true;
             if(this.selectedProduct != null)
             {
                 if(this.salesTypeSelectedValue=='')
                 {
                    const evt = new ShowToastEvent({
                    title: "Incomplete Information",
                    message: 'Please Select Sale Type to continue.',
                    variant: 'error',
                    });
                    this.dispatchEvent(evt);
                 }
                 else{
                        getChildProducts({parentId: this.selectedProduct })
                                .then(result =>{
                                    this.resultWrapper = result;
                                
                                    for(let i = 0; i< this.resultWrapper.length;i++)
                                    {
                                        var itemData = JSON.stringify(this.resultWrapper[i]);
                                        var parseditemData = JSON.parse(itemData);
                                        parseditemData.Sales_Type = this.salesTypeSelectedValue;
                                        this.productItemsInTable.push(parseditemData);
                                    }
                                     this.salesTypeSelectedValue='';
                                    this.template.querySelector('c-product-table').itemlist = JSON.parse(JSON.stringify(this.productItemsInTable));
                                    //this.productItemsInTable = [];
                                    this.selectedProduct=null;

                                    this.template.querySelector('c-custom-lookup-advanced').handleRemove()
                                    this.InProcess=false;
                                })
                                .catch(error =>{
                                    console.log('Error:'+error);
                                    this.InProcess=false;
                                })

                               
                    }
             }
        }

    }

    get disableSave()
    {
        return !this.isValid;
    }


    handleDeleteOps(event)
    {
        const listofItems = event.detail.listofItems;
        event.stopPropagation();
        this.productItemsInTable = listofItems; 
    }
    
    handleValidate(event){
        var returnObj =  this.template.querySelector('c-product-table').handleList();
        if(!returnObj.allDetailsValid)
        {
            //ShowToast
            const evt = new ShowToastEvent({
            title: "Incomplete Information",
            message: 'Please complete product details to proceed.',
            variant: 'error',
        });
        this.dispatchEvent(evt);
        }
        else{
            this.isValid =true;
             const evt = new ShowToastEvent({
                            title: "Succesfully Validated!",
                            
                            variant: 'success',
                            });
                            this.dispatchEvent(evt);
             }
        }
     
     handleSave(event){
          if(!this.InProcess){
                this.InProcess = true;
        var returnObj =  this.template.querySelector('c-product-table').handleList();
        if(!returnObj.allDetailsValid)
        {
            //ShowToast
            const evt = new ShowToastEvent({
            title: "Incomplete Information",
            message: 'Please complete product details to proceed.',
            variant: 'error',
            });
             this.dispatchEvent(evt);
               this.InProcess=false;
        }
        else{
            this.isValid =true;
                        for(var i=0;i<returnObj.listofItem.length;i++)
                        {
                            returnObj.listofItem[i].SortOrderforRecords = i;
                         
                        }
                        console.log(returnObj)
console.log('this.SAAS_Discount'+this.SAAS_Discount);
                        upsertProducts({wrapperList: returnObj.listofItem,sObjectId:this.recordId ,sObjectName: this.sObjectName  , SAAS_Discount: this.SAAS_Discount, OTI_Discount:this.OTI_Discount})
                        .then(result =>{
                            const evt = new ShowToastEvent({
                            title: "Products Saved",
                            message: 'The Products have been saved.',
                            variant: 'success',
                            });
                            this.dispatchEvent(evt);
                            this.InProcess=false;
                            const closeQA = new CustomEvent('refreshclose');
                            // Dispatches the event.
                            this.dispatchEvent(closeQA);
                              
                        })
                        .catch(error =>{
                            console.log(error);
                              this.InProcess=false;
                        })
             }
          }
        }
    
    handleChange(event) {

        this.salesTypeSelectedValue = event.detail.value;

    }
    
    handleClose(event){
             const closeQA = new CustomEvent('close');
                            // Dispatches the event.
                            this.dispatchEvent(closeQA);
    }
    
    handleRefresh(event)
    {
          const refreshQA = new CustomEvent('refresh');
                            // Dispatches the event.
                            this.dispatchEvent(refreshQA);
    }

    handleDiscount(event)
    {
              this.template.querySelector('c-product-table').addDiscount(this.SAAS_Discount,this.OTI_Discount);
    }

    handleOTIdiscount(event)
    { 
        if(event.detail.value){
             this.OTI_Discount = event.detail.value;
        }
        else{
           this.OTI_Discount = 0;
        }
        
    }

    handleSAASdiscount(event)
    {
        if(event.detail.value){
            this.SAAS_Discount = event.detail.value;
        }
        else{
            this.SAAS_Discount = 0;
        }
    }
}
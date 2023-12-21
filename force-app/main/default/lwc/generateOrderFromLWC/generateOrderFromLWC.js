/**
 * @author [Dinesh B]
 * @email dinesh.b@utilitarianLab.com
 * @create date 2023-11-20 12:44:40
 * @modify date 2023-11-21 13:10:55
 * @desc [description]
 */

import { LightningElement,api } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateSelectedOrderForm from '@salesforce/apex/GenerateOrderFromLWCHelper.generateSelectedOrderForm';
import getQuoteDetails from '@salesforce/apex/GenerateOrderFromLWCHelper.getQuoteDetails';

import SubscriptionWithOTIOFLabel from '@salesforce/label/c.SubscriptionWithOTIOFLabel'; 
import OrderFormSubsOnlyLabel from '@salesforce/label/c.OrderFormSubsOnlyLabel'; 
import OrderFormSubsWithCardLabel from '@salesforce/label/c.OrderFormSubsWithCardLabel'; 
import SubscriptionOTICardOFLabel from '@salesforce/label/c.SubscriptionOTICardOFLabel'; 

export default class GenerateOrderFromLWC extends LightningElement {
    @api recordId;
    isShowPDFPreview = false;
    isShowButton = false;
    isShowSaveCancelButton = false;
    isShowButtonHide = false;
    value = '--None--';
    error;
    data;
    showContactErrorPanel = false;
   
      get options() {
        debugger;
        return [
            { label: 'OF With OTI And Subscription', value: 'OF With OTI And Subscription'},
            { label: 'OF Only With Subscription', value: 'OF Only With Subscription' },
            { label: 'OF With Subscription and Card Details', value: 'OF With Subscription and Card Details' },
            { label: 'OF With OTI, Subscription and Card Details', value: 'OF With OTI, Subscription and Card Details' },
        ];
    }


    connectedCallback(){
        setTimeout(() => {
              debugger;
             this.getData();
           // alert(this.recordId);
        }, 600);
    }

getData(){
    debugger;
    getQuoteDetails({recordId : this.recordId})
    .then(result =>{
     this.data = result;
     if(this.data.ContactId !=undefined && this.data.Contact.Email !=undefined){
       this.isShowButtonHide = true;
    this.showContactErrorPanel = false;
     }else{
         this.showContactErrorPanel = true;
    //  this.showWarningToastWarning();
     }
    })
    .catch(error =>{
       this.error = error;
    })
}



    getPDFViewData() {
        debugger;
         if (this.value == 'OF With OTI And Subscription') {
            this.pdfLink = SubscriptionWithOTIOFLabel+this.recordId;
        }
        if (this.value == 'OF Only With Subscription') {
            this.pdfLink = OrderFormSubsOnlyLabel+this.recordId;
        }
        if (this.value == 'OF With Subscription and Card Details') {
            this.pdfLink = OrderFormSubsWithCardLabel+this.recordId;
        }
        if (this.value == 'OF With OTI, Subscription and Card Details') {
            this.pdfLink = SubscriptionOTICardOFLabel +this.recordId;
        }

    }

    HandleChangeLeaveType(event) {
        debugger;
        this.value = event.detail.value;
        this.getPDFViewData();
        if (this.value != '--None--') {
            this.isShowButton = true;
        } else {
            this.isShowButton = false;
        }
    }

    HandleNextButton() {
        debugger;
        this.isShowPDFPreview = true;
        this.isShowButtonHide = false;
    }

    HandleSumbit() {
        debugger;
        generateSelectedOrderForm({ orderformName: this.value, recordId: this.recordId })
            .then((result) => {
                if (result =='SUCCESS') {
                    this.closeQuickAction();
                    const event = new ShowToastEvent({
                        title: 'SUCCESS',
                        message: 'Order Form generated Successfully !',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    
                } else {
                    this.showErrorToast();
                    this.closeQuickAction();
                }
            })
            .catch((error) => {
                this.error = error;
           })
    }

    closeQuickAction() {
        debugger;
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'SUCCESS',
            message: 'Order Form generated Successfully !',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
        this.closeQuickAction();
    }

    showErrorToast() {
        const evt = new ShowToastEvent({
            title: 'ERROR',
            message: 'Something went wrong !',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
        
    }

    showWarningToastWarning() {
    const evt = new ShowToastEvent({
        title: 'WARNING',
        message: 'Please add Billing Contact before Generating Order Form',
        variant: 'warning',
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
    return;
}

}
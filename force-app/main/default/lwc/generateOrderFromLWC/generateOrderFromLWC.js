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
import OnlySubscriptionOF from '@salesforce/label/c.Order_Only_Subscription_OF'; 
import SubscriptionImplementationOF from '@salesforce/label/c.OrderSubscription_Implementation_OF'; 
import OrderWithCardDeals from '@salesforce/label/c.OrderForm_OfWithCardDeals'; 
import OnlySubscriptionWithCards from '@salesforce/label/c.OrderForm_OnlySubscriptionWithCards'; 
export default class GenerateOrderFromLWC extends LightningElement {
    @api recordId;
    isShowPDFPreview = false;
    isShowButton = false;
    isShowSaveCancelButton = false;
    isShowButtonHide = true;
    value = '--None--';
    get options() {
        debugger;
        return [
            { label: 'Subscription & Implementation OF', value: 'Subscription & Implementation OF'},
            { label: 'Only Subscription OF', value: 'Only Subscription OF' },
            { label: 'OF With Card Deals', value: 'OF With Card Deals' },
            { label: 'Only Subscription With Cards', value: 'Only Subscription With Cards' },
        ];
    }

    connectedCallback(){
        setTimeout(() => {
            // this.getPDFViewData();
           // alert(this.recordId);
        }, 600);
    }

    getPDFViewData() {
        debugger;
        if (this.value == 'Subscription & Implementation OF') {
            this.pdfLink = SubscriptionImplementationOF+this.recordId;
        }
        if (this.value == 'Only Subscription OF') {
            this.pdfLink = OnlySubscriptionOF+this.recordId;
        }
        if (this.value == 'OF With Card Deals') {
            this.pdfLink = OrderWithCardDeals+this.recordId;
        }
        if (this.value == 'Only Subscription With Cards') {
            this.pdfLink = OnlySubscriptionWithCards +this.recordId;
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

}
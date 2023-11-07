import { LightningElement, api, track } from 'lwc';
import insertQuoteAttachmentPDF from '@salesforce/apex/HappyOrderFormVFController.insertQuoteAttachmentPDF';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class InsertQuotePDF extends LightningElement {
     @api recordId;
    @track someData = 'dinesh';

      connectedCallback(){

           setTimeout(() => {
          
          this.getQuoteDetails();
          
           }, 300);
          
      }
     
     getQuoteDetails() {
          debugger;
          insertQuoteAttachmentPDF({ recordId: this.recordId })
               .then(result => {
                    var data = result;
                    if (data != null) {
                         this.handleSuccess();
                    }
          })
     }
     
     handleSuccess() {
          // Close the modal window and display a success toast
          this.dispatchEvent(new CustomEvent('myevent', {
               detail: {
                  // data: someData
               }
           }));
           
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'SUCCESS',
                  message: 'Quote generated successfully !',
                  variant: 'success'
              })
          );
     }
     
}
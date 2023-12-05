import { LightningElement,api,wire,track } from 'lwc';
import updateSowApprove from '@salesforce/apex/ApproveSowController.updateSowApprove';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class ApproveSowController extends LightningElement {

@api recordId;
   connectedCallback(){
        setTimeout(() => {
            this.handleSearch();
        }, 300);
    }

     handleSearch() {
         debugger;
    updateSowApprove({ oppId: this.recordId })
      .then((result) => {
       if(result == 'SUCCESS'){
          this.showNotification('success','SOW Approved','Success');
           this.closeModal();
          eval("$A.get('e.force:refreshView').fire();");
       }
      })
      .catch((error) => {
        this.error = error;
        this.contacts = undefined;
      });
  }

   showNotification(title,msg,res) {
    const evt = new ShowToastEvent({
      title: title,
      message: msg,
      variant: res,
    });
    this.dispatchEvent(evt);
  }

closeModal() {
    this.dispatchEvent(new CloseActionScreenEvent());
}



}
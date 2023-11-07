import { LightningElement, api, track, wire } from 'lwc';
import PaymentTermselectionItem from '@salesforce/apex/NewPaymentTermsCondtionController.getActivePaymentTermselectionItem';
import getTermsAndConditions from '@salesforce/apex/NewPaymentTermsCondtionController.getTermsAndConditions';
import createTermasCondition from '@salesforce/apex/NewPaymentTermsCondtionController.createTermasCondition';
import gettermsCoditions from '@salesforce/apex/NewPaymentTermsCondtionController.getTermsConditions';
import { CloseActionScreenEvent } from 'lightning/actions';
export default class NewPaymentTermsCondtion extends LightningElement {

     @api recordId;
     @track termSectionList = [];
     @track termsAndConditions = [];
     @track IsLoaded = false;
     @track checked = true;
     @track IsSelected = false;
     @track PaymentTermValue;
     @track richtext;
     error;
     showDecription = true;
     popUpOpen = true;
     myMap = new Map();
     termmyMap = new Map();
     lateTermMap = new Map();
     report50_00_TermMap = new Map();
     reportgreterthan_100 = new Map();
     childparentMap = new Map();
     AMC_10_20ofARR = new Map();
     termsConditions = [];
     termsshouldUpdate = false;
     namevalue;
     childId;
     inputTextareaValue = '';
     TliIdDecriptionmap = new Map();
   
     @wire(getTermsAndConditions, { quoteId: '$recordId' })
     debugger;
     wiredTermsAndConditions({ error, data }) {
       if (data) {
         this.termsAndConditions = data;
         this.error = undefined;
       } else if (error) {
         this.error = error;
         this.termsAndConditions = undefined;
       }
     }
     connectedCallback() {
      debugger;
       this.wiredTermsAndConditions;
       PaymentTermselectionItem({}).then(result => {
         debugger;
         let res = [];
         res = result;
         this.termSectionList = res;
         debugger;
        //  gettermsCoditions({ recordId: this.recordId }).then(res => {
        //    this.termsConditions = res;
        //  })
       })
     }

     handleDescriptionChange(event){
       debugger;
      // this.inputTextareaValue = event.target.value;
       var selectedChildId = event.target.dataset.id;
       var clonedataObj = this.termSectionList;
       var actualDataobj =  JSON.parse(JSON.stringify(clonedataObj));
        actualDataobj.forEach(term => {
         term.Term_Attribute_Line_Items__r.forEach(tli => {
             if ((tli.Id == selectedChildId)) {
              this.inputTextareaValue = event.target.value;
              this.TliIdDecriptionmap.set(tli.Id,this.inputTextareaValue);
             }else{
                this.inputTextareaValue= '';
             }
         });
       });
     }

     handleChildSelection(event) {
       debugger;
       const selectedTermId = event.target.value;
       const selectedTermSectId = event.target.name;
       const sectionName = event.target.dataset.sectionname;
       this.termSectionList.forEach(term => {
         term.Term_Attribute_Line_Items__r.forEach(tli => {
           if (sectionName == term.Name) {
             if ((tli.Id == selectedTermId)) {
               tli.IsSelected = true;
             } else {
               tli.IsSelected = false;
             }
           }
      if(sectionName == term.Name){
           
           if (tli.Id == selectedTermId) {
          if(tli.Name == 'Plan 5'){
              tli.InputValue = true;
          }
          else if (tli.Name == 'Mandays Criteria') {
                tli.InputValue = true;
            }
          else {
                tli.InputValue = false;
          }
        }else{
          tli.InputValue = false;
        }
      }
        

         });
       });

        //  var deepClonedata = this.termSectionList;
        //   var student2 = JSON.parse(JSON.stringify(deepClonedata))
        //   student2.forEach(term => {
        //        term.Term_Attribute_Line_Items__r.forEach(tli => {
        //             if (tli.Id == selectedTermId) {
        //                 if(tli.Name == 'Plan 5'){
        //                     tli.InputValue = true;
        //                 }
        //                 else if (tli.Name == 'Mandays Criteria') {
        //                       tli.InputValue = true;
        //                   }
        //                 else {
        //                       tli.InputValue = false;
        //                 }
        //             }
        //        })
        //   })
        //   this.termSectionList = student2;
       if (this.myMap.has(selectedTermSectId)) {
         this.myMap.set(selectedTermSectId, selectedTermId);
       } else {
         this.myMap.set(selectedTermSectId, selectedTermId);
       }
     }
   
     handleInputNumberValue(e) {
       debugger;
       this.childId = e.target.dataset.id;
       var value = e.target.value;
        this.namevalue = e.target.name;
       const sectionName = e.target.dataset.sectionname;
       this.termSectionList.forEach(term => {
         term.Term_Attribute_Line_Items__r.forEach(termLI => {
             if (sectionName == 'Delay Payment Interest') {
               this.lateTermMap.set(this.namevalue, value);
               this.childparentMap.set(this.namevalue,this.childId);
             } else if (sectionName == 'YoY | PUPM/Report 50-100') {
               this.report50_00_TermMap.set(this.namevalue, value);
               this.childparentMap.set(this.namevalue,this.childId);
             }
             else if (sectionName == 'YoY | PUPM/Report >100') {
               this.reportgreterthan_100.set(this.namevalue, value);
                 this.childparentMap.set(this.namevalue,this.childId);
             }
              else if (sectionName == 'YoY | AMC 10-20% of ARR') {
               this.AMC_10_20ofARR.set(this.namevalue, value);
                 this.childparentMap.set(this.namevalue,this.childId);
             }
         })
       });
     }
   
     handleSaveData() {
       debugger;
       this.IsLoaded = true;
       let wrapperListJson = '';
       let wrapperlist = [];
       let descriptionTliList = [];
       let descriptionJson = '';
       if (this.myMap.size > 0) {
        for (const [key, value] of this.myMap.entries()) {
          let wrapperObj = {
            quoteName: this.recordId,
            sectionLineItemKey: key,
            attributeLineItemValue: value
          }
          wrapperlist.push(wrapperObj);
        }
       }

       if (this.lateTermMap.size >0) {
        for (const [key, value] of this.lateTermMap.entries()) {
          let wrapperObj = {
            quoteName: this.recordId,
            sectionLineItemKey: key,
            attributeLineItemValue: this.childparentMap.get(key),
            LatePaymentInterest: this.lateTermMap.get(key)
          }
          wrapperlist.push(wrapperObj);
         }
       }

       if (this.report50_00_TermMap.size > 0) {
        for (const [key, value] of this.report50_00_TermMap.entries()) {
          let wrapperObj = {
            quoteName: this.recordId,
            sectionLineItemKey: key,
            attributeLineItemValue: this.childparentMap.get(key),
            YoYPUPMReport_50_100: this.report50_00_TermMap.get(key)
          }
          wrapperlist.push(wrapperObj);
        }
       }

        if (this.reportgreterthan_100.size > 0) {
        for (const [key, value] of this.reportgreterthan_100.entries()) {
          let wrapperObj = {
            quoteName: this.recordId,
            sectionLineItemKey: key,
            attributeLineItemValue: this.childparentMap.get(key),
            pumaReportgreaterthan_100Map: this.reportgreterthan_100.get(key)
          }
          wrapperlist.push(wrapperObj);
        }
       }

         if (this.AMC_10_20ofARR.size > 0) {
        for (const [key, value] of this.AMC_10_20ofARR.entries()) {
          let wrapperObj = {
            quoteName: this.recordId,
            sectionLineItemKey: key,
            attributeLineItemValue: this.childparentMap.get(key),
            pumaReport20_ARRMap: this.AMC_10_20ofARR.get(key)
          }
          wrapperlist.push(wrapperObj);
        }
       }
        
       if(this.TliIdDecriptionmap.size >0){
         for(const [key, value] of this.TliIdDecriptionmap.entries()){
           let wrapperObj = {
             attributeLineId : key,
             attributeDescription : this.TliIdDecriptionmap.get(key)
           }
           descriptionTliList.push(wrapperObj);
         }
       }
       
       descriptionJson =    JSON.stringify(descriptionTliList);
       wrapperListJson = JSON.stringify(wrapperlist);
       debugger;
       createTermasCondition({ wrapperJsonList: wrapperListJson, recordId: this.recordId ,descriptiontalidList : descriptionJson}).then(result => {
         debugger;
         this.IsLoaded = false;
         this.popUpOpen = false;
         this.dispatchEvent(new CloseActionScreenEvent());
         let baseURL = window.location.href.slice(0,56);
         window.location.replace(baseURL+this.recordId);
       });
       this.wiredTermsAndConditions;
     }
    
     handleClose() {
      debugger;
      this.popUpOpen = false
      this.dispatchEvent(new CloseActionScreenEvent());
      let baseURL = window.location.href.slice(0,56);
      window.location.replace(baseURL+this.recordId);
 }
 
}
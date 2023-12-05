// <!---------------------------
// Name: Happy
// File: newPaymentTermsCondition
// -----------------------------
// Author: Dinesh B
// Data:   11/8/2023, 1:13:05 PM
// ---------------------------->

// New alert for more than 10005
//----------------------------------

import { LightningElement, api, track, wire } from 'lwc';
import PaymentTermselectionItem from '@salesforce/apex/NewPaymentTermsCondtionController.getActivePaymentTermselectionItem';
import getExistingTermsConditions from '@salesforce/apex/NewPaymentTermsCondtionController.getExistingTermsConditions';
import createTermasCondition from '@salesforce/apex/NewPaymentTermsCondtionController.createTermasCondition';
import { CloseActionScreenEvent } from 'lightning/actions';
import LightningAlert from 'lightning/alert';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class NewPaymentTermsCondtion extends LightningElement {

  @api recordId;
  @track termSectionList = [];
  @track termsAndConditions = [];
  @track IsLoaded = false;
  @track checked = true;
  @track IsSelected = false;
  @track PaymentTermValue;
  @track richtext;
  @track showErrorMessage=false;
  @track showConformationBox=false;
  @track OnClickOfSaveButton;
  @track IsUpdate;
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
  showBool = false;

  termsectId = new Map();


  connectedCallback() {
    debugger;
    this.wiredTermsAndConditions;
    PaymentTermselectionItem({}).then(result => {
      debugger;
      let res = [];
      res = result;
      this.termSectionList = res;

       this.termSectionList.forEach(term =>{
           term.IsSectionValueSelected=false;
           if(term.Name == 'YoY | AMC 10-20% of ARR'){
             term.IsSectionValueSelected = true;
           }
        })

      this.termSectionList.forEach(term =>{
        if(term.Name == 'YoY | PUPM/Report 50-100'){
          term.wavercheck = true;
        }else{
          term.wavercheck = false;
        }
      })

          getExistingTermsConditions({ recordId: this.recordId }).then(res => {
        this.termsConditions = res;
        if(this.termsConditions.length > 0){
            this.OnClickOfSaveButton='Update Function';
        }else{
           this.OnClickOfSaveButton='Insert Function';
        }
        this.checkMarkedValue();
      })

    })
  }

    checkMarkedValue() {
    this.debugger;
    let tmList = [];
    this.termSectionList.forEach(term => {
      if (term.Term_Attribute_Line_Items__r) {
        let taList = [];
        term.Term_Attribute_Line_Items__r.forEach(tli => {
          let t = { ...tli };
          if (this.termsConditions.find(item => tli.Term_Section_Line_Item__c == item.Term_Section_Line_Item__c && tli.Id == item.Term_Attribute_Line_Item__c)) {
            let record = this.termsConditions.find(item => tli.Term_Section_Line_Item__c == item.Term_Section_Line_Item__c && tli.Id == item.Term_Attribute_Line_Item__c);
           // console.log('record === >', record);
            t.checkValue = true;
            term.IsSectionValueSelected=true;
            if(record.Term_Attribute_Line_Item__c==t.Id && t.Name=='Plan 5'){
                t.InputValue=true;
                t.inputTextareaValue=record.Comments__c
            }
            if(record.Term_Attribute_Line_Item__c==t.Id && t.Name=='Mandays Criteria'){
                t.InputValue=true;
                t.inputTextareaValue=record.Comments__c
            }
            if(record.Term_Attribute_Line_Item__c==t.Id && t.Name=='Delay Payment Interest'){
                    t.InputBoxValue=record.Late_Payment_Interest__c;
            }
            if(record.Term_Attribute_Line_Item__c==t.Id && t.Name=='YoY | PUPM/Report 50-100'){
                    t.InputBoxValue=record.YoY_PUPM_Report__c;
            }
             if(record.Term_Attribute_Line_Item__c==t.Id && t.Name=='YoY | PUPM/Report >100'){
                    t.InputBoxValue=record.YoY_PUPM_Report_100__c;
            }
             if(record.Term_Attribute_Line_Item__c==t.Id && t.Name=='YoY | AMC 10-20% of ARR'){
                    t.InputBoxValue=record.YoY_AMC_10_20_of_ARR__c;
            }
            if(record.Term_Attribute_Line_Item__c==t.Id && t.Name=='Quartely Billing'){
                  this.termSectionList.forEach(term => {
                term.Term_Attribute_Line_Items__r.forEach(tli => {
                  if (term.Name == 'Payment Due Date') {
                    if (tli.Name == '60') {
                      tli.hideClass = 'slds-hidden';
                    }
                  }
                })
              })
            }
          }
          taList.push(t);
        })
        let termDup = Object.assign({}, term);
        termDup.Term_Attribute_Line_Items__r = taList;
        tmList.push(termDup);
      }
    })
    this.termSectionList = tmList;
  }

  handleDescriptionChange(event) {
    debugger;
    // this.inputTextareaValue = event.target.value;
    var selectedChildId = event.target.dataset.id;
    var clonedataObj = this.termSectionList;
    var actualDataobj = JSON.parse(JSON.stringify(clonedataObj));
    actualDataobj.forEach(term => {
      term.Term_Attribute_Line_Items__r.forEach(tli => {
        if ((tli.Id == selectedChildId)) {
          this.inputTextareaValue = event.target.value;
          this.TliIdDecriptionmap.set(tli.Id, this.inputTextareaValue);
          this.termsectId.set(tli.Id, term.Id); 
        } else {
          this.inputTextareaValue = '';
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
            term.IsSectionValueSelected=true;
          if ((tli.Id == selectedTermId)) {
            tli.IsSelected = true;
          } else {
            tli.IsSelected = false;
          }
        }
        if (sectionName == term.Name) {
          if (tli.Id == selectedTermId) {
            if (tli.Name == 'Plan 5') {
              tli.InputValue = true;
            }
            else if (tli.Name == 'Mandays Criteria') {
              tli.InputValue = true;
            }
            else {
              tli.InputValue = false;
            }
          } else {
            tli.InputValue = false;
          }
        }

       
        if (sectionName == 'Billing Type') {
          if ((tli.Id == selectedTermId)) {
            if (tli.Name == 'Quartely Billing') {
              this.termSectionList.forEach(term => {
                term.Term_Attribute_Line_Items__r.forEach(tli => {
                  if (term.Name == 'Payment Due Date') {
                    if (tli.Name == '60') {
                      tli.hideClass = 'slds-hidden';
                    }
                  }
                })
              })
            } else {

              this.termSectionList.forEach(term => {
                term.Term_Attribute_Line_Items__r.forEach(tli => {
                  if (term.Name == 'Payment Due Date') {
                    if (tli.Name == '60') {
                      tli.hideClass = '';
                    }
                  }

                })

              })
            }
          }
        }


      });
    });

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
    if(value > 100){
      this.percentageAlertClick();
    }
    this.namevalue = e.target.name;
    const sectionName = e.target.dataset.sectionname;
   // this.termSectionList.forEach(term => {
      //term.Term_Attribute_Line_Items__r.forEach(termLI => {
      for (let i=0;i<this.termSectionList.length;i++){
            if (sectionName == 'Delay Payment Interest' && sectionName==this.termSectionList[i].Name) {
              if(e.target.value =="" || e.target.value==null){
                   this.termSectionList[i].IsSectionValueSelected=false;
              }else{
                 this.termSectionList[i].IsSectionValueSelected=true;
              }
                  
              this.lateTermMap.set(this.namevalue, value);
              this.childparentMap.set(this.namevalue, this.childId);
              break;
            } else if (sectionName == 'YoY | PUPM/Report 50-100' && sectionName==this.termSectionList[i].Name) {
              if(e.target.value =="" || e.target.value==null){
                   this.termSectionList[i].IsSectionValueSelected=false;
                   this.report50_00_TermMap.set(this.namevalue, 0);
              }else{
                 this.termSectionList[i].IsSectionValueSelected=true;
                 this.report50_00_TermMap.set(this.namevalue, value);
              }
              
              this.childparentMap.set(this.namevalue, this.childId);
              break;
            }
            else if (sectionName == 'YoY | PUPM/Report >100' && sectionName==this.termSectionList[i].Name) {
                if(e.target.value =="" || e.target.value==null){
                   this.termSectionList[i].IsSectionValueSelected=false;
                   this.reportgreterthan_100.set(this.namevalue, 0);
              }else{
                 this.termSectionList[i].IsSectionValueSelected=true;
                 this.reportgreterthan_100.set(this.namevalue, value);
              }
              
              this.childparentMap.set(this.namevalue, this.childId);
              break;
            }
            else if (sectionName == 'YoY | AMC 10-20% of ARR' && sectionName==this.termSectionList[i].Name) {
              if(e.target.value =="" || e.target.value==null){
                   this.AMC_10_20ofARR.set(this.namevalue, 0);
              }else{
                   this.AMC_10_20ofARR.set(this.namevalue, value);
              }
              this.childparentMap.set(this.namevalue, this.childId);
              break;
            }
      }
       
    //})
  }

  handleClickConfirm(){
     debugger;
     this.IsUpdate='yes';
     this.handleSaveData();
  }

  handleSaveData() {
    debugger;
  this.termSectionList.forEach(term =>{
           if(term.Name == 'YoY | PUPM/Report 50-100' && term.IsSectionValueSelected ==true){
              this.termSectionList.forEach(term =>{ 
                if(term.Name == 'YoY | PUPM/Report >100'){
                  term.IsSectionValueSelected = true;
                }
              })
             
           }else if(term.Name == 'YoY | PUPM/Report >100' && term.IsSectionValueSelected ==true){
             this.termSectionList.forEach(term =>{ 
                if(term.Name == 'YoY | PUPM/Report 50-100'){
                  term.IsSectionValueSelected = true;
                }
              })
           }
  })
      let Counter=0;
       this.termSectionList.forEach(term =>{
           if(term.IsSectionValueSelected==false){
               this.showErrorMessage=true;
               this.handleAlertClick(); 
           }else{
              Counter++
           }
      })
        if(this.termSectionList.length==Counter){
           this.showErrorMessage=false;
        }
if(this.showErrorMessage==false){
      
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

    if (this.lateTermMap.size > 0) {
      for (const [key, value] of this.lateTermMap.entries()) {
        let checkLatePaymentIntrest = this.lateTermMap.get(key);
        if(checkLatePaymentIntrest > 100){
          this.percentageAlertClick();
          return;
        }
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
         let report50_00 = this.report50_00_TermMap.get(key);
        if(report50_00 > 100){
          this.percentageAlertClick();
          return;
        }
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

          let reportGreaterThan100 = this.reportgreterthan_100.get(key);
        if(reportGreaterThan100 > 100){
          this.percentageAlertClick();
          return;
        }
        
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

          let amc10_20 = this.AMC_10_20ofARR.get(key);
        if(amc10_20 > 100){
          this.percentageAlertClick();
          return;
        }

        let wrapperObj = {
          quoteName: this.recordId,
          sectionLineItemKey: key,
          attributeLineItemValue: this.childparentMap.get(key),
          pumaReport20_ARRMap: this.AMC_10_20ofARR.get(key)
        }
        wrapperlist.push(wrapperObj);
      }
    }

    if (this.TliIdDecriptionmap.size > 0) {
      for (const [key, value] of this.TliIdDecriptionmap.entries()) {
        if(wrapperlist.length > 0){  
            if(wrapperlist.find(item=>item.sectionLineItemKey==this.termsectId.get(key))){
              if(wrapperlist.find(item=>item.attributeLineItemValue==key)){
                  let getRecord=wrapperlist.find(item=>item.attributeLineItemValue==key);
                  getRecord.attributeDescription=this.TliIdDecriptionmap.get(key);
                  let index = wrapperlist.indexOf(getRecord);
                  wrapperlist[index]=getRecord;
              } 
          }else{
            let wrapperObj = {
              quoteName: this.recordId,
              sectionLineItemKey: this.termsectId.get(key),
              attributeLineItemValue:key,
              attributeDescription:this.TliIdDecriptionmap.get(key)
            }
            wrapperlist.push(wrapperObj);
          }
        }else{
           let wrapperObj = {
                quoteName: this.recordId,
                sectionLineItemKey: this.termsectId.get(key),
                attributeLineItemValue:key,
                attributeDescription:this.TliIdDecriptionmap.get(key)
              }
              wrapperlist.push(wrapperObj);
        }
           
      }
    }

    descriptionJson = JSON.stringify(descriptionTliList);
    wrapperListJson = JSON.stringify(wrapperlist);

    if(this.OnClickOfSaveButton=='Insert Function'){
          createTermasCondition({ wrapperJsonList: wrapperListJson, recordId:this.recordId, descriptiontalidList: descriptionJson }).then(result => {
            debugger;
            this.IsLoaded = false;
            this.popUpOpen = false;
            this.dispatchEvent(new CloseActionScreenEvent());
            let baseURL = window.location.href.slice(0, 56);
            window.location.replace(baseURL + this.recordId);
          });
          this.wiredTermsAndConditions;
    }else if(this.OnClickOfSaveButton=='Update Function'){
          this.showConformationBox=true;
          this.popUpOpen=false;
          this.IsLoaded = false;
          if(this.IsUpdate=='yes'){
              createTermasCondition({ wrapperJsonList: wrapperListJson, recordId: this.recordId, descriptiontalidList: descriptionJson }).then(result => {
                debugger;
                this.IsLoaded = false;
                this.popUpOpen = false;
                this.showConformationBox=true;
                this.dispatchEvent(new CloseActionScreenEvent());
                let baseURL = window.location.href.slice(0, 56);
                window.location.replace(baseURL + this.recordId);
              });
              this.wiredTermsAndConditions;
          }         
    }
    
  }else{
    return;
  }
}


  handleClose() {
    debugger;
    this.popUpOpen = false
    this.dispatchEvent(new CloseActionScreenEvent());
    let baseURL = window.location.href.slice(0, 56);
    window.location.replace(baseURL + this.recordId);
  }

    handleAlertClick() {
        const evt = new ShowToastEvent({
          title: 'Error',
          message: 'All Sections are Mandatory',
          variant: 'error',
        });
        this.dispatchEvent(evt);
    }

     percentageAlertClick() {
        const evt = new ShowToastEvent({
          title: 'Error',
          message: 'Percentage cannot exceed 100%',
          variant: 'error',
        });
        this.dispatchEvent(evt);
        this.IsLoaded = false;
    }

    closeModal(){
      debugger;
      this.showConformationBox=false;
    }

   handleClickCancel(){
        debugger;
        this.popUpOpen = false
        this.dispatchEvent(new CloseActionScreenEvent());
        let baseURL = window.location.href.slice(0, 56);
        window.location.replace(baseURL + this.recordId);
   }

    
}
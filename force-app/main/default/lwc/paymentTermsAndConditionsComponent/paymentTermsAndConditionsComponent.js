import { LightningElement, api, track, wire } from 'lwc';
import PaymentTermselectionItem from '@salesforce/apex/PaymentTermsAndConditionsLWCController.PaymentTermselectionItem';
import getTermsAndConditions from '@salesforce/apex/PaymentTermsAndConditionsLWCController.getTermsAndConditions';
import createTC from '@salesforce/apex/PaymentTermsAndConditionsLWCController.createTC';
import gettermsCoditions from '@salesforce/apex/PaymentTermsAndConditionsLWCController.getTermsConditions';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class PaymentTermsAndConditionsComponent extends LightningElement {
  @api recordId;
  @track termSectionList = [];
  @track termsAndConditions = [];
  @track IsLoaded = false;
  @track checked = true;
  @track IsSelected = false;
  @track PaymentTermValue;
  @track richtext;
  error;
  draftValues = [];
  popUpOpen = true;
  myMap = new Map();
  termmyMap = new Map();
  lateTermMap = new Map();
  ChangeRequestMap = new Map();
  termsConditions = [];
  termsshouldUpdate = false;

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

  get termsAndConditionsColumns() {
    return [
      { label: 'Name', fieldName: 'termName', editable: false },
      { label: 'Term Attribute Line Item', fieldName: 'termAttributeLineItemName', editable: false },
      { label: 'Term Section Line Item', fieldName: 'termSectionLineItemName', editable: false },
      { label: 'Quote Name', fieldName: 'quoteName', editable: false },
    ];
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
      console.log(' termSectionList >>>>>', this.termSectionList);
      debugger;
      gettermsCoditions({ recordId: this.recordId }).then(res => {
        this.termsConditions = res;

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
            console.log('record === >', record);
            t.checkValue = true;
            if (tli.Custom_Entry_Require__c == true) {
              t.IsSelected = true;
              if (record.Comments__c != null) {
                t.Comments__c = record.Comments__c;
              }
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

  handlenew() {
    this.popUpOpen = true;
  }

  handleChildSelection(event) {
    debugger;
    console.log(event.target.value)
    console.log(event.target.name);
    debugger;
    const selectedTermId = event.target.value;
    const selectedTermSectId = event.target.name;
    const sectionName = event.target.dataset.sectionname;
    // this.selectedValues[selectedTermSectId] = selectedTermId;
    console.log('termSectionList--', this.termSectionList);
    this.termSectionList.forEach(term => {
      term.Term_Attribute_Line_Items__r.forEach(tli => {
        if (sectionName == term.Name) {
          if ((tli.Id == selectedTermId) && (tli.Custom_Entry_Require__c == true)) {
            tli.IsSelected = true;
          } else {
            tli.IsSelected = false;
          }
        }
      });
    });

    if (this.myMap.has(selectedTermSectId)) {
      this.myMap.set(selectedTermSectId, selectedTermId);
    } else {
      this.myMap.set(selectedTermSectId, selectedTermId);
    }
    console.log('mapdata key ==== >', JSON.stringify(this.myMap.key));
  }

  handleComments(e) {
    debugger;
    var textId = e.target.dataset.id;
    var value = e.target.value;
    const sectionName = e.target.dataset.sectionname;
    this.termSectionList.forEach(term => {
      term.Term_Attribute_Line_Items__r.forEach(tli => {
        if (sectionName == term.Name) {
          if ((tli.Id == textId) && (tli.Custom_Entry_Require__c == true)) {
            tli.Comments__c = value;
            this.termmyMap.set(textId, value);
          }
        }
      });
    });
    console.log('termSectionList === >', this.termSectionList);
  }

  handleInputBox(e) {
    debugger;
    var textId = e.target.dataset.id;
    var value = e.target.value;
    const sectionName = e.target.dataset.sectionname;
    console.log('termSectionList--', this.termSectionList);
   // let sachinrecord = this.termSectionList.find(eachstudent => eachstudent.name = 'sachin');
    //console.log(sachinrecord);
    this.termSectionList.forEach(term => {
      // if (sectionName==term.Name && term.Id==textId) {
      term.Term_Attribute_Line_Items__r.forEach(termLI => {
        if (termLI.Id == textId) {
          if (sectionName == 'Delay Payment Interest') {
            this.lateTermMap.set(textId, value);
          } else if (sectionName == 'Change Request') {
            this.ChangeRequestMap.set(textId, value);
            console.log('ChangeRequestMap---' + JSON.stringify(this.ChangeRequestMap));
          }

        }

      })
      /*if (sectionName == term.Name && term.Term_Attribute_Line_Items__r[0].Term_Section_Line_Item__c == textId) {

        if (sectionName == 'Delay Payment Interest') {
          this.lateTermMap.set(textId, value);
        } else if (sectionName == 'Change Request') {
          this.ChangeRequestMap.set(textId, value);
          console.log('ChangeRequestMap---' + JSON.stringify(this.ChangeRequestMap));
        }
      }*/
    });
  }

  handleSavetc() {
    debugger;
    this.IsLoaded = true;
    console.log('mapdata on save ===>');
    const keyValuesList = []; // initialize a new list to hold the key-value pairs
    debugger;
    let wrapperListJson = '';
    let attributeList = [];
    let wrapperlist = [];
    for (const [key, value] of this.myMap.entries()) {
      let wrapperObj = {
        quoteName: this.recordId,
        sectionLineItemKey: key,
        attributeLineItemValue: value,
        Comment: this.termmyMap.get(value),
        LatePaymentInterest: this.lateTermMap.get(key),
        changeRequest: this.ChangeRequestMap.get(key)
      }
      wrapperlist.push(wrapperObj);
      attributeList.push(value);
      // let wrapper = new WrapperClass();
      // wrapper.key = key;
      // wrapper.value = value;
      // wrapperList.push(wrapper);

      // const keyValueMap = {}; 
      // keyValueMap.key = key;
      // keyValueMap.value = value;
      // console.log(key + ' = ' + value);
      // console.log('mapdata on   keyValueMap.value',  keyValueMap.value);
      // keyValuesList.push(keyValueMap); // add the map to the list
      // console.log('mapdata on save',keyValuesList);
    }
    wrapperListJson = JSON.stringify(wrapperlist);
    // alert('wrapperListJson ===== >'+wrapperListJson);
    // alert('wrapperListJson Stringify ===== >'+JSON.stringify(wrapperlist));
    debugger;
    createTC({ wrapperListJson: wrapperListJson, recordId: this.recordId }).then(result => {
      debugger;
      console.log('T&C is ====> ', result);
      this.IsLoaded = false;
      this.popUpOpen = false;
      window.location.reload();
      //this.dispatchEvent(new CloseActionScreenEvent());
      debugger;
    });
    this.wiredTermsAndConditions;
    // createTC({attributeList: attributeList, recordId: this.recordId}).then(result => {
    //   debugger;
    //   console.log('T&C is>>>', result);
    //   this.popUpOpen = false;
    //   debugger;
    // });
  }
  handleClose() {
    debugger;
    this.popUpOpen = false
    this.dispatchEvent(new CloseActionScreenEvent());
    window.location.reload();
  }

  handleSave(event) {
    const recordInputs = event.detail.draftValues.slice().map(draft => {
      const fields = Object.assign({}, draft);
      return { fields };
    });
    const promises = recordInputs.map(recordInput => updateRecord(recordInput));
    Promise.all(promises)
      .then(() => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Success',
            message: 'Terms and Conditions updated',
            variant: 'success',
          }),
        );
        this.draftValues = [];
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error updating record',
            message: error.body.message,
            variant: 'error',
          }),
        );
      });
  }

}
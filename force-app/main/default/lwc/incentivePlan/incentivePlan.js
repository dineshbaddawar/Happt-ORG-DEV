import { LightningElement,track,wire,api } from 'lwc';
import processIncentiveRecords from '@salesforce/apex/IncentivePlanController.processIncentiveRecords';
import pickListValueDynamically from '@salesforce/apex/IncentivePlanController.pickListValueDynamically';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation';
import getApplicableIncentiveTypeValues from '@salesforce/apex/IncentivePlanController.getApplicableIncentiveTypeValues';

export default class IncentivePlan extends NavigationMixin(LightningElement) {
    step = 1;
    currentStep = "1";
    keyIndex = 0;
    objects=[];
    fields=[];
    
    selectedProfile='';
    selectedObject='';
    selectedField='';
    isEnabled=false;
    startDate='';
    endDate='';
    upperBound=[];
    lowerBound=[];
    amount=[];
    profileList;
    profileOptions=[];
    objectList;
    objectOptions=[];
    fieldList;
    fieldOptions=[];
    incentivePlanRecordId;
    sfdcBaseURL;
    @track picklistVal;
    ubVal;
    lbVal;
    amountVal;
    appIncentiveType=[];
    incentiveType=[];
    showIncentiveDiv=false;
    @track itemList = [
        {
            id: 0
        }
    ];

    connectedCallback(){
        getApplicableIncentiveTypeValues({ ObjectName: 'Incentive_Slabs__c',fieldName: 'Applicable_incentive_Type__c'})
		.then(result => {
            for (var key in result) {
                this.appIncentiveType.push({ label: key, value: result[key] });
            }
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			this.accounts = undefined;
		})
           
    }

    @wire(pickListValueDynamically) wiredData({error,data}){
        if(data){
            this.profileList=data.profileList;
            this.profileOptions = this.profileList.map( item => {
                return {
                    label: `${item}`,
                    value: `${item}`
                }
            });
         // this.profileList=data.profileList;
          this.objectList=data.objectList;
          this.objectOptions = this.objectList.map( item => {
            return {
                label: `${item}`,
                value: `${item}`
            }
        });
          this.fieldList=data.fieldList;
          this.fieldOptions = this.fieldList.map( item => {
            return {
                label: `${item}`,
                value: `${item}`
            }
        });
        }else if(error){
          this.error=error;
        }
      }
  
   
    addRow() {
        ++this.keyIndex;
        var newItem = [{ id: this.keyIndex }];
        this.itemList = this.itemList.concat(newItem);
    }
    
    removeRow(event) {
        
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }
    handleSetUpSteps() {       
        this.currentStep = "" + this.step;
    }

    handleEnableValueChange(event){
        this.isEnabled=event.target.checked;
        console.log('Enabled::'+this.isEnabled);
    }
    handleStartDateValueChange(event){
        this.startDate=event.target.value;
        console.log('starDate::'+this.startDate);
    }
    handleEndDateValueChange(event){
        this.endDate=event.target.value;
        console.log('EndDate::'+this.endDate);
    } 
    createRecords(){
        this.template.querySelectorAll('lightning-input').forEach(element => {
            if(element.label==='Upper Bound'){
                this.upperBound.push(element.value);
            }if(element.label==='Lower Bound'){
                this.lowerBound.push(element.value);
            }if(element.label==='Incentive % or Amount'){
                this.amount.push(element.value);
            }
        });
        this.template.querySelectorAll('lightning-combobox').forEach(element => {

            if(element.label==='Incentive Objects'){
                this.objects.push(element.value);   
            }if(element.label==='Incentive Field'){
                this.fields.push(element.value);
            }if(element.label==='Applicable incentive Type'){
                this.incentiveType.push(element.value);
            }
        });
        let InputWrapper={
            profile_Nm:this.selectedProfile,
            isEnabled:this.isEnabled,
            startDate:this.startDate,
            endDate:this.endDate,
            object_Nm:this.objects,
            evaluationField:this.fields,
            upperBound:this.upperBound,
            lowerBound:this.lowerBound,
            incentiveAmount:this.amount,
            applicableIncentiveType:this.incentiveType,
        }
        processIncentiveRecords({ wrapperRecord: InputWrapper })
            .then(result => {
                this.incentivePlanRecordId=result;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Incentive Plan Created Successfully!!!!',
                        variant: 'success',
                    }),
                );
                /*Start Navigation*/
                this[NavigationMixin.Navigate]({
                     type: 'standard__recordPage',
                        attributes: {
                                    recordId: this.incentivePlanRecordId,
                                    objectApiName: 'Incentive_Plan__c',
                                    actionName: 'view'
                         },
                });
                 /*End Navigation*/
             
             })
            .catch(error => {
                console.log('e==>'+error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error Occured',
                        variant: 'error',
                    }),
                );
            });

    }
    selectOptionChangeValueProfile(event){  
        this.selectedProfile = event.target.value;
    }  
    selectOptionChangeValueObject(event){
        this.selectedObject = event.target.value;
      }
      selectOptionChangeValueField(event){
        this.selectedField = event.target.value;
      }
      proceedAction(){
        if (this.step != 3) {
            this.step++;
        }
        this.showIncentiveDiv=true;
        this.handleSetUpSteps();
      }
      onCancel(){

      }
     

}
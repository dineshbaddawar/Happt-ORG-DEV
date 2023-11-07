import { LightningElement,wire,api } from 'lwc';
import pickListValueDynamically from '@salesforce/apex/IncentivePlanController.pickListValueDynamically';
import fetchIncentivePlan from '@salesforce/apex/IncentivePlanEditCtrl.fetchIncentivePlan';

export default class IncentivePlanEdit extends LightningElement {
    profileList;
    profileOptions=[];
    objectList;
    objectOptions=[];
    fieldList;
    fieldOptions=[];
    @api incentivePlanRecordId;
    appIncentiveType;
    incentiveWrapper;
    startDate;
    endDate;
    upperBound;
    lowerBound;
    amount;
    profileName;
    objectName;
    fieldName;
    amount;
    connectedCallback(){
        alert('incentivePlanRecordId::'+this.incentivePlanRecordId);
        fetchIncentivePlan({ recordId: this.incentivePlanRecordId })
		.then(result => {
            console.log('result;=='+result);
			this.incentiveWrapper = result;
            this.startDate=this.incentiveWrapper.startDate;
            this.endDate=this.incentiveWrapper.endDate;
            this.amount=this.incentiveWrapper.incentiveAmount;
            this.objectName=this.incentiveWrapper.object_Nm;
            this.fieldName=this.incentiveWrapper.evaluationField;
            this.upperBound=this.incentiveWrapper.upperBound;
            this.lowerBound=this.incentiveWrapper.lowerBound;

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

}
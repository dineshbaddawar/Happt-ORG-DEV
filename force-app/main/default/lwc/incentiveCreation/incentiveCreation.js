import { LightningElement,api,track,wire } from 'lwc';
import getAllobjects from '@salesforce/apex/FetchObjectsFields.getAllObject';
import getAllfields from '@salesforce/apex/FetchObjectsFields.getAllfields';
import createIncentive from '@salesforce/apex/IncentiveCreationLwcHandler.createIncentive';
import getProfiles from '@salesforce/apex/IncentiveCreationLwcHandler.getProfiles';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class IncentiveCreation extends LightningElement {
   
    
   
    @track showPopUp = false;
    @track objOptions =[];
    @track objFieldOptions =[];
    @track profileOptions =[];
    @track ComputatioobjFieldName ='';
    @track ComputatioobjFieldOptions =[];
    @track objName;
    @track ProfileName ='';
    @track objFieldName;

    connectedCallback(){
      this.getObjects();
    
    }
   getObjects(){
    getAllobjects({}).then(result => {
        debugger;
          console.log('Object is>>>',result); 
              var conts = result;
             for(var key in result){
                 this.objOptions.push({value:key, label:conts[key]});
       
                }
                   
            console.log('Object is', this.objOptions);
   
           });
          
           getProfiles({}).then(result =>{
              let tempdata = result;

            var temprofile =[];
            tempdata.forEach(res =>{
                temprofile.push({value:res.Name, label:res.Name});
            });
            this.profileOptions = temprofile;
                

                })
           
   }




    

    handleChangeObj(event){
        this.objName = event.detail.value;
        console.log('Object api name is',  this.objName );

        
        getAllfields({objectName:  this.objName}).then(result => {
            debugger;
            console.log('Object is>>>',result);
            
            var fconts = result;
            var temparr = [];
            for(var key in result){
                temparr.push({value:key, label:fconts[key]});
    
             }
             this.objFieldOptions = temparr;
            this.ComputatioobjFieldOptions= temparr;
                 console.log('Object field is', this.objFieldOptions);
                 
      })
    }
    handleChangeObjField(event){
        this.objFieldName = event.detail.value;
        console.log('Object field name is',  this.objFieldName );
    }
    handleChangeprofiles(event){
       this.ProfileName = event.detail.value;
       console.log('profile is', this.ProfileName);

    }
    handleComputatioChangeObjField(event){
        this.ComputatioobjFieldName = event.detail.value;
            console.log('compField is', this.ComputatioobjFieldName);
    
    }

    handleNewClick(){
        this.showPopUp = true;
    }
    handleClose(){
        this.showPopUp = false;
    }
    handleSave(){
       debugger;
       const incentiveData = {
        obj: this.objName,
        objfield: this.objFieldName,
        profile: this.ProfileName,
        computationField: this.ComputatioobjFieldName,
      };
      console.log('incentive data is',incentiveData);
      createIncentive({input: incentiveData})
        .then(result => {
         // this.showNotification('Records', result + 'fully' + 'created', 'success')
         console.log('result is >>', result)
          this.showPopUp = false;
        })
        .catch(error => {
          this.showNotification('Error', error, 'error');
        });
    }
    
    
    
    showNotification(title,message,variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}
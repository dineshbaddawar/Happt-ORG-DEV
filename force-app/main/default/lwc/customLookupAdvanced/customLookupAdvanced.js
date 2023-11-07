import { LightningElement,api,wire} from 'lwc';
// import apex method from salesforce module 
import fetchLookupData from '@salesforce/apex/customLookupLWCController.fetchLookupData';
import fetchDefaultRecord from '@salesforce/apex/customLookupLWCController.fetchDefaultRecord';

const DELAY = 300; // dealy apex callout timing in miliseconds  

export default class CustomLookupAdvanced extends LightningElement {
    // public properties with initial default values 
    @api label;
    @api displayfield = '';
    @api placeholder = 'search...'; 
    @api iconName = '';
    @api sObjectApiName = 'Account';
    @api fieldstoquery = '';
    @api whereClause ='';
    @api defaultRecordId = '';

    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true; 
    searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    selectedRecord = {}; // to store selected lookup record in object formate 

    get selctedRecordLabel(){
        if(this.selectedRecord!=null)
        return this.selectedRecord[this.displayfield];
        else{
          return  null;
        }
    }

   // initial function to populate default selected lookup record if defaultRecordId provided  
    connectedCallback(){
         if(this.defaultRecordId != ''){
             //this.fieldstoquery = 'Product__r.Description';
            fetchDefaultRecord({ recordId: this.defaultRecordId , 'sObjectApiName' : this.sObjectApiName, 'displayField' : this.displayfield ,'whereClause':this.whereClause})
            .then((result) => {
                if(result != null){
                    this.selectedRecord = result;
                    this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
                }
            })
            .catch((error) => {
                this.error = error;
                this.selectedRecord = {};
            });
         }
    }

    // wire function property to fetch search record based on user input
   /* @wire(fetchLookupData, { searchKey: '$searchKey' , displayField : '$displayfield' ,
                             fieldstoquery : '$fieldstoquery',   
                            sObjectApiName : '$sObjectApiName', whereClause  : '$whereClause' })
     searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
             this.hasRecords = data.length == 0 ? false : true; 
             this.lstResult = JSON.parse(JSON.stringify(data)); 
         }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };*/
       
  // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
                                                this.searchKey = searchKey;
                                            }, DELAY);
        
    }


    handleFocus(event)
    {
       
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
                 clsList.add('slds-is-open');
        
        const searchKey = event.target.value;
          this.delayTimeout = setTimeout(() => {
                                                this.searchKey = searchKey;
                                                this.searchForValue()
                                            }, DELAY);
    }

    handleBlur(event)
    {
        const lookupInputContainer = this.template.querySelector('.lookupContainer');
        const clsList = lookupInputContainer.classList;
                 clsList.remove('slds-is-open');
    }

    searchForValue(){
       
        fetchLookupData({ 
            searchKey: this.searchKey , displayField : this.displayfield ,
                             fieldstoquery : this.fieldstoquery,   
                            sObjectApiName : this.sObjectApiName, whereClause  : this.whereClause 
        })
            .then((result) => {
                  this.isSearchLoading = false;
                if(result != null){
                    this.hasRecords = result.length == 0 ? false : true; 
                    this.lstResult = JSON.parse(JSON.stringify(result)); 
                }
            })
            .catch((error) => {
                this.error = error;
                
            });
            
    }


    // method to toggle lookup result section on UI 
    toggleResult(event){

        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
               break;
             case 'lookupContainer':
               clsList.remove('slds-is-open');    
            break;                    
           }
    }

   // method to clear selected lookup record  
  @api handleRemove(){
    this.searchKey = '';    
    this.selectedRecord = {};
    this.lookupUpdatehandler({}); // update value on parent component as well from helper function 
    
    // remove selected pill and display input field again 
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-hide');
     searchBoxWrapper.classList.add('slds-show');

     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-show');
     pillDiv.classList.add('slds-hide');
  }

  // method to update selected record from search result 
handelSelectedRecord(event){   
     var objId = event.target.getAttribute('data-recid'); // get selected record Id 
     this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
    if(this.selectedRecord)
    {
        this.lookupUpdatehandler(this.selectedRecord); // update value on parent component as well from helper function 

     this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
    }
    else{
        console.log('handling well');
    }
}

/*COMMON HELPER METHOD STARTED*/

handelSelectRecordHelper(){
    this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');

     const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-show');
     searchBoxWrapper.classList.add('slds-hide');

     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-hide');
     pillDiv.classList.add('slds-show');     
}

// send selected lookup record to parent component using custom event
lookupUpdatehandler(value){    

    const oEvent = new CustomEvent('lookupupdate',
    {
        'detail': {selectedRecord: value}
    }
    );
    this.dispatchEvent(oEvent);

}


}
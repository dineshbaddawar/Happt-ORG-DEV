import { LightningElement } from 'lwc';

export default class MultiSelectParent extends LightningElement {
    fieldValue = 'eCommerce,Retailer,Investor';

    get pickListValues(){
        return[
            {label: 'eCommerce', value: 'eCommerce'},
            {label: 'Health Care', value: 'Health Care'},
            {label: 'Education', value: 'Education'},
            {label: 'Retailer', value: 'Retailer'},
            {label: 'Manufacturer', value: 'Manufacturer'},
            {label: 'Food Service', value: 'Food Service'},
            {label: 'Investor', value: 'Investor'},
        ]
    }

    multipicklistgenericevent(event){
        this.fieldValue = event.detail.value;
    }
}
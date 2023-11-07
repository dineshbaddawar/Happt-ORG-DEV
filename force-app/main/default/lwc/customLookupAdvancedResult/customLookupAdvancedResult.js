import { LightningElement,api } from 'lwc';
export default class CustomLookupAdvancedResult extends LightningElement {
@api obj;
@api displayfield;

get displayLabel()
{
    return this.obj[this.displayfield];
}

}
import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import POSITION_SELECTED from '@salesforce/messageChannel/PositionSelected__c';
import POSITION_NAME from '@salesforce/schema/Position__c.Name';

export default class SelectedPositionBanner extends LightningElement {
    positionId;
    subscription = null;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$positionId', fields: [POSITION_NAME] })
    position;

    get positionName() {
        return getFieldValue(this.position.data, POSITION_NAME);
    }

    connectedCallback() {
        this.subscription = subscribe(this.messageContext, POSITION_SELECTED, (msg) => {
            this.positionId = msg.positionId;
        });
    }

    disconnectedCallback() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
}
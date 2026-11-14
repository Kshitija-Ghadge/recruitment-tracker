import { LightningElement, wire } from 'lwc';
import getOpenPositions from '@salesforce/apex/PositionController.getOpenPositions';
import { publish, MessageContext } from 'lightning/messageService';
import POSITION_SELECTED from '@salesforce/messageChannel/PositionSelected__c';

export default class PositionList extends LightningElement {
    searchKey = '';
    selectedId;
    timer;

    @wire(getOpenPositions, { searchKey: '$searchKey' })
    positions;

    @wire(MessageContext)
    messageContext;

    get items() {
        if (!this.positions.data) return [];
        return this.positions.data.map((p) => ({
            ...p,
            cssClass:
                'slds-box slds-m-bottom_x-small position-card' +
                (p.Id === this.selectedId ? ' selected' : '')
        }));
    }

    get isEmpty() {
        return this.positions.data && this.positions.data.length === 0;
    }

    // Debounce: user type karna thambla ki 300ms nantar search hoto
    handleSearch(event) {
        const value = event.target.value;
        window.clearTimeout(this.timer);
        this.timer = window.setTimeout(() => {
            this.searchKey = value;
        }, 300);
    }

    handleSelect(event) {
        this.selectedId = event.currentTarget.dataset.id;
        this.dispatchEvent(
            new CustomEvent('positionselect', { detail: { positionId: this.selectedId } })
        );
    }

    handleSelect(event) {
        this.selectedId = event.currentTarget.dataset.id;
        this.dispatchEvent(
            new CustomEvent('positionselect', { detail: { positionId: this.selectedId } })
        );
        // LMS: ekmekanna na olkhnarya components sathi
        publish(this.messageContext, POSITION_SELECTED, { positionId: this.selectedId });
    }
}
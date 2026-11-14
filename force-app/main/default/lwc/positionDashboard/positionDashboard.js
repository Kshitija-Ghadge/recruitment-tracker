import { LightningElement } from 'lwc';

export default class PositionDashboard extends LightningElement {
    selectedPositionId;

    handlePositionSelect(event) {
        this.selectedPositionId = event.detail.positionId;
    }

    // Child method call: @api method
    handleApplied() {
        this.template.querySelector('c-application-table').refresh();
    }

    handleStatusChange() {
        // Hired nantar Position Closed zali asel, ithe future madhe list refresh karta yeil
    }
}
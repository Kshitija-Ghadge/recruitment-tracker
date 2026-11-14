import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getApplications from '@salesforce/apex/ApplicationController.getApplications';
import updateStatus from '@salesforce/apex/ApplicationController.updateStatus';
import updateApplications from '@salesforce/apex/ApplicationController.updateApplications';

const ACTIONS = [
    { label: 'View', name: 'view' },
    { label: 'Screening', name: 'Screening' },
    { label: 'Interview', name: 'Interview' },
    { label: 'Offered', name: 'Offered' },
    { label: 'Hired', name: 'Hired' },
    { label: 'Rejected', name: 'Rejected' }
];

const COLUMNS = [
    { label: 'Application', fieldName: 'Name' },
    { label: 'Candidate', fieldName: 'candidateName' },
    { label: 'Status', fieldName: 'Status__c' },
    { label: 'Expected Salary', fieldName: 'Expected_Salary__c', type: 'currency', editable: true },
    { type: 'action', typeAttributes: { rowActions: ACTIONS } }
];

export default class ApplicationTable extends NavigationMixin(LightningElement) {
    @api positionId;   // Parent kadun yeto
    @api recordId;     // Record page var vaparla tar auto yeto

    columns = COLUMNS;
    rows = [];
    draftValues = [];
    wiredResult;

    get effectiveId() {
        return this.positionId || this.recordId;
    }

    get noRows() {
        return this.rows.length === 0;
    }

    @wire(getApplications, { positionId: '$effectiveId' })
    wiredApps(result) {
        this.wiredResult = result;
        const { data, error } = result;
        if (data) {
            this.rows = data.map((r) => ({
                ...r,
                candidateName: r.Candidate__r ? r.Candidate__r.Name : ''
            }));
        } else if (error) {
            this.rows = [];
            this.showToast('Error', this.getError(error), 'error');
        }
    }

    // Parent la call karta yeto (new application nantar)
    @api
    refresh() {
        return refreshApex(this.wiredResult);
    }

    async handleSave(event) {
        try {
            await updateApplications({ apps: event.detail.draftValues });
            this.draftValues = [];
            this.showToast('Success', 'Applications update zali', 'success');
            await refreshApex(this.wiredResult);
        } catch (e) {
            this.showToast('Error', this.getError(e), 'error');
        }
    }

    async handleRowAction(event) {
        const action = event.detail.action.name;
        const row = event.detail.row;

        if (action === 'view') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: { recordId: row.Id, objectApiName: 'Application__c', actionName: 'view' }
            });
            return;
        }

        try {
            await updateStatus({ applicationId: row.Id, newStatus: action });
            this.showToast('Success', `Status ${action} kela`, 'success');
            await refreshApex(this.wiredResult);
            // Hired zala tar Position close hou shakto, parent la kalva
            this.dispatchEvent(new CustomEvent('statuschange'));
        } catch (e) {
            this.showToast('Error', this.getError(e), 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    getError(e) {
        if (e && e.body && e.body.message) return e.body.message;
        if (e && e.message) return e.message;
        return 'Unknown error';
    }
}
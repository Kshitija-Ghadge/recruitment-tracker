import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PositionSummary extends NavigationMixin(LightningElement) {
    @api recordId;

    goToApplications() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: { objectApiName: 'Application__c', actionName: 'list' },
            state: { filterName: 'Recent' }
        });
    }
}
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createApplication from '@salesforce/apex/ApplicationController.createApplication';

export default class ApplyForm extends LightningElement {
    @api positionId;
    isSaving = false;

    getValue(field) {
        return this.template.querySelector(`[data-field="${field}"]`).value;
    }

    isValid() {
        return [...this.template.querySelectorAll('lightning-input')].reduce(
            (valid, input) => input.reportValidity() && valid,
            true
        );
    }

    async handleSubmit() {
        if (!this.isValid()) return;
        this.isSaving = true;
        try {
            await createApplication({
                positionId: this.positionId,
                candidateName: this.getValue('name'),
                email: this.getValue('email'),
                phone: this.getValue('phone'),
                experience: this.getValue('experience') ? Number(this.getValue('experience')) : null,
                expectedSalary: this.getValue('salary') ? Number(this.getValue('salary')) : null
            });
            this.dispatchEvent(
                new ShowToastEvent({ title: 'Success', message: 'Application submit zali!', variant: 'success' })
            );
            this.clearForm();
            this.dispatchEvent(new CustomEvent('applied'));
        } catch (e) {
            const msg = e && e.body && e.body.message ? e.body.message : 'Kahitari chuklay';
            this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: msg, variant: 'error' }));
        } finally {
            this.isSaving = false;
        }
    }

    clearForm() {
        this.template.querySelectorAll('lightning-input').forEach((i) => (i.value = null));
    }
}
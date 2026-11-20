import { LightningElement, api } from 'lwc';
import createCase from '@salesforce/apex/SupportCaseFormController.createCase';

const FIELDS = ['customerName', 'customerEmail', 'customerMobile', 'issueDescription'];
const GENERIC_ERROR = 'The case could not be created right now. Please try again.';

/**
 * Agentforce output renderer for the iPhoneSupportCaseFormView Lightning type.
 * Shows an editable support case form, pre-filled with anything the agent already knows.
 * Submit validates the fields and creates the case through SupportCaseFormController.
 */
export default class IphoneSupportCaseFormView extends LightningElement {
    form = { customerName: '', customerEmail: '', customerMobile: '', issueDescription: '' };
    isSubmitting = false;
    errorMessage = '';
    caseNumber = '';

    @api
    get value() {
        return this._value;
    }
    set value(incoming) {
        this._value = incoming;
        let data = incoming;
        if (typeof data === 'string') {
            try {
                data = JSON.parse(data);
            } catch (e) {
                data = null;
            }
        }
        if (data && typeof data === 'object' && data.caseForm && typeof data.caseForm === 'object') {
            data = data.caseForm;
        }
        const next = { ...this.form };
        FIELDS.forEach((field) => {
            if (data && typeof data === 'object' && data[field]) {
                next[field] = String(data[field]);
            }
        });
        this.form = next;
    }

    get submitLabel() {
        return this.isSubmitting ? 'Submitting...' : 'Submit';
    }

    handleChange(event) {
        this.form = { ...this.form, [event.target.name]: event.detail.value };
    }

    async handleSubmit() {
        this.errorMessage = '';
        const inputs = [...this.template.querySelectorAll('lightning-input, lightning-textarea')];
        const valid = inputs.reduce((ok, input) => input.reportValidity() && ok, true);
        if (!valid) {
            return;
        }
        this.isSubmitting = true;
        try {
            const result = await createCase({
                customerName: (this.form.customerName || '').trim(),
                customerEmail: (this.form.customerEmail || '').trim(),
                customerMobile: (this.form.customerMobile || '').trim(),
                issueDescription: (this.form.issueDescription || '').trim()
            });
            if (result && result.isSuccess && result.caseNumber) {
                this.caseNumber = result.caseNumber;
            } else {
                this.errorMessage = (result && result.errorMessage) || GENERIC_ERROR;
            }
        } catch (e) {
            this.errorMessage = GENERIC_ERROR;
        } finally {
            this.isSubmitting = false;
        }
    }
}

import { LightningElement, api } from 'lwc';

const FIELDS = ['customerName', 'customerEmail', 'customerMobile', 'issueDescription'];

/**
 * Agentforce input editor for the iPhoneSupportCaseForm Lightning type.
 * Receives any details the agent already collected as `value` and reports every edit with
 * `valuechange`. The chat's own Confirm button submits the form to the Create Support Case action.
 */
export default class IphoneSupportCaseForm extends LightningElement {
    @api readOnly = false;

    form = { customerName: '', customerEmail: '', customerMobile: '', issueDescription: '' };

    @api
    get value() {
        return { ...this.form };
    }
    set value(incoming) {
        let data = incoming;
        if (typeof data === 'string') {
            try {
                data = JSON.parse(data);
            } catch (e) {
                data = null;
            }
        }
        if (data && typeof data === 'object' && data.caseRequest && typeof data.caseRequest === 'object') {
            data = data.caseRequest;
        }
        const next = { ...this.form };
        FIELDS.forEach((field) => {
            if (data && typeof data === 'object' && data[field] != null) {
                next[field] = String(data[field]);
            }
        });
        this.form = next;
    }

    handleChange(event) {
        event.stopPropagation();
        this.form = { ...this.form, [event.target.name]: event.detail.value };
        this.dispatchEvent(
            new CustomEvent('valuechange', {
                detail: { value: { ...this.form } }
            })
        );
    }
}

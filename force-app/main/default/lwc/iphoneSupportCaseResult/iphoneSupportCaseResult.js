import { LightningElement, api } from 'lwc';

/**
 * Agentforce output renderer for the iPhoneSupportCaseResult Lightning type.
 */
export default class IphoneSupportCaseResult extends LightningElement {
    @api value;

    get caseNumber() {
        return this.value?.caseNumber || '';
    }

    get caseId() {
        return this.value?.caseId || '';
    }
}
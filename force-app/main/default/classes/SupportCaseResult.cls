/**
 * Result of a support case submission. Backs the iPhoneSupportCaseResult custom Lightning type.
 */
public class SupportCaseResult {
    @AuraEnabled
    public String caseNumber;

    @AuraEnabled
    public String caseId;
}
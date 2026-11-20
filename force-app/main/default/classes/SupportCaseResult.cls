/**
 * Result of a support case submission. Backs the iPhoneSupportCaseResult custom Lightning type.
 */
@JsonAccess(serializable='always' deserializable='always')
public class SupportCaseResult {
    @AuraEnabled
    public String caseNumber;

    @AuraEnabled
    public String caseId;
}
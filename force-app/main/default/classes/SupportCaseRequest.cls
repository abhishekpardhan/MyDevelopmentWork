/**
 * Support case form submitted by a customer through the iPhone Help Assistant.
 * Backs the iPhoneSupportCaseForm custom Lightning type; the @AuraEnabled fields define the form shape.
 */
@JsonAccess(serializable='always' deserializable='always')
public class SupportCaseRequest {
    @AuraEnabled
    public String customerName;

    @AuraEnabled
    public String customerEmail;

    @AuraEnabled
    public String customerMobile;

    @AuraEnabled
    public String issueDescription;
}
/**
 * Support case form shown to the customer by the iPhone Help Assistant.
 * Backs the iPhoneSupportCaseFormView custom Lightning type, whose renderer is the
 * iphoneSupportCaseFormView LWC (an editable form with a Submit button).
 * The fields hold any details the agent already collected, used to pre-fill the form.
 */
public class SupportCaseFormView {
    @AuraEnabled
    public String customerName;

    @AuraEnabled
    public String customerEmail;

    @AuraEnabled
    public String customerMobile;

    @AuraEnabled
    public String issueDescription;
}

/**
 * Controller for the iphoneSupportCaseFormView LWC. Creates the support case when the customer
 * clicks Submit, reusing CreateSupportCaseAction so validation and the
 * Create_iPhone_Support_Case Flow stay in one place.
 */
public with sharing class SupportCaseFormController {

    /**
     * Validates the form and creates a Case linked to a new or existing Contact.
     * @return Map with isSuccess, caseNumber, caseId and errorMessage
     */
    @AuraEnabled
    public static Map<String, Object> createCase(
        String customerName,
        String customerEmail,
        String customerMobile,
        String issueDescription
    ) {
        CreateSupportCaseAction.Request req = new CreateSupportCaseAction.Request();
        req.caseRequest = new SupportCaseRequest();
        req.caseRequest.customerName = customerName;
        req.caseRequest.customerEmail = customerEmail;
        req.caseRequest.customerMobile = customerMobile;
        req.caseRequest.issueDescription = issueDescription;

        CreateSupportCaseAction.Response res = CreateSupportCaseAction.execute(
            new List<CreateSupportCaseAction.Request>{ req }
        )[0];

        return new Map<String, Object>{
            'isSuccess' => res.isSuccess == true,
            'caseNumber' => res.caseNumber,
            'caseId' => res.caseId,
            'errorMessage' => res.errorMessage
        };
    }
}

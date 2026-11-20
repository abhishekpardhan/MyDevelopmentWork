/**
 * Agentforce action that shows the support case form in the chat.
 * Returns a SupportCaseFormView (rendered by the iphoneSupportCaseFormView LWC), pre-filled with
 * any details the agent already has. The customer submits the form from the LWC, which calls
 * SupportCaseFormController.createCase to create the Case.
 */
public with sharing class ShowSupportCaseFormAction {

    /**
     * Builds one pre-filled form per request.
     * @param requests Details the agent already collected (all optional)
     * @return One form per request, in the same order
     */
    @InvocableMethod(
        label='Show iPhone Support Case Form'
        description='Shows the support case form so the customer can enter their details and submit a case.'
        category='iPhone Help Assistant'
    )
    public static List<Response> execute(List<Request> requests) {
        List<Response> responses = new List<Response>();
        if (requests == null) {
            return responses;
        }
        for (Request req : requests) {
            SupportCaseFormView form = new SupportCaseFormView();
            form.customerName = clean(req?.customerName);
            form.customerEmail = clean(req?.customerEmail);
            form.customerMobile = clean(req?.customerMobile);
            form.issueDescription = clean(req?.issueDescription);
            Response res = new Response();
            res.caseForm = form;
            responses.add(res);
        }
        return responses;
    }

    private static String clean(String value) {
        return String.isBlank(value) ? '' : value.trim();
    }

    /**
     * Optional details to pre-fill the form with.
     */
    public class Request {
        @InvocableVariable(label='Customer Name' description='Full name, if the customer already gave it')
        public String customerName;

        @InvocableVariable(label='Customer Email' description='Email, if the customer already gave it')
        public String customerEmail;

        @InvocableVariable(label='Customer Mobile' description='Mobile number, if the customer already gave it')
        public String customerMobile;

        @InvocableVariable(label='Issue Description' description='Problem and iPhone model, if the customer already described it')
        public String issueDescription;
    }

    /**
     * The form to show in the chat.
     */
    public class Response {
        @InvocableVariable(label='Support Case Form' description='Form the customer fills in and submits')
        public SupportCaseFormView caseForm;
    }
}

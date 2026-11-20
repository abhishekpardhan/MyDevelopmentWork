/**
 * Agentforce action that submits the iPhone support case form.
 * Validates the form, then delegates to the Create_iPhone_Support_Case Flow, which finds or
 * creates the Contact by email and creates a Case linked to it.
 */
public with sharing class CreateSupportCaseAction {

    private static final String FLOW_NAME = 'Create_iPhone_Support_Case';
    private static final String EMAIL_PATTERN = '^[A-Za-z0-9._%+\\-]+@[A-Za-z0-9.\\-]+\\.[A-Za-z]{2,}$';
    private static final String VALIDATION_ERROR = 'VALIDATION';
    private static final String FLOW_ERROR = 'FLOW_ERROR';

    /**
     * Creates one support case per request.
     * @param requests Form submissions from the agent
     * @return One response per request, in the same order
     */
    @InvocableMethod(
        label='Create iPhone Support Case'
        description='Validates the support case form and creates a Case linked to a new or existing Contact.'
        category='iPhone Help Assistant'
    )
    public static List<Response> execute(List<Request> requests) {
        List<Response> responses = new List<Response>();
        if (requests == null || requests.isEmpty()) {
            return responses;
        }

        Invocable.Action flowAction = Invocable.Action.createCustomAction('flow', FLOW_NAME);
        List<Integer> flowRequestIndexes = new List<Integer>();
        for (Integer i = 0; i < requests.size(); i++) {
            Response res = new Response();
            responses.add(res);
            SupportCaseRequest form = requests[i]?.caseRequest;
            String validationError = validate(form);
            if (validationError != null) {
                setError(res, validationError, VALIDATION_ERROR);
                continue;
            }
            flowAction.addInvocation()
                .setInvocationParameter('customerName', form.customerName.trim())
                .setInvocationParameter('customerEmail', form.customerEmail.trim())
                .setInvocationParameter('customerMobile', form.customerMobile.trim())
                .setInvocationParameter('issueDescription', form.issueDescription.trim());
            flowRequestIndexes.add(i);
        }

        if (flowRequestIndexes.isEmpty()) {
            return responses;
        }

        List<Invocable.Action.Result> results;
        try {
            results = flowAction.invoke();
        } catch (Exception e) {
            for (Integer index : flowRequestIndexes) {
                setError(responses[index], 'The case could not be created right now.', e.getTypeName());
            }
            return responses;
        }

        for (Integer j = 0; j < results.size(); j++) {
            applyFlowResult(responses[flowRequestIndexes[j]], results[j]);
        }
        return responses;
    }

    private static String validate(SupportCaseRequest form) {
        if (form == null) {
            return 'The support case form is empty.';
        }
        if (String.isBlank(form.customerName)) {
            return 'Full name is required.';
        }
        if (String.isBlank(form.customerEmail)) {
            return 'Email is required.';
        }
        if (!Pattern.matches(EMAIL_PATTERN, form.customerEmail.trim())) {
            return 'Email must look like name@domain.com.';
        }
        if (String.isBlank(form.customerMobile)) {
            return 'Mobile number is required.';
        }
        if (String.isBlank(form.issueDescription)) {
            return 'Issue description is required.';
        }
        return null;
    }

    private static void applyFlowResult(Response res, Invocable.Action.Result result) {
        Map<String, Object> outputs = result.getOutputParameters() ?? new Map<String, Object>();
        String flowError = (String) outputs.get('errorMessage');
        String caseNumber = (String) outputs.get('caseNumber');
        if (!result.isSuccess() || String.isNotBlank(flowError) || String.isBlank(caseNumber)) {
            setError(res, 'The case could not be created right now.', FLOW_ERROR);
            return;
        }
        res.isSuccess = true;
        res.caseNumber = caseNumber;
        res.caseId = (String) outputs.get('caseId');
        res.contactId = (String) outputs.get('contactId');
        res.caseResult = new SupportCaseResult();
        res.caseResult.caseNumber = res.caseNumber;
        res.caseResult.caseId = res.caseId;
    }

    private static void setError(Response res, String message, String errorType) {
        res.isSuccess = false;
        res.errorMessage = message;
        res.errorType = errorType;
    }

    /**
     * Input from the agent: the submitted support case form.
     */
    public class Request {
        @InvocableVariable(label='Support Case Form' description='Customer name, email, mobile number and issue description' required=true)
        public SupportCaseRequest caseRequest;
    }

    /**
     * Output to the agent.
     */
    public class Response {
        @InvocableVariable(label='Case Result' description='Case number and case Id for display')
        public SupportCaseResult caseResult;

        @InvocableVariable(label='Case Number' description='Case Number of the created case')
        public String caseNumber;

        @InvocableVariable(label='Case Id' description='Record Id of the created case')
        public String caseId;

        @InvocableVariable(label='Contact Id' description='Id of the Contact the case is linked to')
        public String contactId;

        @InvocableVariable(label='Success' description='Whether the case was created')
        public Boolean isSuccess;

        @InvocableVariable(label='Error Message' description='Customer-safe error message if the case was not created')
        public String errorMessage;

        @InvocableVariable(label='Error Type' description='Error category if the case was not created')
        public String errorType;
    }
}
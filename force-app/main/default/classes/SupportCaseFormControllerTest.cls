@IsTest
private class SupportCaseFormControllerTest {

    @IsTest
    static void createCaseCreatesCaseForValidForm() {
        Test.startTest();
        Map<String, Object> result = SupportCaseFormController.createCase(
            'Test Customer', 'test.customer@example.com', '9876543210', 'Cracked screen on iPhone 15'
        );
        Test.stopTest();

        Assert.isTrue((Boolean) result.get('isSuccess'), 'Case should be created: ' + result.get('errorMessage'));
        Assert.isNotNull(result.get('caseNumber'), 'Case number should be returned');
        Assert.areEqual(1, [SELECT COUNT() FROM Case WHERE Id = :(String) result.get('caseId')], 'Case should exist');
    }

    @IsTest
    static void createCaseReturnsErrorWhenNameMissing() {
        Map<String, Object> result = SupportCaseFormController.createCase(
            '', 'test.customer@example.com', '9876543210', 'Cracked screen'
        );

        Assert.isFalse((Boolean) result.get('isSuccess'), 'Case should not be created without a name');
        Assert.areEqual('Full name is required.', result.get('errorMessage'), 'Should explain the missing name');
    }

    @IsTest
    static void showFormPrefillsKnownDetails() {
        ShowSupportCaseFormAction.Request req = new ShowSupportCaseFormAction.Request();
        req.customerName = '  Test Customer ';
        req.issueDescription = 'Cracked screen';

        List<ShowSupportCaseFormAction.Response> responses = ShowSupportCaseFormAction.execute(
            new List<ShowSupportCaseFormAction.Request>{ req }
        );

        Assert.areEqual(1, responses.size(), 'One form per request');
        Assert.areEqual('Test Customer', responses[0].caseForm.customerName, 'Name should be trimmed and pre-filled');
        Assert.areEqual('', responses[0].caseForm.customerEmail, 'Unknown fields should be empty');
        Assert.areEqual('Cracked screen', responses[0].caseForm.issueDescription, 'Issue should be pre-filled');
    }
}

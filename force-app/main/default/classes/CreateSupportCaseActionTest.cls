@IsTest
private class CreateSupportCaseActionTest {

    private static CreateSupportCaseAction.Request buildRequest(String name, String email, String mobile, String issue) {
        SupportCaseRequest form = new SupportCaseRequest();
        form.customerName = name;
        form.customerEmail = email;
        form.customerMobile = mobile;
        form.issueDescription = issue;
        CreateSupportCaseAction.Request req = new CreateSupportCaseAction.Request();
        req.caseRequest = form;
        return req;
    }

    @IsTest
    static void createsContactAndLinkedCaseWhenNoContactExists() {
        Test.startTest();
        List<CreateSupportCaseAction.Response> responses = CreateSupportCaseAction.execute(
            new List<CreateSupportCaseAction.Request>{
                buildRequest('Jane Tester', 'jane.tester@example.com', '555-0100', 'Screen flickers')
            }
        );
        Test.stopTest();

        CreateSupportCaseAction.Response res = responses[0];
        Assert.isTrue(res.isSuccess, 'Expected success but got: ' + res.errorMessage);
        Assert.isNotNull(res.caseResult, 'Case result object should be populated');
        Case createdCase = [SELECT CaseNumber, ContactId, Contact.LastName, Contact.MobilePhone FROM Case WHERE Id = :res.caseId];
        Assert.areEqual(createdCase.CaseNumber, res.caseNumber, 'Returned case number should match the record');
        Assert.areEqual(res.caseResult.caseNumber, res.caseNumber, 'Result object should carry the case number');
        Assert.areEqual('Tester', createdCase.Contact.LastName, 'Last name should come from the full name');
        Assert.areEqual('555-0100', createdCase.Contact.MobilePhone, 'Mobile number should be stored on the contact');
    }

    @IsTest
    static void reusesExistingContactByEmail() {
        Contact existing = new Contact(LastName = 'Existing', Email = 'existing.customer@example.com');
        insert existing;

        Test.startTest();
        List<CreateSupportCaseAction.Response> responses = CreateSupportCaseAction.execute(
            new List<CreateSupportCaseAction.Request>{
                buildRequest('Existing Customer', 'existing.customer@example.com', '555-0101', 'Battery drains fast')
            }
        );
        Test.stopTest();

        Assert.isTrue(responses[0].isSuccess, 'Expected success but got: ' + responses[0].errorMessage);
        Assert.areEqual(existing.Id, responses[0].contactId, 'Case should be linked to the existing contact');
        Assert.areEqual(1, [SELECT COUNT() FROM Contact WHERE Email = 'existing.customer@example.com'], 'No duplicate contact should be created');
    }

    @IsTest
    static void rejectsInvalidAndIncompleteForms() {
        Test.startTest();
        List<CreateSupportCaseAction.Response> responses = CreateSupportCaseAction.execute(
            new List<CreateSupportCaseAction.Request>{
                buildRequest('Bad Email', 'not-an-email', '555-0102', 'Camera issue'),
                buildRequest('No Mobile', 'no.mobile@example.com', ' ', 'Camera issue'),
                new CreateSupportCaseAction.Request()
            }
        );
        Test.stopTest();

        Assert.areEqual(3, responses.size(), 'One response per request');
        for (CreateSupportCaseAction.Response res : responses) {
            Assert.isFalse(res.isSuccess, 'Invalid forms must not create a case');
            Assert.areEqual('VALIDATION', res.errorType, 'Should fail validation');
        }
        Assert.areEqual(0, [SELECT COUNT() FROM Case], 'No case should be created');
    }

    @IsTest
    static void returnsEmptyListForNoRequests() {
        Assert.areEqual(0, CreateSupportCaseAction.execute(null).size(), 'Null input returns an empty list');
    }
}
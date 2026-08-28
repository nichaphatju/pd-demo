/**
 * @description Tests for CreateLeadAction covering positive, duplicate (existing
 *              and within-batch), negative save-failure, and bulk scenarios.
 */
@isTest
private class CreateLeadActionTest {

    @TestSetup
    static void setupTestData() {
        TestDataFactory.createLead(true);
    }

    @isTest
    static void shouldCreateLead_WhenNewEmail() {
        // Given
        CreateLeadAction.LeadRequest req = new CreateLeadAction.LeadRequest();
        req.firstName = 'Jane';
        req.lastName = 'Doe';
        req.email = 'jane.doe@example.com';

        // When
        Test.startTest();
        List<CreateLeadAction.LeadResponse> responses = CreateLeadAction.createLead(
            new List<CreateLeadAction.LeadRequest>{ req }
        );
        Test.stopTest();

        // Then
        List<Lead> createdLeads = [SELECT Id, FirstName, LastName, Email, LeadSource FROM Lead WHERE Email = 'jane.doe@example.com'];
        Assert.areEqual(1, createdLeads.size(), 'A new Lead should be created for a new email');
        Assert.areEqual('Agentforce Agent', createdLeads[0].LeadSource, 'LeadSource should be set on the new Lead');
        Assert.areEqual(
            'Jane, Thank you! Our representative will contact you soon on the provided Email Address: jane.doe@example.com.',
            responses[0].responseMessage,
            'Response message should thank the user and reference their email'
        );
    }

    @isTest
    static void shouldCreateLead_WhenEmailAndPhoneBothProvided() {
        // Given
        CreateLeadAction.LeadRequest req = new CreateLeadAction.LeadRequest();
        req.firstName = 'Jane';
        req.lastName = 'Doe';
        req.email = 'jane.phone@example.com';
        req.phone = '555-0100';

        // When
        Test.startTest();
        List<CreateLeadAction.LeadResponse> responses = CreateLeadAction.createLead(
            new List<CreateLeadAction.LeadRequest>{ req }
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            'Jane, Thank you! Our representative will contact you soon on the provided Email Address: jane.phone@example.com or Phone number: 555-0100.',
            responses[0].responseMessage,
            'Response message should reference both email and phone'
        );
    }

    @isTest
    static void shouldDefaultCompanyToUnknown_WhenCompanyNotProvided() {
        // Given
        CreateLeadAction.LeadRequest req = new CreateLeadAction.LeadRequest();
        req.firstName = 'Jane';
        req.lastName = 'Doe';
        req.email = 'jane.nocompany@example.com';

        // When
        Test.startTest();
        CreateLeadAction.createLead(new List<CreateLeadAction.LeadRequest>{ req });
        Test.stopTest();

        // Then
        Lead createdLead = [SELECT Company FROM Lead WHERE Email = 'jane.nocompany@example.com'];
        Assert.areEqual('Unknown', createdLead.Company, 'Company should default to Unknown when not provided');
    }

    @isTest
    static void shouldUseProvidedCompany_WhenCompanyGiven() {
        // Given
        CreateLeadAction.LeadRequest req = new CreateLeadAction.LeadRequest();
        req.firstName = 'Jane';
        req.lastName = 'Doe';
        req.email = 'jane.company@example.com';
        req.company = 'Acme Corp';

        // When
        Test.startTest();
        CreateLeadAction.createLead(new List<CreateLeadAction.LeadRequest>{ req });
        Test.stopTest();

        // Then
        Lead createdLead = [SELECT Company FROM Lead WHERE Email = 'jane.company@example.com'];
        Assert.areEqual('Acme Corp', createdLead.Company, 'Company should use the provided value when given');
    }

    @isTest
    static void shouldCreateLead_WhenOnlyPhoneProvided() {
        // Given
        CreateLeadAction.LeadRequest req = new CreateLeadAction.LeadRequest();
        req.firstName = 'Jane';
        req.lastName = 'Doe';
        req.phone = '555-0199';

        // When
        Test.startTest();
        List<CreateLeadAction.LeadResponse> responses = CreateLeadAction.createLead(
            new List<CreateLeadAction.LeadRequest>{ req }
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            'Jane, Thank you! Our representative will contact you soon on the provided Phone number: 555-0199.',
            responses[0].responseMessage,
            'Response message should reference only the phone number when email is not provided'
        );
    }

    @isTest
    static void shouldSkipCreation_WhenLeadAlreadyExistsByEmail() {
        // Given
        Lead existingLead = [SELECT Id, Email FROM Lead LIMIT 1];

        CreateLeadAction.LeadRequest req = new CreateLeadAction.LeadRequest();
        req.firstName = 'Jane';
        req.lastName = 'Doe';
        req.email = existingLead.Email;

        // When
        Test.startTest();
        List<CreateLeadAction.LeadResponse> responses = CreateLeadAction.createLead(
            new List<CreateLeadAction.LeadRequest>{ req }
        );
        Test.stopTest();

        // Then
        List<Lead> leadsWithEmail = [SELECT Id FROM Lead WHERE Email = :existingLead.Email];
        Assert.areEqual(1, leadsWithEmail.size(), 'No additional Lead should be created for an existing email');
        Assert.isTrue(
            responses[0].responseMessage.startsWith('Jane, Thank you!'),
            'Duplicate email should still return the standard thank-you message'
        );
    }

    @isTest
    static void shouldSkipDuplicate_WhenSameNewEmailRepeatedInBatch() {
        // Given
        CreateLeadAction.LeadRequest req1 = new CreateLeadAction.LeadRequest();
        req1.firstName = 'Jane';
        req1.lastName = 'Doe';
        req1.email = 'jane.repeat@example.com';

        CreateLeadAction.LeadRequest req2 = new CreateLeadAction.LeadRequest();
        req2.firstName = 'Jane';
        req2.lastName = 'Doe';
        req2.email = 'jane.repeat@example.com';

        // When
        Test.startTest();
        List<CreateLeadAction.LeadResponse> responses = CreateLeadAction.createLead(
            new List<CreateLeadAction.LeadRequest>{ req1, req2 }
        );
        Test.stopTest();

        // Then
        List<Lead> createdLeads = [SELECT Id FROM Lead WHERE Email = 'jane.repeat@example.com'];
        Assert.areEqual(1, createdLeads.size(), 'Only one Lead should be created when the same new email repeats in a batch');
        Assert.areEqual(2, responses.size(), 'A response should still be returned for every request');
    }

    @isTest
    static void shouldReturnErrorMessage_WhenLeadSaveFails() {
        // Given
        CreateLeadAction.LeadRequest req = new CreateLeadAction.LeadRequest();
        req.firstName = 'Jane';
        req.lastName = 'Doe';
        req.email = 'not-a-valid-email';

        // When
        Test.startTest();
        List<CreateLeadAction.LeadResponse> responses = CreateLeadAction.createLead(
            new List<CreateLeadAction.LeadRequest>{ req }
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            'Sorry, we encountered an issue while saving your details. Please try again.',
            responses[0].responseMessage,
            'A failed save should return the generic error message'
        );
    }

    @isTest
    static void shouldReturnMessageWithoutContactDetails_WhenNoEmailOrPhoneProvided() {
        // Given
        CreateLeadAction.LeadRequest req = new CreateLeadAction.LeadRequest();
        req.firstName = 'Jane';
        req.lastName = 'Doe';

        // When
        Test.startTest();
        List<CreateLeadAction.LeadResponse> responses = CreateLeadAction.createLead(
            new List<CreateLeadAction.LeadRequest>{ req }
        );
        Test.stopTest();

        // Then
        Assert.areEqual(
            'Jane, Thank you! Our representative will contact you soon on the provided .',
            responses[0].responseMessage,
            'Message should omit contact details when neither email nor phone is provided'
        );
    }

    @isTest
    static void shouldBulkProcessAndStayWithinLimits_When251Requests() {
        // Given
        List<CreateLeadAction.LeadRequest> requests = new List<CreateLeadAction.LeadRequest>();
        for (Integer i = 0; i < 251; i++) {
            CreateLeadAction.LeadRequest req = new CreateLeadAction.LeadRequest();
            req.firstName = 'Bulk';
            req.lastName = 'Lead ' + i;
            req.email = 'bulk.lead' + i + '@example.com';
            requests.add(req);
        }

        // When
        Test.startTest();
        List<CreateLeadAction.LeadResponse> responses = CreateLeadAction.createLead(requests);
        Integer queryCount = Limits.getQueries();
        Integer dmlCount = Limits.getDmlStatements();
        Test.stopTest();

        // Then
        Assert.areEqual(251, responses.size(), 'A response should be returned for every request');
        Assert.areEqual(251, [SELECT COUNT() FROM Lead WHERE Email LIKE 'bulk.lead%@example.com'], 'All 251 leads should be created');
        Assert.areEqual(1, queryCount, 'Duplicate check should use exactly one bulk SOQL query regardless of batch size');
        Assert.areEqual(1, dmlCount, 'Lead creation should use exactly one bulk DML statement regardless of batch size');
    }
}

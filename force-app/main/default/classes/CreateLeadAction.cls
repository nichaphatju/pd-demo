/**
 * Invocable Apex action that creates a Lead from an Agentforce Agent or Flow.
 * Skips creation when a Lead with the same email already exists (including
 * duplicates within the same request batch), and always returns a response
 * message per request.
 */
public with sharing class CreateLeadAction {

    private static final String LEAD_SOURCE = 'Agentforce Agent';
    private static final String DEFAULT_COMPANY = 'Unknown';
    private static final String SAVE_ERROR_MESSAGE = 'Sorry, we encountered an issue while saving your details. Please try again.';

    /**
     * Checks if a lead exists by email for each request. If found, skips creation.
     * If not, bulk-creates the new leads. Returns a response message either way.
     * @param requests List of Request inputs from the calling Flow or Agent
     * @return List of Response outputs, one per request, in the same order
     */
    @InvocableMethod(
        label='Create Lead'
        description='Checks if a lead exists by email. If found, skips creation. If not, creates a new lead. Returns a response message either way.'
        category='Lead Management'
    )
    public static List<LeadResponse> createLead(List<LeadRequest> requests) {
        Set<String> existingEmails = getExistingLeadEmails(requests);

        List<LeadResponse> responses = new List<LeadResponse>();
        List<Lead> leadsToInsert = new List<Lead>();
        List<Integer> leadRequestIndexes = new List<Integer>();
        Set<String> emailsQueuedForInsert = new Set<String>();

        for (Integer i = 0; i < requests.size(); i++) {
            LeadRequest req = requests[i];
            LeadResponse res = new LeadResponse();
            res.responseMessage = buildThankYouMessage(req);
            responses.add(res);

            Boolean isDuplicate = String.isNotBlank(req.email)
                && (existingEmails.contains(req.email) || emailsQueuedForInsert.contains(req.email));
            if (isDuplicate) {
                continue;
            }

            leadsToInsert.add(buildLead(req));
            leadRequestIndexes.add(i);
            if (String.isNotBlank(req.email)) {
                emailsQueuedForInsert.add(req.email);
            }
        }

        applySaveResults(leadsToInsert, leadRequestIndexes, responses);

        return responses;
    }

    /**
     * Bulk-queries existing Leads whose email matches any request, so each
     * request can be checked without a query per iteration.
     * @param requests List of Request inputs to check
     * @return Set of Lead emails that already exist
     */
    private static Set<String> getExistingLeadEmails(List<LeadRequest> requests) {
        Set<String> emails = new Set<String>();
        for (LeadRequest req : requests) {
            if (String.isNotBlank(req.email)) {
                emails.add(req.email);
            }
        }

        Set<String> existingEmails = new Set<String>();
        if (emails.isEmpty()) {
            return existingEmails;
        }

        for (Lead existingLead : [SELECT Email FROM Lead WHERE Email IN :emails WITH USER_MODE]) {
            existingEmails.add(existingLead.Email);
        }
        return existingEmails;
    }

    /**
     * Builds a new Lead record from a request, without inserting it.
     * @param req The input request
     * @return An uninserted Lead record
     */
    private static Lead buildLead(LeadRequest req) {
        Lead newLead = new Lead();
        newLead.FirstName = req.firstName;
        newLead.LastName = req.lastName;
        newLead.Email = req.email;
        newLead.Phone = req.phone;
        newLead.Company = String.isNotBlank(req.company) ? req.company : DEFAULT_COMPANY;
        newLead.LeadSource = LEAD_SOURCE;
        return newLead;
    }

    /**
     * Bulk-inserts the new leads and overwrites the response message for any
     * request whose Lead failed to save.
     * @param leadsToInsert New Lead records to insert, outside any loop
     * @param leadRequestIndexes responses index that each leadsToInsert entry corresponds to
     * @param responses Responses to update in place on save failure
     */
    private static void applySaveResults(List<Lead> leadsToInsert, List<Integer> leadRequestIndexes, List<LeadResponse> responses) {
        if (leadsToInsert.isEmpty()) {
            return;
        }

        List<Database.SaveResult> saveResults = Database.insert(leadsToInsert, false, AccessLevel.USER_MODE);
        for (Integer i = 0; i < saveResults.size(); i++) {
            if (!saveResults[i].isSuccess()) {
                responses[leadRequestIndexes[i]].responseMessage = SAVE_ERROR_MESSAGE;
            }
        }
    }

    /**
     * Builds the standard thank-you message shown for both existing and newly created leads.
     * @param req The input request
     * @return The response message, including whichever contact details were provided
     */
    private static String buildThankYouMessage(LeadRequest req) {
        return req.firstName + ', Thank you! Our representative will contact you soon on the provided ' + buildContactMethod(req) + '.';
    }

    /**
     * Describes which contact detail(s) were provided on the request.
     * @param req The input request
     * @return A phrase naming the email, phone, or both
     */
    private static String buildContactMethod(LeadRequest req) {
        Boolean hasEmail = String.isNotBlank(req.email);
        Boolean hasPhone = String.isNotBlank(req.phone);

        if (hasEmail && hasPhone) {
            return 'Email Address: ' + req.email + ' or Phone number: ' + req.phone;
        }
        if (hasEmail) {
            return 'Email Address: ' + req.email;
        }
        if (hasPhone) {
            return 'Phone number: ' + req.phone;
        }
        return '';
    }

    /**
     * Input parameters from the calling Flow or Agent.
     */
    public class LeadRequest {
        @InvocableVariable(required=true label='First Name' description='First name of the user.')
        public String firstName;

        @InvocableVariable(required=true label='Last Name' description='Last name of the user.')
        public String lastName;

        @InvocableVariable(required=true label='Email' description='Email address of the user.')
        public String email;

        @InvocableVariable(label='Phone' description='Phone number of the user (optional).')
        public String phone;

        @InvocableVariable(label='Company' description='Company name of the user (optional). Defaults to "Unknown" when not provided, since Company is required on Lead.')
        public String company;
    }

    /**
     * Output result returned to the calling Flow or Agent.
     */
    public class LeadResponse {
        @InvocableVariable(label='Response Message' description='Message to display to the user.')
        public String responseMessage;
    }
}
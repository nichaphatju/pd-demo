public with sharing class CreateLeadAction {

    public class LeadRequest {
        @InvocableVariable(required=true label='First Name' description='First name of the user.')
        public String firstName;

        @InvocableVariable(required=true label='Last Name' description='Last name of the user.')
        public String lastName;

        @InvocableVariable(required=true label='Email' description='Email address of the user.')
        public String email;

        @InvocableVariable(label='Phone' description='Phone number of the user (optional).')
        public String phone;
    }

    public class LeadResponse {
        @InvocableVariable(label='Response Message' description='Message to display to the user.')
        public String responseMessage;
    }

    @InvocableMethod(
        label='Create Lead'
        description='Checks if a lead exists by email. If found, skips creation. If not, creates a new lead. Returns a response message either way.'
        category='Lead Management'
    )
    public static List<LeadResponse> createLead(List<LeadRequest> requests) {
        List<LeadResponse> responses = new List<LeadResponse>();

        for (LeadRequest req : requests) {
            LeadResponse res = new LeadResponse();

            // Build the contact method string for the response
            String contactMethod = '';
            if (String.isNotBlank(req.email) && String.isNotBlank(req.phone)) {
                contactMethod = 'Email Address: ' + req.email + ' or Phone number: ' + req.phone;
            } else if (String.isNotBlank(req.email)) {
                contactMethod = 'Email Address: ' + req.email;
            } else if (String.isNotBlank(req.phone)) {
                contactMethod = 'Phone number: ' + req.phone;
            }

            // Check if lead already exists by email
            if (String.isNotBlank(req.email)) {
                List<Lead> existingLeads = [
                    SELECT Id FROM Lead WHERE Email = :req.email LIMIT 1
                ];
                if (!existingLeads.isEmpty()) {
                    res.responseMessage = req.firstName + ', Thank you! Our representative will contact you soon on the provided ' + contactMethod + '.';
                    responses.add(res);
                    continue;
                }
            }

            // Create new lead
            Lead newLead = new Lead();
            newLead.FirstName  = req.firstName;
            newLead.LastName   = req.lastName;
            newLead.Email      = req.email;
            newLead.Phone      = req.phone;
            newLead.LeadSource = 'Agentforce Agent';

            try {
                insert as user newLead;
                res.responseMessage = req.firstName + ', Thank you! Our representative will contact you soon on the provided ' + contactMethod + '.';
            } catch (Exception e) {
                res.responseMessage = 'Sorry, we encountered an issue while saving your details. Please try again.';
            }

            responses.add(res);
        }

        return responses;
    }
}
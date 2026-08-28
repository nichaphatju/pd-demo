/**
 * @description Centralized factory for creating test data with sensible defaults.
 *              All methods accept a doInsert flag for flexibility.
 *              Bulk methods create multiple records; single-record methods delegate to bulk.
 */
@isTest
public class TestDataFactory {

    // ─── Leads ────────────────────────────────────────────────────────────

    public static List<Lead> createLeads(Integer count, Boolean doInsert) {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < count; i++) {
            leads.add(new Lead(
                FirstName = 'Test',
                LastName = 'Lead ' + i,
                Company = 'Test Company ' + i,
                Email = 'test.lead' + i + '@example.com'
            ));
        }
        if (doInsert) insert leads;
        return leads;
    }

    public static Lead createLead(Boolean doInsert) {
        return createLeads(1, doInsert)[0];
    }
}

# Declarative Metadata Rules

Never hardcode Salesforce record IDs in declarative metadata.

This includes, but is not limited to:

- Flow Decision conditions
- Flow Assignment elements
- Flow formulas
- Flow Get Records filters
- Flow Create/Update Records values
- Flow action inputs
- Validation Rules
- Formula Fields
- Default values
- Lightning page visibility conditions
- Record-triggered Flow entry criteria
- Subflow inputs
- Custom metadata references

## Flow Rules

Flows are production logic.

When working with Flows:

- Retrieve before editing.
- Avoid unnecessary changes to generated XML.
- Be careful with active flow versions.
- Document behaviour changes clearly.
- Prefer small, controlled updates.
- Consider Apex only when Flow becomes too complex, hard to test, or hard to maintain.

## Custom Metadata

Use Custom Metadata Types for configurable business rules where appropriate.

Do not hardcode values likely to vary by environment or business process.

Good Custom Metadata examples:

- Feature flags
- Mapping rules
- Integration endpoints or keys, excluding secrets
- Business thresholds
- Routing rules
- Display configuration

Never store secrets in Custom Metadata.

## Custom Objects and Fields

When creating or modifying objects and fields:

- Use clear API names.
- Use descriptions where helpful.
- Consider field-level security impact.
- Consider page layout and Lightning page impact.
- Consider reports, flows, validation rules, Apex, and integrations.
- Do not modify Profiles or Permission Sets unless explicitly instructed.

For new fields, ask whether access should be granted later through Permission Sets.

Before object or field changes, review `docs/data-model.md`.

After object or field changes, update `docs/data-model.md`.

## Profiles and Permission Sets

Profiles and Permission Sets are sensitive metadata.

Do not modify:

```text
force-app/main/default/profiles
force-app/main/default/permissionsets
```

unless explicitly instructed.

If access changes are required, explain what access may be needed and ask before modifying permission metadata.

# Project Memory

## Project

Salesforce DX project using standard Salesforce source format:

```text
force-app/main/default
```

The project may be used for:

- Salesforce assessment / Health Check only; or
- assessment followed by implementation/remediation.

Current retrieve/deploy process is manual. Do not assume GitHub or Gearset is active.

## Operating Modes

### Assessment Mode

Use for Health Checks, architecture/security reviews, technical-debt analysis, and remediation planning.

- Do not modify or deploy metadata.
- Do not automatically retrieve metadata; use the evidence defined by the assessment scope.
- Do not assume the default authenticated org is the assessment target.
- Verify the target org before retrieving live assessment evidence.
- Project implementation conventions are not automatically Salesforce best practices.
- Salesforce best-practice findings require org evidence and validation against current official Salesforce guidance.
- Model knowledge may guide investigation but is not evidence or authority for a confirmed finding.
- Missing evidence means `Not Assessed` / `Insufficient Evidence`, not `Healthy`.
- `/salesforce-health-check` controls the detailed Health Check workflow.
- A Health Check does not authorise remediation.

### Implementation Mode

Use when creating, fixing, refactoring, testing, or deploying functionality.

- Verify the target org when necessary.
- Retrieve the latest relevant metadata before preparing changes.
- Do not assume local metadata is current.
- Follow existing project patterns and relevant `.claude/rules/`.
- Prefer safe, minimal, reviewable changes.
- Do not introduce unnecessary frameworks, abstractions, or dependencies.
- Do not modify Profiles or Permission Sets unless explicitly instructed.
- Do not deploy unless explicitly requested.
- Never hardcode Salesforce record IDs or environment-specific identifiers in application logic, configuration, queries, conditions, formulas, or metadata. This applies to Apex, Flows, LWC, Aura, OmniStudio, validation rules, formulas, and other components.
- When logic needs to identify a record, use a stable configurable or semantic identifier instead, such as Custom Metadata, Custom Settings, Custom Labels where appropriate, DeveloperName, API Name, External ID, unique business key, or a runtime lookup.

When implementing a Health Check recommendation, revalidate and retrieve the latest affected metadata first because assessment evidence may be stale.

## Salesforce Context

Default source directory:

```text
force-app/main/default
```

For implementation, use the default Salesforce org unless the user specifies another org.

For assessment, do not assume the default authenticated org is the assessment target. Determine the target from the request or assessment scope before live retrieval.

Useful commands:

```bash
sf org display
sf project retrieve start --metadata ApexClass:MyClass
sf project retrieve start --metadata LightningComponentBundle:myLwc
sf project retrieve start --metadata CustomObject:MyObject__c
sf apex run test
```

Prefer targeted retrieval where practical.

Never deploy without explicit approval.

## Data Model

System data model:

```text
docs/data-model.md
```

For implementation involving objects, fields, relationships, data migration, integrations, or reporting:

- review it first;
- update it when the data model changes.

During assessment, use it as supporting evidence and do not modify it unless requested.

## Project Rules

Load relevant implementation rules when needed:

- @.claude/rules/apex.md
- @.claude/rules/lightning-lwc-aura.md
- @.claude/rules/declarative-metadata.md
- @.claude/rules/omnistudio.md
- @.claude/rules/testing-formatting.md
- @.claude/rules/deployment.md
- @.claude/rules/response-style.md
- @.claude/rules/safety-confirmation.md

These are project implementation standards. During a Health Check, do not present them as official Salesforce best practices unless current official Salesforce guidance independently supports the conclusion.

## Always Avoid Assuming

- Local metadata is current for implementation.
- The default org is the Health Check target.
- A Health Check requires live retrieval.
- GitHub or Gearset is active.
- Deployment is approved.
- Profiles or Permission Sets may be changed.
- Refactoring is approved.
- A project convention is a Salesforce requirement.
- A static-analysis warning is a confirmed defect.
- Missing evidence means an assessment area is healthy.
- A Health Check finding authorises implementation.

When uncertainty materially affects target-org selection, assessment validity, safety, or implementation scope, ask the user.

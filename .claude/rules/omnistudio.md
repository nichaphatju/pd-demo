# OmniStudio Rules

Use this rule file when working with Salesforce OmniStudio metadata, including FlexCards, OmniScripts, DataRaptors, Integration Procedures, Calculation Procedures, and related custom metadata.

## Core OmniStudio Rules

- Retrieve the latest OmniStudio metadata before reviewing or changing anything.
- Do not assume the local OmniStudio JSON or metadata is current.
- Keep changes small, focused, and easy to review.
- Follow existing naming, folder, and versioning patterns.
- Do not activate, deactivate, or change production behaviour without explicit confirmation.
- Do not delete OmniStudio components unless explicitly approved.
- Document assumptions, risks, and impacted components before proposing deployment.

## Retrieval and Deployment

Prefer targeted retrieval where possible.

Common metadata types may include:

```bash
sf project retrieve start --metadata OmniScript:ComponentName
sf project retrieve start --metadata FlexCard:ComponentName
sf project retrieve start --metadata DataRaptor:ComponentName
sf project retrieve start --metadata IntegrationProcedure:ComponentName
```

If metadata type names differ in the project or org, inspect existing `sfdx-project.json`, package metadata, and local source structure before deciding the command.

Do not deploy OmniStudio changes unless the user explicitly confirms deployment.

## OmniScripts

When modifying OmniScripts:

- Review the full user journey before changing steps, blocks, or conditional views.
- Be careful with active versions and version-specific behaviour.
- Avoid changing element names that are referenced by formulas, conditions, DataRaptors, or Integration Procedures.
- Preserve existing JSON structure and only change relevant nodes.
- Check navigation, validation, required fields, conditional display rules, and save/submit behaviour.
- Consider whether changes affect embedded FlexCards, custom LWCs, or Integration Procedures.

## FlexCards

When modifying FlexCards:

- Keep UI changes consistent with existing card patterns.
- Avoid changing data source configuration unless required.
- Check actions, events, states, filters, and conditional visibility.
- Confirm whether the card is used on record pages, Experience Cloud pages, or inside OmniScripts.
- Be careful with versioning and activation behaviour.

## DataRaptors (or Data Mappers)

When modifying DataRaptors:

- Confirm whether it is Extract, Load, Transform, or Turbo Extract before changing it.
- Review input JSON paths, output mappings, formulas, filters, and linked objects.
- Avoid changing field mappings without checking downstream dependencies.
- Do not hardcode IDs or environment-specific values.
- Consider CRUD/FLS and data exposure risks for user-facing processes.
- Test with realistic input payloads before recommending deployment.

## Integration Procedures

When modifying Integration Procedures:

- Review the complete orchestration flow before changing elements.
- Check Remote Actions, DataRaptor actions, Response Actions, Set Values, Loop Blocks, Try/Catch behaviour, and conditional execution.
- Keep response payloads backward compatible unless the user confirms downstream consumers can change.
- Avoid unnecessary chainable or cache changes.
- Consider timeout, error handling, and performance impact.
- Do not expose sensitive data in response nodes.

## Custom LWCs Used by OmniStudio

When OmniStudio uses custom LWCs:

- Check the interface between OmniStudio JSON data and the LWC API.
- Avoid changing public `@api` properties without checking all usages.
- Keep client-side logic focused on UI behaviour.
- Put business logic in Apex, DataRaptors, or Integration Procedures where appropriate.

## Testing and Validation

Before finalising OmniStudio changes, validate:

- The relevant OmniScript, FlexCard, DataRaptor, or Integration Procedure was retrieved first.
- Active version and versioning impact were considered.
- Input and output JSON paths still match expected payloads.
- Conditional logic still works.
- Error scenarios are handled clearly.
- Downstream components or consumers are not broken.
- Any related Apex tests are suggested or run when Apex is changed.

## Response Summary Format

For OmniStudio changes, include:

```text
Changed:
- path/to/component — summary of change

OmniStudio impact:
- Component type: OmniScript / FlexCard / DataRaptor / Integration Procedure
- Version impact: active / inactive / new version / unknown
- Dependencies checked: yes / no / recommended

Validation:
- Local review: completed / not completed
- Runtime test: completed / recommended
- Apex tests: passed / not run / recommended

Deployment:
- Not deployed. Please confirm if you want to deploy.
```

# Lightning Rules

## LWC Standards

Prefer LWC for new UI work unless the existing feature is Aura-based and consistency requires Aura.

LWC rules:

- Keep components focused and small.
- Move business logic to Apex where appropriate.
- Avoid duplicating server-side validation.
- Use reactive properties correctly.
- Use clear naming.
- Avoid excessive imperative Apex calls.
- Use `@wire` where it improves readability and data refresh behaviour.
- Use `refreshApex` when needed.
- Use Lightning Data Service where suitable.
- Do not hardcode labels or messages where Custom Labels would be better.
- Prefer readable JavaScript over clever code.

## Aura Standards

Aura may exist for legacy functionality.

When modifying Aura:

- Keep changes minimal.
- Follow existing component structure.
- Avoid converting Aura to LWC unless requested.
- Do not mix large architectural changes with bug fixes.
- Use Apex service classes for business logic.

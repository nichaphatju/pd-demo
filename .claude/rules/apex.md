# Apex Rules

## General Apex Standards

Apex must be bulk-safe, secure, testable, readable, maintainable, and consistent with existing project patterns.

Avoid:

- SOQL inside loops
- DML inside loops
- Hardcoded record IDs or environment-specific identifiers
- Hardcoded profile names
- Hardcoded permission set names
- Unnecessary static state
- Overly complex logic in triggers or controllers
- Business logic directly inside LWC/Aura controllers

Use constants where appropriate.

Use Custom Metadata for configurable behaviour where reasonable.

## Trigger Standards

Every trigger must have a handler.

Do not place business logic directly in triggers.

Preferred pattern:

```text
Trigger
  -> Trigger Handler
    -> Service Class
      -> Selector / Query Helper where useful
```

For LWC and Aura:

```text
LWC / Aura
  -> Apex Controller
    -> Service Class
      -> Selector / Query Helper where useful
```

Controller classes should be thin.

Service classes should contain business rules, orchestration, validations, and reusable operations.

Selector/query helper classes may be used when query logic is reused or complex.

## Apex Security

Use `with sharing`, `without sharing`, or `inherited sharing` intentionally.

Default preference:

```apex
public with sharing class MyClass {
}
```

Use `inherited sharing` where the class is reused across different execution contexts and sharing should follow the caller.

Use `without sharing` only when required and document why.

When exposing Apex to LWC or Aura:

- Validate inputs.
- Avoid returning sensitive fields.
- Use sharing intentionally.
- Apply CRUD/FLS checks where required.
- Avoid exposing broad update/delete methods.
- Do not trust client-side validation only.

For user-facing data access, consider `WITH SECURITY_ENFORCED` or explicit field/object access checks where more control is required.

## SOQL and DML

SOQL and DML must be bulk-safe.

Good pattern:

```apex
Set<Id> accountIds = new Map<Id, Account>(accounts).keySet();

List<Contact> contacts = [
    SELECT Id, AccountId, Email
    FROM Contact
    WHERE AccountId IN :accountIds
];
```

Avoid:

```apex
for (Account accountRecord : accounts) {
    List<Contact> contacts = [
        SELECT Id
        FROM Contact
        WHERE AccountId = :accountRecord.Id
    ];
}
```

Perform DML outside loops.

Use partial success where appropriate:

```apex
Database.SaveResult[] results = Database.update(recordsToUpdate, false);
```

Handle errors clearly and avoid swallowing exceptions.

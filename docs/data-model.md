# Data Model

This document tracks custom objects and fields in `force-app/main/default` and their relationships. Update it whenever the data model changes.

## Account (standard object)

| Field | API Name | Type | Notes |
| --- | --- | --- | --- |
| ABN | `ABN__c` | Text(11) | Australian Business Number for the account. |

## Customer Feedback (`Customer_Feedback__c`)

Captures quick, informal feedback (compliment, suggestion, or concern) logged against a Contact, without requiring a full Case.

- Sharing model: `ReadWrite`
- Name field: Auto Number, format `CF-{0000}` ("Feedback Number")

| Field | API Name | Type | Required | Notes |
| --- | --- | --- | --- | --- |
| Contact | `Contact__c` | Lookup(Contact) | Yes | Parent Contact; delete constraint `Restrict`. Child relationship name `Customer_Feedbacks`. |
| Feedback Type | `Feedback_Type__c` | Picklist (restricted) | Yes | Values: Compliment, Suggestion, Concern. |
| Feedback Notes | `Feedback_Notes__c` | Long Text Area (32,768) | No | Free-text detail. |
| Follow Up Required | `Follow_Up_Required__c` | Checkbox | No | Defaults to unchecked. |
| Date Received | `Date_Received__c` | Date | No | No field-level default; intended to be set to today by the "Log Customer Feedback" screen flow (separate story). |

### Relationships

- `Contact` 1 → * `Customer_Feedback__c` (Lookup, `Contact__c`)

### Access

- Permission set `Customer_Feedback_Access` grants Create/Read/Edit (no Delete) on `Customer_Feedback__c` and field-level access to the non-required fields. Required fields (`Contact__c`, `Feedback_Type__c`) have no explicit FLS entries, as Salesforce does not support field permissions on required fields — they are implicitly available to any user with object-level access.

### Out of scope (tracked separately)

- "Log Customer Feedback" screen flow and its Contact record page button (see PDD-5 linked Confluence spec — data model only was delivered under PDD-5).

## Source of truth

Reference: Confluence — "Customer Feedback Data Model & Flow" (linked from Jira PDD-5).

# Data Model

This document tracks custom objects and fields in `force-app/main/default` and their relationships. Update it whenever the data model changes.

## Account (standard object)

| Field | API Name | Type | Notes |
| --- | --- | --- | --- |
| ABN | `ABN__c` | Text(11) | Australian Business Number for the account. |

## Case (standard object) — DCC (Disputes, Claims, Complaints)

Delivered under PDD-7 (fields) and PDD-8 (record types / layouts). Source of truth: Confluence "Data Model" page (linked from PDD-7/PDD-8).

### Status, Stage and Origin

- `Status` (standard value set `CaseStatus`): DCC values added — Acknowledged, In Investigation, In Negotiation / On Hold, Awaiting Admin, Awaiting Customer, Awaiting Sales, Awaiting Credit, Awaiting Service, Awaiting Production/Ops, Awaiting Technical, Pending Release Documents, Ready To Close, Pending Approval, Resolution Finalised, Closed - Approved, Closed - Rejected, Closed - NFI, Cancelled (closed values: the four Closed/Cancelled), Reopened. Existing values (New, Working, Escalated, Closed) retained for non-DCC cases.
- `Origin` (standard value set `CaseOrigin`): Email2Case and Internal added.
- `Stage__c`: picklist grouping Status values — Intake (New), Acknowledgement (Acknowledged), Investigation (In Investigation, In Negotiation / On Hold), Waiting (Awaiting…, Pending Release Documents, Ready To Close), Approval (Pending Approval), Resolution (Resolution Finalised), Closed (Closed - …, Cancelled), Reopened (Reopened). Default Intake. Drives the Case Path.

### Business process and record types

- Business process `DCC_Process` — New plus the DCC Status values above.
- Record type `Disputes_Claims` (Disputes/Claims) — Dispute vs Claim differentiated via `Issue_Type__c`.
- Record type `Complaints`.
- Page layouts: `Case-DCC Disputes Claims Layout`, `Case-DCC Complaints Layout`. Paths on `Stage__c` per record type.

### Common fields

| Field | API Name | Type | Notes |
| --- | --- | --- | --- |
| Stage | `Stage__c` | Picklist (restricted) | See above. Read-only on DCC layouts (automation-managed). |
| Customer Acknowledgement Sent | `Customer_Acknowledgement_Sent__c` | Checkbox | |
| Incident Date | `Incident_Date__c` | Date | "Date of Issue"; required at intake on Disputes/Claims layout. |
| Closed By | `Closed_By__c` | Lookup(User) | Intended to be set by automation. |
| Reopen Count | `Reopen_Count__c` | Number(3,0) | |
| Reopen Reason | `Reopen_Reason__c` | Picklist | Admin Error, Customer Request. |
| RFI Number | `RFI_Number__c` | Number(18,0) | Disputes/Claims only. |
| Account Manager | `Account_Manager__c` | Lookup(User) | |
| Credit Officer | `Credit_Officer__c` | Lookup(User) | Legacy data is free text — needs transformation before migration. |
| Escalation Level | `Escalation_Level__c` | Picklist | L1, L2, L3. Intended to be set by automation. |
| Approval Required | `Approval_Required__c` | Checkbox | |
| Approval Status | `Approval_Status__c` | Picklist | Required, Not Required, Pending, Submitted, Approved, Rejected. |
| Approval Level | `Approval_Level__c` | Picklist | 1, 2, 3, 4, Auto Approved. Intended to be set by automation. |
| Approval Date | `Approval_Date__c` | Date | Intended to be set by automation. |
| Corrective Action Needed | `Corrective_Action_Needed__c` | Checkbox | |
| Corrective Action | `Corrective_Action__c` | Text(255) | |
| Issue Type | `Issue_Type__c` | Picklist | Damage to Property, Cost Recovery, Site Clean-up or Rectification Required, Rework or Replacement Needed, Other. Disputes/Claims only; required at intake. |
| Issue | `Issue__c` | Picklist | Incorrect Rate, Incorrect Quantity. Controls Root Cause. |
| Root Cause | `Root_Cause__c` | Dependent picklist (on Issue) | Incorrect Rate → Incorrect Project, Masterfile Setup; Incorrect Quantity → Incorrect Order, Keying Error. |
| Error Source | `Error_Source__c` | Dependent picklist (on Root Cause) | Incorrect Project → Customer, Other; Masterfile Setup → Pricing Team, Sales, Other; Incorrect Order / Keying Error → Service Centre, Other. |

| SLA Type | `DCC_SLA_Type__c` | Picklist (restricted) | Dispute, Claim, Complaint. Set by the New Dispute/Claim intake flow from Issue Type via `DCC_Issue_Type_Mapping__mdt` (PDD-10). Read-only on DCC layouts. |

Contact Email uses the standard `ContactEmail` field. Trading Region is not yet built (depends on an Account trading-region field that does not exist).

### Dispute fields

| Field | API Name | Type | Notes |
| --- | --- | --- | --- |
| Invoice Number | `Invoice_Number__c` | Text(100) | Primary invoice; required at intake on Disputes/Claims layout. |
| Invoice Amount | `Invoice_Amount__c` | Currency(16,2) | |
| Disputed Amount | `Disputed_Amount__c` | Currency(16,2) | |
| Credit Amount Approved | `Credit_Amount_Approved__c` | Currency(16,2) | |
| Credit Issued | `Credit_Issued__c` | Checkbox | |
| Credit Issued Date | `Credit_Issued_Date__c` | Date | |
| Credit Amount | `Credit_Amount__c` | Currency(16,2) | |

### Validation rules

- `DCC_Investigation_Required_Fields` — on DCC record types, Account, Contact, Subject and Description are required once `Stage__c` is past Intake/Acknowledgement.
- Intake-required fields (Account, Incident Date, Invoice Number, Issue Type) are enforced as layout-required on the Disputes/Claims layout (UI only), so Email-to-Case creation is not blocked.

## Invoice Number (`DCC_Invoice_Numbers__c`)

One or more invoice references against a DCC Case; one record per Case is the Primary Invoice.

- Sharing model: `ControlledByParent`
- Name field: Auto Number, format `INV-{000000}` ("Record Name")

| Field | API Name | Type | Required | Notes |
| --- | --- | --- | --- | --- |
| Case | `Case__c` | Master-Detail(Case) | Yes | Child relationship name `Invoice_Numbers`. |
| Invoice Number | `Invoice_Number__c` | Text(100) | Yes | Used for search and matching. |
| Primary Invoice | `Primary_Invoice__c` | Checkbox | No | Only one per Case should be true (not yet enforced). |
| Source | `Source__c` | Picklist (restricted) | No | Case Primary Field, Manually Added, Email Parsed. |
| Invoice Amount | `Invoice_Amount__c` | Currency(16,2) | No | |

### Relationships

- `Case` 1 → * `DCC_Invoice_Numbers__c` (Master-Detail, `Case__c`)

## DCC Issue Type Mapping (`DCC_Issue_Type_Mapping__mdt`)

Custom metadata type mapping a Case `Issue_Type__c` value to the `DCC_SLA_Type__c` to set at intake (PDD-10). Editable without changing the flow.

| Field | API Name | Type | Notes |
| --- | --- | --- | --- |
| Issue Type | `Issue_Type__c` | Text(255) | Case Issue_Type__c picklist value. |
| SLA Type | `SLA_Type__c` | Picklist | Dispute, Claim. |

Seeded records (default; confirm with business): Damage to Property → Claim; Cost Recovery → Dispute; Site Clean-up or Rectification Required → Claim; Rework or Replacement Needed → Claim; Other → Dispute.

## Related configuration

- Queue `DCC_Generic_Intake_Queue` ("DCC - Generic Intake", Case) — fallback owner for intake cases with no Account.
- Custom Label `DCC_Brand_Name` = "Boral" — brand used in customer acknowledgement emails.
- Case related lists on DCC layouts (PDD-9): Invoice Numbers (Disputes/Claims), Child Cases, Emails, Activities, Case History, Comments, Files.

### Out of scope (tracked separately)

- Status → Stage sync automation, primary-invoice sync to Case, single-primary enforcement, Invoice Amount roll-up.
- DCC permission sets (object/field access, read-only Stage FLS, record type visibility).

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

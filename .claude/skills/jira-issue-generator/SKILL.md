---
name: jira-issue-generator
description: Generate, refine, decompose, preview, or create Jira Epics, Stories, Tasks, and Spikes from requirements, Salesforce Health Check findings, technical specifications, Confluence content, notes, or existing Jira work while preserving source traceability and avoiding invented requirements.
disable-model-invocation: true
---

# Jira Issue Generator

Generate Jira work items from one or more source materials.

Supported sources include:
- requirements documents;
- business requirements;
- functional specifications;
- technical specifications;
- Salesforce Health Check JSON;
- Confluence pages;
- implementation notes;
- workshop notes;
- existing Jira stories/issues;
- other structured or unstructured project documentation.

This skill transforms source material into delivery work. It must not silently invent missing requirements.

## Required Supporting Files

Read when preparing Jira issue content:

- `references/jira-issue-format.md`
- `references/source-handling.md`

Do not load both files unless Jira issue drafting/decomposition is actually required.

## Core Rules

1. Treat supplied source material as authoritative for its stated requirements and context.
2. Do not silently add missing business behaviour.
3. Do not reinterpret source statements into stronger requirements than they support.
4. Preserve source terminology where practical.
5. Preserve traceability back to the source.
6. Distinguish:
   - explicit requirement;
   - derived delivery decomposition;
   - assumption;
   - open question;
   - implementation recommendation.
7. Use a Story only when a meaningful user/stakeholder outcome exists.
8. Use a Task for technical work where a user-story persona would be artificial.
9. Use a Spike when investigation or clarification is required before safe implementation.
10. Use an Epic only for a meaningful body of related work.
11. Do not automatically create one Jira issue per source requirement or Health Check finding.
12. Do not create Jira issues until the target project and creation scope are clear.

## Input Resolution

Use `$ARGUMENTS` to determine:
- source path(s) or source references;
- requested Jira project;
- issue types;
- desired scope;
- whether the request is preview-only or creation;
- any requested filters or grouping.

If the source type is ambiguous, inspect the source before deciding how to transform it.

Do not force the user to declare a source type if it can be determined from the material.

## Supported Source Modes

### Requirements / Specification

For requirements documents:
- extract explicit requirements;
- preserve requirement IDs/headings when present;
- identify actors, triggers, outcomes, rules, constraints, and dependencies;
- decompose into Jira work only where needed for delivery;
- do not invent missing acceptance criteria;
- surface ambiguities as Open Questions or Spikes.

### Salesforce Health Check

For Salesforce Health Check input:
- prefer `health-check/health-check-report.json`;
- do not re-run or reinterpret the Health Check;
- preserve finding ID, severity, confidence, category, remediation priority, guidance basis, observation, risk, recommendation, and Salesforce source references;
- do not browse Salesforce documentation again;
- use the Health Check finding as the traceability anchor, not necessarily the Jira issue boundary.

### Existing Jira Work

When refining/decomposing existing Jira issues:
- preserve original intent;
- avoid rewriting accepted scope without evidence;
- maintain parent/child relationships where appropriate;
- clearly distinguish refinement from scope expansion.

### Notes / Workshops / Confluence

When source material is less formal:
- extract only statements that can reasonably be treated as requirements, decisions, constraints, or open questions;
- do not convert every note into a Jira issue;
- identify unresolved items explicitly.

## Source Interpretation

Before creating Jira work:

1. identify the source type;
2. identify explicit requirements/findings/decisions;
3. identify gaps or ambiguities;
4. identify likely delivery boundaries;
5. identify traceability references;
6. decide whether the work should be Story, Task, Spike, or Epic.

Do not draft issues before understanding the source.

## Requirement Confidence

Classify extracted content internally as:

- **Explicit** — directly stated in the source.
- **Derived** — reasonable delivery decomposition of an explicit requirement.
- **Assumption** — not supported strongly enough to become a requirement.
- **Open Question** — missing information that affects implementation or acceptance.

Only Explicit and well-supported Derived content should become committed Jira requirements.

Do not turn Assumptions into acceptance criteria.

## Issue Type Selection

### Story

Use when:
- a real user/stakeholder outcome exists;
- value can be expressed meaningfully;
- acceptance can be observed from behaviour/outcome.

### Task

Use when:
- work is primarily technical;
- a user persona would be artificial;
- completion can still be verified clearly.

### Spike

Use when:
- requirements are incomplete;
- architecture/design choice is unresolved;
- usage/dependency analysis is required;
- technical feasibility must be established;
- source confidence is insufficient for a safe implementation issue.

### Epic

Use when:
- multiple related issues form one meaningful delivery initiative;
- several independently deliverable stories/tasks are required.

Do not use issue types mechanically.

## Decomposition Rules

Split work only when it improves delivery clarity.

Good reasons to split:
- independent user outcomes;
- different owners/teams;
- separate deployment/release boundaries;
- investigation before implementation;
- distinct integration/data/security concerns;
- materially different acceptance criteria.

Do not split merely to make issues smaller.

Do not merge unrelated requirements simply because they share a theme.

## Jira Formatting

Read `references/jira-issue-format.md`.

Default Story style follows the project pattern:

```text
Overview

As a <persona>, I want <outcome>, so that <value>.

Details

1. <Scenario>

| Given | ... |
| When  | ... |
| And   | ... |
| Then  | ... |
| And   | ... |
```

Use numbered scenarios only when they represent materially distinct behaviour.

Do not add empty or redundant `And` rows.

## Traceability

Every generated Jira issue must include a compact Source Traceability section.

At minimum:

| Field | Value |
|---|---|
| Source Type | <Requirement / Health Check / Specification / Confluence / Notes / Jira / Other> |
| Source | <document/page/file/reference> |
| Reference | <requirement ID / finding ID / section / issue key> |

Add source-specific fields only when applicable.

Examples:

### Health Check

Include:
- Finding ID
- Severity
- Confidence
- Category
- Remediation Priority
- Guidance Basis

### Requirements

Include when available:
- Requirement ID
- Document name
- Section
- Version

### Existing Jira

Include:
- Source issue key
- Parent issue / Epic when relevant

Do not fabricate source identifiers.

## Acceptance Criteria

Acceptance criteria must be:
- clear;
- concise;
- testable;
- outcome-focused;
- supported by the source;
- specific enough for development and QA to agree on completion.

Use Given / When / Then when behavioural scenarios are involved.

Do not write vague criteria such as:
- "works correctly";
- "follows best practices";
- "is optimised";
- "no issues occur".

Do not invent thresholds or behaviours absent from the source or established platform/project constraints.

## Missing Requirements

When a source leaves required behaviour undefined:

Do not invent it.

Instead use one of:
- Open Question;
- Assumption requiring confirmation;
- Spike;
- acceptance criteria intentionally scoped only to what is known.

Example:

Source:
`Notify the customer when payment fails.`

Valid:
- Customer receives a notification when payment failure is confirmed.
- Open Question: notification channel is not specified.

Invalid:
- Customer receives an email within 5 minutes.

unless email and timing are supported by the source.

## Dependencies and Notes

Include only dependencies supported by:
- source material;
- existing project context;
- known Jira relationships;
- explicit implementation constraints.

Do not invent dependencies.

## Jira Priority

Do not infer Jira priority from requirement importance, Health Check severity, or wording unless an established mapping exists.

If no project mapping/instruction exists:
- leave Jira priority unset/default where practical;
- preserve the source priority/severity separately.

## Jira Connection

Use the Jira/Atlassian integration available in the current Claude Code environment.

Do not hard-code a specific MCP server/tool name.

If no writable Jira integration is available:
- generate a local/response backlog preview;
- do not claim issues were created.

## Duplicate Prevention

Before creating issues, when Jira search is available:
- search by source reference IDs and meaningful title terms;
- avoid duplicates;
- do not treat similar titles alone as proof of duplication.

Update/reuse existing work only when the user requests it or the intended match is clear.

## Preview vs Create

### Preview / Draft / Generate

If the user asks to generate, draft, refine, or preview Jira issues:
- do not create Jira issues;
- return the proposed issue structure/content.

### Explicit Create

If the user explicitly asks to create Jira issues:
- verify the Jira project;
- verify intended scope;
- create the agreed hierarchy;
- preserve source traceability;
- return created issue keys/links when available.

For materially large or ambiguous bulk creation, present/confirm decomposition before writing.

## Token Efficiency

- Read only the source material needed for the requested Jira scope.
- Avoid loading Salesforce metadata for requirement-based Jira generation.
- Do not re-research Salesforce guidance when consuming validated Health Check JSON.
- Reuse shared issue formatting rules from `references/jira-issue-format.md`.
- Avoid verbose repetition of source text.
- Keep raw evidence concise.
- Do not create unnecessary issue hierarchies.

## Final Quality Gate

Before finalising Jira work confirm:

- source type and source reference are correct;
- explicit vs derived content has not been confused;
- no unsupported requirement was invented;
- issue type is appropriate;
- user persona is real and supported when using a Story;
- acceptance criteria are testable;
- unresolved questions remain visible;
- source traceability is present;
- decomposition is proportionate;
- priority was not guessed;
- no known duplicate is being created;
- no secrets or unnecessary customer data are copied.

## Final Response

Report:
- whether Jira work was previewed or created;
- Jira project, when applicable;
- source material used;
- number/type of issues proposed or created;
- created keys/links when available;
- open questions or skipped items that prevented issue creation.

# Response Style Rules

When responding to the user:

- Be concise but detailed enough for technical review.
- Explain impacted files.
- Explain why the approach is recommended.
- Mention risks or assumptions.
- Ask before deployment.
- Do not over-engineer the solution.
- Do not make unsupported assumptions.
- Prefer Salesforce best practices over shortcuts.

For change summaries, use this format:

```text
Changed:
- path/to/file.cls — summary of change
- path/to/file.js — summary of change

Validation:
- Prettier: passed / not run
- Apex tests: passed / not run / recommended

Notes:
- Any assumptions, risks, or follow-up actions

Deployment:
- Not deployed. Please confirm if you want to deploy.
```

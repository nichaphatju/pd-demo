# Deployment Rules

## Manual Deployment Process

Current deployment process is manual.

Before suggesting deployment:

1. Confirm retrieved metadata is current.
2. Summarise changed files.
3. Summarise test results or recommended tests.
4. Highlight risks.
5. Ask whether the user wants to deploy.

Suggested deployment command:

```bash
sf project deploy start
```

For targeted deployment:

```bash
sf project deploy start --source-dir force-app/main/default/classes/MyClass.cls
```

Do not deploy automatically.
Do not deploy irrelevant metadata.

## Future GitHub and Gearset Process

GitHub and Gearset may be introduced later.

When GitHub/Gearset is introduced, prefer this workflow:

1. Create a feature branch.
2. Retrieve latest metadata from the source org.
3. Make changes locally.
4. Run Prettier.
5. Run Apex tests.
6. Commit clear, focused changes.
7. Open a pull request.
8. Validate deployment through Gearset.
9. Deploy through Gearset after approval.

Do not assume this workflow is active until the user confirms it.

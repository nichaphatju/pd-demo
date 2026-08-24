# Safety and Confirmation Rules

Claude must not do the following without explicit user confirmation:

- Deploy metadata
- Modify Profiles
- Modify Permission Sets
- Delete metadata
- Rename API names
- Change active Flow behaviour
- Change sharing model
- Change security-related logic
- Introduce a new framework or package
- Make broad refactoring changes
- Modify unrelated files

## Preferred Design Principles

Use these principles when proposing solutions:

- Configuration over hardcoding
- Service layer for business logic
- Thin controllers
- Handler-based triggers
- Bulk-safe Apex
- Secure Apex
- Small, focused changes
- Clear test coverage
- Minimal deployment risk
- Consistency with existing project patterns

# Testing and Formatting Rules

## Testing

Run Apex tests when Apex changes are made.

Default command:

```bash
sf apex run test
```

For targeted tests:

```bash
sf apex run test --tests MyClassTest
```

Apex tests should:

- Use clear test data setup.
- Avoid relying on existing org data.
- Cover positive and negative scenarios.
- Cover bulk scenarios where relevant.
- Assert expected outcomes.
- Avoid excessive `SeeAllData=true`.
- Test security-sensitive behaviour where practical.

When adding or changing Apex, add or update tests unless the user says not to.

## Formatting

Run Prettier after changes:

```bash
npx prettier --write .
```

Do not reformat unrelated files unnecessarily if it creates noisy diffs.

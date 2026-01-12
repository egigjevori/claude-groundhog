---
max-iterations: 25
completion-promise: TEST_COVERAGE_COMPLETE
---

# Write Missing Tests

Add tests for code that lacks test coverage.

## Your Task

Each iteration:

1. Find a function/class without adequate tests
2. Analyze what needs to be tested
3. Write comprehensive tests
4. Update the progress report

## Test Guidelines

- Test happy paths and edge cases
- Test error conditions
- Use descriptive test names
- Follow existing test patterns in the codebase

## Report Format

Create/update `.groundhog/reports/test-progress.md`:

```markdown
# Test Writing Progress

Generated on [date]

## Summary
- Functions tested: X
- Tests written: Y
- Files covered: Z

## Progress

### Completed
| File | Function | Tests Added |
|------|----------|-------------|
| src/utils.py | `parse_config` | 5 tests |

### Remaining
| File | Function | Priority |
|------|----------|----------|
| src/api.py | `handle_request` | High |
```

## Rules

1. Run tests after writing to verify they pass
2. Don't break existing tests
3. Focus on untested public functions first
4. Skip trivial getters/setters

## Iteration Strategy

- Each iteration: write tests for 1-2 functions
- Prioritize critical/complex functions
- Track what's been tested

## Completion

When major functions have test coverage, output:

TEST_COVERAGE_COMPLETE

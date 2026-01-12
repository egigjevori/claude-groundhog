---
max-iterations: 20
completion-promise: UNUSED_CODE_SCAN_COMPLETE
---

# Find Unused Code

Scan the codebase for unused code and report findings.

## Your Task

Each iteration, pick ONE area to analyze:

1. **Unused imports** - imports never used in the file
2. **Unused functions** - functions defined but never called
3. **Unused classes** - classes defined but never instantiated
4. **Unused variables** - variables assigned but never read
5. **Dead code paths** - code after return statements, unreachable branches

## Directories to Scan

Focus on these directories in order:
- `src/` - Main source code
- `lib/` - Library code
- `utils/` - Utility functions

## Report Format

Create/update `.groundhog/reports/unused-code.md`:

```markdown
# Unused Code Report

Generated on [date]

## Summary
- Total unused items: X
- Files scanned: Y

## Findings

### Unused Imports
| File | Line | Import | Reason |
|------|------|--------|--------|

### Unused Functions
| File | Line | Function | Reason |
|------|------|----------|--------|
```

## Rules

1. DO NOT modify any source code - only report findings
2. Skip test files (`*_test.py`, `test_*.py`, `tests/`)
3. Skip `__pycache__` and generated files
4. Be careful with:
   - Public API exports
   - Framework-specific patterns (decorators, etc.)
   - Dependency injection

## Iteration Strategy

- Each iteration: scan 2-3 files deeply OR one directory for a specific issue type
- Track which files you've scanned in the report
- Build up the report incrementally

## Completion

When all directories are thoroughly scanned, output:

UNUSED_CODE_SCAN_COMPLETE

---
max-iterations: 15
completion-promise: DOCUMENTATION_COMPLETE
---

# Generate Documentation

Create comprehensive documentation for the codebase.

## Your Task

Each iteration, document ONE component:

1. Read the source code
2. Understand what it does
3. Write clear documentation
4. Add to the documentation report

## What to Document

- Public functions and their parameters
- Classes and their methods
- API endpoints (if applicable)
- Configuration options
- Usage examples

## Report Format

Create/update `.groundhog/reports/documentation.md`:

```markdown
# Code Documentation

Generated on [date]

## Overview

Brief description of the project.

## Modules

### module_name

**Purpose:** What this module does

**Functions:**

#### `function_name(param1, param2)`

Description of what the function does.

**Parameters:**
- `param1` (type): Description
- `param2` (type): Description

**Returns:** Description of return value

**Example:**
\`\`\`python
result = function_name("foo", 42)
\`\`\`
```

## Rules

1. Focus on public APIs, skip internal helpers
2. Include type information when available
3. Add practical examples
4. Note any edge cases or gotchas

## Iteration Strategy

- Each iteration: fully document 1-2 modules/files
- Start with core/main modules
- Track progress in the report

## Completion

When all major components are documented, output:

DOCUMENTATION_COMPLETE

---
description: List all available loops
---

# List Groundhog Loops

List all available loop files.

## Instructions

1. Check if `.groundhog/loops/` directory exists
   - If not, inform the user and suggest creating it with `/groundhog:create <name>`

2. List all `.md` files in `.groundhog/loops/`

3. For each loop file found:
   - Read the frontmatter to get `max-iterations` and `completion-promise`
   - Extract the first heading as the title

4. Display in a formatted table:
   ```
   --- GROUNDHOG: Available Loops ---

   | Loop Name | Title | Max Iterations | Completion Promise |
   |-----------|-------|----------------|-------------------|
   | example   | Find Unused Code | 20 | SCAN_COMPLETE |

   To start: /groundhog:start <name>
   To create: /groundhog:create <name>
   ---
   ```

5. If no loops found, suggest creating one with `/groundhog:create <name>`

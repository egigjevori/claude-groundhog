---
description: Create a new loop from template
---

# Create Groundhog Loop

Create a new loop file from a template.

## Instructions

1. The loop name is provided as an argument: `$ARGUMENTS`
   - If no name provided, ask the user for a name

2. Validate the loop name:
   - Must be lowercase letters, numbers, and hyphens only
   - Must not already exist in `.groundhog/loops/`

3. Create the directory if needed: `.groundhog/loops/`

4. Ask the user what the loop should do (brief description)

5. Create the loop file at `.groundhog/loops/<name>.md` with this template:
   ```markdown
   ---
   max-iterations: 20
   completion-promise: <NAME>_COMPLETE
   ---

   # <Title based on description>

   <Brief description of what this loop does>

   ## Your Task

   Each iteration:
   1. <Step 1>
   2. <Step 2>
   3. Update progress in `.groundhog/reports/<name>.md`

   ## Progress Tracking

   Create/update `.groundhog/reports/<name>.md` with your findings.

   ## Completion

   When the task is fully complete, output:

   <NAME>_COMPLETE
   ```

6. Confirm creation:
   ```
   --- GROUNDHOG: Loop Created ---
   File: .groundhog/loops/<name>.md

   To start: /groundhog:start <name>
   To edit: Open .groundhog/loops/<name>.md
   ---
   ```

## Note

The user can edit the generated file to customize:
- `max-iterations`: How many iterations before auto-stop
- `completion-promise`: The string that signals completion
- Task instructions and rules

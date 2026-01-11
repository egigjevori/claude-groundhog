---
description: Start running a groundhog loop
---

# Start Groundhog Loop

Start running a loop from `.groundhog/loops/`.

## Instructions

1. Parse the argument: `$ARGUMENTS`
   - Extract loop name (required)
   - Check for `--reset` flag to force fresh start

2. If no name provided, ask the user to provide one or suggest `/groundhog:list` to see available loops

3. Check if the loop file exists at `.groundhog/loops/<name>.md`
   - If not found, tell the user and suggest `/groundhog:create <name>` or `/groundhog:list`

4. Read the loop file and parse the YAML frontmatter to extract:
   - `max-iterations` (default: 50)
   - `completion-promise` (default: empty string)

5. Check for previous state in `.groundhog/state.json`:
   - If state exists for THIS loop name AND `--reset` was NOT provided:
     - Check if `active` is false (loop was stopped)
     - If stopped, ask user: "This loop was previously stopped at iteration X. Resume from there, or start fresh?"
       - If resume: Keep the existing iteration count
       - If fresh: Reset iteration to 0
   - Otherwise: Start fresh with iteration 0

6. Create/update the state file at `.groundhog/state.json`:
   ```json
   {
     "active": true,
     "loop_name": "<loop-name>",
     "started_at": "<current ISO timestamp>",
     "iteration": <0 or previous iteration if resuming>,
     "max_iterations": <from frontmatter>,
     "completion_promise": "<from frontmatter>"
   }
   ```

7. Read the loop file content (everything after the frontmatter `---`)

8. Output a header:
   ```
   --- GROUNDHOG: Starting Loop '<loop-name>' ---
   Max iterations: <max>
   Completion promise: <promise or "none">
   Starting from iteration: <iteration>

   To stop: /groundhog:stop
   ---
   ```

9. Then follow the instructions in the loop file to begin working on the task

## Important

The stop hook will automatically:
- Increment the iteration counter after each response
- Re-inject the loop prompt to continue work
- Stop when max iterations reached or completion promise detected

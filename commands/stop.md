---
description: Stop the currently running loop
---

# Stop Groundhog Loop

Stop the currently running groundhog loop.

## Instructions

1. Read the state file at `.groundhog/state.json`
   - If it doesn't exist or `active` is false, inform the user no loop is running

2. If a loop is active:
   - Note the loop name and current iteration
   - Update the state file:
     ```json
     {
       "active": false,
       "stopped_at": "<current ISO timestamp>",
       "stopped_reason": "user_request"
     }
     ```
   - Keep all other fields intact

3. Output confirmation:
   ```
   --- GROUNDHOG: Loop Stopped ---
   Loop: <loop-name>
   Iterations completed: <iteration>
   Reason: User requested stop

   To resume: /groundhog:start <loop-name>
   ---
   ```

## Note

The stop hook will detect `active: false` and allow normal conversation to continue.

---
description: Show current loop status
---

# Groundhog Status

Show the current status of groundhog loops.

## Instructions

1. Check if `.groundhog/state.json` exists
   - If not, report "No groundhog activity detected"

2. Read and parse the state file

3. Display status based on `active` field:

   **If active:**
   ```
   --- GROUNDHOG: Status ---
   Status: RUNNING
   Loop: <loop_name>
   Iteration: <iteration> / <max_iterations>
   Started: <started_at>
   Completion Promise: <completion_promise or "none">

   To stop: /groundhog:stop
   ---
   ```

   **If not active:**
   ```
   --- GROUNDHOG: Status ---
   Status: STOPPED
   Last Loop: <loop_name>
   Iterations Completed: <iteration>
   Started: <started_at>
   Stopped: <stopped_at>
   Reason: <stopped_reason>

   To start: /groundhog:start <loop_name>
   ---
   ```

4. If state file is malformed, report the error

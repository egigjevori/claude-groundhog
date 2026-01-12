# Groundhog 🦫

**Persistent iterative task loops for Claude Code**

Groundhog is a Claude Code plugin that enables you to define repeatable tasks in markdown files and have Claude work through them systematically with automatic progress tracking.

## Features

- **Iterative Execution**: Define tasks that run across multiple iterations
- **Progress Tracking**: Automatic iteration counting and state persistence
- **Completion Detection**: Auto-stop when a "completion promise" is detected
- **Markdown-Based**: Define loops in simple markdown files with YAML frontmatter
- **Report Generation**: Built-in support for generating reports during execution

## Installation

### Option 1: Install via Marketplace (Recommended)

```bash
# Add the marketplace
/plugin marketplace add egigjevori/claude-groundhog

# Install the plugin
/plugin install groundhog@groundhog-marketplace
```

### Option 2: Clone and use with --plugin-dir

```bash
# Clone the repository
git clone https://github.com/egigjevori/claude-groundhog.git ~/claude-groundhog

# Run Claude Code with the plugin
claude --plugin-dir ~/claude-groundhog
```

### Option 3: Add as a git submodule (for project-specific use)

```bash
cd your-project
git submodule add https://github.com/egigjevori/claude-groundhog.git .claude-plugins/groundhog

# Run Claude Code with the plugin
claude --plugin-dir .claude-plugins/groundhog
```

## Quick Start

```bash
# Create a new loop
/groundhog:create my-task

# List available loops
/groundhog:list

# Start a loop
/groundhog:start my-task

# Check status
/groundhog:status

# Stop a running loop
/groundhog:stop
```

## Commands

| Command | Description |
|---------|-------------|
| `/groundhog:start <name>` | Start running a loop (supports resume from previous iteration) |
| `/groundhog:stop` | Stop the currently running loop |
| `/groundhog:list` | List all available loops |
| `/groundhog:status` | Show current loop status |
| `/groundhog:create <name>` | Create a new loop from template |

## Creating Loops

Loops are markdown files stored in `.groundhog/loops/` in your project. They use YAML frontmatter for configuration:

```markdown
---
max-iterations: 20
completion-promise: TASK_COMPLETE
---

# My Task

Description of what this loop accomplishes.

## Your Task

Each iteration, do the following:
1. Pick the next item to process
2. Do the work
3. Update the report file

## Rules

- Don't modify source files
- Skip test files
- Track progress in `.groundhog/reports/my-task.md`

## Completion

When all items are processed, output:

TASK_COMPLETE
```

### Frontmatter Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `max-iterations` | number | 50 | Number of iterations to run |
| `completion-promise` | string | - | (Optional) String that signals early completion |

**Note:** You can run a loop for a fixed number of iterations without a completion promise. Just set `max-iterations` to the desired count - the loop will run exactly that many times.

## How It Works

1. **Start**: `/groundhog:start <name>` initializes state and begins the loop
2. **Execute**: Claude works on the task according to loop instructions
3. **Continue**: After each response, the stop hook:
   - Increments the iteration counter
   - Checks for completion promise
   - Re-injects the loop prompt if continuing
4. **Stop**: Loop ends when:
   - User runs `/groundhog:stop`
   - Completion promise is detected in output
   - Max iterations reached

## Directory Structure

When using Groundhog, your project will have:

```
your-project/
├── .groundhog/
│   ├── state.json      # Current loop state (auto-managed)
│   ├── loops/          # Your loop definitions
│   │   └── my-task.md
│   └── reports/        # Generated reports
│       └── my-task.md
└── ...
```

## Example Loops

### Fixed Iteration Loop (No Completion Promise)

```markdown
---
max-iterations: 5
---

# Review 5 Files

Review exactly 5 files for code quality.

## Your Task

Each iteration:
1. Pick the next unreviewed file
2. Check for code smells, security issues, performance
3. Add findings to `.groundhog/reports/review.md`
```

### Code Scanner

```markdown
---
max-iterations: 30
completion-promise: SCAN_COMPLETE
---

# Find Unused Code

Scan the codebase for unused imports, functions, and variables.

## Your Task

Each iteration, scan 2-3 files for:
- Unused imports
- Unused functions
- Dead code paths

## Output

Update `.groundhog/reports/unused-code.md` with findings.

## Completion

When all directories are scanned, output: SCAN_COMPLETE
```

### Documentation Generator

```markdown
---
max-iterations: 15
completion-promise: DOCS_COMPLETE
---

# Generate API Docs

Document all API endpoints.

## Your Task

Each iteration:
1. Find an undocumented endpoint
2. Read the implementation
3. Write documentation
4. Add to `.groundhog/reports/api-docs.md`

## Completion

When all endpoints are documented, output: DOCS_COMPLETE
```

### Test Writer

```markdown
---
max-iterations: 25
completion-promise: TESTS_COMPLETE
---

# Write Missing Tests

Add tests for uncovered code.

## Your Task

Each iteration:
1. Find a function without tests
2. Write comprehensive tests
3. Run tests to verify
4. Track in `.groundhog/reports/test-coverage.md`

## Completion

When coverage target reached, output: TESTS_COMPLETE
```

## State File

The `state.json` file tracks loop execution:

```json
{
  "active": true,
  "loop_name": "my-task",
  "started_at": "2024-01-15T10:30:00Z",
  "iteration": 5,
  "max_iterations": 20,
  "completion_promise": "TASK_COMPLETE"
}
```

When stopped:

```json
{
  "active": false,
  "loop_name": "my-task",
  "started_at": "2024-01-15T10:30:00Z",
  "stopped_at": "2024-01-15T11:45:00Z",
  "iteration": 12,
  "max_iterations": 20,
  "completion_promise": "TASK_COMPLETE",
  "stopped_reason": "completed"
}
```

## Tips

1. **Be Specific**: Clear instructions lead to better results
2. **Track Progress**: Have loops update a report file for visibility
3. **Set Limits**: Use `max-iterations` to prevent runaway loops
4. **Use Completion Promises**: Define clear completion conditions
5. **Iterate Small**: Each iteration should do a focused piece of work
6. **Add to .gitignore**: Add `.groundhog/state.json` to your project's `.gitignore` to avoid committing loop state

## Requirements

- Claude Code CLI
- `jq` (JSON processor) - usually pre-installed on macOS/Linux
- Bash shell

## Troubleshooting

**Loop not starting?**
- Check that `.groundhog/loops/<name>.md` exists
- Verify YAML frontmatter is valid

**Loop stopped unexpectedly?**
- Check `.groundhog/state.json` for `stopped_reason`
- May have hit `max-iterations` limit

**Hook errors?**
- Ensure `jq` is installed: `brew install jq` or `apt install jq`
- Check hook script is executable: `chmod +x scripts/stop-hook.sh`

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

Contributions welcome! Please open an issue or PR on GitHub.

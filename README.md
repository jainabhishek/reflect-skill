# Reflect Skill

A self-improving skill for Claude Code that learns from your corrections and remembers them across sessions.

**Correct Claude once, never again.**

## What It Does

When you correct Claude ("No, always use `const` not `let`" or "Never commit directly to main"), Reflect extracts these learnings and saves them to skill files. Next session, Claude automatically applies what it learned.

## Installation

```bash
/plugin add jainabhishek/reflect-skill
```

Or clone and install locally:

```bash
git clone https://github.com/jainabhishek/reflect-skill.git
/plugin add ./reflect-skill
```

## Usage

### Manual Reflection

After a session where you made corrections:

```
/reflect
```

Claude will:
1. Analyze the conversation for corrections and preferences
2. Show you what it learned (categorized by confidence)
3. Ask for approval before saving
4. Update your skill files

### Automatic Reflection

Enable auto-learning on every session end:

```
reflect on      # Enable
reflect off     # Disable
reflect status  # Check current mode
```

### Hook Setup (for automatic mode)

Add to your `.claude/settings.json`:

```json
{
  "hooks": {
    "stop": [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/skills/reflect/scripts/reflect-hook.sh"
      }]
    }]
  }
}
```

## How It Works

1. **Detects signals** - Explicit corrections (HIGH), success patterns (MEDIUM), implied preferences (LOW)
2. **Presents for review** - Shows detected learnings with proposed skill file changes
3. **Persists learnings** - Updates skill files after your approval
4. **Git integration** - Optionally commits changes for version history

## Learning Categories

| Category | Examples |
|----------|----------|
| Code Style | Naming conventions, formatting |
| Security | Input validation, SQL injection checks |
| Testing | Coverage requirements, edge cases |
| API Design | Endpoint conventions, responses |
| UI/UX | Component usage, accessibility |
| Workflow | PR process, commit format |

## Example

```
You: Review the auth module
Claude: [Reviews code]
You: You missed SQL injection - always check for that

You: /reflect

Claude: HIGH: "Always check for SQL injections"

        Proposed for security-review.md:
        + - Validate all database queries for SQL injection

        Accept? [Y/n]

You: Y

Claude: Updated security-review.md
```

Next session: Claude automatically checks for SQL injection.

## License

MIT

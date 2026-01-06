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

## How Continuous Learning Works

Claude doesn't have persistent memory between sessions. Instead, Reflect uses **external memory** through skill files:

```
┌─────────────────────────────────────────────────────────────┐
│                    THE LEARNING LOOP                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   Session 1                                                 │
│   ─────────                                                 │
│   You: "Review auth code"                                   │
│   Claude: [misses SQL injection]                            │
│   You: "Always check for SQL injection!"  ◄── CORRECTION   │
│   You: "/reflect"                                           │
│        │                                                    │
│        ▼                                                    │
│   ┌────────────────────────────┐                            │
│   │ ~/.claude/skills/          │                            │
│   │   security.md              │ ◄── SKILL FILE UPDATED     │
│   │   + Check for SQL injection│                            │
│   └────────────────────────────┘                            │
│                                                             │
│   Session 2 (NEW SESSION)                                   │
│   ───────────────────────                                   │
│   Claude loads skills at startup ◄── READS SKILL FILES     │
│        │                                                    │
│        ▼                                                    │
│   You: "Review auth code"                                   │
│   Claude: [NOW checks for SQL injection automatically]      │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### The Mechanism

| Step | What Happens |
|------|--------------|
| 1. **Correction** | You correct Claude during a session |
| 2. **Extract** | `/reflect` extracts the correction as text |
| 3. **Persist** | Saves to a `.md` skill file on your filesystem |
| 4. **Load** | Next session, Claude reads skill files at startup |
| 5. **Apply** | Claude follows instructions in those files |

### Where Learnings Live

```
~/.claude/skills/
├── code-style.md      # "Use const, not let"
├── security.md        # "Check for SQL injection"
├── workflow.md        # "Never push to main directly"
└── project-x.md       # Project-specific preferences
```

### Important Note

This is **not** model fine-tuning. Reflect works by writing human-readable instructions to files that Claude reads at the start of each session—like building a growing instruction manual that Claude consults every time.

## Signal Detection

Reflect categorizes learnings by confidence:

| Confidence | Source | Examples |
|------------|--------|----------|
| **HIGH** | Explicit corrections | "Never do X", "Always check Y" |
| **MEDIUM** | Success patterns | Approaches that worked after iteration |
| **LOW** | Implied preferences | Patterns to review later |

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

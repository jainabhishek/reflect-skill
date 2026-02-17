# jainabhishek-plugins

A collection of Claude Code plugins for productivity and code quality.

## Plugins

### Reflect

A self-improving skill that learns from your corrections and remembers them across sessions.

**Correct Claude once, never again.**

### PR Review

A comprehensive PR review workflow that runs specialized review agents, verifies issues against the base branch, and implements fixes with your approval. No noise from pre-existing issues.

---

## Installation

Subscribe to the marketplace (one-time):

```bash
/plugin marketplace add jainabhishek/jainabhishek-plugins
```

Then install any plugin:

```bash
/plugin install reflect@jainabhishek-plugins
/plugin install pr-review@jainabhishek-plugins
```

Or install directly without subscribing:

```bash
/plugin add jainabhishek/jainabhishek-plugins
/plugin add jainabhishek/jainabhishek-plugins --plugin pr-review
```

### Local install

```bash
git clone https://github.com/jainabhishek/jainabhishek-plugins.git
/plugin add ./jainabhishek-plugins
```

---

## Reflect

### What It Does

When you correct Claude ("No, always use `const` not `let`" or "Never commit directly to main"), Reflect extracts these learnings and saves them to skill files. Next session, Claude automatically applies what it learned.

### Usage

#### Manual Reflection

After a session where you made corrections:

```
/reflect
```

Claude will:
1. Analyze the conversation for corrections and preferences
2. Show you what it learned (categorized by confidence)
3. Ask for approval before saving
4. Update your skill files

#### Automatic Reflection

Enable auto-learning on every session end:

```
reflect on      # Enable
reflect off     # Disable
reflect status  # Check current mode
```

The session-end hook is **auto-registered** when you install this plugin—no manual setup needed.

### How Continuous Learning Works

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
│   ┌────────────────────────────────┐                        │
│   │ ~/.claude/skills/              │                        │
│   │   security.md                  │ ◄── SKILL FILE UPDATED │
│   │   + Check for SQL injection    │                        │
│   └────────────────────────────────┘                        │
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

### Signal Detection

Reflect categorizes learnings by confidence:

| Confidence | Source | Examples |
|------------|--------|----------|
| **HIGH** | Explicit corrections | "Never do X", "Always check Y" |
| **MEDIUM** | Success patterns | Approaches that worked after iteration |
| **LOW** | Implied preferences | Patterns to review later |

### Learning Categories

| Category | Examples |
|----------|----------|
| Code Style | Naming conventions, formatting |
| Security | Input validation, SQL injection checks |
| Testing | Coverage requirements, edge cases |
| API Design | Endpoint conventions, responses |
| UI/UX | Component usage, accessibility |
| Workflow | PR process, commit format |

### Example

```
You: Review the auth module
Claude: [Reviews code]
You: You missed SQL injection - always check for that

You: /reflect

Claude: Signals Detected:

        HIGH CONFIDENCE:
        - "Always check for SQL injection"

        Proposed Changes to security.md:

        + ## Security
        + - Always validate database queries for SQL injection

        Commit message: "Add SQL injection validation rule"

        Accept changes? [Y/n/edit with natural language]

You: Y

Claude: Updated security.md
        Committed: "Add SQL injection validation rule"
```

Next session: Claude automatically checks for SQL injection.

---

## PR Review

### What It Does

Most review tools flag every issue they find, including problems that existed long before your changes. PR Review cross-references each finding against the base branch so you only see issues **you** introduced. No noise, no false positives from legacy code.

### Usage

```
/pr-review
```

### The Review Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                   THE REVIEW PIPELINE                       │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   1. RUN REVIEW AGENTS                                      │
│   ──────────────────                                        │
│   Parallel agents analyze your uncommitted changes:         │
│                                                             │
│   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐     │
│   │ Quality  │ │ Security │ │  Arch    │ │  Tests   │     │
│   │ - Style  │ │ - OWASP  │ │ - Patt.  │ │ - Gaps   │     │
│   │ - Naming │ │ - Inject │ │ - SoC    │ │ - Edge   │     │
│   │ - Dupes  │ │ - Auth   │ │ - Deps   │ │ - Quality│     │
│   └────┬─────┘ └────┬─────┘ └────┬─────┘ └────┬─────┘     │
│        │             │            │             │            │
│        └──────┬──────┘────────────┘─────────────┘            │
│               ▼                                              │
│   2. VERIFY AGAINST BASE BRANCH                             │
│   ─────────────────────────────                             │
│   For each issue found:                                     │
│   - Exists on base branch? → DISCARD (pre-existing)         │
│   - New in your changes?   → KEEP (real issue)              │
│               │                                              │
│               ▼                                              │
│   3. PRESENT FIX PLAN                                       │
│   ───────────────────                                       │
│   1. [critical] auth.ts:42 - SQL injection risk             │
│   2. [high] api.ts:15 - Missing input validation            │
│   3. [medium] utils.ts:88 - Unused import                   │
│               │                                              │
│               ▼                                              │
│   4. YOUR CALL                                              │
│   ────────────                                              │
│   "all" / "1, 3" / "none" / "all except 2"                 │
│               │                                              │
│               ▼                                              │
│   5. IMPLEMENT & VERIFY                                     │
│   ─────────────────────                                     │
│   Fix → Lint → Build → Re-review → Done                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Review Agents

| Agent | What It Checks |
|-------|---------------|
| **Code Quality** | Style, patterns, anti-patterns, naming, duplication |
| **Security** | Input validation, injection vulnerabilities, auth issues, OWASP top 10 |
| **Architecture** | Pattern compliance, separation of concerns, dependency direction |
| **Tests** | Coverage gaps, missing edge cases, test quality |
| **Comments** | Accuracy, staleness, value of comments |

### Approval Options

| Input | Effect |
|-------|--------|
| `all` | Apply all fixes |
| `1, 3, 5` | Apply only selected fixes |
| `none` | Skip all fixes |
| `all except 2` | Natural language selection |

### How Verification Works

| Step | What Happens |
|------|--------------|
| 1. **Detect base** | Finds `develop`, `main`, or `master` automatically |
| 2. **Compare** | Checks each flagged issue against base branch code |
| 3. **Filter** | Discards anything that already existed before your changes |
| 4. **Report** | Only presents genuinely new issues |

### Example

```
You: /pr-review

Claude: Running review agents on 4 changed files...

        Verified Issues (3 total):

        1. [critical] auth.ts:42 - Unsanitized user input in SQL query
           Why: Direct string interpolation enables SQL injection
           Fix: Use parameterized query

        2. [high] api.ts:15 - Missing rate limiting on login endpoint
           Why: Brute force attacks possible without rate limiting
           Fix: Add rate limiter middleware

        3. [medium] utils.ts:88 - Unused import left after refactor
           Why: Dead code adds confusion
           Fix: Remove unused import

        Which fixes to apply? [all / numbers / none]

You: all

Claude: Applying 3 fixes...
        Running lint... passed
        Running build... passed
        Re-verifying... all issues resolved
```

### Notes

- Reviews are scoped to uncommitted changes only (not the full codebase)
- Base branch detection is automatic but can be overridden
- The workflow is iterative: fix → verify → fix until clean
- All fixes require explicit user approval before implementation

---

## License

MIT

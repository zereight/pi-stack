# pistack Guide (English)

**pistack** is a [pi](https://pi.dev/) extension that ports [Cursor pstack](https://cursor.com/marketplace/cursor/pstack) workflows to the pi TUI.

Use `/poteto-mode`, `/how`, `/tdd`, and the rest of poteto's rigorous engineering skills from pi without copying skill files by hand.

This repo ships the extension and install scripts. Skill content is fetched from upstream [pstack](https://github.com/cursor/plugins/tree/main/pstack) via `scripts/sync-pistack-skills.sh`. **Cursor IDE is not required.**

**Origin:** pstack and `/poteto-mode` are by **[poteto](https://x.com/poteto)** (Lauren Tan). Original article: [How I Use Cursor](https://x.com/poteto/status/2058975157503570132?s=20)


---

## Prerequisites

1. **[pi](https://pi.dev/)** with extension support
2. **git** and **network** on first skills sync (or set `PISTACK_SOURCE_SKILLS`)
3. **`enableSkillCommands: true`** in `~/.pi/agent/settings.json` (or project `.pi/settings.json`)

---

## Install

### One command (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash
```

Installs pi package + fetches pstack skills. No Cursor IDE.

### Option A: `pi install`

**Global** (all projects):

```bash
pi install git:github.com/zereight/pi-stack@main
```

**Project-local** (team shares via `.pi/settings.json`):

```bash
pi install -l git:github.com/zereight/pi-stack@main
```

**Local checkout** (while developing):

```bash
pi install /path/to/pi-stack
# or from inside the repo:
pi install .
```

**Try once** without changing settings:

```bash
pi -e git:github.com/zereight/pi-stack@main
```

### Option B: Shell script

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
chmod +x scripts/*.sh
./scripts/install.sh
```

Symlinks `~/.pi/agent/extensions/pistack` and runs skills sync.

### Option C: Manual symlink

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
./scripts/sync-pistack-skills.sh
ln -sf "$(pwd)/extensions/pistack" ~/.pi/agent/extensions/pistack
```

Project-local:

```bash
mkdir -p .pi/extensions
ln -sf /path/to/pi-stack/extensions/pistack .pi/extensions/pistack
```

---

## Sync pstack skills

Skill files are **not** vendored in git. `pi install` runs `postinstall`, which calls `sync-pistack-skills.sh` automatically.

Manual re-sync:

```bash
# git install path:
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh

# local clone:
./scripts/sync-pistack-skills.sh
```

Skills are sparse-cloned from [cursor/plugins](https://github.com/cursor/plugins) into `~/.pi/agent/cache/pstack-plugins/pstack/skills`.

**Environment variables:**

| Variable | Applies to | Purpose |
|----------|------------|---------|
| `PISTACK_SKILLS_DIR` | Runtime (extension) | Read skills from this path without symlink |
| `PISTACK_SOURCE_SKILLS` | sync script | One-time sync source path |
| `PISTACK_PLUGINS_REPO` | sync script | Override Git repo (default: cursor/plugins) |
| `PISTACK_PLUGINS_REF` | sync script | Git branch or tag (default: main) |
| `PISTACK_SKIP_FETCH` | sync script | Skip GitHub fetch; use cache or env only |
| `PISTACK_GIT_REF` | bootstrap | pi-stack install ref (default: main) |

**Examples:**

```bash
PISTACK_SOURCE_SKILLS=/path/to/pstack/skills ./scripts/sync-pistack-skills.sh
export PISTACK_SKILLS_DIR=/path/to/pstack/skills
PISTACK_PLUGINS_REF=main ./scripts/sync-pistack-skills.sh
PISTACK_SKIP_FETCH=1 ./scripts/sync-pistack-skills.sh
```

---

## Verify

Restart pi (or run `/reload`), then:

```text
/pistack
```

You should see the skills path and the list of workflow commands.

Example task:

```text
/poteto-mode build a small feature behind a flag. verify it really works.
```

If skills are missing:

```bash
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh
```

Then `/reload` in pi.

---

## Shell commands

### `pi install`

Registers pi-stack as a pi package. Runs `postinstall`, which calls `sync-pistack-skills.sh`.

| Command | Purpose |
|---------|---------|
| `pi install git:github.com/zereight/pi-stack@main` | Global install (all projects) |
| `pi install -l git:github.com/zereight/pi-stack@main` | Project-local (`.pi/settings.json`) |
| `pi install /path/to/pi-stack` | Dev install from checkout |
| `pi install .` | Dev install from current directory |
| `pi -e git:github.com/zereight/pi-stack@main` | Try once without changing settings |

**Example (global):**

```bash
pi install git:github.com/zereight/pi-stack@main
```

**Example (team project):**

```bash
cd my-app
pi install -l git:github.com/zereight/pi-stack@main
```

After install, package lives at `~/.pi/agent/git/github.com/zereight/pi-stack/` (global) or `.pi/git/...` (local).

---

### `./scripts/bootstrap.sh`

Wraps `pi install` + skills sync. Use when you want an explicit one-shot flow.

```bash
./scripts/bootstrap.sh              # remote @main
./scripts/bootstrap.sh --ref v0.1.1 # pinned tag
./scripts/bootstrap.sh --local      # from checkout
```

---

### `./scripts/sync-pistack-skills.sh`

Fetches pstack `SKILL.md` trees and symlinks `extensions/pistack/skills`.

| When | Run |
|------|-----|
| First install | Automatic via `postinstall` |
| Skills missing | Manual re-run |
| Offline / custom fork | Set `PISTACK_SOURCE_SKILLS` |

**Example (default GitHub fetch):**

```bash
./scripts/sync-pistack-skills.sh
```

**Example (custom skills directory):**

```bash
PISTACK_SOURCE_SKILLS=/path/to/my-pstack/skills ./scripts/sync-pistack-skills.sh
```

**Example (pin upstream ref):**

```bash
PISTACK_PLUGINS_REF=main ./scripts/sync-pistack-skills.sh
```

**Example (offline, use existing cache only):**

```bash
PISTACK_SKIP_FETCH=1 ./scripts/sync-pistack-skills.sh
```

Skills cache: `~/.pi/agent/cache/pstack-plugins/pstack/skills`

---

### `./scripts/install.sh`

Symlinks extension to `~/.pi/agent/extensions/pistack` and runs sync. Alternative to `pi install` when you prefer manual extension wiring.

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
chmod +x scripts/*.sh
./scripts/install.sh
```

Skip skills sync:

```bash
./scripts/install.sh --skip-skills
```

---

### Environment variables

| Variable | Applies to | Purpose |
|----------|------------|---------|
| `PISTACK_SKILLS_DIR` | Runtime (extension) | Read skills from this path without symlink |
| `PISTACK_SOURCE_SKILLS` | sync script | One-time sync source path |
| `PISTACK_PLUGINS_REPO` | sync script | Override Git repo (default: cursor/plugins) |
| `PISTACK_PLUGINS_REF` | sync script | Git branch or tag (default: main) |
| `PISTACK_SKIP_FETCH` | sync script | Skip GitHub fetch; use cache or env only |
| `PISTACK_GIT_REF` | bootstrap | pi-stack install ref (default: main) |

---

### Package management

```bash
pi list                              # show installed packages
pi remove ../../Documents/pi-stack     # use path from pi list
pi update --extensions               # pull git packages
```

---

## Pi TUI slash commands

Type these inside pi after install. Each command injects the matching pstack `SKILL.md` as a user message.

**Default entry point:** `/poteto-mode` for almost all engineering tasks.

### Quick reference

| pi command | Purpose | When |
|------------|---------|------|
| `/poteto-mode` | Rigorous playbooks (bug, feature, perf, investigation, …) | Non-trivial tasks that need verification |
| `/how` | Subsystem walkthrough | Before changing code: "how does this run?" |
| `/why` | Design history and rationale (MCP: git/issues/docs) | "Why was it built this way?" |
| `/tdd` | Failing test first, minimal fix | Bugs reproducible with unit tests |
| `/architect` | Module boundaries, types, data shape | Cross-file or cross-layer changes |
| `/interrogate` | Multi-model adversarial review | High-risk PRs before merge |
| `/arena` | Parallel attempts, best-of merge | Compare multiple approaches |
| `/unslop` | Plain, non-AI prose | README, PR text, user-facing copy |
| `/figure-it-out` | Custom rigorous playbook | Tasks that fit no bundled playbook |
| `/show-me-your-work` | Decision trail (TSV) | Long or autonomous runs, handoffs |
| `/automate-me` | Draft your own `-mode` skill | Repeated personal patterns |
| `/reflect` | Encode lessons into skills/playbooks | After large tasks |
| `/pistack` | List commands and skills path | Install check, `NOT FOUND` debug |

Principle skills: `/skill:principle-<name>` when not shadowed by global skills. Full upstream usage: [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack).

---

### `/poteto-mode`

**Purpose:** Meta-orchestrator. Picks a playbook (bug fix, feature, perf, investigation, …), applies engineering principles, routes to other skills.

**When:** Any non-trivial task where you want rigor and verification.

```text
/poteto-mode this pr has a subtle bug where scroll drifts every 750ms even when idle. repro first, then fix and verify.
```

```text
/poteto-mode build a small feature behind a feature flag. verify it really works.
```

```text
/poteto-mode i'm going to bed. land the stack even if ci flakes. i want everything merged by morning.
```

---

### `/how`

**Purpose:** Explain how a subsystem works. Architecture walkthrough before you change code.

**When:** "How does X work?", onboarding, tracing a code path.

```text
/how how does run cancellation work? trace the full path and flag any N+1 queries.
```

```text
/how walk me through the auth middleware stack from request to session.
```

---

### `/why`

**Purpose:** Why something was built this way. Uses MCP sources when available (git, issues, docs).

**When:** Design rationale, regression history, "was this intentional?"

```text
/why why do we batch these writes instead of flushing on every keystroke?
```

```text
/why was this flag defaulting to false? check git history and linked issues.
```

---

### `/tdd`

**Purpose:** Failing test first, then minimal fix. Red-green-refactor.

**When:** Bug with a cheap local test path; behavior you can assert in a unit test.

```text
/tdd the parser drops trailing newlines. write a failing test, then fix.
```

```text
/tdd edge case: empty input should return null, not throw. test first.
```

---

### `/architect`

**Purpose:** Set types and module boundaries before code crosses a function boundary.

**When:** New feature touching multiple files; refactor with unclear ownership.

```text
/architect we're adding export to PDF. sketch modules, types, and data flow before coding.
```

```text
/architect split this god-module into feature vs adapter layers. propose boundaries.
```

---

### `/interrogate`

**Purpose:** Multi-model adversarial review of a plan, PR, or design.

**When:** High-stakes change; you want stress-testing before merge.

```text
/interrogate review this PR for correctness, security, and missing edge cases.
```

```text
/interrogate stress-test this migration plan. what breaks at scale?
```

---

### `/arena`

**Purpose:** N parallel attempts at the same problem, then merge the best parts.

**When:** Unclear best approach; compare implementations.

```text
/arena build two prototypes of the markdown renderer so we can compare. spawn an agent for each.
```

```text
/arena try three caching strategies for this endpoint. summarize tradeoffs.
```

---

### `/unslop`

**Purpose:** Strip AI writing patterns from prose or comments.

**When:** Docs, PR descriptions, user-facing copy sound generic or over-engineered.

```text
/unslop rewrite this README section. short sentences, no filler.
```

```text
/unslop clean up these error messages so they sound like a human wrote them.
```

---

### `/figure-it-out`

**Purpose:** Custom rigorous playbook when no bundled playbook fits.

**When:** Unusual one-off task that still needs structure and verification.

```text
/figure-it-out open source these skills as a plugin. nothing internal leaks, work in a temp dir, show dependency graph first.
```

---

### `/show-me-your-work`

**Purpose:** Decision trail (TSV) for long or autonomous runs.

**When:** Handoff, audit, "trust but verify" overnight work.

```text
/show-me-your-work log major decisions as you refactor the billing module.
```

---

### `/automate-me`

**Purpose:** Draft a personal `-mode` skill from how you work.

**When:** You have a repeated style and want a custom mode on top of pstack.

```text
/automate-me mine my recent sessions and draft a tao-mode skill.
```

---

### `/reflect`

**Purpose:** Capture lessons from a long session into skill improvements.

**When:** After a big task; update your playbook recipes.

```text
/reflect what should we encode in a skill so we don't repeat today's mistakes?
```

---

### `/pistack`

**Purpose:** Diagnostic. Lists workflow commands and resolved skills path.

**When:** Verify install; debug "skills not found".

```text
/pistack
```

Expected output includes `skills: /path/to/.../skills` (not `NOT FOUND`).

---

### Principle skills

When not shadowed by global skills in `~/.pi/agent/skills`:

```text
/skill:principle-prove-it-works
/skill:principle-laziness-protocol
```

Use `/pistack` to see which principle skills are available.

---

Then `/reload` in pi.

---

## How it works

```text
pi TUI slash command (/poteto-mode)
        │
        ▼
pistack extension (extensions/pistack/index.ts)
        │
        ├─ reads pstack SKILL.md from:
        │    extensions/pistack/skills  (symlink)
        │    PISTACK_SKILLS_DIR
        │    ~/.pi/agent/cache/pstack-plugins/pstack/skills
        │
        └─ injects skill block as user message → agent runs playbook
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `pistack: no skills dir` | Run `./scripts/sync-pistack-skills.sh` (needs git + network first time) |
| Slash commands missing | Check `enableSkillCommands: true`; restart pi or `/reload` |
| Skill name collision | Global `~/.pi/agent/skills/<name>` shadows pstack. pistack `/tdd` still injects pstack inline |
| `pi install` works but no skills | Run sync manually; check git/network or set `PISTACK_SOURCE_SKILLS` |

---

## pi-cursor + Cursor SDK

When pi runs with `defaultProvider: cursor`:

- Callable tools = **Cursor SDK tools only**
- pistack **slash commands** and **skill discovery** still work
- Other pi extension **tools** (memory, harness, …) do not run on the cursor path

[pi-cursor](https://github.com/zereight/pi-cursor) also ships a copy of this extension. **pi-stack** is the standalone home for pistack.

---

## Related

| Project | Role |
|---------|------|
| [pi-stack](https://github.com/zereight/pi-stack) | This repo |
| [pstack](https://cursor.com/marketplace/cursor/pstack) | Upstream skill content |
| [pi-cursor](https://github.com/zereight/pi-cursor) | Pi + Cursor SDK profile |

## License

MIT — see [`LICENSE`](../../LICENSE). pstack skill content remains MIT by [poteto](https://x.com/poteto) (Lauren Tan) / Cursor.

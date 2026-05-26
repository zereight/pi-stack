# Command Reference

Shell commands install pistack and fetch pstack skills. Pi TUI slash commands run those skills inside pi.

**Cursor IDE is not required.** Skills come from [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack) via `scripts/sync-pistack-skills.sh`.

---

## One-line install (recommended)

Installs the pi package and fetches skills in one step.

```bash
curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash
```

Pinned version:

```bash
PISTACK_GIT_REF=v0.1.1 curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash
```

From a local clone:

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
chmod +x scripts/*.sh
./scripts/bootstrap.sh --local
```

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

## Verify install

```text
/pistack
/poteto-mode echo smoke test — confirm skill block loads
```

If skills are missing:

```bash
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh
```

Then `/reload` in pi.

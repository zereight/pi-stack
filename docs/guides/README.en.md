# pistack Guide (English)

**pistack** is a [pi](https://pi.dev/) extension that ports [Cursor pstack](https://cursor.com/marketplace/cursor/pstack) workflows to the pi TUI.

Use `/poteto-mode`, `/how`, `/tdd`, and the rest of poteto's rigorous engineering skills from pi without copying skill files by hand.

This repo ships the extension and install scripts. Skill content is fetched from upstream [pstack](https://github.com/cursor/plugins/tree/main/pstack) via `scripts/sync-pistack-skills.sh`. **Cursor IDE is not required.**

**Origin:** pstack and `/poteto-mode` are by **[poteto](https://x.com/poteto)** (Lauren Tan). Original article: [How I Use Cursor](https://x.com/poteto/status/2058975157503570132?s=20)

**Command reference (install + slash commands with examples):** [docs/COMMANDS.md](../COMMANDS.md)

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

**Overrides:**

```bash
# one-time sync from a custom directory
PISTACK_SOURCE_SKILLS=/path/to/pstack/skills ./scripts/sync-pistack-skills.sh

# runtime override (no symlink needed)
export PISTACK_SKILLS_DIR=/path/to/pstack/skills
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

---

## Commands

See **[docs/COMMANDS.md](../COMMANDS.md)** for full install commands, environment variables, and every slash command with examples.

| pi command | Purpose |
|------------|---------|
| `/poteto-mode` | Default entry point — rigorous playbooks (bug fix, feature, perf, …) |
| `/how` | Subsystem walkthrough |
| `/why` | History and rationale (MCP-backed when available) |
| `/tdd` | Failing test first, then fix |
| `/architect` | Cross-boundary design before coding |
| `/interrogate` | Multi-model adversarial review |
| `/arena` | Parallel attempts, best-of merge |
| `/unslop` | Plain, non-AI prose |
| `/figure-it-out` | Custom rigorous playbook |
| `/show-me-your-work` | Decision trail (TSV) |
| `/automate-me` | Draft your own `-mode` skill |
| `/reflect` | Capture lessons into skills |
| `/pistack` | List commands and skills path |

Principle skills: `/skill:principle-<name>` when not shadowed by global skills.

Full pstack usage: [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)

---

## Example prompts

```text
/poteto-mode this pr has a subtle bug where scroll drifts every 750ms even when idle. repro first, then fix and verify.

/poteto-mode a big list takes a second or two to load even though we virtualize. run a cpu trace and tell me why.

/poteto-mode build two prototypes of the markdown renderer so we can compare. spawn an agent for each.

/how do we cancel runs? is there an N+1 when we look up every run to cancel?
```

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

## Manage packages

```bash
pi list
pi remove ../../Documents/pi-stack   # use the source path from pi list
pi update --extensions
```

---

## Related

| Project | Role |
|---------|------|
| [pi-stack](https://github.com/zereight/pi-stack) | This repo |
| [pstack](https://cursor.com/marketplace/cursor/pstack) | Upstream skill content |
| [pi-cursor](https://github.com/zereight/pi-cursor) | Pi + Cursor SDK profile |

## License

MIT — see [`LICENSE`](../../LICENSE). pstack skill content remains MIT by [poteto](https://x.com/poteto) (Lauren Tan) / Cursor.

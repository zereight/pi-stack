# pistack (pi extension)

**pistack** is a pi extension that ports [Cursor pstack](https://cursor.com/marketplace/cursor/pstack) workflows to native pi:

- `resources_discover` → loads pstack `SKILL.md` trees into pi
- Short slash commands (`/how`, `/tdd`, `/poteto-mode`, …) → inject pstack skill content inline

This is **not** a Cursor plugin install. It is for pi TUI and pi providers that load extensions.

Skill content stays upstream MIT pstack. This repo only wires paths and slash commands.

**Origin:** [poteto](https://x.com/poteto) (Lauren Tan) created pstack and `/poteto-mode`. [How I Use Cursor](https://x.com/poteto/status/2058975157503570132?s=20)

**Full guides:** [English](../../docs/guides/README.en.md) · [한국어](../../docs/guides/README.ko.md) · [简体中文](../../docs/guides/README.zh-CN.md)

## Prerequisites

- [pi](https://pi.dev/) with extension support
- pstack skill files from Cursor plugin cache or `PISTACK_SKILLS_DIR`

## Quick install

**With pi package manager (recommended):**

```bash
pi install git:github.com/zereight/pi-stack@main
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh
```

Project-local: `pi install -l git:github.com/zereight/pi-stack@main`

**With install script:**

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
chmod +x scripts/*.sh
./scripts/install.sh
```

Restart pi, then run `/pistack` to confirm the skills path.

## Manual install

### 1. Sync skills (required once)

```bash
./scripts/sync-pistack-skills.sh
```

Symlinks `extensions/pistack/skills` → latest Cursor pstack plugin cache (`~/.cursor/plugins/cache/cursor-public/pstack/<version>/skills`).

Requires pstack installed in Cursor once (`/add-plugin pstack`) so the cache exists.

Override source:

```bash
PISTACK_SOURCE_SKILLS=/path/to/pstack/skills ./scripts/sync-pistack-skills.sh
```

Or point the extension at skills at runtime:

```bash
export PISTACK_SKILLS_DIR=/path/to/pstack/skills
```

### 2. Enable the extension

**Global (recommended)**

```bash
ln -sf /path/to/pi-stack/extensions/pistack ~/.pi/agent/extensions/pistack
```

Ensure `~/.pi/agent/settings.json` has:

```json
{
  "enableSkillCommands": true
}
```

Auto-discovery loads extensions under `~/.pi/agent/extensions/`. Restart pi, then `/reload` if already running.

**Project-local**

```bash
mkdir -p .pi/extensions
ln -sf /path/to/pi-stack/extensions/pistack .pi/extensions/pistack
```

See [`examples/project/.pi/settings.json`](../../examples/project/.pi/settings.json).

## Usage

| Command | Maps to |
|---------|---------|
| `/poteto-mode …` | Rigorous engineering playbooks (default entry point) |
| `/how …` | Subsystem walkthrough |
| `/tdd …` | Failing test first, then fix |
| `/interrogate …` | Multi-model adversarial review |
| `/architect …` | Types and module shape before cross-boundary code |
| `/pistack` | List workflows and skills path |

Principle skills: `/skill:principle-<name>` when not already in `~/.pi/agent/skills`.

Example:

```text
/poteto-mode this pr has a subtle bug where scroll drifts every 750ms even when idle. repro first, then fix and verify.
```

See [pstack README](https://github.com/cursor/plugins/tree/main/pstack) for full usage.

### Skill conflicts

If pi reports collisions:

- **tdd / how / …:** global `~/.pi/agent/skills/<name>` (often addy) shadows pstack. pistack `/tdd` still uses pstack content via inline injection. Remove global symlinks if you want `/skill:tdd` to mean pstack too.

## pi-cursor + Cursor SDK

When pi runs with `defaultProvider: cursor`:

- **Extension slash commands** (`/how`, `/pistack`) and **skill discovery** still work under `~/.pi/agent/extensions/`.
- **Pi custom tools** from other extensions do not run on the cursor provider path.

For full native pi tools plus pistack, use a non-cursor provider or restore the pi-setup extension stack.

## Related

| Project | Role |
|---------|------|
| [pi-stack](https://github.com/zereight/pi-stack) | This repo — pistack extension |
| [pstack](https://cursor.com/marketplace/cursor/pstack) | Upstream Cursor plugin (skill content) |
| [pi-cursor](https://github.com/zereight/pi-cursor) | Pi TUI + Cursor SDK profile (also ships pistack copy) |

## License

pstack upstream is MIT ([cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack)). pistack wiring in this repo is MIT — see root `LICENSE`. Skill content by [poteto](https://x.com/poteto) (Lauren Tan).

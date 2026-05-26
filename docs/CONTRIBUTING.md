# Contributing Guide

Thank you for helping improve pi-stack. This repo is a **thin pi port** of [Cursor pstack](https://cursor.com/marketplace/cursor/pstack). Most skill content belongs upstream; we welcome changes to extension wiring, install UX, and documentation.

## What belongs in this repo

| In scope | Out of scope (upstream) |
|----------|-------------------------|
| `extensions/pistack/index.ts` — slash commands, skill discovery, env resolution | `poteto-mode` playbooks, `/how`, `/tdd` skill bodies |
| `scripts/install.sh`, `scripts/sync-pistack-skills.sh` | Changing pstack engineering principles |
| `package.json` pi manifest | Vendoring full `skills/` trees into git |
| User and maintainer docs | Forking pstack under a different name without attribution |

Skill content is MIT by **[poteto](https://x.com/poteto)** (Lauren Tan). See the [original article](https://x.com/poteto/status/2058975157503570132?s=20).

To change skill behavior, prefer:

1. [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack) upstream, or
2. Your own pstack fork checkout, then point `PISTACK_SKILLS_DIR` / `PISTACK_SOURCE_SKILLS` at it.

## Development setup

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
chmod +x scripts/*.sh
./scripts/sync-pistack-skills.sh   # requires git + network first time
pi install .
```

Ensure `~/.pi/agent/settings.json` includes:

```json
{
  "enableSkillCommands": true
}
```

Reload pi (`/reload`) after extension changes.

### Local iteration without `pi install`

```bash
ln -sf "$(pwd)/extensions/pistack" ~/.pi/agent/extensions/pistack
./scripts/sync-pistack-skills.sh
```

Useful when editing `index.ts` frequently.

## Project layout

```text
extensions/pistack/index.ts   # extension entry (edit here)
scripts/                      # install + skills symlink
docs/guides/                  # EN / KO / ZH-CN user guides
docs/DEPLOYMENT.md            # maintainer releases
docs/CONTRIBUTING.md          # this file
package.json                  # pi package manifest + version
```

## Making changes

### Extension code (`index.ts`)

- Keep the extension **dependency-free** (Node built-ins + `@earendil-works/pi-coding-agent` types only).
- Export helpers (`resolvePistackSkillsDir`, etc.) only when tests or scripts need them.
- New slash commands: add to `PISTACK_WORKFLOW_COMMANDS` and document in guides.
- Error messages should point users at `./scripts/sync-pistack-skills.sh` or `PISTACK_SKILLS_DIR`.

### Scripts

- Shell scripts must stay `set -euo pipefail`.
- Prefer env overrides (`PISTACK_SKILLS_DIR`, `PISTACK_SOURCE_SKILLS`) over hardcoded paths.
- Do not commit generated symlinks under `extensions/pistack/skills`.

### Documentation

User-facing install or command changes require updates to:

- `docs/guides/README.en.md` (required)
- `docs/guides/README.ko.md` and `docs/guides/README.zh-CN.md` (required for user-visible changes)
- Root `README.md` (short hub + links)

Maintainer-only changes go in `docs/DEPLOYMENT.md`.

### Version bumps

Only maintainers bump `package.json` `"version"` at release time. Contributors do not need to bump version in PRs unless asked.

## Testing

There is no automated test suite yet. Manual verification:

```bash
./scripts/sync-pistack-skills.sh
pi install .    # or symlink extension
```

In pi:

```text
/pistack
/poteto-mode <short task>
/how <subsystem question>
```

Verify:

- Skills path resolves (or error message is actionable)
- Slash commands inject skill blocks (agent receives `<skill name="…">` content)
- Agent-busy guard shows warning if you retry while streaming

If you add non-trivial logic to `index.ts`, consider extracting pure functions and adding a small test runner in a follow-up PR.

## Pull request workflow

1. Fork `zereight/pi-stack`
2. Create a focused branch (`fix/sync-error-message`, `feat/typescript-best-practices-command`)
3. Keep PRs small and reviewable
4. Open a PR against `main` with:
   - **What** changed
   - **Why** (user or maintainer problem)
   - **How you tested** (commands run, pi slash output)
5. Link related upstream pstack issues if the change depends on new upstream skills

### Commit messages

Use conventional, imperative English:

```text
Add arena slash command to pistack extension.

Fix sync script when pstack cache has multiple versions.

Document pi install project-local flag in English guide.
```

### Code review expectations

- No vendored pstack skill files in git
- No secrets (`.env`, tokens, keys)
- Attribution preserved for [poteto](https://x.com/poteto) / pstack upstream
- Docs updated when user behavior changes

## Security

Extensions run with full local permissions. Reviewers should check:

- No arbitrary shell execution from untrusted input
- No network calls added without clear justification
- Skill paths only read from configured dirs (bundled symlink, env, agent cache)

Report security issues privately to the repository owner if you find a vulnerability.

## License

Contributions to pi-stack wiring and docs are MIT — see [`LICENSE`](../LICENSE).

pstack skill content remains MIT by poteto / Cursor; do not relicense upstream skill text in this repo.

## Questions

- **User install help:** [docs/guides/README.en.md](guides/README.en.md)
- **Releases:** [docs/DEPLOYMENT.md](DEPLOYMENT.md)
- **Upstream pstack:** [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)

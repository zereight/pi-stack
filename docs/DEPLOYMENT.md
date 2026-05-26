# Deployment Guide

This document is for **maintainers** of [pi-stack](https://github.com/zereight/pi-stack). End users install pistack via `pi install`; they do not need this file.

## What “deploy” means here

pi-stack is distributed as a **pi package** over **git**, not as a hosted service.

| Artifact | Purpose |
|----------|---------|
| `main` branch | Rolling install: `pi install git:github.com/zereight/pi-stack@main` |
| Git tag (`v*.*.*`) | Pinned install: `pi install git:github.com/zereight/pi-stack@v0.1.0` |
| GitHub Release | Release notes + discoverability |

Skill content is **not** deployed from this repo. Users fetch pstack skills from [cursor/plugins](https://github.com/cursor/plugins) via `scripts/sync-pistack-skills.sh` (no Cursor IDE required).

## Prerequisites

- Push access to `zereight/pi-stack`
- [GitHub CLI](https://cli.github.com/) (`gh`) authenticated
- [pi](https://pi.dev/) installed locally for smoke tests
- git and network for skills sync smoke test (or `PISTACK_SOURCE_SKILLS`)

## Release checklist

### 1. Verify the tree

```bash
git status          # clean working tree
git pull origin main
```

Confirm:

- `extensions/pistack/index.ts` loads without syntax errors
- `package.json` `"pi.extensions"` points at `./extensions/pistack/index.ts`
- `package.json` `"version"` matches the tag you are about to create
- `.gitignore` still excludes `extensions/pistack/skills` and `.skills-discover-cache`

### 2. Bump version (if releasing a new version)

Edit `package.json`:

```json
"version": "0.1.1"
```

Commit on `main` before tagging:

```bash
git add package.json
git commit -m "Bump version to 0.1.1."
git push origin main
```

Use [semver](https://semver.org/):

- **Patch** — docs, scripts, extension bugfixes (no API change to slash commands)
- **Minor** — new slash commands, new env vars, backward-compatible behavior
- **Major** — breaking install path, removed commands, renamed package identity

### 3. Tag and push

Tag must match `package.json` version with a `v` prefix:

```bash
git tag v0.1.1
git push origin v0.1.1
```

### 4. Create a GitHub Release

```bash
gh release create v0.1.1 \
  --title "v0.1.1" \
  --notes "$(cat <<'EOF'
## Summary

One-line summary of what changed.

## Install

\`\`\`bash
pi install git:github.com/zereight/pi-stack@v0.1.1
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh
\`\`\`

## Credit

pstack skill content by [poteto](https://x.com/poteto). Original article: https://x.com/poteto/status/2058975157503570132?s=20
EOF
)"
```

Edit the summary and install block before running.

### 5. Smoke test after publish

```bash
pi install git:github.com/zereight/pi-stack@v0.1.1
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh
```

Restart pi (or `/reload`), then:

```text
/pistack
/poteto-mode echo smoke test
```

Expected:

- `/pistack` shows a valid skills path (or a clear error if pstack cache is missing)
- `/poteto-mode` injects the poteto-mode skill block and starts a turn

### 6. Optional: update rolling `@main` users

Users on `@main` pick up changes on next `pi update --extensions` or reinstall. Mention breaking changes in the GitHub Release and in `docs/guides/README.en.md` if needed.

## What we do not deploy from this repo

| Item | Where it lives |
|------|----------------|
| pstack `SKILL.md` trees | [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack) via sparse clone |
| `/poteto-mode` playbook content | Upstream pstack (synced, not vendored) |
| npm tarball | Not published yet (see below) |

Do **not** commit `extensions/pistack/skills` into git.

## npm publish (optional, not active)

`package.json` names the package `@zereight/pi-stack`, but npm publish is **not** part of the current release process.

If npm distribution is added later:

1. Confirm the package name is available on npm
2. Add `files` whitelist in `package.json` (extension + scripts + docs, not `.git`)
3. Run `npm publish --access public` from a clean tag
4. Document `pi install npm:@zereight/pi-stack@<version>` in guides

Until then, treat **git tags + GitHub Releases** as the only supported deployment path.

## Hotfix workflow

1. Fix on `main`
2. Bump patch version
3. Tag `vX.Y.Z+1`
4. GitHub Release with “fix” summary
5. Smoke test pinned install

Do not retag an existing release. Create a new patch version instead.

## Rollback

There is no runtime to roll back. Users pin versions with git refs:

```bash
pi install git:github.com/zereight/pi-stack@v0.1.0
```

If a bad release shipped, publish a patch release and mark the bad tag as deprecated in the GitHub Release notes.

## Related docs

- [User guide (English)](guides/README.en.md)
- [Contributing](CONTRIBUTING.md)

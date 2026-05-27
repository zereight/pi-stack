# pi-stack

**pistack** brings [pstack](https://github.com/cursor/plugins/tree/main/pstack) workflows to native [pi](https://pi.dev/) TUI.

Use `/poteto-mode`, `/how`, `/tdd`, and the rest of poteto's rigorous engineering skills from pi. **No Cursor IDE required.**

## Origin

pstack skill content and `/poteto-mode` workflows are by **[poteto](https://x.com/poteto)** (Lauren Tan), Cursor React core team.

Read the original article: [How I Use Cursor](https://x.com/poteto/status/2058975157503570132?s=20)

pi-stack ports those workflows to pi. Skill content is fetched from upstream [pstack](https://github.com/cursor/plugins/tree/main/pstack).

## Guides

Each guide covers install, shell commands, environment variables, pi slash commands, troubleshooting, and architecture.

| Language | Document |
|----------|----------|
| English | [docs/guides/README.en.md](docs/guides/README.en.md) |
| 한국어 | [docs/guides/README.ko.md](docs/guides/README.ko.md) |
| 简体中文 | [docs/guides/README.zh-CN.md](docs/guides/README.zh-CN.md) |

## Quick start (one command)

```bash
curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash
```

Or with `pi install` (skills sync runs via `postinstall`):

```bash
pi install git:github.com/zereight/pi-stack@main
```

Prerequisites: [pi](https://pi.dev/), git, network on first sync, `"enableSkillCommands": true` in settings.

Restart pi, then:

```text
/pistack
/poteto-mode build a small feature behind a flag. verify it really works.
```

See the [English guide](docs/guides/README.en.md) for every command and example.

## Maintainers

| Document | Audience |
|----------|----------|
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) | Release tags, GitHub Releases, smoke tests |
| [docs/CONTRIBUTING.md](docs/CONTRIBUTING.md) | Development setup, PR workflow, scope |

## Repository layout

```text
pi-stack/
├── docs/
│   ├── DEPLOYMENT.md
│   ├── CONTRIBUTING.md
│   └── guides/           # EN / KO / ZH-CN user guides (one doc per language)
├── extensions/pistack/
├── scripts/
│   ├── bootstrap.sh      # one-shot install
│   ├── install.sh
│   └── sync-pistack-skills.sh
└── package.json
```

## Related

| Project | Role |
|---------|------|
| [pstack](https://github.com/cursor/plugins/tree/main/pstack) | Upstream skill content |
| [pi-cursor](https://github.com/zereight/pi-cursor) | Pi + Cursor SDK profile |

## License

MIT — see [`LICENSE`](LICENSE). pstack skill content remains MIT by [poteto](https://x.com/poteto) (Lauren Tan) / Cursor.

# pi-stack

**pistack** brings [Cursor pstack](https://cursor.com/marketplace/cursor/pstack) workflows to native [pi](https://pi.dev/) TUI.

Use `/poteto-mode`, `/how`, `/tdd`, and the rest of poteto's rigorous engineering skills from pi without copying skill files by hand.

## Origin

pstack skill content and `/poteto-mode` workflows are by **[poteto](https://x.com/poteto)** (Lauren Tan), Cursor React core team.

Read the original article: [How I Use Cursor](https://x.com/poteto/status/2058975157503570132?s=20)

pi-stack ports those workflows to pi. Skill content stays upstream [pstack](https://cursor.com/marketplace/cursor/pstack).

## Guides

| Language | Document |
|----------|----------|
| English | [docs/guides/README.en.md](docs/guides/README.en.md) |
| 한국어 | [docs/guides/README.ko.md](docs/guides/README.ko.md) |
| 简体中文 | [docs/guides/README.zh-CN.md](docs/guides/README.zh-CN.md) |

## Quick start

```bash
pi install git:github.com/zereight/pi-stack@main
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh
```

Prerequisites: [pi](https://pi.dev/), Cursor `/add-plugin pstack` once, `"enableSkillCommands": true` in settings.

Restart pi, then:

```text
/pistack
/poteto-mode build a small feature behind a flag. verify it really works.
```

See the [English guide](docs/guides/README.en.md) for install options, commands, troubleshooting, and pi-cursor notes.

## Repository layout

```text
pi-stack/
├── docs/guides/          # EN / KO / ZH-CN guides
├── extensions/pistack/   # pi extension
├── scripts/              # install.sh, sync-pistack-skills.sh
├── examples/project/.pi/
└── package.json          # pi package manifest (pi install)
```

## Related

| Project | Role |
|---------|------|
| [pstack](https://cursor.com/marketplace/cursor/pstack) | Upstream skill content |
| [pi-cursor](https://github.com/zereight/pi-cursor) | Pi + Cursor SDK profile |

## License

MIT — see [`LICENSE`](LICENSE). pstack skill content remains MIT by [poteto](https://x.com/poteto) (Lauren Tan) / Cursor.

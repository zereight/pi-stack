# pistack 指南（简体中文）

**pistack** 是一个 [pi](https://pi.dev/) 扩展，将 [Cursor pstack](https://cursor.com/marketplace/cursor/pstack) 工作流移植到 pi TUI。

无需手动复制 skill 文件，即可在 pi 中使用 `/poteto-mode`、`/how`、`/tdd` 等 poteto 的严谨工程 skill。

本仓库只提供扩展和安装脚本。skill 从 upstream [pstack](https://github.com/cursor/plugins/tree/main/pstack) 经 `sync-pistack-skills.sh` 获取。**无需 Cursor IDE。**

**来源：** pstack 与 `/poteto-mode` 原作者为 **[poteto](https://x.com/poteto)**（Lauren Tan）。原文：[How I Use Cursor](https://x.com/poteto/status/2058975157503570132?s=20)

**命令参考（安装 + 斜杠命令 + 示例）：** [COMMANDS.zh-CN.md](COMMANDS.zh-CN.md) · [COMMANDS.md](../COMMANDS.md) (EN)

---

## 前置条件

1. 支持扩展的 **[pi](https://pi.dev/)**
2. **git + 网络**（首次 skill sync，或设置 `PISTACK_SOURCE_SKILLS`）
3. **`enableSkillCommands: true`** — 写入 `~/.pi/agent/settings.json` 或项目 `.pi/settings.json`

---

## 安装

### 一行安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash
```

### 方式 A：`pi install`

**全局**（所有项目）：

```bash
pi install git:github.com/zereight/pi-stack@main
```

**项目本地**（通过 `.pi/settings.json` 与团队共享）：

```bash
pi install -l git:github.com/zereight/pi-stack@main
```

**本地 checkout**（开发时）：

```bash
pi install /path/to/pi-stack
# 或在仓库内：
pi install .
```

**不修改 settings，仅试用一次：**

```bash
pi -e git:github.com/zereight/pi-stack@main
```

### 方式 B：Shell 脚本

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
chmod +x scripts/*.sh
./scripts/install.sh
```

会创建 `~/.pi/agent/extensions/pistack` 符号链接并同步 skills。

### 方式 C：手动符号链接

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
./scripts/sync-pistack-skills.sh
ln -sf "$(pwd)/extensions/pistack" ~/.pi/agent/extensions/pistack
```

项目本地：

```bash
mkdir -p .pi/extensions
ln -sf /path/to/pi-stack/extensions/pistack .pi/extensions/pistack
```

---

## 同步 pstack skills

skill 文件**不包含在 git 中**。安装后需同步一次：

```bash
# git install 路径：
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh

# 本地 clone：
./scripts/sync-pistack-skills.sh
```

skill 文件**不包含在 git 中**。`pi install` 的 `postinstall` 会自动运行 `sync-pistack-skills.sh`。

**路径 override：**

```bash
PISTACK_SOURCE_SKILLS=/path/to/pstack/skills ./scripts/sync-pistack-skills.sh
export PISTACK_SKILLS_DIR=/path/to/pstack/skills
```

---

## 验证

重启 pi（或执行 `/reload`），然后：

```text
/pistack
```

应显示 skills 路径和工作流命令列表。

示例：

```text
/poteto-mode build a small feature behind a flag. verify it really works.
```

---

## 命令

详细说明与示例：**[COMMANDS.zh-CN.md](COMMANDS.zh-CN.md)**

Principle skills：未被全局 skill 覆盖时使用 `/skill:principle-<name>`

完整 pstack 用法：[cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)

---

## 示例 prompt

```text
/poteto-mode this pr has a subtle bug where scroll drifts every 750ms even when idle. repro first, then fix and verify.

/poteto-mode a big list takes a second or two to load even though we virtualize. run a cpu trace and tell me why.

/poteto-mode build two prototypes of the markdown renderer so we can compare. spawn an agent for each.
```

---

## 工作原理

```text
pi TUI 斜杠命令 (/poteto-mode)
        │
        ▼
pistack 扩展 (extensions/pistack/index.ts)
        │
        ├─ 读取 pstack SKILL.md：
        │    extensions/pistack/skills  (symlink)
        │    PISTACK_SKILLS_DIR
        │    ~/.pi/agent/cache/pstack-plugins/pstack/skills
        │
        └─ 将 skill 块注入为 user message → agent 执行 playbook
```

---

## 故障排除

| 问题 | 处理 |
|------|------|
| `pistack: no skills dir` | 运行 `./scripts/sync-pistack-skills.sh`（首次需 git + 网络） |
| 缺少斜杠命令 | 确认 `enableSkillCommands: true`；重启 pi 或 `/reload` |
| skill 名称冲突 | 全局 `~/.pi/agent/skills/<name>` 覆盖 pstack。pistack `/tdd` 仍通过 inline 注入使用 pstack |
| `pi install` 后无 skills | 手动运行 sync；缓存可能尚未存在 |

---

## pi-cursor + Cursor SDK

当 pi 使用 `defaultProvider: cursor` 时：

- 可调用工具 = **仅 Cursor SDK 工具**
- pistack **斜杠命令**与 **skill discovery** 仍可用
- 其他 pi 扩展 **custom tools**（memory、harness 等）在 cursor path 下不可用

[pi-cursor](https://github.com/zereight/pi-cursor) 也包含此扩展副本。**pi-stack** 是 pistack 的独立主仓库。

---

## 包管理

```bash
pi list
pi remove ../../Documents/pi-stack   # 使用 pi list 中的 source 路径
pi update --extensions
```

---

## 相关项目

| 项目 | 角色 |
|------|------|
| [pi-stack](https://github.com/zereight/pi-stack) | 本仓库 |
| [pstack](https://cursor.com/marketplace/cursor/pstack) | upstream skill 内容 |
| [pi-cursor](https://github.com/zereight/pi-cursor) | Pi + Cursor SDK 配置 |

## 许可证

MIT — 见 [`LICENSE`](../../LICENSE)。pstack skill 内容仍为 [poteto](https://x.com/poteto)（Lauren Tan）/ Cursor MIT。

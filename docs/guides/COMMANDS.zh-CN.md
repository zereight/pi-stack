# 命令参考（简体中文）

Shell 命令用于安装 pistack 和下载 pstack skill。pi TUI 斜杠命令在 pi 内执行 skill。

**无需 Cursor IDE。** skill 来自 [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)，经 `sync-pistack-skills.sh` 获取。

英文版：[docs/COMMANDS.md](../COMMANDS.md)

---

## 一行安装（推荐）

一次完成 pi 包安装 + skill 同步。

```bash
curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash
```

固定版本：

```bash
PISTACK_GIT_REF=v0.1.1 curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash
```

本地 clone：

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
chmod +x scripts/*.sh
./scripts/bootstrap.sh --local
```

---

## pi TUI 斜杠命令

在 pi 内输入。每条命令将对应 pstack `SKILL.md` 注入为 user message，agent 按 skill 规则执行。

**默认入口：** 几乎所有工程任务从 `/poteto-mode` 开始。其余命令在 playbook 内自动调用，或需要特定步骤时直接使用。

### 快速参考

| pi 命令 | 用途 | 何时使用 |
|---------|------|----------|
| `/poteto-mode` | 自动选择严谨 playbook（bug、feature、perf、调查等） | 需要验证的非 trivial 任务 |
| `/how` | 子系统 walkthrough | 改代码前："这是怎么运行的？" |
| `/why` | 设计历史与依据（MCP：git/issue/docs） | "为什么这样设计？"、回归原因 |
| `/tdd` | 先写失败测试，再最小 fix | 可用单元测试复现的 bug |
| `/architect` | 模块边界、类型、数据 shape | 跨文件/跨层变更前 |
| `/interrogate` | 多模型 adversarial review | 合并前高风险 PR/设计 |
| `/arena` | N 路并行尝试，best-of 合并 | 方案不明确时对比 |
| `/unslop` | 去除 AI 文风 | README、PR 说明、错误文案 |
| `/figure-it-out` | 自定义严谨 playbook | 现有 playbook 不适用的特殊任务 |
| `/show-me-your-work` | decision trail（TSV） | 长时间/自主运行、交接 |
| `/automate-me` | 生成个人 `-mode` skill | 固定重复的个人风格 |
| `/reflect` | 将经验写入 skill/playbook | 大任务后改进 recipe |
| `/pistack` | 列出命令与 skills 路径 | 安装确认、`NOT FOUND` 调试 |

---

### `/poteto-mode`

**用途：** 元编排器。按任务类型选择 playbook（bug fix、feature、perf、investigation 等 14 种），应用 engineering principle，逐步路由到 `/how`、`/tdd`、`/architect` 等。

**agent 会做什么：** 建 todo → 读 Principles → 执行 playbook 步骤 → 运行时验证 → unslop 回复。

**何时：** bug 修复、功能开发、性能调查、overnight 自主运行等 **几乎所有非 trivial 工作**。

**不必用：** 改一行注释、typo、已有明确答案的简单问题。

**示例 — bug（复现 → fix → verify）：**

```text
/poteto-mode idle 时 scroll 每 750ms drift。先 repro，找 root cause，fix 后 verify。
```

**示例 — feature（flag + 真实验证）：**

```text
/poteto-mode 在 feature flag 后加 export-to-CSV 小功能。验证文件确实生成。
```

**示例 — 性能（baseline → trace → 原因）：**

```text
/poteto-mode 已 virtualize 但列表首屏仍慢 1–2 秒。建 baseline，跑 cpu trace，找瓶颈。
```

**示例 — UI parity（截图对照）：**

```text
/poteto-mode 开 flag 后 row spacing 太宽。第二张图是标准。repro 并 fix 到像素一致。
```

**示例 — 自主运行（overnight）：**

```text
/poteto-mode 我去睡了。CI flake 也要 land stack。早上前要 merge 完。
```

**示例 — 原型对比：**

```text
/poteto-mode 做两个 markdown renderer 原型对比。各 spawn 一个 agent。
```

---

### `/how`

**用途：** 探索代码库，解释子系统 **如何** 工作。资深工程师 onboarding 级 mental model。支持 critique 模式。

**何时：** 修改前理清流程、新人 onboarding、"该放哪一层？"

**不必用：** "为什么这样？" → `/why`。直接写代码 → `/architect` 或 `/poteto-mode`。

**示例 — 运行时路径：**

```text
/how run cancellation 怎么工作？从 API 到 DB 全路径 trace，看有没有 N+1。
```

**示例 — 中间件栈：**

```text
/how 从 request 到 session 确立，walkthrough auth middleware stack。
```

**示例 — 状态管理：**

```text
/how 这屏 optimistic update 失败时如何 rollback。
```

**示例 — critique 模式：**

```text
/how 解释 payment retry 逻辑，并单独指出架构问题。
```

---

### `/why`

**用途：** 收集 **为什么** 这样设计/实现。并行 MCP 查 git、issue、docs、Slack 等。

**何时：** 回归、是 bug 还是设计、flag 默认值、追溯 ADR。

**不必用：** 只需当前行为 → `/how`。

**示例 — 设计意图：**

```text
/why 为什么 batch write 而不是每次 keystroke flush？查 git history 和相关 issue。
```

**示例 — flag 默认值：**

```text
/why 这个 feature flag 默认 false？谁何时改的，给 PR 和 ticket 链接。
```

**示例 — 回归调查：**

```text
/why v2.3 起 latency 升高？对照 suspect commit 和 changelog。
```

**示例 — 产品 vs bug：**

```text
/why 空购物车 checkout 按钮 disabled？设计 spec 和代码哪个是 source of truth？
```

---

### `/tdd`

**用途：** red-green-refactor。**先写失败测试**，再写 **最小 fix** 通过。

**何时：** 单元测试可复现的 bug、清晰的输入输出 contract。

**不必用：** 仅 E2E 可复现的 UI bug、integration test 成本高 → `/poteto-mode` bug fix playbook。

**示例 — 解析器 bug：**

```text
/tdd parser 丢弃 trailing newline。先 failing test，再 fix。
```

**示例 — 边界情况：**

```text
/tdd empty input 应返回 null 而非 throw。test first。
```

**示例 — 回归防护：**

```text
/tdd DST 切换导致日期差一天。加 regression test 并 fix。
```

**示例 — 重构前安全网：**

```text
/tdd extract 前用 characterizing test 固定当前 public API 行为。
```

---

### `/architect`

**用途：** 跨模块边界 **之前** 定类型、data shape、ownership、分层。并行探索设计后选一。

**何时：** 跨包 feature、拆分 god-module、API contract。

**不必用：** 单文件小改、类型已定的 trivial 变更。

**示例 — 新 feature：**

```text
/architect 加 PDF export。先 sketch feature/adapter/infra 层、类型、数据流。
```

**示例 — 拆分 god-module：**

```text
/architect 800 行 service 拆成 feature/adapter。提 boundary，避免 circular dep。
```

**示例 — API 设计：**

```text
/architect webhook retry queue：idempotency key、dead letter、consumer contract 类型先行。
```

**示例 — 迁移：**

```text
/architect REST 迁 gRPC 前：boundary 上 parse 哪些 DTO？
```

---

### `/interrogate`

**用途：** 多模型 **独立** 审查同一对象（PRD、PR、设计），adversarial 找漏洞与反例。

**何时：** 合并前高风险变更、安全敏感逻辑、大规模 migration plan。

**不必用：** trivial diff、本地已充分验证的一行改动。

**示例 — PR review：**

```text
/interrogate 从 correctness、security、edge case stress test 这个 PR。列出被打破的假设。
```

**示例 — migration plan：**

```text
/interrogate 审查 dual-write migration。规模上去哪里会坏？
```

**示例 — auth 变更：**

```text
/interrogate session refresh 变更：token leak、race、logout 场景。
```

**示例 — 数据模型：**

```text
/interrogate FK 改 nullable。现有 query 和 report 会不会坏？
```

---

### `/arena`

**用途：** 同一问题 **N 路并行**，比较 tradeoff，合成 best-of。

**何时：** 两种以上可行方案；renderer/算法/UI 模式选择。

**不必用：** 唯一 obvious fix、时间或 token 紧张。

**示例 — renderer 对比：**

```text
/arena 两个 markdown renderer 原型（AST walk vs streaming）。各 spawn agent，tradeoff 表。
```

**示例 — 缓存策略：**

```text
/arena 此 endpoint：in-memory vs redis vs stale-while-revalidate。各 prototype，比 latency 与复杂度。
```

**示例 — UI layout：**

```text
/arena settings 用 tab vs sidebar vs accordion 三种 mock。含 accessibility 对比。
```

**示例 — 算法：**

```text
/arena dedupe：hash set vs sort vs trie。10 万行 memory/time 估算。
```

---

### `/unslop`

**用途：** 去掉 AI 痕迹（翻译腔、filler、过多 bullet、冗长连接词），改成 **短而 plain 的 prose**。

**何时：** README、PR 描述、release note、面向用户的错误信息、注释。

**不必用：** 改代码逻辑或 API contract。

**示例 — README：**

```text
/unslop 重写安装小节。一句一意，无 filler。
```

**示例 — PR 说明：**

```text
/unslop 这个 PR body。只写改了什么、为什么。去掉 "Additionally"、"Furthermore"。
```

**示例 — 错误信息：**

```text
/unslop 这条 validation error。一行告诉用户下一步做什么。
```

**示例 — 注释：**

```text
/unslop 本文件注释。删掉代码已表达的；只留 non-obvious 的 why。
```

---

### `/figure-it-out`

**用途：** 为 **不适配** bug/feature/perf playbook 的任务设计 **自定义严谨 playbook**。含步骤、验证门、decision trail。

**何时：** 开源整理、大迁移、安全 audit、"从没做过"的项目。

**不必用：** 标准 bug fix 或 feature → `/poteto-mode` 足够。

**示例 — 开源 export：**

```text
/figure-it-out 把 internal skill 导出为 public plugin。无 secret leak，temp dir，先 dependency graph，分步 checklist。
```

**示例 — 下线 legacy：**

```text
/figure-it-out v1 REST API sunset。caller inventory → migrate → delete playbook 与 verify gate。
```

**示例 — compliance：**

```text
/figure-it-out PII logging audit。trace 采集/存储/传输，写 remediation playbook。
```

---

### `/show-me-your-work`

**用途：** 长时/自主任务中 **用 TSV 记录主要决策**。交接、审计、"通宵做了什么"。

**何时：** overnight run、多 PR stack、交给其他 agent 或人。

**不必用：** 五分钟 one-shot fix。

**示例 — refactor trail：**

```text
/show-me-your-work billing refactor：boundary 决策、放弃的方案、verify 结果 TSV。
```

**示例 — migration：**

```text
/show-me-your-work DB migration：每 phase 的 rollback 点与 smoke test 结果。
```

**示例 — 自主运行：**

```text
/show-me-your-work 修 3 个 CI red：尝试的 hypothesis 与 revert 的改动 TSV。
```

---

### `/automate-me`

**用途：** 分析近期 transcript，起草 **`<your-name>-mode` skill**。在 pstack 上叠加个人风格。

**何时：** 重复 prompt 模式、团队 playbook 固化为 skill。

**不必用：** 想替代 poteto-mode（应并存）。

**示例：**

```text
/automate-me 从近两周 session 提取我的 review 习惯，draft tao-mode skill。
```

```text
/automate-me 含 async suffix、Screen postfix 的 bankx-mode 初稿。
```

```text
/automate-me test-mode skill：Given-When-Then，每 test 最多一个 mock。
```

---

### `/reflect`

**用途：** 长 session 后整理 **错误、低效、好模式**，写入 skill/playbook/lint/rule。

**何时：** 大 feature/refactor 后、eval 前、skill 质量迭代。

**示例：**

```text
/reflect agent 今天两次 mis-read 同一文件。skill 加什么能防住？
```

```text
/reflect bug fix 未 repro 就改。如何 tighten playbook step？
```

```text
/reflect PR review 漏了 security check。建议更新 interrogate trigger。
```

---

### `/pistack`

**用途：** **仅诊断。** 列出 workflow 斜杠命令与 **当前 skills 路径**。

**何时：** 安装后确认、`pistack: no skills dir`、principle skill 冲突。

**示例：**

```text
/pistack
```

**期望输出（摘要）：**

```text
pistack (pi port of Cursor pstack)
skills: /Users/you/.pi/agent/cache/pstack-plugins/pstack/skills

Workflows (inline pstack SKILL.md — not shadowed by global skills):
  /how
  /poteto-mode
  ...
```

若 `skills: NOT FOUND`：

```bash
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh
```

pi 内 `/reload` 后再 `/pistack`。

---

### Principle skill

未与全局 skill 冲突时：

```text
/skill:principle-prove-it-works
```

用 `/pistack` 查看可用列表。

---

## 验证安装

```text
/pistack
/poteto-mode smoke test — 确认 skill block 已加载
```

若缺少 skill：

```bash
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh
```

pi 内 `/reload`。

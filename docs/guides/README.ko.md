# pistack 가이드 (한국어)

**pistack**는 [Cursor pstack](https://cursor.com/marketplace/cursor/pstack) 워크플로를 [pi](https://pi.dev/) TUI에서 쓸 수 있게 옮긴 pi 확장입니다.

스킬 파일을 수동으로 복사하지 않고 `/poteto-mode`, `/how`, `/tdd` 등 poteto의 엄밀한 엔지니어링 스킬을 pi에서 바로 쓸 수 있습니다.

이 레포는 확장과 설치 스크립트만 제공합니다. 스킬 본문은 upstream [pstack](https://github.com/cursor/plugins/tree/main/pstack)에서 `sync-pistack-skills.sh`로 가져옵니다. **Cursor IDE는 필요 없습니다.**

**출처:** pstack과 `/poteto-mode`의 원작자는 **[poteto](https://x.com/poteto)** (Lauren Tan)입니다. 원문: [How I Use Cursor](https://x.com/poteto/status/2058975157503570132?s=20)

**명령어 레퍼런스 (설치 + 슬래시 명령 + 예시):** [COMMANDS.ko.md](COMMANDS.ko.md) · [COMMANDS.md](../COMMANDS.md) (EN)

---

## 사전 준비

1. **확장 지원 [pi](https://pi.dev/)**
2. **git + network** (최초 skill sync 시, 또는 `PISTACK_SOURCE_SKILLS` 설정)
3. **`enableSkillCommands: true`** — `~/.pi/agent/settings.json` 또는 프로젝트 `.pi/settings.json`

---

## 설치

### 한 줄 설치 (권장)

```bash
curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash
```

pi 패키지 + skill fetch를 한 번에 처리합니다.

### 방법 A: `pi install`

**전역** (모든 프로젝트):

```bash
pi install git:github.com/zereight/pi-stack@main
```

**프로젝트 로컬** (팀이 `.pi/settings.json`으로 공유):

```bash
pi install -l git:github.com/zereight/pi-stack@main
```

**로컬 checkout** (개발 중):

```bash
pi install /path/to/pi-stack
# 또는 repo 안에서:
pi install .
```

**설정 변경 없이 한 번만 시험:**

```bash
pi -e git:github.com/zereight/pi-stack@main
```

### 방법 B: 셸 스크립트

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
chmod +x scripts/*.sh
./scripts/install.sh
```

`~/.pi/agent/extensions/pistack` 심링크와 skills sync를 실행합니다.

### 방법 C: 수동 심링크

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
./scripts/sync-pistack-skills.sh
ln -sf "$(pwd)/extensions/pistack" ~/.pi/agent/extensions/pistack
```

프로젝트 로컬:

```bash
mkdir -p .pi/extensions
ln -sf /path/to/pi-stack/extensions/pistack .pi/extensions/pistack
```

---

## pstack 스킬 동기화

스킬 파일은 **git에 포함되지 않습니다**. `pi install` 시 `postinstall`이 `sync-pistack-skills.sh`를 자동 실행합니다.

```bash
# git install 경로:
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh

# 로컬 clone:
./scripts/sync-pistack-skills.sh
```

[cursor/plugins](https://github.com/cursor/plugins)에서 sparse clone → `~/.pi/agent/cache/pstack-plugins/pstack/skills`

**경로 override:**

```bash
PISTACK_SOURCE_SKILLS=/path/to/pstack/skills ./scripts/sync-pistack-skills.sh
export PISTACK_SKILLS_DIR=/path/to/pstack/skills
```

---

## 확인

pi를 재시작하거나 `/reload` 후:

```text
/pistack
```

skills 경로와 워크플로 명령 목록이 보이면 성공입니다.

예시:

```text
/poteto-mode 기능 플래그 뒤에 작은 기능을 만들고, 실제로 동작하는지 검증해줘.
```

---

## 명령어

상세 설명과 예시: **[COMMANDS.ko.md](COMMANDS.ko.md)**

| pi 명령 | 용도 |
|---------|------|
| `/poteto-mode` | 기본 진입점 — 엄밀한 playbook (버그 수정, 기능, 성능 등) |
| `/how` | 서브시스템 walkthrough |
| `/why` | 설계 이력·근거 (MCP 사용 가능 시) |
| `/tdd` | 실패 테스트 먼저, 그다음 fix |
| `/architect` | 모듈 경계 넘기 전 설계 |
| `/interrogate` | 다중 모델 adversarial review |
| `/arena` | 병렬 시도 후 best-of 합성 |
| `/unslop` | AI 티 제거, plain prose |
| `/figure-it-out` | 맞춤 rigorous playbook |
| `/show-me-your-work` | decision trail (TSV) |
| `/automate-me` | 나만의 `-mode` 스킬 초안 |
| `/reflect` | 배운 점을 스킬에 반영 |
| `/pistack` | 명령·skills 경로 목록 |

Principle 스킬: 전역 스킬과 겹치지 않을 때 `/skill:principle-<name>`

전체 pstack 사용법: [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)

---

## 예시 프롬프트

```text
/poteto-mode idle 상태인데 750ms마다 scroll이 drift하는 미묘한 버그가 있어. repro 먼저, fix 후 verify.

/poteto-mode virtualize 하는데도 리스트 로딩이 1~2초 걸려. cpu trace 돌려서 원인 알려줘.

/poteto-mode markdown renderer 프로토타입 두 개 만들어서 비교. agent 각각 spawn.
```

---

## 동작 방식

```text
pi TUI 슬래시 명령 (/poteto-mode)
        │
        ▼
pistack 확장 (extensions/pistack/index.ts)
        │
        ├─ pstack SKILL.md 읽기:
        │    extensions/pistack/skills  (symlink)
        │    PISTACK_SKILLS_DIR
        │    ~/.pi/agent/cache/pstack-plugins/pstack/skills
        │
        └─ skill 블록을 user message로 주입 → agent가 playbook 실행
```

---

## 문제 해결

| 증상 | 해결 |
|------|------|
| `pistack: no skills dir` | `./scripts/sync-pistack-skills.sh` 실행 (최초 1회 git + network 필요) |
| 슬래시 명령 없음 | `enableSkillCommands: true` 확인, pi 재시작 또는 `/reload` |
| 스킬 이름 충돌 | `~/.pi/agent/skills/<name>`이 pstack을 가림. pistack `/tdd`는 inline 주입으로 pstack 사용 |
| `pi install` 후 skills 없음 | sync 수동 실행. git/network 확인 또는 `PISTACK_SOURCE_SKILLS` 설정 |

---

## pi-cursor + Cursor SDK

pi가 `defaultProvider: cursor`일 때:

- 호출 가능 도구 = **Cursor SDK 도구만**
- pistack **슬래시 명령**과 **skill discovery**는 동작
- 다른 pi 확장 **custom tools**(memory, harness 등)는 cursor path에서 비활성

[pi-cursor](https://github.com/zereight/pi-cursor)에도 사본이 있습니다. **pi-stack**이 pistack 단독 홈입니다.

---

## 패키지 관리

```bash
pi list
pi remove ../../Documents/pi-stack   # pi list에 나온 source 경로 사용
pi update --extensions
```

---

## 관련 프로젝트

| 프로젝트 | 역할 |
|----------|------|
| [pi-stack](https://github.com/zereight/pi-stack) | 이 레포 |
| [pstack](https://cursor.com/marketplace/cursor/pstack) | upstream 스킬 |
| [pi-cursor](https://github.com/zereight/pi-cursor) | Pi + Cursor SDK 프로필 |

## 라이선스

MIT — [`LICENSE`](../../LICENSE) 참고. pstack 스킬 본문은 [poteto](https://x.com/poteto) (Lauren Tan) / Cursor MIT.

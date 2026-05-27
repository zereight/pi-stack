# pistack 가이드 (한국어)

**pistack**는 [Cursor pstack](https://cursor.com/marketplace/cursor/pstack) 워크플로를 [pi](https://pi.dev/) TUI에서 쓸 수 있게 옮긴 pi 확장입니다.

스킬 파일을 수동으로 복사하지 않고 `/poteto-mode`, `/how`, `/tdd` 등 poteto의 엄밀한 엔지니어링 스킬을 pi에서 바로 쓸 수 있습니다.

이 레포는 확장과 설치 스크립트만 제공합니다. 스킬 본문은 upstream [pstack](https://github.com/cursor/plugins/tree/main/pstack)에서 `sync-pistack-skills.sh`로 가져옵니다. **Cursor IDE는 필요 없습니다.**

**출처:** pstack과 `/poteto-mode`의 원작자는 **[poteto](https://x.com/poteto)** (Lauren Tan)입니다. 원문: [How I Use Cursor](https://x.com/poteto/status/2058975157503570132?s=20)


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

**환경 변수:**

| 변수 | 적용 | 용도 |
|------|------|------|
| `PISTACK_SKILLS_DIR` | runtime (확장) | symlink 없이 이 경로에서 skill 읽기 |
| `PISTACK_SOURCE_SKILLS` | sync | sync 소스 경로 |
| `PISTACK_PLUGINS_REPO` | sync | Git repo override |
| `PISTACK_PLUGINS_REF` | sync | branch/tag |
| `PISTACK_SKIP_FETCH` | sync | GitHub fetch 생략 |
| `PISTACK_GIT_REF` | bootstrap | pi-stack install ref |

**예시:**

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

skill 없으면:

```bash
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh
```

pi에서 `/reload` 후 `/pistack` 재시도.

---


## 셸 명령

### `pi install`

pi-stack을 pi package로 등록합니다. `postinstall`에서 skill sync가 자동 실행됩니다.

| 명령 | 용도 |
|------|------|
| `pi install git:github.com/zereight/pi-stack@main` | 전역 설치 |
| `pi install -l git:github.com/zereight/pi-stack@main` | 프로젝트 로컬 (`.pi/settings.json`) |
| `pi install /path/to/pi-stack` | checkout 개발용 |
| `pi install .` | 현재 디렉터리에서 개발용 |
| `pi -e git:github.com/zereight/pi-stack@main` | settings 변경 없이 한 번만 시험 |

**예시 (전역):**

```bash
pi install git:github.com/zereight/pi-stack@main
```

**예시 (팀 프로젝트):**

```bash
cd my-app
pi install -l git:github.com/zereight/pi-stack@main
```

---

### `./scripts/bootstrap.sh`

`pi install` + skill sync를 묶은 one-shot 설치.

```bash
./scripts/bootstrap.sh              # remote @main
./scripts/bootstrap.sh --ref v0.1.1 # 태그 고정
./scripts/bootstrap.sh --local      # 로컬 checkout
```

---

### `./scripts/sync-pistack-skills.sh`

pstack `SKILL.md`를 받아 `extensions/pistack/skills` symlink를 만듭니다.

| 상황 | 실행 |
|------|------|
| 최초 설치 | `postinstall`에서 자동 |
| skill 없음 | 수동 재실행 |
| 오프라인 / fork | `PISTACK_SOURCE_SKILLS` 설정 |

**예시 (GitHub에서 기본 fetch):**

```bash
./scripts/sync-pistack-skills.sh
```

**예시 (직접 경로 지정):**

```bash
PISTACK_SOURCE_SKILLS=/path/to/pstack/skills ./scripts/sync-pistack-skills.sh
```

**예시 (upstream ref 고정):**

```bash
PISTACK_PLUGINS_REF=main ./scripts/sync-pistack-skills.sh
```

**예시 (오프라인, 캐시만):**

```bash
PISTACK_SKIP_FETCH=1 ./scripts/sync-pistack-skills.sh
```

캐시 경로: `~/.pi/agent/cache/pstack-plugins/pstack/skills`

---

### `./scripts/install.sh`

`~/.pi/agent/extensions/pistack` symlink + sync. `pi install` 대신 수동 wiring할 때.

```bash
./scripts/install.sh
./scripts/install.sh --skip-skills   # skill sync 생략
```

---

### 환경 변수

| 변수 | 적용 | 용도 |
|------|------|------|
| `PISTACK_SKILLS_DIR` | runtime (확장) | symlink 없이 이 경로에서 skill 읽기 |
| `PISTACK_SOURCE_SKILLS` | sync | sync 소스 경로 |
| `PISTACK_PLUGINS_REPO` | sync | Git repo override |
| `PISTACK_PLUGINS_REF` | sync | branch/tag |
| `PISTACK_SKIP_FETCH` | sync | GitHub fetch 생략 |
| `PISTACK_GIT_REF` | bootstrap | pi-stack install ref |

---

## pi TUI 슬래시 명령

pi 안에서 입력합니다. 각 명령은 해당 pstack `SKILL.md`를 user message로 주입합니다.

**기본 진입점:** 거의 모든 작업은 `/poteto-mode`로 시작.

### 빠른 참조

| pi 명령 | 용도 | 언제 |
|---------|------|------|
| `/poteto-mode` | playbook 자동 선택 (버그, 기능, 성능, 조사 등) | 검증이 필요한 비자명 작업 |
| `/how` | 서브시스템 walkthrough | 코드 수정 전: "이게 어떻게 동작해?" |
| `/why` | 설계 이력·근거 (MCP: git/issue/docs) | "왜 이렇게 만들었어?" |
| `/tdd` | 실패 테스트 먼저, 최소 fix | 단위 테스트로 재현 가능한 버그 |
| `/architect` | 모듈 경계, 타입, data shape | 파일/레이어를 넘는 변경 전 |
| `/interrogate` | 다중 모델 adversarial review | 머지 전 고위험 PR |
| `/arena` | N개 병렬 시도, best-of 합성 | 여러 접근 비교 |
| `/unslop` | AI 티 제거 | README, PR 설명, 사용자 문구 |
| `/figure-it-out` | 맞춤 rigorous playbook | 기존 playbook에 안 맞는 작업 |
| `/show-me-your-work` | decision trail (TSV) | 장시간/자율 실행, handoff |
| `/automate-me` | 개인 `-mode` skill 초안 | 반복되는 개인 패턴 |
| `/reflect` | skill/playbook에 교훈 반영 | 큰 작업 후 |
| `/pistack` | 명령·skills 경로 나열 | 설치 확인, `NOT FOUND` 디버그 |

Principle skill: 전역 skill과 겹치지 않을 때 `/skill:principle-<name>`. upstream: [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack).

---

### `/poteto-mode`

**용도:** playbook 자동 선택 (버그, 기능, 성능, 조사 등), 원칙 적용, 다른 skill 라우팅.

**언제:** 검증이 필요한 비자명 작업.

```text
/poteto-mode idle인데 750ms마다 scroll이 drift해. repro 먼저, fix 후 verify.
```

```text
/poteto-mode feature flag 뒤에 작은 기능 만들고, 실제로 동작하는지 검증해줘.
```

---

### `/how`

**용도:** 서브시스템 동작 설명. 코드 수정 전 walkthrough.

```text
/how run cancellation 전체 경로 trace하고 N+1 있는지 봐줘.
```

---

### `/why`

**용도:** 왜 이렇게 만들었는지. MCP로 git/issue/docs 조회 가능.

```text
/why 이 batch write가 왜 필요한지, git history랑 issue도 확인해줘.
```

---

### `/tdd`

**용도:** 실패 테스트 먼저, 최소 fix.

```text
/tdd parser가 trailing newline을 drop해. failing test 먼저, 그다음 fix.
```

---

### `/architect`

**용도:** 모듈 경계·타입을 코드 작성 전에 정리.

```text
/architect PDF export 추가할 건데, 모듈·타입·데이터 흐름 먼저 sketch.
```

---

### `/interrogate`

**용도:** 다중 모델 adversarial review.

```text
/interrogate 이 PR correctness·security·edge case 관점에서 stress test.
```

---

### `/arena`

**용도:** N개 병렬 시도 후 best-of 합성.

```text
/arena markdown renderer 프로토타입 두 개 만들어서 비교. agent 각각 spawn.
```

---

### `/unslop`

**용도:** AI 티 제거 (글, 주석, PR 설명).

```text
/unslop 이 README 섹션 짧은 문장으로 다시 써줘.
```

---

### `/figure-it-out`

**용도:** playbook에 안 맞는 작업용 맞춤 rigorous playbook.

```text
/figure-it-out skill을 오픈소스로 내보내. internal leak 없이 temp dir에서 dependency graph 먼저.
```

---

### `/show-me-your-work`

**용도:** decision trail (TSV). 장시간/자율 작업 handoff.

```text
/show-me-your-work billing refactor하면서 주요 결정 TSV로 남겨줘.
```

---

### `/automate-me`

**용도:** 나만의 `-mode` skill 초안.

```text
/automate-me 최근 세션 패턴으로 tao-mode skill draft.
```

---

### `/reflect`

**용도:** 긴 작업 후 skill/playbook 개선점 반영.

```text
/reflect 오늘 실수 반복 안 하려면 skill에 뭐를 encode해야 해?
```

---

### `/pistack`

**용도:** 진단. 워크플로 목록 + skills 경로.

```text
/pistack
```

`skills: NOT FOUND`면 sync 스크립트 재실행.

---

### Principle skill

전역 skill과 겹치지 않을 때:

```text
/skill:principle-prove-it-works
```

`/pistack`으로 사용 가능 목록 확인.

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

## 관련 프로젝트

| 프로젝트 | 역할 |
|----------|------|
| [pi-stack](https://github.com/zereight/pi-stack) | 이 레포 |
| [pstack](https://cursor.com/marketplace/cursor/pstack) | upstream 스킬 |
| [pi-cursor](https://github.com/zereight/pi-cursor) | Pi + Cursor SDK 프로필 |

## 라이선스

MIT — [`LICENSE`](../../LICENSE) 참고. pstack 스킬 본문은 [poteto](https://x.com/poteto) (Lauren Tan) / Cursor MIT.

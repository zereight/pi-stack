# 명령어 레퍼런스 (한국어)

셸 명령은 pistack 설치와 pstack skill 다운로드용입니다. pi TUI 슬래시 명령은 pi 안에서 skill을 실행합니다.

**Cursor IDE는 필요 없습니다.** skill은 [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack)에서 `sync-pistack-skills.sh`로 가져옵니다.

상세 영문: [docs/COMMANDS.md](../COMMANDS.md)

---

## 한 줄 설치 (권장)

pi 패키지 + skill sync를 한 번에 처리합니다.

```bash
curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash
```

버전 고정:

```bash
PISTACK_GIT_REF=v0.1.1 curl -fsSL https://raw.githubusercontent.com/zereight/pi-stack/main/scripts/bootstrap.sh | bash
```

로컬 clone:

```bash
git clone https://github.com/zereight/pi-stack.git
cd pi-stack
chmod +x scripts/*.sh
./scripts/bootstrap.sh --local
```

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

## 설치 확인

```text
/pistack
/poteto-mode smoke test — skill block 로드 확인
```

skill 없으면:

```bash
bash ~/.pi/agent/git/github.com/zereight/pi-stack/scripts/sync-pistack-skills.sh
```

pi에서 `/reload`.

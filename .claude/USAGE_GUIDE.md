# Claude Code 인프라 사용 가이드

## 구성 요소 및 동작 방식

| 구성 요소 | 동작 방식 | 설명 |
|-----------|----------|------|
| **Hooks** | 자동 | 매 프롬프트/편집마다 백그라운드에서 실행 |
| **Agents** | 수동 | 직접 요청해야 실행 |
| **Commands** | 수동 | `/명령어`로 직접 실행 |
| **Skills** | 반자동 | Hook이 키워드 감지 → Claude가 스킬 자동 로드 |

---

## Hooks (자동)

별도 조작 없이 백그라운드에서 동작합니다.

### skill-activation-prompt

프롬프트에 등록된 키워드가 포함되면 관련 스킬을 Claude에게 자동 추천합니다.

```
나: 스킬 하나 만들고 싶어
→ Hook이 "스킬" 키워드 감지
→ Claude에게 "skill-developer 스킬을 사용하세요" 안내 자동 주입
→ Claude가 스킬 생성 가이드를 따라 안내
```

> `skill-developer`와 `flutter-dev-guidelines` 스킬이 등록되어 있습니다.
> 새 스킬을 만들고 `skill-rules.json`에 키워드를 등록하면 더 많은 상황에서 활성화됩니다.

### post-tool-use-tracker

파일 편집 시 어떤 모듈(`lib/`, `test/` 등)이 변경되었는지 자동 추적합니다.

---

## Agents (수동)

대화 중에 자연어로 요청합니다.

### 사용 가능한 Agents

| Agent | 용도 | 요청 예시 |
|-------|------|----------|
| **code-architecture-reviewer** | 코드 아키텍처 리뷰 | `code-architecture-reviewer agent로 온보딩 코드 리뷰해줘` |
| **code-refactor-master** | 리팩토링 실행 | `code-refactor-master agent로 이 파일 리팩토링해줘` |
| **refactor-planner** | 리팩토링 계획 수립 | `refactor-planner agent로 presentation 레이어 분석해줘` |
| **plan-reviewer** | 개발 계획 검토 | `plan-reviewer agent로 이 계획 검토해줘` |
| **documentation-architect** | 문서 생성 | `documentation-architect agent로 아키텍처 문서 만들어줘` |
| **web-research-specialist** | 기술 리서치 | `web-research-specialist agent로 GoRouter deep linking 조사해줘` |

### Agent 사용 예시

#### 코드 리뷰

```
나: code-architecture-reviewer agent로 오늘 작성한 예약 관련 코드 리뷰해줘
```

→ Clean Architecture 준수 여부, Riverpod 패턴, 에러 핸들링 등을 검토하고 리포트 생성

#### 리팩토링

```
나: refactor-planner agent로 presentation 레이어 분석해줘
→ 현재 구조 분석 및 리팩토링 계획서 생성

나: code-refactor-master agent로 실행해줘
→ 계획대로 파일 이동, import 수정, 위젯 분리 수행
```

#### 디버깅/리서치

```
나: GoRouter에서 중첩 라우트 전환 시 화면이 깜빡이는 문제가 있어.
    web-research-specialist agent로 해결 방법 찾아줘
→ GitHub issues, Stack Overflow, Reddit 등을 검색하여 해결 방법 정리
```

---

## Commands (수동)

슬래시(`/`)로 시작하는 명령어입니다.

### /dev-docs

개발 계획을 체계적으로 문서화합니다.

```
나: /dev-docs 예약 기능 구현
```

`dev/active/[작업명]/` 디렉토리에 3개 파일 생성:

| 파일 | 내용 |
|------|------|
| `*-plan.md` | 전략적 계획서 (현재 상태 분석, 구현 단계, 리스크) |
| `*-context.md` | 핵심 파일, 의사결정, 의존성 |
| `*-tasks.md` | 체크리스트 형식 작업 목록 |

### /dev-docs-update

세션이 길어져서 컨텍스트가 리셋되기 전에 실행합니다.

```
나: /dev-docs-update
```

→ 현재 세션의 진행 상황, 미완료 작업, 다음 단계를 문서에 저장
→ 다음 세션에서 해당 문서를 읽으면 이어서 작업 가능

---

## Skills (반자동)

Hook이 키워드를 감지하면 자동으로 활성화됩니다.

### 현재 등록된 Skills

| Skill | 용도 | 활성화 키워드 |
|-------|------|--------------|
| **flutter-dev-guidelines** | Flutter/Dart 개발 가이드라인 | "화면", "widget", "provider", "repository", "route", "에러 처리" 등 |
| **skill-developer** | 새 스킬 생성/관리 | "스킬 생성", "create skill", "add skill" 등 |

### flutter-dev-guidelines 상세

프로젝트의 실제 코드에서 추출한 Flutter 개발 패턴 가이드입니다.
"화면 만들어줘", "컨트롤러 구현해줘" 같은 요청이나 `lib/` 내 `.dart` 파일 편집 시 자동 활성화됩니다.

**포함된 내용:**

| 리소스 파일 | 내용 |
|------------|------|
| `riverpod-patterns.md` | 프로바이더 타입 선택, 상태 갱신, keepAlive 기준 |
| `widget-patterns.md` | 위젯 타입 선택, 화면 구성 공식, ref.listen, PopScope |
| `data-layer-patterns.md` | Repository, DataSource, Model/Entity 변환, Firestore 규칙 |
| `error-handling.md` | Exception 계층, Either 체이닝, UI 메시지 매핑 |
| `navigation-patterns.md` | GoRouter, SCRoute enum, 인증 리다이렉트 |
| `ui-commons.md` | 공통 위젯, 색상 시스템, 테마, 상수 |

### 새 스킬 추가 방법

1. `.claude/skills/[스킬명]/SKILL.md` 파일 생성
2. `.claude/skills/skill-rules.json`에 트리거 키워드 등록
3. Hook이 해당 키워드를 감지하면 자동 활성화

---

## 추천 워크플로우

### 새 기능 개발

```
1. /dev-docs [기능 설명]                           ← 계획 수립
2. plan-reviewer agent로 검토해줘                   ← 계획 검증
3. 구현 작업 진행                                    ← 평소처럼 코딩
4. code-architecture-reviewer agent로 리뷰해줘      ← 코드 리뷰
5. /dev-docs-update                                ← 세션 종료 전 저장
```

### 리팩토링

```
1. refactor-planner agent로 [대상] 분석해줘         ← 현황 분석
2. plan-reviewer agent로 검토해줘                   ← 계획 검증
3. code-refactor-master agent로 실행해줘            ← 리팩토링 실행
4. code-architecture-reviewer agent로 결과 리뷰해줘  ← 결과 검증
```

### 문제 해결

```
1. web-research-specialist agent로 [문제] 조사해줘  ← 리서치
2. 해결 방법 적용                                    ← 구현
3. /dev-docs-update                                ← 해결 과정 기록
```

---

## 파일 구조

```
.claude/
├── CLAUDE.md                    # 프로젝트 규칙 (Claude가 항상 읽음)
├── USAGE_GUIDE.md               # 이 문서
├── settings.json                # Hook 등록 설정
├── settings.local.json          # 로컬 설정
├── hooks/                       # 자동 실행 스크립트
│   ├── skill-activation-prompt.sh/.ts
│   ├── post-tool-use-tracker.sh
│   ├── package.json
│   └── tsconfig.json
├── agents/                      # Agent 정의 (6개)
│   ├── code-architecture-reviewer.md
│   ├── code-refactor-master.md
│   ├── documentation-architect.md
│   ├── plan-reviewer.md
│   ├── refactor-planner.md
│   └── web-research-specialist.md
├── commands/                    # 슬래시 명령어 (2개)
│   ├── dev-docs.md
│   └── dev-docs-update.md
└── skills/                      # 스킬 (2개)
    ├── skill-rules.json         # 스킬 활성화 규칙
    ├── skill-developer/         # 메타 스킬
    │   ├── SKILL.md
    │   └── *.md (참조 문서들)
    └── flutter-dev-guidelines/  # Flutter 개발 가이드라인
        ├── SKILL.md             # 메인 가이드 (전체 요약)
        └── resources/
            ├── riverpod-patterns.md
            ├── widget-patterns.md
            ├── data-layer-patterns.md
            ├── error-handling.md
            ├── navigation-patterns.md
            └── ui-commons.md
```

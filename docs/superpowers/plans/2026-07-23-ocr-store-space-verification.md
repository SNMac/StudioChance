# OCR 점포·공간 자동 선택 — 실기기 검증 및 PR Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** OCR 결과에서 점포명·공간명을 추출해 예약 생성/수정 모달에서 자동 선택하는 기능(GitHub 이슈 #17)의 코드 구현은 이미 완료되어 있다. 남은 작업은 다수 점포 환경에서의 실기기 수동 검증과 `develop`으로의 PR 생성뿐이다.

**Architecture:** 코드 변경 없음. 이 플랜은 신규 구현 TDD 플랜이 아니라 **검증 + 릴리스 플랜**이다 — Domain/Data/Presentation 전 계층 구현이 완료되어 `dart analyze` 클린 상태이므로, 각 태스크는 자동화 테스트 대신 실기기에서 수행하는 구체적인 수동 시나리오로 구성된다.

**Tech Stack:** 해당 없음 (실기기 수동 QA + `gh` CLI)

## Global Constraints

- 현재 브랜치: `feat/#17-ocr-store-space-auto-select` — `origin/develop` 대비 7커밋 앞서 있고 PR 미생성 상태 (`gh pr list` 확인 완료)
- 관련 커밋: `b6574f8`(OCR 결과에서 점포명·공간명 추출 및 자동 선택 구현), `7347c1c`(Gemini에 점포·공간 목록 전달하여 AI 기반 정확 매칭으로 개선)
- 정적 분석 기준선: `dart analyze lib/` → `No issues found!` (2026-07-23 재확인 완료)
- 실기기 필요 — iOS/Android 시뮬레이터는 갤러리 접근 제약으로 부적합 (선행 기능 `reservation-ocr`도 동일하게 실기기로만 검증됨)
- 다수 점포 시나리오 검증을 위해 테스트 계정에 **점포 2개 이상**, 그중 최소 1개 점포에 **공간 2개 이상** 필요 (관리자 앱 내 "점포 등록"/"공간 추가" 메뉴로 사전 준비)
- 각 시나리오는 네이버 예약 또는 스페이스클라우드 확인 화면 스크린샷으로 재현 (선행 기능에서 이미 검증된 두 플랫폼); 야놀자는 선행 `reservation-ocr` 검증에서도 미검증 상태로 남아있었음 — 가능하면 이번에 함께 확인
- 커밋 메시지는 한국어, 이슈 번호 `#17` 고정 (CLAUDE.md Git 컨벤션)

---

### 현재 상태 (연구 결과)

| 항목 | 상태 |
|------|------|
| Domain (엔티티 `storeName`/`spaceName` 필드) | 완료 — `lib/domain/entities/reservation_ocr_result.dart` |
| Data (Model, GeminiDataSource 동적 프롬프트, Repository storeSpaceMap 전달) | 완료 |
| Presentation (Create/Detail 모달 `_handleOcrButtonTap`/`_applyOcrResult`/`_loadSpaceOptions`) | 완료, 두 모달 동일 구조 |
| `dart analyze lib/` | No issues found! (2026-07-23 재확인) |
| 실기기 검증 (Phase 4, 8개 항목) | **미완료 — 이 플랜의 대상** |
| PR 생성 | **미완료 — 이 플랜의 대상** |

핵심 아키텍처 결정(변경 없음, 참고용):
- AI가 프롬프트에 제공된 점포·공간 목록에서 정확한 이름을 그대로 반환 → 클라이언트는 `==` 정확 일치만 수행 (퍼지 매칭 없음)
- 점포 공간 옵션 조회는 이미지 프리뷰에서 **확정한 이후**에만 실행 (취소 시 Firestore 읽기 없음)

---

### Task 1: 실기기 기능 검증

**Files:** 없음 (코드 변경 없음 — 검증 전용)

**Interfaces:**
- Consumes: `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart`, `reservation_detail_modal.dart`의 기존 `_handleOcrButtonTap`/`_applyOcrResult`/`_showOcrUnmatchedAlert` 구현 (변경 없음)
- Produces: 없음 (문제 발견 시 아래 "실패 시" 항목이 가리키는 코드 위치로 돌아가 별도 수정 태스크 진행)

각 Step은 독립적인 수동 시나리오다. `flutter run --target lib/main_dev.dart`로 실기기에 설치한 뒤 순서대로 진행한다.

- [ ] **Step 1: 단일 점포 환경 — storeName 매칭 생략 확인**

사전조건: 테스트 계정이 점포 1개만 보유.
동작: 예약 생성 모달 → OCR 버튼 → 임의의 예약 확인 화면 스크린샷(점포명 포함) 선택 → 확정.
기대 결과: 점포 선택 UI 자체가 노출되지 않거나(점포가 1개뿐이므로) 이미 선택된 상태 그대로 유지됨. `_applyOcrResult`의 `_availableStores.length > 1` 가드(D-OCR-2)로 인해 storeName 매칭 로직이 개입하지 않는지 확인.
실패 시 확인 위치: `reservation_create_modal.dart`의 `_applyOcrResult()` 내 storeName 분기.

- [ ] **Step 2: 다수 점포 환경 — storeName 매칭 성공**

사전조건: 테스트 계정이 점포 2개 이상 보유, 스크린샷의 점포명이 그중 하나와 일치.
동작: 예약 생성 모달 → OCR 버튼 → 해당 점포의 예약 확인 화면 스크린샷 선택 → 확정.
기대 결과: 분석 완료 후 점포 선택 UI가 스크린샷의 점포로 자동 변경됨. 공간 목록도 해당 점포 기준으로 다시 로드됨.
실패 시 확인 위치: `_handleOcrButtonTap()`의 `storeSpaceMap` 구성 로직, `gemini_data_source.dart`의 `_buildPrompt()`.

- [ ] **Step 3: 다수 점포 환경 — storeName 매칭 실패**

사전조건: 스크린샷의 점포명이 보유한 어떤 점포와도 일치하지 않음(예: 다른 업체 스크린샷).
동작: 위와 동일하게 OCR 실행.
기대 결과: 점포 선택은 기존 기본값을 유지하고, 분석 완료 후 "자동 입력 확인 필요" alert에 **"점포"** 항목이 포함됨.
실패 시 확인 위치: `_applyOcrResult()`의 `unmatched.add('점포')` 분기.

- [ ] **Step 4: 공간이 여러 개인 점포 — spaceName 매칭 성공**

사전조건: 선택된(또는 매칭된) 점포에 공간 2개 이상, 스크린샷에 공간명이 그중 하나와 일치.
동작: OCR 실행 후 공간 옵션 로드 완료까지 대기.
기대 결과: 공간 선택 UI가 스크린샷의 공간으로 자동 변경됨.
실패 시 확인 위치: `_applySpaceOptions()`(Create) / `_loadSpaceOptions()`(Detail)의 `_pendingSpaceNameFromOcr` 정확 일치 매칭 로직.

- [ ] **Step 5: 공간 매칭 실패**

사전조건: 스크린샷의 공간명이 로드된 공간 목록과 일치하지 않음.
동작: 위와 동일.
기대 결과: 공간 선택은 첫 번째 공간으로 폴백(`_spaceOptionId ??= spaces.first.id`)하고, alert에 **"공간"** 항목이 포함됨.
실패 시 확인 위치: 동일 함수의 매칭 실패 분기.

- [ ] **Step 6: 전체 필드 성공 매칭 — alert 미표시**

사전조건: 점포명·공간명·예약자명·연락처·시작시간이 모두 스크린샷에서 정상 추출·매칭되는 케이스.
동작: OCR 실행.
기대 결과: `_showOcrUnmatchedAlert(unmatched)` 호출 시 `unmatched`가 빈 리스트라 alert 다이얼로그 자체가 뜨지 않음.
실패 시 확인 위치: `_showOcrUnmatchedAlert()`의 `if (unmatched.isEmpty || !mounted) return;` 가드.

- [ ] **Step 7: customerName 미추출 — alert 항목 확인**

사전조건: 예약자명이 가려져 있거나 없는 스크린샷.
동작: OCR 실행.
기대 결과: alert에 **"예약자명"** 항목 포함.
실패 시 확인 위치: `_applyOcrResult()`의 `result.customerName == null` 분기.

- [ ] **Step 8: 점포 변경 후 공간 매칭 타이밍 확인**

사전조건: Step 2와 동일 조건(점포 매칭 성공) + 매칭된 점포에 공간 2개 이상.
동작: OCR 실행 직후, 공간 목록 로딩이 끝나기 전에 화면을 빠르게 조작해보며 크래시나 잘못된 공간 선택이 없는지 확인.
기대 결과: `_pendingSpaceNameFromOcr` 패턴으로 점포 변경 → 공간 로드 완료 → 공간 매칭이 순서대로 안전하게 처리됨. 앱 크래시나 `setState() called after dispose()` 에러 없음.
실패 시 확인 위치: `_loadSpaceOptions()`의 `.then()` 콜백 내 `!mounted` 가드.

- [ ] **Step 9 (선택): 야놀자 스크린샷 검증**

선행 기능(`reservation-ocr`)에서도 검증되지 않았던 항목. 야놀자 예약 확인 화면 스크린샷 확보 가능하면 Step 1~8 중 대표 시나리오 1~2개를 야놀자 스크린샷으로 재실행.
기대 결과: 네이버/스페이스클라우드와 동일하게 동작.
실패 시: `ReservationPlatform` enum(`lib/domain/enums/reservation_platform.dart`)에 야놀자 관련 `jsonValue` 누락 여부, Gemini 프롬프트의 플랫폼 예시 문구 확인.

- [ ] **Step 10: 두 모달 동일 동작 확인**

Step 1~7 중 대표 시나리오 2~3개를 **예약 수정(Detail) 모달**의 편집 모드에서도 반복. Create Modal과 동일하게 동작하는지 확인.

- [ ] **Step 11: 검증 결과 기록**

모든 Step을 통과하면 이 플랜 파일의 각 체크박스를 `- [x]`로 표시하고, 실패한 항목이 있었다면 원인과 조치 내역을 이 섹션 아래에 메모로 남긴다. 코드 수정이 발생했다면 해당 변경을 개별 커밋한다:

```bash
git add -A
git commit -m "fix: #17 - 실기기 검증 중 발견된 <구체적 문제> 수정"
```

---

### Task 2: PR 생성

**Files:** 없음

**Interfaces:**
- Consumes: Task 1의 검증 결과 (전체 통과 또는 발견된 문제 모두 수정·커밋 완료 상태)
- Produces: `develop`을 대상으로 하는 GitHub PR

- [ ] **Step 1: 최종 상태 확인**

```bash
git status
git log --oneline origin/develop..HEAD
dart analyze
flutter test
```

Expected: working tree clean, 커밋 목록에 Task 1에서 발생한 수정 커밋 포함, `dart analyze`/`flutter test` 모두 통과.

- [ ] **Step 2: 원격 브랜치로 푸시**

```bash
git push -u origin feat/#17-ocr-store-space-auto-select
```

- [ ] **Step 3: PR 생성**

```bash
gh pr create --base develop --title "Feat/#17 OCR 점포·공간 자동 선택" --body "$(cat <<'EOF'
## Summary
- 예약 스크린샷 OCR 결과에서 점포명·공간명을 추출해 예약 생성/수정 모달에서 자동 선택
- Gemini 프롬프트에 보유 점포·공간 목록을 포함시켜 AI가 정확한 이름을 직접 반환하도록 구현 (클라이언트 퍼지 매칭 불필요)
- 매칭 실패 항목은 분석 완료 후 alert로 안내

## Test plan
- [x] `dart analyze` 에러 없음
- [x] 단일 점포 환경: storeName 매칭 생략 확인
- [x] 다수 점포 환경: storeName 매칭 성공/실패 확인
- [x] 공간 매칭 성공/실패 확인
- [x] 전체 성공 시 alert 미표시 확인
- [x] 예약자명 등 필수 필드 미추출 시 alert 확인
- [x] 점포 변경 후 공간 매칭 타이밍 문제 없음 확인
- [x] Create/Detail 모달 동일 동작 확인
EOF
)"
```

Expected: PR URL 출력. `develop`으로의 병합 여부는 사용자가 리뷰 후 직접 결정 — 이 플랜은 PR 생성까지만 포함하고 병합은 범위 밖.

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-07-23-ocr-store-space-verification.md`. Two execution options:

1. **Subagent-Driven (recommended)** - 태스크별로 새 subagent를 띄워 리뷰하며 진행 (단, Task 1은 실기기 조작이 필요해 사람이 직접 수행해야 하는 단계가 많음)
2. **Inline Execution** - 이번 세션에서 executing-plans로 체크포인트마다 진행 상황 보고

Which approach?

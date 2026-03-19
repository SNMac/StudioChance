# 홈 화면 구현 - 작업 체크리스트

Last Updated: 2026-03-20

## Phase 1~7: 초기 구현 ✅ (완료)
## Phase 8~12: 피드백 1~5차 ✅ (완료)

## Phase 13: 피드백 반영 6차 ✅ (완료 — 일부 추가 수정 필요, Phase 14로 이관)

- [x] **13-3**: `PageView.builder(padEnds: false)` — 오늘 첫 번째 열 표시
- [x] **13-4/5**: `currentTimeTopPosition()` `-6` 제거 — 캡슐 중앙 = 정확한 현재 시간 (추가 미세조정은 14-7)
- [x] **13-6**: GestureDetector 최상위 이동 — 시간 열 포함 전체 핀치 줌 인식
- [x] **13-7**: `monthlyCalendarWeekdayRowHeight = 20`
- [x] **13-8**: 월간 캘린더 `Padding(all: 8)` + `Expanded` 레이아웃
- [x] **13-9**: `selectDateFromMonthly()` 추가 + 월간→3일 animateToPage
- [x] **13-10**: 시간 레이블 `Offset(0, -12)` → `Offset(0, -6)` (추가 조정 필요, 14-3)
- [x] **13-2**: bouncing sync 중 입력 차단 임시 수정 (bouncing 범위 skip) — 완전 해결 필요 (14-2)
- [x] **13-1**: `AnimatedContainer` 200ms 선택 UI 애니메이션 — 추가 수정 필요 (14-4)
- [ ] **13-11**: CurrentTimeLine 날짜별 틀어짐 — Phase 14-2/14-6 수정 후 재검증

---

## Phase 14: 피드백 반영 7차 (다음 세션 구현 예정)

### 아키텍처 변경 (우선순위 높음)

- [ ] **14-1**: 네비바 우측 버튼 기능 변경
  - **현재**: 피커(날짜 선택기) 버튼
  - **변경**: 점포 필터 버튼 (애플 캘린더의 "캘린더 선택"과 유사)
  - 탭 시 사용자가 멤버로 있는 점포 목록 표시 → 어떤 점포의 일정을 볼지 필터링
  - 날짜 피커는 별도 진입점 필요 여부 확인 필요
  - ⚠️ **시각적 크기 확인**: 점포 필터 버튼 아이콘의 **시각적 크기**가 오늘 날짜 버튼(24×24)과 동일한지 확인
    - 터치 영역(44×44)이 아닌 아이콘 자체 크기 기준
    - `home_nav_bar.dart`에서 두 버튼의 아이콘/컨테이너 크기 일치 여부 점검

### 버그 수정 (우선순위 높음)

- [ ] **14-2**: bouncing 효과 전체 날짜 동기화
  - **현재**: 13-2 수정으로 bouncing 중 sync 건너뜀 → 하나의 날짜 열만 늘어짐
  - **원래 동작**: 모든 날짜 열이 함께 bouncing되어야 함
  - **해결 방향**: bouncing 범위(offset < 0 또는 > maxExtent)에서도 sync 허용
    - `_syncAllScrollControllers` + `jumpTo`가 BouncingScrollPhysics에서 음수 offset을 수용하는지 확인
    - `try-catch`로 안전하게 감싸서 bouncing sync 재활성화

- [ ] **14-5**: 네비바 연/월 animateToPage 중 중간값 표시 버그
  - 예: 12월 → 3월 이동 시 네비바에 "12월 → 1월 → 2월 → 3월" 순차 표시
  - **원인**: `monthly_calendar.dart`의 `onPageChanged`가 animateToPage 중 중간 페이지마다 `setDisplayedMonth()` 호출
  - **해결 방향**: `_MonthlyCalendarState`에 `_isAnimating` 플래그 추가
    - `_syncPageToMonth`에서 animateToPage 호출 전 `_isAnimating = true`
    - `animateToPage` 완료(`.then(...)`) 후 `_isAnimating = false`
    - `onPageChanged` 내에서 `if (_isAnimating) return;` 조건 추가

- [ ] **14-6**: 날짜 열 사이 수직 구분선 구조 변경
  - **현재**: `ThreeDayCalendar` Stack의 `Positioned` 오버레이 (고정)
  - **변경**: 각 날짜 `Column`의 오른쪽 Border로 이동
    - `DecoratedBox(decoration: BoxDecoration(border: Border(right: BorderSide(color: separator, width: 0.5))))` 로 각 페이지 Column 래핑
    - Stack의 기존 2개 `Positioned` 구분선 제거
  - **효과**: bouncing 시 날짜 내용과 구분선이 자연스럽게 연동

### UI 수정

- [ ] **14-3**: 시간 라벨과 구분선 수평 정렬 추가 조정 필요
  - `Transform.translate(0, -6)` 적용 후에도 아직 불일치
  - labelSmall(10px) 폰트의 실제 렌더 높이 측정 필요
  - **접근**: `-6`을 텍스트 실제 높이의 절반으로 동적 계산, 또는 값을 `-5`, `-4`로 시도
  - `TextPainter`로 실제 렌더 높이 측정 후 정확한 값 산출 가능

- [ ] **14-4**: 월간 캘린더 선택 UI AnimatedContainer 수정
  - **문제 1**: 선택한 날짜에 먼저 애니메이션이 뜨다가, 이전 날짜에서 새 날짜로 이어지는 순서 오류
    - 원인: `AnimatedContainer`가 셀별 독립 동작 → 새 선택 셀이 이전 셀보다 먼저 rebuild
    - 해결: Provider에서 `previousStartDate`를 추적하여 이전 셀도 동시에 애니메이션 처리
  - **문제 2**: 애니메이션 중간에 코너 radius 없음
    - 원인: 비선택 셀 기본값 `BoxDecoration()` (radius=0) → 선택 시 radius가 0에서 8로 보간
    - **해결**: 비선택 셀도 `BoxDecoration(borderRadius: BorderRadius.circular(8))` 기본값 사용

- [ ] **14-7**: 현재 시간 캡슐 X축 위치 조정
  - **현재**: `Positioned(right: 0, ...)` → 시간 열 오른쪽 끝에 붙음
  - **변경**: 시간 레이블과 수직 정렬되도록 `right: 4` (레이블 우측 패딩과 동일)
  - 파일: `three_day_calendar.dart`의 `CurrentTimeCapsule` Positioned

---

## 최종 검증 (Phase 14 완료 후 재검증)
- [x] 월간 캘린더 overflow 없이 접힘/펼침
- [x] 월간 캘린더 좌우 스와이프 월 이동
- [x] 날짜 이동 시 월간 캘린더 열림/닫힘 상태 유지
- [x] 3일 캘린더 좌우 스와이프 날짜 이동 (1일 단위, 스냅, padEnds:false로 오늘이 왼쪽)
- [x] 3일 캘린더 시간 열 고정, 날짜 열만 스크롤
- [x] picker 완료 버튼에서만 날짜 이동 + animateToPage
- [x] 오늘 날짜 UI: 선택 시 label 사각형 + systemBackground 원 + label 숫자
- [x] 오늘 날짜 UI: 미선택 시 label 원 + systemBackground 숫자
- [x] 다크 모드 색상 정상
- [x] `dart analyze lib/` 에러 없음
- [ ] 현재 시간 캡슐 위치 정확 (14-7)
- [ ] 시간 라벨 & 구분선 Y축 정렬 (14-3)
- [ ] bouncing 시 전체 날짜 동기화 (14-2)
- [ ] 네비바 연/월 animateToPage 중 중간값 없음 (14-5)
- [ ] 날짜 열 구분선 날짜별 소유 구조 (14-6)
- [ ] 점포 필터 버튼 구현 (14-1 — 별도 피처)

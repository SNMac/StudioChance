# 홈 화면 구현 - 작업 체크리스트

Last Updated: 2026-03-19

## Phase 1~7: 초기 구현 ✅ (완료)
- 상수, 상태관리, 탭바, 네비바, 월간 캘린더, 3일 캘린더, HomeScreen 조합 모두 완료

## Phase 8: 피드백 반영 1차 ✅ (완료)
- [x] 8-1: HomeNavBar 플랫폼별 높이 (`Platform.isIOS ? 44 : kToolbarHeight`)
- [x] 8-2: 날짜 picker 플랫폼별 모달 (iOS Cupertino / Android Material)
- [x] 8-3: 월간 캘린더 좌우 PageView (월 단위 스냅, PageController initialPage=10000)
- [x] 8-4: 월간 캘린더 선택 셀 40×40 명확화 (Center > Container 구조)
- [x] 8-5: 월간 캘린더 overflow `mainAxisSize: MainAxisSize.min` 추가
- [x] 8-6: 3일 헤더 수직→수평 레이아웃 (Row, 간격 4)
- [x] 8-7: 3일 캘린더 날짜 열 사이 세로 구분선
- [x] 8-8: 시간 열↔날짜 열 사이 구분선 + 1px gap
- [x] 8-9: 스크롤 `BouncingScrollPhysics()`
- [x] 8-10: 3일 캘린더 헤더 PageView 연속 스크롤+스냅

## Phase 9: 피드백 반영 2차 ✅ (완료)
- [x] 9-1: 요일 헤더 구분선 제거 (`_ThreeDayHeaderPage` 구분선 없음)
- [x] 9-2: 0~1시 높이 - 시간 레이블 `Transform.translate(0, -12)`으로 구분선 위로 이동
- [x] 9-3: 현재 시간 캡슐 `borderRadius(100)`, 텍스트 `height: 1.0`
- [x] 9-4: 월간 캘린더 overflow → `OverflowBox(maxHeight)` 로 근본 해결
- [x] 9-5: 3일 캘린더 좌우 스크롤 → PageView 전체 영역 + shared ScrollController
- [x] 9-6: picker 완료 버튼에서만 날짜 적용 (`StatefulBuilder` + `tempDate`)
- [x] 9-7: 상수 변경 (`monthlyCalendarHeight=260`, `threeDayHeaderHeight=28`)
- [x] 9-8: bouncing 구분선 → `LayoutBuilder` + Positioned 오버레이 (ThreeDayCalendar Stack)
- [x] 9-9: 0시/24시 구분선 제거 (루프 `1..23`으로 변경)

## Phase 10: 피드백 반영 3차 ✅ (완료)
- [x] 10-1: 월간 캘린더 overflow → `OverflowBox` 로 재수정
- [x] 10-2: picker 날짜 선택 후 월간 캘린더 선택 표시 → 이슈 10-7 해결로 자동 해결
- [x] 10-3: 시간 열 구분선 시작 위치 → `top: threeDayHeaderHeight + 0.5` (종일 행부터)
- [x] 10-4: 열 사이 구분선 bouncing 시에도 연속 → LayoutBuilder 오버레이로 처리
- [x] 10-5: 0~1시 영역 넓음 → 레이블 `Transform.translate(0,-12)` 구분선 위로
- [x] 10-6: 현재 시간 캡슐 위치 → `SizedBox(width: timeColumnWidth+0.5-capsuleWidth)` 좌측 여백
- [x] 10-7: 날짜 이동 시 월간 캘린더 상태 유지 → `selectDate`/`goToToday`에서 `isMonthlyCalendarVisible` 변경 제거

## Phase 11: 피드백 반영 4차 ✅ (완료)
- [x] 11-1: 월간 캘린더 날짜 선택 시 3일 캘린더 슬라이드 애니메이션 제거 → `animateToPage` → `jumpToPage`
- [x] 11-2: 피커/오늘 버튼 → 월간 캘린더 표시 월 + 네비바 연/월 미반영 수정
- [x] 11-3: 피커 모달에 grabber 표시 + 끌어내려서 dismiss 지원
- [x] 11-4: 네비바 chevron 크기 12×7, 간격 8 (커스텀 CustomPaint)
- [x] 11-5: 현재 시간 캡슐이 시간 레이블을 가리도록 수직 위치 보정
- [x] 11-6: 월간 캘린더 펼쳤을 때 3일 캘린더와 간격 제거 → 헤더 SizedBox(height: 60) 고정
- [x] 11-7: 오늘 버튼 클릭 시 3일 캘린더 현재 시간 위치로 스크롤
- [x] 11-8: 현재 시간 타이머 딜레이 → 정각에 맞춘 타이머로 교체

## Phase 12: 피드백 반영 5차 (미구현 - 다음 작업)

### 12-1: 애니메이션 정책 수정 ⬜
- **문제**: 11-1에서 모든 `animateToPage`를 `jumpToPage`로 교체했으나, 일부 케이스에는 애니메이션이 필요함
- **올바른 정책**:
  - `jumpToPage` (애니메이션 없음): 월간 캘린더에서 날짜 선택 시
  - `animateToPage` (슬라이드 애니메이션): 오늘 버튼, 피커로 날짜 이동, 3일 캘린더 스크롤 중 월 변경 시 월간 캘린더 PageView 이동
- **수정 대상**: `ThreeDayCalendar`의 `selectedStartDate` listen 분기 처리 + 월간 캘린더 `_syncPageToMonth` 분기 처리
- **아이디어**: `HomeCalendarController`에 날짜 변경 소스를 추적하는 필드 추가 (`DateChangeSource enum`) 또는 별도 트리거 Provider 사용

### 12-2: 월간 캘린더 오늘 날짜 UI ⬜
- **현재**: 오늘 날짜도 선택일과 동일한 label색 둥근 사각형만 표시
- **목표**:
  - 오늘 날짜가 선택된 경우: label색 둥근 사각형 + 그 안에 systemBackground 24×24 원 + 원 안에 숫자(label색)
  - 오늘 날짜가 선택 해제된 경우: label색 24×24 원 + 원 안에 숫자(systemBackground색)
  - 일반 날짜 선택 시: 기존과 동일 (label색 둥근 사각형 + 숫자 systemBackground)
- **수정 대상**: `monthly_calendar_grid.dart` 날짜 셀 렌더링 로직

### 12-3: 네비바 버튼 크기 통일 ⬜
- **현재**: 오늘 날짜 버튼 20×20, 캘린더 피커 버튼 아이콘 크기 미지정
- **목표**: 오늘 날짜 버튼 + 캘린더 피커 버튼 모두 24×24로 통일 (터치 영역 44×44 유지)
- **수정 대상**: `home_nav_bar.dart`

### 12-4: 3일 캘린더 스크롤 방식 변경 ⬜
- **현재**: PageView 1페이지 = 3일, 스크롤 시 3일씩 이동 (예: 20,21,22 → 23,24,25)
- **목표**: PageView 1페이지 = 1일, 뷰포트에 3일 표시 (예: 20,21,22 표시 중 → 스크롤 → 21,22,23)
  - 한 번에 1일씩 이동 (기본)
  - 빠른 스와이프 시 가속도에 따라 여러 날 이동 가능
  - 항상 일(day) 단위로 스냅
- **구현 방식**: `PageView`의 `viewportFraction: 1/3`으로 변경하거나, `ListWheelScrollView` 검토, 또는 커스텀 스크롤 + `SnapScrollPhysics` 구현
  - 권장: `PageController(viewportFraction: 1/3)` + 페이지 기준점을 가운데 날짜로 잡기
  - 대안: 완전 커스텀 (`Scrollable` + `ScrollPhysics` 상속)
- **영향 범위**: `three_day_calendar.dart`, `three_day_header.dart`, `time_grid.dart`, `all_day_row.dart`

### 12-5: 3일 캘린더 좌우 스크롤 레이아웃 구조 변경 ⬜
- **현재**: 시간 열(timeColumn)이 PageView 내부에 포함되어 좌우 스크롤 시 함께 움직임, 구분선도 배경에 오버레이
- **목표**: 시간 열은 고정, 날짜 헤더 + 종일 행 + 시간 그리드 열만 좌우 스크롤, 구분선도 날짜 열 영역 내에 존재
- **구현 방식**:
  ```
  Row
  ├── 고정: 시간 열 (SizedBox, width: timeColumnWidth)  ← 스크롤 안됨
  │   └── 시간 레이블 + (세로) 시간열↔날짜열 구분선
  └── Expanded: 날짜 영역 전체
      └── PageView (3일 뷰, 좌우 스크롤)
          └── Column (per page/day)
              ├── 3일 헤더
              ├── 종일 행
              └── TimeGrid (시간 그리드, 수직 스크롤)
                  └── 시간 구분선 + 열 간 구분선 포함
  ```
- **주의**: 수직 스크롤(sharedScrollController)과 수평 스크롤(PageView) 분리 유지 필요
- **영향 범위**: `three_day_calendar.dart`, `time_grid.dart`, `three_day_header.dart`, `all_day_row.dart`

---

## 최종 검증
- [ ] 월간 캘린더 overflow 없이 접힘/펼침
- [ ] 월간 캘린더 좌우 스와이프 월 이동
- [ ] 날짜 이동 시 월간 캘린더 열림/닫힘 상태 유지
- [ ] 3일 캘린더 좌우 스와이프 날짜 이동 (1일 단위, 스냅)
- [ ] 3일 캘린더 시간 열 고정, 날짜 열만 스크롤
- [ ] 3일 캘린더 세로 구분선: 종일 행부터 bouncing 시에도 연속 (날짜 영역 내)
- [ ] 열 사이 구분선 bouncing 시에도 연속
- [ ] 현재 시간 캡슐 위치, 둥근 모서리, 텍스트 정렬 정상
- [ ] 높이: 월간 캘린더 260, 3일 헤더 28
- [ ] picker 완료 버튼에서만 날짜 이동 + animateToPage
- [ ] 오늘 버튼 → 3일 캘린더 animateToPage + 현재 시간 스크롤
- [ ] 월간 캘린더 날짜 선택 → jumpToPage (애니메이션 없음)
- [ ] 오늘 날짜 UI: 선택 시 label 사각형 + systemBackground 원(24×24) + label 숫자
- [ ] 오늘 날짜 UI: 미선택 시 label 원(24×24) + systemBackground 숫자
- [ ] 0시/24시 구분선 없음, 1~23시 레이블 구분선 위에 표시
- [ ] 다크 모드 색상 정상 표시
- [ ] `dart analyze lib/` 에러 없음

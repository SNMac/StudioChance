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

## Phase 11: 피드백 반영 4차 (진행중)
- [x] 11-1: 월간 캘린더 날짜 선택 시 3일 캘린더 슬라이드 애니메이션 제거 → `animateToPage` → `jumpToPage`
- [x] 11-2: 피커/오늘 버튼 → 월간 캘린더 표시 월 + 네비바 연/월 미반영 수정
- [x] 11-3: 피커 모달에 grabber 표시 + 끌어내려서 dismiss 지원
- [x] 11-4: 네비바 chevron 크기 12×7, 간격 8 (커스텀 CustomPaint)
- [x] 11-5: 현재 시간 캡슐이 시간 레이블을 가리도록 수직 위치 보정
- [x] 11-6: 월간 캘린더 펼쳤을 때 3일 캘린더와 간격 제거 → 헤더 SizedBox(height: 60) 고정
- [x] 11-7: 오늘 버튼 클릭 시 3일 캘린더 현재 시간 위치로 스크롤
- [x] 11-8: 현재 시간 타이머 딜레이 → 정각에 맞춘 타이머로 교체

---

## 최종 검증
- [ ] 월간 캘린더 overflow 없이 접힘/펼침
- [ ] 월간 캘린더 좌우 스와이프 월 이동
- [ ] 날짜 이동 시 월간 캘린더 열림/닫힘 상태 유지
- [ ] 3일 캘린더 좌우 스와이프 날짜 이동 (연속 스크롤 + 스냅)
- [ ] 3일 캘린더 세로 구분선: 종일 행부터 bouncing 시에도 연속
- [ ] 열 사이 구분선 bouncing 시에도 연속
- [ ] 현재 시간 캡슐 위치, 둥근 모서리, 텍스트 정렬 정상
- [ ] 높이: 월간 캘린더 260, 3일 헤더 28
- [ ] picker 완료 버튼에서만 날짜 이동 + 애니메이션
- [ ] 0시/24시 구분선 없음, 1~23시 레이블 구분선 위에 표시
- [ ] 다크 모드 색상 정상 표시
- [ ] `dart analyze lib/` 에러 없음 ✅

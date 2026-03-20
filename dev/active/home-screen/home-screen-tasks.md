# 홈 화면 구현 - 작업 체크리스트

Last Updated: 2026-03-21 (8차)

## Phase 1~19: 완료 ✅

---

## Phase 20: 진행 중 🔧

### 미해결 버그

- [x] **20-1**: 3일 캘린더 날짜별 수직 스크롤 위치 어긋남
  - **근본 원인**: `isInitialized = true`를 `!ctrl.hasClients` 체크 **전**에 설정
    - `hasClients = false`이면 교정 없이 early return, 그러나 `isInitialized = true`는 이미 설정됨
    - 이후 ScrollView가 attach 될 때 `notifyListeners()` 발생 → listener 활성 상태로 진입
    - `ctrl.offset = initialScrollOffset (stale Y)` != `_currentVerticalOffset (Z)` → stale Y로 덮어씀 + 전체 sync
  - **해결**: `postFrameCallback`을 `scheduleInit()` 재귀 함수로 교체
    - `hasClients = false`이면 다음 프레임 재시도 (dispose 시 `containsValue` 체크로 자동 중단)
    - `isInitialized = true`를 교정 완료 **후**에 설정
  - 파일: `three_day_calendar.dart` `_controllerForPage()`

---

## Phase 19: 완료 ✅

### 버그 수정 (크리티컬)

- [x] **19-1**: 수직 스크롤 위치 어긋남 (Critical) 수정
  - **원인**: `_controllerForPage`로 새 컨트롤러 생성 시 `initialScrollOffset: _currentVerticalOffset`로 초기화하지만, 컨트롤러 attach 직후 listener가 stale offset으로 `_currentVerticalOffset`을 덮어쓰고 전체 열을 잘못된 위치로 sync하는 버그
  - **해결**: `isInitialized` 로컬 flag 추가. postFrameCallback에서 true 설정 전까지 listener 무시. attach 후 `_currentVerticalOffset`으로 교정.
  - 파일: `three_day_calendar.dart` `_controllerForPage()`

- [x] **19-2**: 시간열↔날짜열 수직 구분선이 가려져 보이지 않는 문제
  - **원인**: Row 안의 `SizedBox(width: 0.5, child: Column([SizedBox, Expanded(ColoredBox)]))` 방식은 layout 제약 조건에서 취약점 존재
  - **해결**: Row-level SizedBox 완전 제거 → GestureDetector child를 Stack으로 감싸고 `Positioned(left: timeColumnWidth, top: 28.5, bottom: 0, width: 0.5)` overlay로 항상 최상단에 렌더링
  - 파일: `three_day_calendar.dart` build()

- [x] **19-3**: 현재 시간선 위치를 캡슐 right에 맞춰 조정
  - **캡슐**: `right: currentTimeCapsuleRightInset` (= 0.25)
  - **선**: `left: -currentTimeCapsuleRightInset` (= -0.25) → 캡슐 오른쪽 끝에서 선이 시작됨
  - `ui_constants.dart`에 `currentTimeCapsuleRightInset = 0.25` 상수 추가
  - `time_grid.dart` Stack: `clipBehavior: Clip.none` 추가 (선이 0.25px 넘어가는 것 허용)
  - 파일: `ui_constants.dart`, `current_time_indicator.dart`, `time_grid.dart`

---

## Phase 18: 완료 ✅

### 버그 수정 (우선순위 높음)

- [x] **18-1**: 시간열↔날짜열 수직 구분선 시작 위치 재수정
  - **현상**: 종일 영역 바깥(아래)에서 시작. 종일 영역 안쪽(위)부터 시작해야 함
  - **원인**: Phase 17-2에서 구분선을 시간 그리드 Stack 안에 넣음 → allday 이하에서만 렌더링
  - **해결**: 시간 그리드 Stack에서 제거 + Row 레벨에 `SizedBox(width: 0.5)` 컬럼 방식으로 복원 (헤더+헤더구분선 만큼 상단 공백)
  - 파일: `three_day_calendar.dart`

- [x] **18-2**: 날짜 열 구분선이 요일 헤더 영역까지 표시
  - **현상**: DecoratedBox(right border)가 헤더 행 포함 전체 높이에 렌더링
  - **해결**: `DecoratedBox` 제거 → `Stack + Positioned(top: threeDayHeaderHeight + calendarDividerThickness)` 방식
  - 파일: `three_day_calendar.dart` `itemBuilder`

- [x] **18-3**: 오늘 버튼 후 스크롤 → 인접 날짜 스크롤 위치 불일치
  - **현상**: 오늘 버튼 → 살짝 스크롤 → 다음 날짜로 이동 시 스크롤 위치가 맞지 않음
  - **원인**: `animateToPage(300ms)` 진행 중에 `_scrollToCurrentTime()`이 호출됨 → 완료 후 일부 컨트롤러 위치 어긋남
  - **해결**: `selectedStartDate` listen 블록의 `animateToPage.then()` 내부에서 `_scrollToCurrentTime()` 호출
  - 파일: `three_day_calendar.dart` `ref.listen(selectedStartDate)` + `ref.listen(scrollToCurrentTimeTrigger)`

---

## Phase 17: 피드백 반영 (미착수)

### 버그 수정 (우선순위 높음)

- [x] **16-1**: 바운싱 스크롤 전체 날짜 열 동기화
  - **현상**: 맨 위/아래 overscroll 시 해당 날짜 열만 늘어남, 나머지 날짜 열은 정지
  - **원인**: `_controllerForPage` 리스너에서 `offset < 0 || offset > maxExtent` 범위는 sync 완전 차단
    - `jumpTo()`는 범위 밖 값 거부 → 대체 방법 필요
  - **해결 방향**: `ScrollPosition.correctPixels(offset)` + `position.notifyListeners()` 사용
    - `correctPixels`는 bounds 체크 없이 `_pixels` 직접 설정 → 음수/초과 offset도 전파 가능
    - bouncing 중에는 `_currentVerticalOffset` 업데이트 생략 (정상 범위로 돌아올 때 재동기화)
    - `_isSyncing` 플래그로 무한 루프 방지 유지
  - **구현 스케치**:
    ```dart
    ctrl.addListener(() {
      if (_isSyncing || !ctrl.hasClients) return;
      final offset = ctrl.offset;
      if (ctrl.position.hasContentDimensions) {
        final maxExtent = ctrl.position.maxScrollExtent;
        if (offset < 0 || offset > maxExtent) {
          // bouncing 중: correctPixels로 다른 컨트롤러에 전파
          _syncAllScrollControllersBouncing(offset, except: ctrl);
          return; // _currentVerticalOffset 업데이트 생략
        }
      }
      if (offset == _currentVerticalOffset) return;
      _currentVerticalOffset = offset;
      _syncAllScrollControllers(offset, except: ctrl);
    });

    void _syncAllScrollControllersBouncing(double offset, {ScrollController? except}) {
      if (_isSyncing) return;
      _isSyncing = true;
      try {
        for (final ctrl in _dayScrollControllers.values) {
          if (ctrl == except || !ctrl.hasClients) continue;
          try {
            ctrl.position.correctPixels(offset);
            ctrl.position.notifyListeners();
          } catch (_) {}
        }
        // 시간 열은 NeverScrollableScrollPhysics이므로 correctPixels 적용 가능
        if (_timeColumnScrollController.hasClients) {
          try {
            _timeColumnScrollController.position.correctPixels(offset);
            _timeColumnScrollController.position.notifyListeners();
          } catch (_) {}
        }
      } finally {
        _isSyncing = false;
      }
    }
    ```
  - 파일: `three_day_calendar.dart`

- [x] **16-2**: 네비바 chevron 아이콘 비율 수정
  - **현상**: chevron 아이콘이 비율이 깨진 느낌
  - **현재 코드**: `CustomPaint(size: const Size(12, 7))` → 12:7 비율 (≈1.71:1)
  - **분석**:
    - V 형태: (0,0)→(6,7)→(12,0) 또는 (0,7)→(6,0)→(12,7)
    - 각 arm의 각도 = arctan(7/6) ≈ 49° → 양쪽 벌어짐 = ~98° (너무 좁음)
    - 자연스러운 chevron: 각 arm이 수평 대비 ~35~45° → 높이 = 6 * tan(35~45°) ≈ 4.2~6px
    - 또는 `strokeCap.round` 때문에 선 끝에 추가 픽셀이 생겨 실제보다 커 보이는 효과
  - **해결 방향**: 너비 12 유지, 높이 조정
    - 옵션 A: `Size(12, 6)` → 각 arm 45° → 정사각형 비율의 chevron (일반적으로 자연스러움)
    - 옵션 B: `Size(12, 5)` → 더 납작한 느낌 (iOS SF Symbols chevron.down에 가까움)
    - strokeWidth 1.5는 그대로 유지
  - **권장**: 실제 렌더링 확인 후 결정. `Size(12, 6)` 먼저 시도
  - 파일: `home_nav_bar.dart` `_ChevronIcon.build()` → `CustomPaint(size: const Size(12, 7))`

### 버그 수정 (우선순위 높음)

- [x] **17-1**: 날짜 열 구분선 좌우 스크롤 연동 복원
  - **원인**: Phase 15-7의 Stack Positioned 오버레이 방식 → 구분선이 PageView 스크롤과 무관하게 고정
  - **해결**: `DecoratedBox(right border)` 방식으로 복원 + `LayoutBuilder` 제거
  - 파일: `three_day_calendar.dart` (itemBuilder + Positioned 오버레이 2개 제거)

- [x] **17-2 + 17-3**: 시간열↔날짜열 수직 구분선 + 현재 시간 캡슐 (묶어서 수정)
  - **17-2**: 수직 구분선이 요일 헤더 영역 침범 → 종일 영역부터 시작되도록 수정
  - **17-3**: 캡슐이 구분선에 잘림 → 구분선을 시간 열 Stack 내부 Positioned로 이동하고 캡슐보다 먼저 paint
  - **해결**:
    1. Row의 `Container(width: 0.5)` 구분선 제거
    2. 시간 열 Stack에 구분선 추가 (Positioned, right: 0, top: threeDayHeaderHeight + calendarDividerThickness부터 시작):
       ```dart
       // Stack children 순서: 구분선 먼저, 캡슐 나중 → 캡슐이 구분선 위에 렌더링
       Positioned(
         top: 0, bottom: 0, right: 0,
         child: Container(width: calendarDividerThickness, color: context.separator),
       ),
       CurrentTimeCapsule(hourHeight: hourHeight),
       ```
    3. 단, Stack 안의 구분선은 top: 0부터 시작하면 또 헤더 침범 → Stack은 시간 열 Expanded 내부에만 있으므로 헤더/종일 영역은 제외됨 ✅ (Stack = allday 이하 영역)
  - 파일: `three_day_calendar.dart`

### 미착수

- [x] **17-4**: 캘린더 날짜 범위 확장 (2001.01.01 ~ 2100.12.31)
  - `_referenceDate = DateTime(2001, 1, 1)`, `_initialPage = today.difference(referenceDate).inDays`
  - ⚠️ **파생 버그**: `_dateForPage`와 `targetPage` 공식이 구 로직 그대로였음 → Phase 18-4에서 수정

- [x] **18-4**: Phase 17-4 날짜 계산 공식 누락 버그 수정
  - **현상**: 앱 시작 시 3일 캘린더가 2001-01-01부터 표시, 오늘 버튼이 잘못된 날짜(약 2051년)로 이동
  - **원인**: `_dateForPage`: `page - _initialPage` → `page` 로 변경 누락
    - `_dateForPage(_initialPage)` = `2001-01-01 + 0` = `2001-01-01` (오늘이어야 함)
  - **원인2**: `targetPage = _initialPage + delta` → `next.difference(_referenceDate).inDays` 로 변경 누락
    - 오늘 버튼: `delta = _initialPage`, `targetPage = 2 * _initialPage ≈ 18420` (2051년!)
  - **해결**: `_dateForPage(page) = _referenceDate.add(Duration(days: page))`, `targetPage = next.difference(_referenceDate).inDays`
  - 파일: `three_day_calendar.dart` `_dateForPage()`, `ref.listen(selectedStartDate)` 블록

---

## 최종 검증 목록

- [x] 월간 캘린더 overflow 없이 접힘/펼침
- [x] 월간 캘린더 좌우 스와이프 월 이동
- [x] 날짜 이동 시 월간 캘린더 열림/닫힘 상태 유지
- [x] 3일 캘린더 좌우 스와이프 날짜 이동 (1일 단위, 스냅)
- [x] 3일 캘린더 시간 열 고정, 날짜 열만 스크롤
- [x] 네비바 animateToPage 중 중간값 없음 (`_isAnimating` ✅)
- [x] 시간 라벨 & 구분선 Y축 정렬 (`FractionalTranslation` ✅)
- [x] 오늘 날짜 UI 정상
- [x] 다크 모드 색상 정상
- [x] `dart analyze lib/` 에러 없음
- [x] 3일 캘린더 animateToPage 중 monthly 중간 상태 없음 (`_isPageAnimating` ✅)
- [x] 바운싱 스크롤 복원 (15-1) ✅
- [x] GestureDetector → CupertinoButton 교체 (15-6) ✅
- [x] 현재 시간 캡슐과 구분선 사이 갭 제거 (15-3) ✅
- [x] 날짜 열 구분선 틀어짐 없음 (15-7) ✅
- [x] 월간 캘린더 선택 UI 깜빡임 없음 (15-5) ✅
- [x] 바운싱 시 전체 날짜 열 동기화 (16-1) ✅
- [x] 네비바 chevron 비율 (16-2) ✅
- [x] 3일 캘린더 좌우 스크롤 시 날짜 열 구분선도 함께 이동 (17-1) ✅
- [x] 현재 시간 캡슐이 구분선 위에 렌더링 (17-3) ✅
- [x] 시간열↔날짜열 구분선이 종일 영역 안쪽부터 시작 (18-1) ✅
- [x] 날짜 열 구분선이 헤더 행 아래부터 시작 (18-2) ✅
- [x] 오늘 버튼 후 인접 날짜 스크롤 위치 동기화 (18-3) ✅
- [x] 앱 시작 시 오늘 날짜로 시작 (18-4) ✅
- [x] 오늘 버튼이 올바른 날짜로 이동 (18-4) ✅
- [x] 시간열↔날짜열 수직 구분선 항상 가시 (19-2 Positioned overlay) ✅
- [x] 현재 시간선 캡슐 오른쪽 끝과 정렬 (19-3 left: -0.25) ✅
- [x] **날짜별 수직 스크롤 위치 동기화 (20-1)** ✅

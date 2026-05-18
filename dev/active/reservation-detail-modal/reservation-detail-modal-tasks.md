# 예약 확인 모달 — 작업 체크리스트

Last Updated: 2026-05-18 (Phase 21 완료 — DraggableScrollableSheet 제거 + AnimationController 기반 두 detent 구현, 편집 모드 드래그 잠금)

---

## ✅ 완료된 Phase (Phase 1~8 — 기존 읽기 전용 구현)

Phase 1~8은 StatelessWidget 기반 읽기 전용 모달로 완료됨.
**단, Phase 9 이후 재작성으로 일부 로직 재활용, 일부 폐기됨.**

---

## ✅ Phase 9: ReservationDetailModal 재작성 (ConsumerStatefulWidget)

> **선행 이유**: 인라인 편집 모드 지원을 위해 상태 관리 필요
> **대상 파일**: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`

### 9-1: 클래스 변경

- [x] `StatelessWidget` → `ConsumerStatefulWidget`으로 변경
- [x] `scrollController` 파라미터 유지
- [x] `onSaved` 파라미터 추가: `required void Function(Reservation) onSaved`
- [x] `availableStores` 파라미터 추가: `List<StoreSummary>? availableStores`
  - null 시 `[reservation.storeSummary]` fallback

### 9-2: 상태 필드 선언

- [x] `bool _isEditing = false`
- [x] `late StoreSummary _storeSummary`
- [x] `late ReservationStatus _status`
- [x] `late bool _isAllDay`
- [x] `late DateTime _startTime, _endTime`
- [x] `late ReservationPlatform _platform, late PaymentMethod _paymentMethod` (String → enum 전환됨)
- [x] `bool _isStartPickerOpen = false`
- [x] `bool _isEndPickerOpen = false`
- [x] `TextEditingController` 6개 (name, headCount, phone, memo, price, adjustment)

### 9-3: initState / dispose

- [x] `initState`: `widget.reservation` 값으로 모든 상태 초기화
  - `_platform` / `_paymentMethod`: 상수 목록에 없으면 `.first`로 fallback
- [x] `dispose`: 컨트롤러 6개 모두 dispose

### 9-4: _resetFields()

- [x] 편집 취소 시 `widget.reservation` 값으로 모든 상태 재초기화하는 메서드
  - TextEditingController는 `.text = ...` 으로 재설정

### 9-5: 유효성 및 액션

- [x] `bool get _isValid`: 예약자명 non-empty AND headCount > 0 AND (isAllDay OR startTime < endTime)
- [x] `_enterEditMode()`: `setState(() => _isEditing = true)`
- [x] `_cancelEdit()`: 편집 중이면 `_resetFields()` + `setState(() => _isEditing = false)`
  - 읽기 전용 중 취소: `Navigator.pop(context)`
- [x] `_onComplete()`: `reservation.copyWith(...)` + `widget.onSaved(updated)` + `setState(() => _isEditing = false)`
- [x] `_onAllDayChanged(bool)`: 시간 리셋 + 피커 닫기 (편집 모달과 동일 로직)
- [x] `_formatDateTime(DateTime, {bool dateOnly})` 헬퍼 (기존 유지)

---

## ✅ Phase 10: AppBar 모드 전환

- [x] **10-1**: `build()`에서 `_isEditing`에 따라 다른 `ModalAppBar` 렌더
  - 읽기 전용: `leading=취소(pop), title=예약 정보, actions=[편집]`
  - 편집: `leading=취소(_cancelEdit), title=예약 수정, actions=[완료(_isValid?)]`

---

## ✅ Phase 11: 섹션별 이중 빌드 메서드

각 섹션에 `_buildSection*()` + 내부에서 `_isEditing` 분기:

### 11-1: 섹션 1 — 기본 정보

- [x] 읽기: `TitleTextLabel` (점포명, 상태)
- [x] 편집: `TitlePopupButton` (점포 컬러 dot 포함, 상태 선택)

### 11-2: 섹션 2 — 예약자 정보

- [x] 읽기: `TitleTextLabel` x3 + `_ReadOnlyMemo`
- [x] 편집: `TitleTextField` x3 + `MemoTextField`
  - 이름/인원 `onChanged: (_) => setState(() {})` (유효성 재평가)

### 11-3: 섹션 3 — 일시 정보

- [x] 읽기: `TitleSwitchButton(onChanged: null)` + `TitleTextLabel` x2
- [x] 편집: `TitleSwitchButton(onChanged: _onAllDayChanged)` + `TitleDateTimeButton` x2

### 11-4: 섹션 4 — 결제 정보

- [x] 읽기: `TitleTextLabel` x4 (footer 없음)
- [x] 편집: `TitlePopupButton` x2 + `TitleTextField` x2 (footer: '할인인 경우 -[값]을 입력해주세요')

### 11-5: 섹션 5 — 안내문

- [x] 읽기/편집 동일: `TitleNavigationButton` x2 (header 유지)

---

## ✅ Phase 12: showReservationDetailModal 파라미터 업데이트

- [x] `onSaved` 파라미터 추가
- [x] `availableStores` 파라미터 추가 (optional)
- [x] `ReservationDetailModal` 생성 시 새 파라미터 전달
- [x] 호출처 `time_grid.dart` 수정

---

## ✅ Phase 13: ReservationEditModal 처리

- [x] `reservation_edit_modal.dart` → 더 이상 `reservation_detail_modal.dart`에서 호출하지 않음
- [x] `reservation_detail_modal.dart`의 `_onEdit` 메서드 제거
- [x] `reservation_edit_modal.dart` import 제거
- [x] 파일 삭제 여부 검토 (독립 진입점 필요 없으면 삭제)

---

## ✅ Phase 14: dart analyze 통과

- [x] `dart analyze` 오류 없음 확인

---

## Phase 15: 시각적 검증

- [x] **V-1**: 모달 열림 → 읽기 전용 모드, 모든 필드 값 표시
- [x] **V-1b**: 읽기 전용 모드 AppBar leading = '닫기' (일반 굵기)
- [x] **V-2**: '편집' 탭 → 필드가 편집 가능하게 전환 (AppBar도 변경)
- [x] **V-2b**: 편집 모드 AppBar leading = '취소' (일반 굵기)
- [x] **V-3**: 편집 중 '취소' 탭 → 읽기 전용 복귀, 변경 내용 폐기
- [x] **V-4**: 편집 후 '완료' 탭 → 읽기 전용 복귀, 변경 내용 반영
- [x] **V-5**: 하루종일 ON/OFF 동작 확인 (편집 모드)
- [x] **V-6**: 예약 플랫폼/결제 방식 팝업 선택 → 반영
- [x] **V-7**: 다크 모드 양쪽 모드 정상 표시

---

---

## ✅ Phase 16: Reservation Data Layer 단위 테스트 (2026-04-20)

- [x] **16-1**: `test/helpers/fake_data.dart` — 예약 관련 fake 데이터 추가
  - `fakeStoreSummary`, `fakeWriterMemberInfo`, `fakeReservation` (도메인 엔티티)
  - `fakeReservationModel`, `fakeStoreModel`, `fakeUserModel` (데이터 모델)
- [x] **16-2**: `test/data/repositories/reservation_repository_test.dart` 작성 (12개 테스트)
  - MockReservationDataSource, MockStoreDataSource, MockUserDataSource, FakeReservationModel
  - createReservation / getReservationsByDateRange / updateReservation / deleteReservation / updateReservationStatus
- [x] **16-3**: `test/domain/use_cases/reservation_use_case_test.dart` 작성 (14개 테스트)
  - MockReservationRepository, MockUserRepository, FakeReservation
  - writer.user 교체 검증 / currentUid 자동 획득 검증 / repo 위임 검증
- [x] **16-4**: `flutter test` 실행 — 26개 전체 통과 확인
- [x] **16-5**: 테스트 파일 커밋 (commit: `test: #5 - 예약 Repository, UseCase 단위 테스트 추가`)

---

---

## Phase 17: 모드 전환 간 스크롤 위치 보존

> **현상**: 읽기↔편집 전환 시 스크롤이 맨 위로 초기화됨

### 실패한 시도 (7가지)

- [x] ~~시도 1: 명시적 ScrollController 소유~~ → 여전히 초기화됨
- [x] ~~시도 2: postFrameCallback + jumpTo~~ → 1프레임 깜빡임
- [x] ~~시도 3: Opacity(0) + postFrameCallback~~ → 배경색 깜빡임
- [x] ~~시도 4: build()에서 correctPixels 선점~~ → 효과 없음
- [x] ~~**17-A**: ScrollPosition 서브클래스~~ → **실패**
- [x] ~~**17-B**: IndexedStack~~ → **실패** (이론상 되어야 하나 여전히 초기화됨)
- [x] ~~**17-C (iOS)**: Stack + Offstage + 독립 컨트롤러~~ → **iOS는 해결됨**

### ✅ 17-C: iOS 해결 (2026-04-22 완료)

- [x] iOS: `_readOnlyController` + `_editController` 두 개의 독립 ScrollController
- [x] `Stack > [Positioned.fill > Offstage > SingleChildScrollView] x2` 구조
- [x] `_syncScrollPosition(toEdit:)` — setState() 전 오프셋 수동 동기화
- [x] '편집' 버튼, `_onCancelPressed()`, `_onComplete()`에서 sync → setState 순서 보장
- [x] `dart analyze` 통과 확인

### ❌ 17-D: Android — scrollController 파라미터 제거 (2026-04-22 실패)

**시도한 전략**: `scrollController` 파라미터 완전 제거 + iOS와 동일한 Stack+Offstage 구조 통일
**실패 원인**: `DraggableScrollableSheet`의 컨트롤러를 내부 ScrollView에 연결하지 않으면
시트가 60% 초기 높이에서 완전히 펼쳐지지 않음.
`DraggableScrollableSheet`는 내부 ScrollView가 컨트롤러를 사용해야 시트 확장/축소를 조율함.

**현재 코드 상태**: 17-D 변경이 파일에 남아있음 (되돌리지 않고 세션 종료)
→ **다음 세션 시작 시 먼저 17-D 변경 롤백 필요**

롤백 범위:
- `ReservationDetailModal`에 `scrollController` 파라미터 복원
- `initState()`: `widget.scrollController == null`일 때만 컨트롤러 생성
- `dispose()`: nullable `?.dispose()` 복원
- `_syncScrollPosition()`: null 체크 복원
- `_buildScrollArea()`: Android/iOS 분기 복원 (Android: IndexedStack + 외부 컨트롤러)
- `showReservationDetailModal` Android 경로: `scrollController: controller` 전달 복원

### ✅ 17-E: Android — DraggableScrollableSheet 제거 (2026-04-22 완료)

> 17-D 상태에서 `DraggableScrollableSheet`만 제거하면 됨 — `ReservationDetailModal` 자체는 이미 준비된 상태였음.

- [x] `showReservationDetailModal` Android 경로: `DraggableScrollableSheet` → `SizedBox(height: MediaQuery.of(ctx).size.height * 0.9)`
- [x] `dart analyze` 통과 (`No issues found!`)
- [ ] **Android 실기기 검증 필요** — 시뮬레이터에서 scroll jank 관찰됨, 실기기에서 재현 여부 확인 필요

**트레이드오프 수용**: 시트 snap(60%/100%) 없어짐, 모달이 고정 90% 높이로 열림.
스크롤 보존 문제는 플랫폼 공통 Stack+Offstage 구조로 해결됨.

### ⚠️ 17-F: Android scroll jank — 실기기 검증 대기 (2026-04-22)

시뮬레이터에서 scroll jank 관찰됨. 실기기(Android 기기) 검증 전까지 현재 코드(17-E) 유지.

**현상**: Android 시뮬레이터에서 모달 내 스크롤 시 프레임 드랍
**가설**: 시뮬레이터 렌더링 한계일 가능성 (iOS는 해당 없음)
**실기기 검증 후 조치**:
- jank 없으면 → 17-E 현 상태 유지, 작업 완료
- jank 있으면 → `showModalBottomSheet`에 `enableDrag: false` 추가 (gesture 충돌 방지)
  - 닫기: AppBar 버튼, barrier 탭, 백버튼 모두 동작함 (drag-to-dismiss만 제거)

---

## ✅ Phase 19: 안내문 섹션 읽기 전용 전용 + TextActionButton (2026-04-22)

- [x] `TextActionButton` 신규 컴포넌트 생성 (`lib/presentation/commons/widgets/input_form/text_action_button.dart`)
  - 투명 배경 + `systemBlue` + `titleMedium`, 텍스트 중앙 정렬
  - iOS plain text button 스타일
- [x] 섹션 5 (`n번째 예약입니다.` + 안내문 버튼): 읽기 전용 모드 전용으로 변경
  - `_buildEditBody()`에서 `_buildSection5()` 제거
  - `TitleNavigationButton` → `TextActionButton` 교체
- [x] `dart analyze` 통과

---

## ✅ Phase 18: 읽기 전용 '예약 점포' 컬러 dot 표시 (2026-04-22)

- [x] `TitleTextLabel`에 optional `leading: Widget?` 파라미터 추가
  - content 텍스트 앞 우측 정렬 영역에 leading 위젯 표시
  - 기존 `TitleTextLabel` 사용처는 파라미터 없이 그대로 사용 가능
- [x] `_buildSection1ReadOnly()`: `예약 점포` 행에 `store.color.foregroundColorValue` 기반 8×8 원형 dot 전달
- [x] `dart analyze` 통과

---

---

## ✅ Phase 20: 종일 이벤트 일시 표시 수정 (2026-05-02)

> **배경**: 종일 이벤트의 endTime이 iCal 관례상 다음날 자정 → "퇴실 일시: 다음날"로 표시되는 문제.
> **설계 결정**: 행 구조 유지 (입실/퇴실 분리). 타이틀을 "입실 일"/"퇴실 일"로 변경 + endTime 표시 시 -1일 보정.
> 하루짜리 종일 이벤트 → 입실 일 = 퇴실 일 = 이벤트 당일.

### 20-1: `_buildSection3ReadOnly()` — 타이틀 + endTime 표시 수정

- [x] `isAllDay = true`일 때 타이틀: `'입실 일시'` → `'입실 일'`, `'퇴실 일시'` → `'퇴실 일'`
- [x] `퇴실 일` content: `endTime.subtract(const Duration(days: 1))`로 -1일 보정 후 `dateOnly: true` 포맷
- [x] `입실 일` content: 기존과 동일 (`startTime`, `dateOnly: true`)
- [x] 데이터 저장값(`endTime`)은 변경 없음 — 표시 시에만 보정

### 20-2: `_onAllDayChanged(true)` 버그 수정

- [x] 수정: `_endTime`을 `_startTime` 기준으로 설정 (iCal 관례 — 다음날 자정)
  ```dart
  _endTime = DateTime(_startTime.year, _startTime.month, _startTime.day)
      .add(const Duration(days: 1));
  ```

### 20-3: 편집 모드 `_buildSection3Edit()` — 종일 이벤트 picker 수정

- [x] 타이틀: `isAllDay`일 때 `'입실 일시'` → `'입실 일'`, `'퇴실 일시'` → `'퇴실 일'` (읽기 전용과 일치)
- [x] `displayEndTime = _isAllDay ? _endTime.subtract(Duration(days:1)) : _endTime` 로컬 변수 도입
- [x] `퇴실 일` `content`/`initialDateTime`: `displayEndTime` 사용
- [x] `퇴실 일` `onDateTimeChanged`: `isAllDay`면 선택된 날짜에 +1일하여 `_endTime` 저장 (iCal 관례 유지)

### 20-4: `dart analyze` 통과

- [x] `dart analyze lib/.../reservation_detail_modal.dart` → `No issues found!`

---

---

## ✅ Phase 21: iOS/Android 통합 — DraggableScrollableSheet 제거 + AnimationController 기반 구현 (2026-05-18)

> **목적**: `showCupertinoSheet`(iOS) + `DraggableScrollableSheet`(Android) 제거.
> 플랫폼 공통 `showModalBottomSheet` + 내부 `AnimationController`로 두 detent 동작 직접 구현.

### 21-0: 근본 원인 규명

- [x] `GestureDetector` 실패 원인: DSS scroll recognizer가 제스처 아레나에서 승리 → 콜백 미실행
- [x] `Listener` 실패 원인: DSS가 전체 시트 영역에 자체 gesture tracking을 갖고 있어 `BottomSheet.onClosing → Navigator.pop`을 독립 호출
- [x] `snap: false`도 실패: DSS scroll physics가 minChildSize 도달 + 잔여 포인터 이동 시 dismiss 트리거
- [x] **결론**: DSS 자체가 문제, 완전 제거 필요

### 21-1: `ReservationDetailModal` 재구성

- [x] `scrollController`, `draggableController` 파라미터 제거
- [x] `required double maxAvailableHeight` 파라미터 추가
- [x] `SingleTickerProviderStateMixin` 추가
- [x] `AnimationController _sheetController` 추가 (value: 0.62, lowerBound: 0.62, upperBound: 1.0)
- [x] `_ownReadOnlyController` non-nullable `late final`로 변경 (항상 생성)
- [x] `_dismissModal()` = `Navigator.pop(context)` 직접 호출 (route 기본 슬라이드다운 exit 활용)
- [x] `build()`: `AnimatedBuilder` → `SizedBox(height: maxAvailableHeight * value)` → `Material(borderRadius: ...)` 구조
- [x] `Listener`: `_sheetController.value` 직접 조작 (DSS 없이 완전 독립)
- [x] 편집 모드 진입: `_sheetController.animateTo(_kModalMaxSize)`

### 21-2: 편집 모드 드래그 잠금 + 그라버 숨김

- [x] `onPointerMove/Up/Cancel`: `if (_isEditing) return;` 추가 → 편집 모드에서 드래그 불가
- [x] `ModalGrabber` → `Opacity(opacity: _isEditing ? 0.0 : 1.0, ...)` → 공간 유지하며 시각만 숨김

### 21-3: `showReservationDetailModal` 재구성

- [x] `DraggableScrollableController` 제거
- [x] `DraggableScrollableSheet` 제거
- [x] `backgroundColor: Colors.transparent` 적용
- [x] `LayoutBuilder`로 `constraints.maxHeight` → `maxAvailableHeight` 전달
- [x] `Platform.isIOS` 분기 완전 제거 (플랫폼 공통 단일 코드)
- [x] `dart:io` import 제거됨

### 21-4: Overflow 수정

- [x] `lowerBound: 0.0` → `lowerBound: _kModalInitialSize` 변경
  - **원인**: 이전 dismiss 애니메이션(`animateTo(0.0)`) 중 Column overflow (h=51.5)
  - **해결**: `lowerBound = 0.62`로 height가 0에 도달하지 않게 차단

### 21-5: `dart analyze` 통과

- [x] `dart analyze` → `No issues found!`

---

## 스코프 아웃

- [x] 요금 콤마 포맷 (50,000)
- [x] `_formatDateTime` 공통 extension 추출
- [x] `n번째` 예약 실제 계산 연결
- [x] `availableStores` 실제 데이터 연결
- [x] `onSaved` 실제 Firestore 저장 연결
- [x] 입금/확정 안내문 화면 연결

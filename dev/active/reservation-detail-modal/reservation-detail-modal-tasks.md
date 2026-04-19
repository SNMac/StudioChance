# 예약 확인 모달 — 작업 체크리스트

Last Updated: 2026-04-19 (Phase 9~14 완료 — 인라인 편집 모드 전환 재구현 완료)

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
- [x] `late String _platform, _paymentMethod`
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
- [x] **V-2**: '편집' 탭 → 필드가 편집 가능하게 전환 (AppBar도 변경)
- [x] **V-3**: 편집 중 '취소' 탭 → 읽기 전용 복귀, 변경 내용 폐기
- [x] **V-4**: 편집 후 '완료' 탭 → 읽기 전용 복귀, 변경 내용 반영
- [x] **V-5**: 하루종일 ON/OFF 동작 확인 (편집 모드)
- [x] **V-6**: 예약 플랫폼/결제 방식 팝업 선택 → 반영
- [x] **V-7**: 다크 모드 양쪽 모드 정상 표시

---

## 스코프 아웃

- [x] 요금 콤마 포맷 (50,000)
- [x] `_formatDateTime` 공통 extension 추출
- [x] `n번째` 예약 실제 계산 연결
- [x] `availableStores` 실제 데이터 연결
- [x] `onSaved` 실제 Firestore 저장 연결
- [x] 입금/확정 안내문 화면 연결

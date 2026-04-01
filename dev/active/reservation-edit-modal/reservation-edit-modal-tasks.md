# 예약 수정 모달 — 작업 체크리스트

Last Updated: 2026-04-01 (Phase 0~9 구현 완료)

---

## Phase 0: ModalBodyPadding 제거 → SafeAreaWithPadding 통일 (선행 정리)

**목표:** `ModalBodyPadding` 위젯을 삭제하고, 사용처를 `SafeAreaWithPadding`으로 교체.  
신규 `reservation_edit_modal.dart`도 `SafeAreaWithPadding`을 사용하므로 선행 처리.

### 0-1: SafeAreaWithPadding에 `top` 파라미터 추가 ✅

**파일:** `lib/presentation/commons/widgets/safe_area_with_padding.dart`

- [x] `final bool top` 파라미터 추가 (기본값 `true` — 기존 동작 유지)
- [x] `SafeArea(child: ...)` → `SafeArea(top: top, child: ...)` 적용

### 0-2: reservation_list_modal.dart — ModalBodyPadding 교체 ✅

**파일:** `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart`

- [x] `import modal_body_padding.dart` 제거
- [x] `ModalBodyPadding` → `SafeAreaWithPadding(top: false, padding: fromSTEB(16,16,16,8))`
- [x] `import safe_area_with_padding.dart` 추가

### 0-3: ModalBodyPadding 파일 삭제 ✅

- [x] `lib/presentation/commons/widgets/modal_body_padding.dart` 삭제

---

## Phase 1: 상수 추가

**파일:** `lib/constants/data_constants.dart`

- [x] **1-1**: `reservationPlatforms: List<String>` 상수 추가
- [x] **1-2**: `paymentMethods: List<String>` 상수 추가

---

## Phase 2: 모달 Shell 구현

**파일:** `lib/presentation/home/widgets/three_day_calendar/reservation_edit_modal.dart` (신규)

- [x] **2-1**: `ReservationEditModal extends ConsumerStatefulWidget` 선언
- [x] **2-2**: `_ReservationEditModalState` — 폼 상태 필드 선언
  - `late StoreSummary _storeSummary`
  - `late ReservationStatus _status`
  - `late final TextEditingController _nameController`
  - `late final TextEditingController _headCountController`
  - `late final TextEditingController _phoneController`
  - `late final TextEditingController _memoController`
  - `late bool _isAllDay`
  - `late DateTime _startTime`
  - `late DateTime _endTime`
  - `bool _isStartPickerOpen = false`
  - `bool _isEndPickerOpen = false`
  - `late String _platform`
  - `late String _paymentMethod`
  - `late final TextEditingController _priceController`
  - `late final TextEditingController _adjustmentController`
- [ ] **2-3**: `initState` — `reservation` 초기값으로 필드 초기화
- [ ] **2-4**: `dispose` — TextEditingController 전부 dispose
- [ ] **2-5**: `isValid` getter 구현
  ```dart
  bool get _isValid => ...
  ```
- [x] **2-3**: `initState` — reservation 초기값으로 필드 초기화
- [x] **2-4**: `dispose` — TextEditingController 전부 dispose
- [x] **2-5**: `_isValid` getter
- [x] **2-6**: `build()` — Material + Column(ModalGrabber, ModalAppBar, Expanded scroll)
- [x] **2-7**: `ModalAppBar` (취소/완료 버튼)
- [x] **2-8**: `_onComplete()` — Reservation.copyWith + onSaved + Navigator.pop
- [x] **2-9**: `showReservationEditModal` 함수
- [x] **2-10**: `_formatDateTime` 헬퍼

---

## Phase 3: 섹션 1 — 기본 정보

- [x] **3-1~3-3**: 예약 점포(컬러 dot), 예약 상태 TitlePopupButton 구현

---

## Phase 4: 섹션 2 — 예약자 정보

- [x] **4-1~4-5**: 예약자명, 인원, 연락처, 메모(0/200) 구현

---

## Phase 5: 섹션 3 — 일시 정보

- [x] **5-1~5-6**: 하루종일 switch, 입실/퇴실 TitleDateTimeButton, _onAllDayChanged 구현
  - 하루종일 ON/OFF에 따라 mode(date/dateAndTime) 전환
  - 피커 동시 열림 방지 (한 쪽 열면 다른 쪽 닫힘)
  - 하루종일 ON시 피커 내용은 계속 표시 (숨김 없음, mode만 전환)

---

## Phase 6: 섹션 4 — 결제 정보

- [x] **6-1~6-5**: 예약 플랫폼, 결제 방식 popup, 요금, 추가요금/할인(부호 허용) 구현
  - footer: '할인인 경우 -[값]을 입력해주세요'
  - 추가요금: `numberWithOptions(signed: true)` + `RegExp(r'^-?\d*')` formatter

---

## Phase 7: 섹션 5 — 안내문

- [x] **7-1~7-3**: 'n번째 예약입니다.' header + 입금/확정 안내문 TitleNavigationButton (onPressed: TODO)

---

## Phase 8: 완료 버튼 상태 관리

- [x] **8-1~8-4**: 완료 버튼 활성화 로직 구현 완료
  - 예약자명 + 인원 onChanged → setState → _isValid 재평가
  - _onComplete: copyWith + totalPrice 계산 + onSaved + Navigator.pop

---

## Phase 9: 시각적 검증

- [ ] **V-1**: 모달 열림 시 기존 reservation 값이 각 필드에 pre-fill
- [ ] **V-2**: 취소 탭 → 모달 닫힘
- [ ] **V-3**: 완료 비활성 → 예약자명 입력 후 활성화 확인
- [ ] **V-4**: 하루종일 ON → 시간 피커 숨김 + 날짜 포맷 전환
- [ ] **V-5**: 하루종일 OFF → 시간 피커 재표시
- [ ] **V-6**: 예약 플랫폼 popup → 선택 후 변경 반영
- [ ] **V-7**: 추가 요금/할인 필드에 '-100' 입력 가능 확인
- [ ] **V-8**: 다크 모드 — 모든 섹션 색상 정상

---

## 스코프 아웃 (후속 작업)

- [ ] `availableStores` 실제 데이터 연결 (현재 mock)
- [ ] `n번째` 실제 계산 로직
- [ ] 입금/확정 안내문 화면 구현
- [ ] `onSaved` → 실제 Firestore 저장 (Repository 구현 후)
- [ ] `reservation_detail_modal.dart` 편집 버튼에서 `showReservationEditModal` 호출

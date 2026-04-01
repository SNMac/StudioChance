# 예약 수정 모달 — 작업 체크리스트

Last Updated: 2026-04-01

---

## Phase 0: ModalBodyPadding 제거 → SafeAreaWithPadding 통일 (선행 정리)

> 승인 대기 중. 구현 전 사용자 확인 필요.

**목표:** `ModalBodyPadding` 위젯을 삭제하고, 사용처를 `SafeAreaWithPadding`으로 교체.  
신규 `reservation_edit_modal.dart`도 `SafeAreaWithPadding`을 사용하므로 선행 처리.

### 0-1: SafeAreaWithPadding에 `top` 파라미터 추가

**파일:** `lib/presentation/commons/widgets/safe_area_with_padding.dart`

- [ ] `final bool top` 파라미터 추가 (기본값 `true` — 기존 동작 유지)
- [ ] `SafeArea(child: ...)` → `SafeArea(top: top, child: ...)` 적용

**변경 전:**
```dart
const SafeAreaWithPadding({super.key, this.child, this.padding = ...});
// SafeArea(child: Padding(...))
```

**변경 후:**
```dart
const SafeAreaWithPadding({super.key, this.child, this.padding = ..., this.top = true});
// SafeArea(top: top, child: Padding(...))
```

> 기존 사용처(`StoreFormScreen` 등)는 `top: true`가 기본값이므로 **변경 없이 동작 유지**.

### 0-2: reservation_list_modal.dart — ModalBodyPadding 교체

**파일:** `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart`

- [ ] `import modal_body_padding.dart` 제거
- [ ] `ModalBodyPadding(child: ...)` →
  ```dart
  SafeAreaWithPadding(
    top: false,
    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
    child: ...,
  )
  ```
- [ ] `import safe_area_with_padding.dart` 추가

### 0-3: ModalBodyPadding 파일 삭제

**파일:** `lib/presentation/commons/widgets/modal_body_padding.dart`

- [ ] 파일 삭제

---

## Phase 1: 상수 추가

**파일:** `lib/constants/data_constants.dart`

- [ ] **1-1**: `reservationPlatforms: List<String>` 상수 추가
  - 값: `['네이버 예약', '카카오 예약', '전화', '직접 방문', '기타']`
- [ ] **1-2**: `paymentMethods: List<String>` 상수 추가
  - 값: `['현금', '계좌이체', '카드', '기타']`

---

## Phase 2: 모달 Shell 구현

**파일:** `lib/presentation/home/widgets/three_day_calendar/reservation_edit_modal.dart` (신규)

- [ ] **2-1**: `ReservationEditModal extends ConsumerStatefulWidget` 선언
  - 파라미터: `reservation`, `availableStores`, `onSaved`, `scrollController?`
- [ ] **2-2**: `_ReservationEditModalState` — 폼 상태 필드 선언
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
  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      (int.tryParse(_headCountController.text) ?? 0) > 0 &&
      (_isAllDay || _startTime.isBefore(_endTime));
  ```
- [ ] **2-6**: `build()` 기본 구조
  - `Material(color: context.systemGroupedBackground)`
  - `Column`: ModalGrabber → ModalAppBar → Expanded(SingleChildScrollView)
- [ ] **2-7**: `ModalAppBar` 설정
  - leading: `AppBarActionButton(label: '취소', isRegularWeight: true, onPressed: Navigator.pop)`
  - title: `'예약 수정'`
  - actions: `AppBarActionButton(label: '완료', onPressed: _isValid ? _onComplete : null)`
- [ ] **2-8**: `_onComplete()` — `Reservation` 빌드 후 `onSaved` 콜백 호출, `Navigator.pop`
- [ ] **2-9**: `showReservationEditModal` 함수 (iOS: showCupertinoSheet / Android: showModalBottomSheet + DraggableScrollableSheet)
- [ ] **2-10**: `_formatDateTime(DateTime, {bool dateOnly})` private 헬퍼 함수

---

## Phase 3: 섹션 1 — 기본 정보

- [ ] **3-1**: `GroupedFormContainer` — 섹션 1 children
- [ ] **3-2**: 예약 점포 행
  - `Padding(horizontal: 16)` + `TitlePopupButton<StoreSummary>`
  - `itemLeadingBuilder`: 8×8 컬러 circle dot
  - `itemLabelBuilder`: `(s) => s.name`
  - `onSelected`: `setState(() => _storeSummary = s)`
- [ ] **3-3**: 예약 상태 행
  - `Padding(horizontal: 16)` + `TitlePopupButton<ReservationStatus>`
  - `items`: `ReservationStatus.values`
  - `itemLabelBuilder`: `(s) => s.displayName`

---

## Phase 4: 섹션 2 — 예약자 정보

- [ ] **4-1**: `GroupedFormContainer` — 섹션 2 children
- [ ] **4-2**: 예약자명 행
  - `TitleTextField(title: '예약자명', controller: _nameController, onChanged: (_) => setState(() {}), keyboardType: TextInputType.name)`
- [ ] **4-3**: 인원 행
  - `TitleTextField(title: '인원', controller: _headCountController, onChanged: (_) => setState(() {}), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])`
- [ ] **4-4**: 연락처 행
  - `TitleTextField(title: '연락처', controller: _phoneController, keyboardType: TextInputType.phone)`
- [ ] **4-5**: 메모 행
  - `MemoTextField(placeholder: '메모', controller: _memoController, maxLength: 200, inputFormatters: [LengthLimitingTextInputFormatter(200)])`

---

## Phase 5: 섹션 3 — 일시 정보

- [ ] **5-1**: `GroupedFormContainer` — 섹션 3 children
- [ ] **5-2**: 하루종일 행
  - `TitleSwitchButton(title: '하루종일', value: _isAllDay, onChanged: _onAllDayChanged)`
- [ ] **5-3**: `_onAllDayChanged(bool)` 구현
  - ON: `_startTime`은 날짜 자정(00:00), `_endTime`은 23:59, 피커 닫기
- [ ] **5-4**: 입실 일시 행 (하루종일 OFF시에만 표시)
  - `TitleDateTimeButton(title: '입실 일시', content: _formatDateTime(_startTime, dateOnly: _isAllDay), isOpen: _isStartPickerOpen, mode: _isAllDay ? date : dateAndTime, ...)`
- [ ] **5-5**: 퇴실 일시 행 (하루종일 OFF시에만 표시)
  - `TitleDateTimeButton(title: '퇴실 일시', ...)`
- [ ] **5-6**: 하루종일 ON시 입실/퇴실 행 숨김 처리
  - `if (!_isAllDay) TitleDateTimeButton(...)` 패턴 또는 AnimatedOpacity

---

## Phase 6: 섹션 4 — 결제 정보

- [ ] **6-1**: `GroupedFormContainer` — 섹션 4, footer 텍스트 포함
  - `footer: Padding(...)` → `'할인인 경우 -[값]을 입력해주세요'` (secondaryLabel 색상, labelMedium)
- [ ] **6-2**: 예약 플랫폼 행
  - `Padding(horizontal: 16)` + `TitlePopupButton<String>`
  - `items`: `reservationPlatforms`
  - `itemLabelBuilder`: `(s) => s`
- [ ] **6-3**: 결제 방식 행
  - `Padding(horizontal: 16)` + `TitlePopupButton<String>`
  - `items`: `paymentMethods`
  - `itemLabelBuilder`: `(s) => s`
- [ ] **6-4**: 요금 행
  - `TitleTextField(title: '요금', controller: _priceController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly])`
- [ ] **6-5**: 추가 요금/할인 행
  - `TitleTextField(title: '추가 요금/할인', controller: _adjustmentController, keyboardType: TextInputType.numberWithOptions(signed: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))])`

---

## Phase 7: 섹션 5 — 안내문

- [ ] **7-1**: `GroupedFormContainer` — 섹션 5, header 텍스트 포함
  - `header: Padding(...)` → `'n번째 예약입니다.'` (secondaryLabel 색상, bodyMedium)
  - TODO: `n`은 현재 `1` 하드코딩
- [ ] **7-2**: 입금 안내문 행
  - `TitleNavigationButton(title: '입금 안내문', onPressed: () {/* TODO */})`
- [ ] **7-3**: 확정 안내문 행
  - `TitleNavigationButton(title: '확정 안내문', onPressed: () {/* TODO */})`

---

## Phase 8: 완료 버튼 상태 관리

- [ ] **8-1**: 인원/요금 TextField의 `onChanged`에 `setState(() {})` 추가 → `_isValid` 재평가
- [ ] **8-2**: 예약자명 변경 시 `setState` 확인 (4-2에서 이미 처리)
- [ ] **8-3**: `_isValid` getter 동작 검증
  - 예약자명 비어있음 → 완료 비활성
  - 인원 0 또는 비어있음 → 완료 비활성
  - `startTime >= endTime` (하루종일 OFF) → 완료 비활성
  - 모두 충족 → 완료 활성 (파란색)
- [ ] **8-4**: `_onComplete()` — Reservation 생성 검증
  - `int.tryParse` 안전 파싱 (null → 0 fallback)
  - `totalPrice = calculatedPrice + priceAdjustment`
  - `onSaved(newReservation)` → `Navigator.pop(context)`

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

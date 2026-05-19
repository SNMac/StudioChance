# 예약 확인 모달 — 컨텍스트 및 참조

Last Updated: 2026-05-19 (Phase 36 완료 — n번째 예약 카운트 실제 데이터 연결)

---

## ✅ 구현 완료 (Phase 9~14)

### 설계
- **단일 모달**에서 읽기 전용 ↔ 편집 모드를 **인라인으로 전환**
- '편집' 버튼 → 같은 모달에서 필드가 편집 가능하게 변환
- '완료' 버튼 → 저장 후 읽기 전용 모드로 복귀 (모달 닫힘 아님)
- '취소' 버튼 → 읽기 전용 중이면 모달 닫기, 편집 중이면 변경 내용 폐기 + 읽기 전용 복귀

### 현재 구현 상태

`ReservationDetailModal extends ConsumerStatefulWidget` — 인라인 편집 모드 전환 완료.
`dart analyze` 통과 (firebase_options.dart 제외).

### 이번 세션 주요 변경
- `_ReadOnlyMemo` 최소 높이: `inputFormComponentHeight(48)` → `memoMinHeight(96)`, bottom padding 12 → 32 (MemoTextField 편집 모드와 높이 일치)
- `ui_constants.dart`에 `memoMinHeight = 96.0` 상수 추가
- **`reservationPlatforms`, `paymentMethods` const List → enum 전환** (2026-04-19)
  - `lib/domain/enums/reservation_platform.dart` (ReservationPlatform: naver/spaceCloud/yanolja/other)
  - `lib/domain/enums/payment_method.dart` (PaymentMethod: onSite/bankTransfer/other)
  - `Reservation.platform: String` → `ReservationPlatform`, `paymentMethod: String` → `PaymentMethod`
  - `ReservationModel` 동일하게 변경
  - 모달 상태 필드: `late String _platform/_paymentMethod` → `late ReservationPlatform/PaymentMethod`
  - `TitlePopupButton<String>` → `TitlePopupButton<ReservationPlatform/PaymentMethod>`, `itemLabelBuilder: (p) => p.displayName`
  - 읽기 전용 표시: `reservation.platform` → `reservation.platform.displayName`
  - `data_constants.dart`에서 두 const List 제거 (import는 `maxMemoCharCount` 때문에 유지)
- **Reservation Data Layer 신규 구현** (2026-04-19)
  - `lib/common/exceptions/reservation_exceptions.dart`
  - `lib/data/data_sources/reservation_data_source.dart` (Firestore 서브컬렉션: `stores/{storeId}/reservations/`)
  - `lib/domain/repository_interfaces/reservation_repository.dart`
  - `lib/data/repositories/reservation_repository_impl.dart`
  - `lib/domain/use_cases/reservation_use_case.dart`
- **Reservation 테스트 코드 추가** (2026-04-20)
  - `test/helpers/fake_data.dart` — 예약 관련 fake 데이터 추가 (fakeStoreSummary, fakeWriterMemberInfo, fakeReservation, fakeReservationModel, fakeStoreModel, fakeUserModel)
  - `test/data/repositories/reservation_repository_test.dart` — Repository 단위 테스트 12개 (전체 통과)
  - `test/domain/use_cases/reservation_use_case_test.dart` — UseCase 단위 테스트 14개 (전체 통과)
  - `flutter test` 26개 전체 통과 확인 후 커밋 완료

---

## 테스트 구조 (Reservation Data Layer)

### fake_data.dart 추가 항목
```dart
// 도메인 엔티티 fakes
final fakeStoreSummary = StoreSummary(id: 'store-123', name: '테스트 점포', color: StoreColor.blue);
final fakeWriterMemberInfo = StoreMemberInfo(user: fakeUser, role: UserRole.admin);
final fakeReservation = Reservation(id: 'res-001', storeSummary: fakeStoreSummary, ...);

// 데이터 모델 fakes (Repository 테스트용)
final fakeReservationModel = ReservationModel(id: 'res-001', storeId: 'store-123', writerId: 'user-123', ...);
final fakeStoreModel = StoreModel(..., memberById: {'user-123': StoreMemberInfoModel(role: UserRole.admin)});
final fakeUserModel = UserModel(..., storeById: {'store-123': UserStoreInfoModel(color: StoreColor.blue, ...)});
```

### reservation_repository_test.dart — 12개 테스트
| group | 테스트 내용 |
|-------|------------|
| createReservation | DataSource 반환 모델로 엔티티 변환 right 반환 / DataSource 실패 시 left |
| getReservationsByDateRange | 빈 목록 → 추가 조회 없음 / StoreSummary color, writer.role 검증 / StoreDataSource null → left / DS 실패 → left |
| updateReservation | 올바른 storeId/reservationId로 DS 호출 / DS 실패 → left |
| deleteReservation | 올바른 파라미터로 DS 호출 / DS 실패 → left |
| updateReservationStatus | status.name 포함 데이터로 DS 호출 / DS 실패 → left |

### reservation_use_case_test.dart — 14개 테스트
| group | 테스트 내용 |
|-------|------------|
| createReservation | writer.user를 현재 로그인 유저로 교체 / writer.role 원본 유지 / 유저 조회 실패 → left + repo 미호출 / 현재 유저 null → left / repo 실패 → left |
| getReservationsByDateRange | currentUid 자동 획득 후 repo 호출 / 유저 조회 실패 → left / repo 실패 → left |
| updateReservation | repo 위임 / repo 실패 → left |
| deleteReservation | 올바른 파라미터 repo 호출 / repo 실패 → left |
| updateReservationStatus | 올바른 파라미터 repo 호출 / repo 실패 → left |

---

## 재구현 방향

### 클래스 변경
```
ReservationDetailModal extends StatelessWidget
→ ReservationDetailModal extends ConsumerStatefulWidget
```

### 추가 상태
```dart
bool _isEditing = false;

// 편집 모드에서 사용하는 상태 (ReservationEditModal과 동일)
late StoreSummary _storeSummary;
late ReservationStatus _status;
late bool _isAllDay;
late DateTime _startTime;
late DateTime _endTime;
late String _platform;
late String _paymentMethod;
bool _isStartPickerOpen = false;
bool _isEndPickerOpen = false;

late final TextEditingController _nameController;
late final TextEditingController _headCountController;
late final TextEditingController _phoneController;
late final TextEditingController _memoController;
late final TextEditingController _priceController;
late final TextEditingController _adjustmentController;
```

### AppBar 전환
```dart
// 읽기 전용 모드: leading='닫기'(일반굵기), actions=['편집']
ModalAppBar(
  title: '예약 정보',
  leading: AppBarActionButton(label: '닫기', isRegularWeight: true, onPressed: _onCancelPressed),
  actions: [AppBarActionButton(label: '편집', onPressed: () => setState(() => _isEditing = true))],
)

// 편집 모드: leading='취소'(일반굵기), actions=['완료'(유효할 때만 활성)]
ModalAppBar(
  title: '예약 수정',
  leading: AppBarActionButton(label: '취소', isRegularWeight: true, onPressed: _onCancelPressed),
  actions: [AppBarActionButton(label: '완료', onPressed: _isValid ? _onComplete : null)],
)
```
> **결정**: leading 버튼은 모드 무관하게 항상 `isRegularWeight: true`.
> 읽기 전용='닫기'(모달 닫기), 편집='취소'(변경 폐기 + 읽기 전용 복귀).
> 실제 코드에서 `_onCancelPressed()`가 `_isEditing` 여부로 분기.
```

### 취소 동작 분기
```dart
void _cancelEdit() {
  // 편집 중: 변경 내용 폐기 + 읽기 전용 복귀
  setState(() {
    _isEditing = false;
    _resetFields(); // widget.reservation 값으로 재초기화
    _isStartPickerOpen = false;
    _isEndPickerOpen = false;
  });
}
```

### 완료 동작
```dart
void _onComplete() {
  final updated = widget.reservation.copyWith(...); // 편집 상태 → Reservation
  widget.onSaved(updated);
  setState(() => _isEditing = false); // 모달 닫지 않고 읽기 전용으로 복귀
}
```

### 섹션별 빌드 전략
```dart
// 읽기 전용: TitleTextLabel, TitleSwitchButton(onChanged: null), _ReadOnlyMemo
// 편집: TitleTextField, TitlePopupButton, TitleSwitchButton(onChanged: ...), MemoTextField, TitleDateTimeButton
Widget _buildSection2() {
  if (_isEditing) return _buildSection2Edit();
  return _buildSection2ReadOnly();
}
```

---

## ReservationEditModal 처리

`reservation_edit_modal.dart`는 더 이상 `ReservationDetailModal`에서 호출하지 않음.
→ `showReservationEditModal` 호출처 없음 (기존 detail modal의 `_onEdit` 제거됨)
→ **2026-04-19 파일 삭제 완료** — 독립 진입점 불필요, 편집 로직은 `ReservationDetailModal` 내부로 통합됨.

---

## 관련 파일 경로

| 파일 | 역할 |
|------|------|
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | **재작성 대상** |
| `lib/presentation/home/widgets/three_day_calendar/reservation_edit_modal.dart` | 편집 로직 참조 (이후 삭제 검토) |
| `lib/domain/enums/reservation_platform.dart` | `ReservationPlatform` enum (naver/spaceCloud/yanolja/other) |
| `lib/domain/enums/payment_method.dart` | `PaymentMethod` enum (onSite/bankTransfer/other) |
| `lib/constants/data_constants.dart` | `maxMemoCharCount` 등 공통 상수 (플랫폼/결제 목록은 enum으로 이전) |
| `lib/domain/entities/reservation.dart` | `Reservation` freezed 엔티티 |
| `lib/presentation/commons/widgets/input_form/` | 폼 컴포넌트 모음 |

---

## 도메인 엔티티 (Reservation)

```dart
@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required StoreSummary storeSummary,
    required StoreMemberInfo writer,
    required ReservationStatus status,
    required String customerName,
    required int headCount,
    required String customerPhone,
    required String memo,
    required bool isAllDay,
    required DateTime startTime,
    required DateTime endTime,
    required ReservationPlatform platform,   // ← String에서 변경
    required PaymentMethod paymentMethod,    // ← String에서 변경
    required int calculatedPrice,
    required int priceAdjustment,
    required int totalPrice,
  }) = _Reservation;
}
```

---

## onSaved 파라미터 추가

`showReservationDetailModal`에 `onSaved` 콜백 추가 필요:
```dart
Future<void> showReservationDetailModal(
  BuildContext context,
  Reservation reservation, {
  List<StoreSummary>? availableStores,   // null이면 [reservation.storeSummary] 사용
  required void Function(Reservation) onSaved,
})
```

호출처인 `time_grid.dart`도 함께 수정 필요.

---

## ✅/🔴 스크롤 위치 보존 — iOS 해결 / Android 미해결

### 증상
- 읽기 전용 모드에서 스크롤 후 '편집' 버튼 탭 시 스크롤이 맨 위로 초기화됨
- 반대 방향(편집 → 읽기 전용 복귀)도 동일

### 원인 분석
`setState`로 `_isEditing`이 바뀌면 섹션 빌드 메서드가 완전히 다른 위젯을 반환하고,
콘텐츠 높이가 바뀌면서 `ScrollPosition`이 0으로 리셋됨.
`SingleChildScrollView`의 `ScrollableState`는 재사용되지만, 내용 변경 시 포지션이 초기화되는 것으로 보임.
정확한 Flutter 내부 원인은 불명확 (iOS `CupertinoSheetRoute` 개입 가능성도 있음).

### 시도한 접근 방법 (모두 실패)

#### 시도 1: 명시적 ScrollController 소유 (효과 없음)
```dart
// initState
_scrollController = widget.scrollController ?? ScrollController();
// SingleChildScrollView(controller: _scrollController, ...)
```
- 이론: 동일 인스턴스를 유지하면 ScrollPosition이 보존될 것
- 결과: 여전히 0으로 초기화됨

#### 시도 2: postFrameCallback + jumpTo (깜빡임 발생)
```dart
void _switchMode(VoidCallback stateChange) {
  final offset = _scrollController.offset;
  setState(stateChange);
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _scrollController.jumpTo(offset.clamp(0, maxScrollExtent));
  });
}
```
- 이론: 프레임 이후 포지션 복원
- 결과: 포지션은 복원되지만 **1프레임 동안 0 위치가 보여 깜빡임 발생**

#### 시도 3: Opacity(0) + postFrameCallback (배경색 깜빡임)
```dart
// _isRestoringScroll = true 동안 Opacity(opacity: 0) 적용
setState(() { stateChange(); _isRestoringScroll = true; });
WidgetsBinding.instance.addPostFrameCallback((_) {
  _scrollController.jumpTo(...);
  setState(() => _isRestoringScroll = false);
});
```
- 이론: 잘못된 포지션 프레임을 숨김
- 결과: 스크롤이 0인 프레임은 보이지 않으나 **배경색으로 깜빡임** (방법은 같고 가리는 것만 다름)

#### 시도 4: build()에서 correctPixels 선점 (효과 없음 — 현재 코드 상태)
```dart
@override
Widget build(BuildContext context) {
  final pending = _pendingScrollOffset;
  if (pending != null && _scrollController.hasClients) {
    _scrollController.position.correctPixels(pending);
    _pendingScrollOffset = null;
  }
  // ...
}

void _switchMode(VoidCallback stateChange) {
  if (_scrollController.hasClients) _pendingScrollOffset = _scrollController.offset;
  setState(stateChange);
}
```
- 이론: layout 시작 전에 _pixels를 선점 → 잘못된 프레임 자체가 생성되지 않음
- 결과: **스크롤 보존 안 됨 (원점)**
- 분석: `correctPixels`가 build 단계에서 적용되지만, 이후 layout/applyContentDimensions에서 덮어쓰이는 것으로 추정

### 시도 6: IndexedStack (2026-04-22 — 실패)

IndexedStack으로 두 콘텐츠를 항상 트리에 유지했지만 포지션이 여전히 0으로 초기화됨.
추정 원인: `ModalAppBar`가 모드 전환 시 미세하게 높이가 달라지면 `Expanded > SingleChildScrollView`의
viewport 높이가 변하고 `applyNewDimensions()` → `goBallistic(0)` 경로로 포지션 초기화될 가능성.

---

### 해결 방법 (2026-04-22 — 17-C: 독립 ScrollController + Stack + Offstage)

**근본 원인**: 6번의 시도 모두 "하나의 ScrollView에서 포지션 보존" 패턴. 이 패턴 자체를 포기.

**해결 전략**: 모드별로 완전히 독립된 `ScrollController`와 `SingleChildScrollView`를 분리.
- 각 ScrollView가 독립적인 `ScrollPosition`을 유지
- 전환 전 `_syncScrollPosition()`으로 오프셋 수동 동기화
- `Offstage(offstage: true)`: layout 유지, paint/hit-test 제외 → 포지션 보존

```dart
// iOS 전용: Stack + Positioned.fill + Offstage
Stack(
  children: [
    Positioned.fill(child: Offstage(
      offstage: _isEditing,
      child: SingleChildScrollView(controller: _readOnlyController, child: _buildReadOnlyBody(...)),
    )),
    Positioned.fill(child: Offstage(
      offstage: !_isEditing,
      child: SingleChildScrollView(controller: _editController, child: _buildEditBody(...)),
    )),
  ],
)

// 전환 전 오프셋 동기화
void _syncScrollPosition({required bool toEdit}) {
  final from = toEdit ? _readOnlyController : _editController;
  final to = toEdit ? _editController : _readOnlyController;
  if (from == null || to == null) return;
  if (!from.hasClients || !to.hasClients) return;
  if (!from.position.haveDimensions || !to.position.haveDimensions) return;
  to.jumpTo(from.offset.clamp(0.0, to.position.maxScrollExtent));
}
```

- iOS: `_readOnlyController` + `_editController` (모드별 독립)
- Android: `widget.scrollController` (DraggableScrollableSheet 제공) + IndexedStack (기존 유지)

---

## ✅ Android 스크롤 보존 해결 (17-E Option A — 2026-04-22)

### 해결 방법

`DraggableScrollableSheet`를 완전 제거하고 `showModalBottomSheet`에 `SizedBox(height: 90%)`를 사용.
`ReservationDetailModal` 자체는 이미 17-D 상태에서 Stack+Offstage 구조로 준비되어 있었으므로
`showReservationDetailModal` 함수의 Android 경로만 변경.

```dart
// 변경 후 (Android 경로)
builder: (ctx) => SizedBox(
  height: MediaQuery.of(ctx).size.height * 0.9,
  child: ReservationDetailModal(
    reservation: reservation,
    availableStores: availableStores,
    onSaved: onSaved,
  ),
),
```

**트레이드오프**: snap(60%→100%) 동작 제거됨. 모달은 항상 90% 높이로 열림.

---

## ⚠️ Android scroll jank — 실기기 검증 대기 (17-F)

### 관찰 (2026-04-22 세션)

Android 시뮬레이터에서 모달 내 스크롤 시 프레임 드랍 관찰됨. iOS 시뮬레이터에서는 동일 현상 없음.

### 원인 가설

1. **시뮬레이터 한계** (가능성 높음): Android 에뮬레이터는 GPU 렌더링이 에뮬레이션되어 실기기보다 훨씬 느림. Stack+Offstage의 이중 layout 비용이 시뮬레이터에서만 두드러질 수 있음.
2. **showModalBottomSheet 제스처 충돌** (실기기에서도 발생 시): `isScrollControlled: true`인 모달의 drag-to-dismiss 제스처와 내부 ScrollView 제스처가 충돌할 수 있음.

### 현재 조치

세션 중 두 가지 수정 시도 후 원래 코드(17-E)로 복원:
- 시도 1 (단일 ScrollView): scroll jank 해결되나 scroll 위치 보존 깨짐 → 롤백
- 시도 2 (enableDrag: false): 이론적으로 제스처 충돌 해결 → 복잡성 대비 효과 불확실 → 롤백

### 실기기에서 jank 재현 시 적용할 수정

```dart
// showReservationDetailModal Android 경로에 enableDrag: false 추가
return showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  enableDrag: false,  // ← 추가
  ...
);
```
- `enableDrag: false` 시 닫기 방법: AppBar '닫기' 버튼, barrier 탭, 백버튼 (drag-to-dismiss만 제거)

---

## ✅ Phase 20: 종일 이벤트 일시 표시 수정 (2026-05-02 완료)

> **요청 배경 (2026-04-22)**: 종일 이벤트에서 "퇴실 일시"가 이벤트 다음날로 표시되는 문제.
> 설계 결정: 두 행(입실/퇴실) 구조는 유지. 대신 타이틀을 "입실 일"/"퇴실 일"로 변경하고,
> endTime을 표시할 때 -1일 보정하여 하루짜리 종일 이벤트이면 입실 일 = 퇴실 일이 되도록 수정.

### 원인 분석: endTime = startTime + 1일 관례

목업 데이터(`three_day_calendar.dart` L74):
```dart
isAllDay: true,
startTime: today,            // 2026.04.22 00:00
endTime: today.add(const Duration(days: 1)),  // 2026.04.23 00:00 ← 다음날!
```
종일 이벤트는 iCal 관례상 `endTime`을 다음날 자정(exclusive)으로 저장.
`_formatDateTime(endTime, dateOnly: true)`는 다음날 날짜를 표시하므로 퇴실이 다음날로 보임.

### 읽기 전용 변경 (`_buildSection3ReadOnly()`)

**현재**:
```dart
TitleTextLabel(title: '입실 일시', content: _formatDateTime(startTime, dateOnly: isAllDay)),
TitleTextLabel(title: '퇴실 일시', content: _formatDateTime(endTime, dateOnly: isAllDay)),
```

**변경 후** (isAllDay=true일 때):
```dart
// 타이틀: '입실 일시' → '입실 일', '퇴실 일시' → '퇴실 일'
// endTime은 exclusive이므로 표시 시 -1일 보정
final displayEnd = isAllDay
    ? endTime.subtract(const Duration(days: 1))
    : endTime;
TitleTextLabel(title: '입실 일', content: _formatDateTime(startTime, dateOnly: true)),
TitleTextLabel(title: '퇴실 일', content: _formatDateTime(displayEnd, dateOnly: true)),
```
결과: 하루짜리 종일 이벤트 → 입실 일 = 퇴실 일 = `2026. 04. 22. (수)`.
멀티일 이벤트 → 입실 일 ≠ 퇴실 일 (예: 22일 ~ 24일).

> **데이터는 변경 없음**: Firestore에 저장된 `endTime`은 그대로 next-day midnight 유지.
> 표시 시에만 -1일 보정.

### Side Effect 분석

#### 1. `_onAllDayChanged(true)` 버그 — 수정 필요
**현재 코드**:
```dart
_endTime = DateTime(_endTime.year, _endTime.month, _endTime.day, 23, 59);
```
**문제**: 종일 이벤트의 `endTime = day+1 00:00`인 상태에서 toggle OFF → ON 재적용 시
`_endTime.day`가 이미 `startDay+1`이므로 `_endTime = startDay+1 23:59`가 됨.
저장하면 1일짜리 이벤트가 2일짜리로 변경되는 버그.

**수정 방향**:
```dart
// isAllDay ON 시 endTime을 startTime 기준으로 맞춤 (iCal 관례: 다음날 자정)
_endTime = DateTime(_startTime.year, _startTime.month, _startTime.day)
    .add(const Duration(days: 1));
```
또는 하루종일 ON 시 항상 startDay의 23:59로 통일하고 저장 시 변환하는 방식도 가능.

#### 2. 편집 모드 퇴실 일 DatePicker — 수정 필요
`_buildSection3Edit()`의 `mode`는 이미 `_isAllDay ? CupertinoDatePickerMode.date : CupertinoDatePickerMode.dateAndTime`으로 **날짜 전용 피커 모드는 올바름**.
그러나 `initialDateTime: _endTime`이 next-day 자정 → picker가 다음날 날짜를 초기값으로 표시 ✗

수정 방향:
- `initialDateTime`: `_isAllDay ? _endTime.subtract(Duration(days:1)) : _endTime`
- `content`: 동일하게 -1일 보정 후 포맷
- `onDateTimeChanged`: 선택 날짜 + 1일 저장 (iCal 관례 유지)
  ```dart
  onDateTimeChanged: (dt) => setState(() {
    _endTime = _isAllDay ? dt.add(const Duration(days: 1)) : dt;
  }),
  ```

#### 3. 캘린더 날짜 배치 — 영향 없음
`AllDayCell`이 `isAllDay` 플래그로 분기하므로 `endTime` 값에 의존하지 않음.
`getReservationsByDateRange` 쿼리는 Firestore 서버 사이드에서 처리 — 별도 확인 필요.

#### 4. `_isValid` 체크 — 영향 없음
`_isAllDay || startTime.isBefore(endTime)` — all-day면 시간 체크 bypass.

---

## 미결/후속 작업

| 항목 | 내용 |
|------|------|
| ~~**Phase 20**~~ | ~~읽기 전용 종일 이벤트 입/퇴실 일시 통합 + `_onAllDayChanged` 버그 수정~~ → 2026-05-02 완료 ✅ |
| ~~**Phase 21**~~ | ~~iOS/Android 통합 모달, DraggableScrollableSheet 제거~~ → 2026-05-18 완료 ✅ |
| ~~**Phase 22**~~ | ~~viewer 역할 편집 제한 + availableStores 공급~~ → 2026-05-19 완료 ✅ |
| ~~**Phase 27~34**~~ | ~~포맷터, 스테일 데이터, 키보드, 최종 요금~~ → 2026-05-19 완료 ✅ |
| ~~**Phase 36**~~ | ~~`n번째` 예약 카운트 실제 데이터 연결~~ → 2026-05-19 완료 ✅ |
| 입금/확정 안내문 | `TextActionButton.onPressed` TODO 유지 |
| `onSaved` 실제 연결 | 예약 저장 Use Case + Repository 구현 후 연결 |
| `_formatDateTime` 공통화 | 현재 편집/확인 모달 각각 private 선언 (스코프 아웃) |
| ~~`ReservationEditModal` 삭제~~ | 2026-04-19 삭제 완료 ✅ |
| ~~숫자 콤마 포맷~~ | ~~`calculatedPrice.toString()` → `"50,000"` style~~ → Phase 31에서 완료 ✅ |

## Phase 22 구현 상세 (2026-05-19)

### `three_day_calendar.dart` — availableStores 필터링

```dart
// 변경 전
final availableStores = storeInfos
    ?.map((info) => StoreSummary(id: info.id, name: info.name, color: info.color))
    .toList();

// 변경 후
final filtered = storeInfos
    ?.where((info) => info.role == UserRole.admin || info.role == UserRole.staff)
    .map((info) => StoreSummary(id: info.id, name: info.name, color: info.color))
    .toList();
final availableStores = (filtered == null || filtered.isEmpty) ? null : filtered;
```

빈 리스트 `[]`는 `?? [reservation.storeSummary]` fallback을 트리거하지 않으므로 반드시 `null`로 전달해야 함.

### `reservation_detail_modal.dart` — `_canEdit` getter

```dart
bool get _canEdit {
  final storeInfos = ref.watch(
    currentUserProvider.select((u) => u.asData?.value?.storeInfos),
  );
  if (storeInfos == null) return false;
  final storeId = widget.reservation.storeSummary.id;
  final info = storeInfos.where((i) => i.id == storeId).firstOrNull;
  return info?.role == UserRole.admin || info?.role == UserRole.staff;
}
```

AppBar actions: `else AppBarActionButton(label: '편집')` → `else if (_canEdit) AppBarActionButton(label: '편집')`

---

## ✅ Phase 21 구현 상세 (2026-05-18)

### 핵심 문제: DraggableScrollableSheet dismiss 버그

DSS + `showModalBottomSheet` 조합에서 그라버 드래그 시 모달이 의도치 않게 dismiss되는 버그.
**시도한 우회책이 모두 실패한 이유**:
- `GestureDetector`: DSS scroll recognizer가 제스처 아레나 승리 → 콜백 미실행
- `Listener` (raw pointer): DSS가 전체 시트 영역에 자체 gesture tracking → `BottomSheet.onClosing` 독립 호출
- `snap: false`: DSS scroll physics가 minChildSize 도달 + 잔여 이동 시 여전히 dismiss 트리거

**해결**: DSS 완전 제거. 내부 `AnimationController`로 시트 높이를 직접 제어.

### 최종 구조

```
showModalBottomSheet(
  isScrollControlled: true, useSafeArea: true,
  enableDrag: false, backgroundColor: transparent
)
  └── LayoutBuilder → constraints.maxHeight → maxAvailableHeight
      └── ReservationDetailModal(maxAvailableHeight: ...)
          └── AnimatedBuilder(animation: _sheetController)
              └── SizedBox(height: maxAvailableHeight * _sheetController.value)
                  └── Material(borderRadius: top-rounded)
                      └── Column
                          ├── Listener(grabber + appbar) ← 직접 _sheetController.value 조작
                          └── Expanded(Stack+Offstage ScrollViews)
```

### `ReservationDetailModal` 파라미터 변경

| 제거 | 추가 |
|------|------|
| `ScrollController? scrollController` | `required double maxAvailableHeight` |
| `DraggableScrollableController? draggableController` | — |

### `_sheetController` 설정

```dart
AnimationController(
  vsync: this,  // SingleTickerProviderStateMixin 추가
  value: _kModalInitialSize,      // 0.62 (초기 열림 높이)
  lowerBound: _kModalInitialSize, // 0.62 (최솟값 — overflow 방지)
  upperBound: _kModalMaxSize,     // 1.0
)
```

> ⚠️ `lowerBound: 0.0`으로 설정하면 dismiss 애니메이션 도중 Column overflow(h=51.5) 발생.
> `lowerBound: _kModalInitialSize`로 설정하고 dismiss는 `Navigator.pop()` 직접 호출.

### 그라버 드래그 로직

```dart
onPointerMove: (event) {
  if (_isEditing) return;  // 편집 모드: 드래그 잠금
  final delta = -event.delta.dy / widget.maxAvailableHeight;
  _sheetController.value = (_sheetController.value + delta).clamp(0.62, 1.0);
},
onPointerUp: (event) {
  if (_isEditing) return;
  final totalDy = event.position.dy - _grabberDragStartY;
  if (totalDy.abs() < 10) return; // 탭 → 무시
  if (totalDy > 30) {
    if (_grabberDragStartSize <= 0.67) _dismissModal(); // 소 detent → dismiss
    else _sheetController.animateTo(0.62, ...);         // 대 detent → 소 detent 스냅
  } else if (totalDy < -30) {
    _sheetController.animateTo(1.0, ...);               // 위로 → 대 detent 스냅
  } else {
    // 중간 → 가까운 detent로 스냅
  }
},
```

### 편집 모드 동작

- 그라버: `Opacity(opacity: _isEditing ? 0.0 : 1.0)` — 공간 유지, 시각만 숨김 (layout shift 없음)
- 드래그: `onPointerMove/Up/Cancel`에서 `_isEditing` 시 early return
- 편집 진입: `_sheetController.animateTo(1.0)` → 자동 전체 높이 확장

---

## Phase 20 구현 상세 (2026-05-02)

### 변경 파일

`lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`

### 변경 내용

#### 1. `_buildSection3ReadOnly()` — 읽기 전용 종일 이벤트 표시

```dart
final displayEnd = isAllDay
    ? widget.reservation.endTime.subtract(const Duration(days: 1))
    : widget.reservation.endTime;

TitleTextLabel(title: isAllDay ? '입실 일' : '입실 일시', ...),
TitleTextLabel(title: isAllDay ? '퇴실 일' : '퇴실 일시', content: _formatDateTime(displayEnd, ...)),
```

#### 2. `_onAllDayChanged(true)` 버그 수정

- **버그**: `_endTime.day` 기준 설정 → endTime이 이미 day+1이면 2일짜리 이벤트로 늘어남
- **수정**: `_startTime` 기준 다음날 자정으로 설정

```dart
_endTime = DateTime(_startTime.year, _startTime.month, _startTime.day)
    .add(const Duration(days: 1));
```

#### 3. `_buildSection3Edit()` — 편집 모드 picker 수정

- `displayEndTime` 로컬 변수 도입 (`_isAllDay ? _endTime - 1일 : _endTime`)
- `initialDateTime`, `content`에 `displayEndTime` 사용
- `onDateTimeChanged`: 종일이면 선택값 +1일 저장 (iCal exclusive 관례 유지)

```dart
onDateTimeChanged: (dt) => setState(
  () => _endTime = _isAllDay ? dt.add(const Duration(days: 1)) : dt,
),
```

### 핵심 불변식

- **데이터 저장**: `endTime`은 항상 iCal 관례(다음날 자정, exclusive) 유지
- **UI 표시**: `isAllDay`일 때만 -1일 보정하여 표시
- `dart analyze` → `No issues found!`

---

## ✅ Phase 27: 기준 끝 시간 00:00 = 1440분 처리 (2026-05-19)

### 문제

온보딩 요금 설정에서 기준 끝 시간을 00:00으로 설정하면 시작 시간이 00:00으로 초기화되는 버그.

### 원인

`CupertinoDatePicker`의 `initialDateTime`: `DateTime(..., hour: 24, minute: 0)`은 Dart에서 다음날 자정으로 정규화됨.
하지만 피커는 "00:00"을 표시하므로 사용자가 00:00을 선택하면 `onDateTimeChanged`에 `hour=0, minute=0`이 들어옴.
이것이 `newMinutes = 0`으로 계산 → `start(1440) >= end(0)` 조건 발동 → `newStart = (0 - 60).clamp(0, 1440) = 0` → 시작 시간 00:00 초기화.

### 해결

- **`time_formatter.dart`**: `formattedTime` getter에 `if (this == 1440) return '00:00';` 특수 케이스 추가
- **`time_slot_input_form.dart`** 끝 시간 `onDateTimeChanged`:
  ```dart
  final int newMinutes =
      newDate.hour == 0 && newDate.minute == 0
          ? 1440
          : newDate.hour * 60 + newDate.minute;
  ```
  - `hour=0, minute=0` 선택 → `1440`으로 매핑 (하루 끝)
  - `_getInitialDate(1440)`: `DateTime(…, 24, 0)` → Dart 정규화 → 다음날 자정 → 피커에서 "00:00" 표시 ✓
- `FilteringTextInputFormatter.digitsOnly` → `PriceInputFormatter()` 교체 (이 변경은 Phase 31과 연관)

---

## ✅ Phase 28: 멀티 슬롯 요금 계산 수정 (2026-05-19)

### 문제

예약 시간대가 여러 TimeSlot에 걸쳐 있을 때, 첫 번째 슬롯의 요금만 적용됨.
예) 10:00~13:00 예약: 10~12시 슬롯(7,000원/시간) + 12~13시 슬롯(8,000원/시간) → 기대 22,000원, 실제 21,000원.

### 원인

`price_setting.dart`의 `calculatePrice`: `firstWhere`로 첫 매칭 슬롯만 찾아 전체 시간에 적용.

### 해결 (`lib/domain/entities/price_setting.dart`)

전체 TimeSlot을 순회하며 예약 시간과의 겹침(overlap)을 계산해 합산:

```dart
for (final slot in group.timeSlots) {
  if (slot.isAllDay) continue;
  final slotEnd = slot.endTime == 0 ? 1440 : slot.endTime;
  final overlapStart = max(startMinutes, slot.startTime);
  final overlapEnd = min(endMinutes, slotEnd);
  if (overlapStart >= overlapEnd) continue;
  final overlapHours = (overlapEnd - overlapStart) / 60.0;
  int slotPrice = slot.isHourly ? (slot.price * overlapHours).round() : slot.price;
  if (slot.isPerPerson) slotPrice *= headCount;
  totalBase += slotPrice;
}
```

- `endTime == 0`은 하위 호환성을 위해 `1440`으로 처리
- `isAllDay` 슬롯은 별도 경로(하루종일 예약 전용)에서 처리

---

## ✅ Phase 29: 입출 시간 자동 조정 (2026-05-19)

`reservation_detail_modal.dart` + `reservation_create_modal.dart` 두 파일 공통 적용.

### 시작 시간 조정

시작 시간을 변경했을 때 종료 시간이 시작 이전이면 자동 조정:

```dart
onDateTimeChanged: (newDate) {
  if (newMinutes >= _endTime.hour * 60 + _endTime.minute) {
    // 끝 시간 = 시작 + 1시간 (자정 넘으면 23:59 clamp)
    setState(() { ... });
  }
}
```

### 종료 시간 조정

종료 시간을 변경했을 때 시작 이전이면 자동 조정:

```dart
onDateTimeChanged: (newDate) {
  if (newMinutes <= _startTime.hour * 60 + _startTime.minute) {
    // 시작 시간 = 끝 - 1시간
    setState(() { ... });
  }
}
```

---

## ✅ Phase 30: 연락처 자동 하이픈 포맷 (2026-05-19)

### 신규 파일: `lib/presentation/commons/extensions/phone_formatter.dart`

```dart
extension StringPhoneFormatter on String {
  String get formattedPhone { ... }  // "01012345678" → "010-1234-5678"
}

class PhoneNumberInputFormatter extends TextInputFormatter {
  // 최대 11자리, 실시간 앞3-중간-뒤4 포맷, 커서 항상 끝
}
```

### 적용

- `_initFields()` / `_resetFields()`: `phone.formattedPhone` 으로 초기화
- `_onComplete()` / `_onSavePressed()`: `.replaceAll('-', '')` 후 저장 (순수 숫자로 DB 저장)
- 전화번호 `TitleTextField`에 `PhoneNumberInputFormatter()` 추가

---

## ✅ Phase 31: 요금 쉼표+원 포맷 (2026-05-19)

### 신규 파일: `lib/presentation/commons/extensions/price_formatter.dart`

```dart
extension IntPriceFormatter on int {
  String get formattedPrice  { ... }  // 30000 → "30,000원"
  String get formattedAmount { ... }  // 30000 → "30,000" (텍스트 필드 초기값용)
}

class PriceInputFormatter extends TextInputFormatter {
  const PriceInputFormatter({this.allowNegative = false});
  // 입력 시 천 단위 쉼표 자동 삽입, 커서 항상 끝
}
```

### 적용

| 위치 | 변경 내용 |
|------|----------|
| `time_slot_input_form.dart` | `FilteringTextInputFormatter.digitsOnly` → `PriceInputFormatter()`, 초기값 `formattedAmount`, 파싱 시 `,` 제거 |
| `reservation_detail_modal.dart` | 조정 금액 필드 포맷터 → `PriceInputFormatter(allowNegative: true)` |
| `reservation_create_modal.dart` | 동일 |
| 요금 표시 읽기 전용 | `.formattedPrice` 사용 |

---

## ✅ Phase 32: 읽기 전용 스테일 데이터 수정 (2026-05-19)

### 문제

편집 완료(`_onComplete`) 후 읽기 전용 모드로 복귀할 때 이전 값(구 `widget.reservation`)이 표시됨.

### 원인

`_buildSection1~4ReadOnly()` 메서드들이 `widget.reservation`을 직접 참조하고 있었음.
`onSaved(updated)` 호출 후 `widget.reservation`이 즉시 갱신되지 않아 스테일 데이터가 노출됨.

### 해결

모든 읽기 전용 빌드 메서드를 로컬 상태 변수로 전환:

| 섹션 | 변경 전 | 변경 후 |
|------|---------|---------|
| Section 1 | `widget.reservation.storeSummary` | `_storeSummary` |
| Section 1 | `widget.reservation.status` | `_status` |
| Section 2 | `widget.reservation.customerName/headCount/phone/memo` | `_*Controller.text` |
| Section 3 | `widget.reservation.isAllDay/startTime/endTime` | `_isAllDay`, `_startTime`, `_endTime` |
| Section 4 | `widget.reservation.platform/paymentMethod/calculatedPrice/priceAdjustment/totalPrice` | `_platform`, `_paymentMethod`, `_calculatedPrice`, `_adjustmentController.text` |

---

## ✅ Phase 33: 키보드 dismiss + Avoidance (2026-05-19)

### 키보드 dismiss

`_onComplete()` 시작 시 `FocusScope.of(context).unfocus()` 추가.

### 키보드 Avoidance

**문제**: 키보드가 올라오면 하단 입력 폼이 가려짐.

**시도 1 (실패)**: ScrollView 콘텐츠 하단에 `SizedBox(height: viewInsets.bottom)` 추가.
- 실패 원인: `Scrollable.ensureVisible`은 viewport 크기를 기준으로 동작. 콘텐츠 크기만 늘려서는 viewport가 줄지 않아 스크롤 불가.

**해결**: `Expanded` 위젯(ScrollView 컨테이너)에 하단 패딩 적용 → viewport 실제 축소:

```dart
Expanded(
  child: Padding(
    padding: EdgeInsets.only(
      bottom: _isEditing
          ? MediaQuery.of(context).viewInsets.bottom
          : 0,
    ),
    child: _buildScrollArea(textTheme),
  ),
),
```

편집 모드에서만 적용 (읽기 전용 모드에서 키보드가 올라오지 않으므로).

---

## ✅ Phase 34: '최종 요금' 필드 추가 (2026-05-19)

### 요청

섹션 4에 '최종 요금' 읽기 전용 필드 추가: `calculatedPrice + priceAdjustment = totalPrice`.
Firestore의 `totalPrice` 필드와 연동.

### 구현

**읽기 전용 (`_buildSection4ReadOnly`)**:

```dart
TitleTextLabel(
  title: '최종 요금',
  content: widget.reservation.totalPrice.formattedPrice,
),
```

**편집 모드 (`_buildSection4Edit`)**:

```dart
// 조정 금액 파싱 (로컬 변수)
final rawAdj = _adjustmentController.text.replaceAll(',', '');
final adjustment = int.tryParse(rawAdj) ?? 0;
final totalPrice = _calculatedPrice + adjustment;

TitleTextLabel(
  title: '최종 요금',
  content: totalPrice.formattedPrice,
),
```

- `_adjustmentController`에 `onChanged: (_) => setState(() {})` 추가 → 입력 시 실시간 업데이트
- `reservation_create_modal.dart`에도 동일 패턴 적용

---

## ✅ Phase 35: 퇴실 시간 변경 시 입실 시간 밀어내기 (2026-05-19)

### 변경 전 동작

퇴실 시간을 입실 이전으로 조정하면 퇴실이 `startTime + 1h/1d`로 고정됨 → 퇴실을 앞으로 당길 수 없었음.

### 변경 후 동작 (time_slot_input_form과 동일)

퇴실 시간을 변경했을 때 `newEnd <= _startTime`이면:
- `_endTime = newEnd` (퇴실을 사용자가 선택한 값으로 설정)
- `_startTime = newEnd - 1h` (시간 예약) / `newEnd - 1d` (종일 예약) 로 입실을 앞으로 밀어냄

```dart
onDateTimeChanged: (dt) {
  final newEnd = _isAllDay ? dt.add(const Duration(days: 1)) : dt;
  setState(() {
    _endTime = newEnd;
    // 퇴실이 입실과 같거나 이전이면 입실을 퇴실 1시간/1일 앞으로 밀어냄
    if (!newEnd.isAfter(_startTime)) {
      _startTime = _isAllDay
          ? newEnd.subtract(const Duration(days: 1))
          : newEnd.subtract(const Duration(hours: 1));
    }
  });
  _recalculatePrice();
},
```

### 적용 파일

- `reservation_detail_modal.dart` — 편집 모드 퇴실 피커
- `reservation_create_modal.dart` — 퇴실 피커

---

## ✅ Phase 36: n번째 예약 카운트 실제 데이터 연결 (2026-05-19)

### 요구사항

`_buildSection5`의 `"n번째 예약입니다."` 문구에서 n을 하드코딩(`1`) → 실제 데이터로 교체.
n = 해당 점포에서 동일 `customerName` + `customerPhone`을 가진 예약의 총 수.

### 구현 레이어

**DataSource** (`reservation_data_source.dart`):
- Firestore 집계 쿼리(`count().get()`) 추가 — 문서 로드 없이 카운트만 조회
  ```dart
  final snapshot = await _reservationsRef(storeId)
      .where('customerName', isEqualTo: customerName)
      .where('customerPhone', isEqualTo: customerPhone)
      .count()
      .get();
  return snapshot.count ?? 0;
  ```

**Repository 인터페이스/구현체** (`reservation_repository.dart`, `reservation_repository_impl.dart`):
- `getReservationCountByCustomer({storeId, customerName, customerPhone}) → Either<Exception, int>` 추가

**UseCase 인터페이스/구현체** (`reservation_use_case.dart`):
- Repository 위임 메서드 추가

**Controller** (`home_reservation_actions_controller.dart`):
- `getReservationCountByCustomer(...)` 추가, 실패 시 `1` 반환(폴백)

**Modal** (`reservation_detail_modal.dart`):
- `int _reservationCount = 1` 상태 필드 추가
- `initState`에서 `_loadReservationCount()` 호출 (비동기, mounted 체크)
- `_buildSection5`: `const int reservationCount = 1` + TODO 제거 → `$_reservationCount` 사용

### Firestore 인덱스 주의사항

`customerName` + `customerPhone` 복합 equality 쿼리는 **Firestore 복합 인덱스**가 필요할 수 있음.
실행 시 인덱스 오류가 발생하면 에러 메시지에 포함된 Firebase Console 링크로 인덱스 생성.
컬렉션: `stores/{storeId}/reservations`, 필드: `customerName ASC`, `customerPhone ASC`

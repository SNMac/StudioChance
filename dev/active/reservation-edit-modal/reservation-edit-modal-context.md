# 예약 수정 모달 — 컨텍스트 및 참조

Last Updated: 2026-04-19 (파기 확정 — reservation_edit_modal.dart 삭제 완료, 편집 로직은 ReservationDetailModal 내부 통합)

---

## 관련 파일 경로

### ⚠️ 파기된 파일 (2026-04-19 삭제)
| 파일 | 사유 |
|------|------|
| ~~`lib/presentation/home/widgets/three_day_calendar/reservation_edit_modal.dart`~~ | ReservationDetailModal 인라인 편집 모드 통합으로 독립 파일 불필요, 삭제 완료 |

### 생성/수정 파일 (Phase 0 정리 작업)
| 파일 | 역할 |
|------|------|
| `lib/constants/data_constants.dart` | 플랫폼/결제수단 상수 추가 (수정) |
| `lib/presentation/commons/widgets/safe_area_with_padding.dart` | `top` 파라미터 추가 (수정) |
| `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart` | ModalBodyPadding → SafeAreaWithPadding 교체 (수정) |

### 삭제 파일
| 파일 | 사유 |
|------|------|
| `lib/presentation/commons/widgets/modal_body_padding.dart` | SafeAreaWithPadding으로 통일, 사용처 1곳뿐 |

### 참조 파일
| 파일 | 참조 목적 |
|------|-----------|
| `reservation_detail_modal.dart` | 모달 shell 패턴 (ModalGrabber + ModalAppBar + Expanded scroll) |
| `store_form_screen.dart` | GroupedFormContainer + 컴포넌트 조합 패턴 |
| `price_setting_input_form.dart` | GroupedFormContainer header 사용 패턴 |
| `reservation_cell.dart` | `ReservationDisplayData`, `ReservationStatus` 참조 |
| `grouped_form_container.dart` | header/footer 파라미터 구조 |
| `title_date_time_button.dart` | `CupertinoDatePickerMode.dateAndTime` 사용법 |
| `memo_text_field.dart` | maxLength + 카운터 패턴 |

---

## 도메인 엔티티 구조

### `Reservation` (`lib/domain/entities/reservation.dart`)
```dart
@freezed
abstract class Reservation with _$Reservation {
  const factory Reservation({
    required String id,
    required StoreSummary storeSummary,   // 예약 점포
    required StoreMemberInfo writer,       // 작성자 (수정 불가)
    required ReservationStatus status,    // 예약 상태
    required String customerName,          // 예약자명
    required int headCount,                // 인원
    required String customerPhone,         // 연락처
    required String memo,                  // 메모
    required bool isAllDay,               // 하루종일
    required DateTime startTime,           // 입실 일시
    required DateTime endTime,             // 퇴실 일시
    required String platform,             // 예약 플랫폼
    required String paymentMethod,         // 결제 방식
    required int calculatedPrice,          // 요금
    required int priceAdjustment,          // 추가 요금/할인
    required int totalPrice,              // 합계 (calculatedPrice + priceAdjustment)
  }) = _Reservation;
}
```

### `ReservationStatus` (`lib/domain/enums/reservation_status.dart`)
```dart
enum ReservationStatus {
  pending,    // 입금 대기
  confirmed,  // 예약 확정
  canceled,   // 예약 취소
}
// displayName getter 존재
```

### `StoreSummary` (`lib/domain/entities/store_summary.dart`)
```dart
@freezed
abstract class StoreSummary with _$StoreSummary {
  const factory StoreSummary({
    required String id,
    required String name,
    required StoreColor color,
  }) = _StoreSummary;
}
```

---

## 기존 컴포넌트 사용법 요약

### GroupedFormContainer — header/footer 패턴
```dart
GroupedFormContainer(
  header: Padding(
    padding: const EdgeInsetsDirectional.only(start: 16, bottom: 8),
    child: Text('n번째 예약입니다.', style: textTheme.bodyMedium?.copyWith(color: context.secondaryLabel)),
  ),
  footer: Padding(
    padding: const EdgeInsetsDirectional.only(start: 16, top: 8),
    child: Text('할인인 경우 -[값]을 입력해주세요', style: textTheme.labelMedium?.copyWith(color: context.secondaryLabel)),
  ),
  children: [...],
)
```
`header`는 컨테이너 **위**, `footer`는 **아래**에 렌더링됨.

### TitlePopupButton — 점포 색상 dot 패턴
```dart
TitlePopupButton<StoreSummary>(
  title: '예약 점포',
  selectedValue: state.storeSummary,
  items: availableStores,
  itemLabelBuilder: (s) => s.name,
  itemLeadingBuilder: (s) => Container(
    width: 8, height: 8,
    decoration: BoxDecoration(
      color: Color(s.color.foregroundColorValue),
      shape: BoxShape.circle,
    ),
  ),
  onSelected: (s) => setState(() => _storeSummary = s),
)
```

### TitlePopupButton — TitlePopupButton padding 주의
`TitlePopupButton`은 내부에 `CupertinoButton(padding: EdgeInsetsDirectional.zero)`를 사용하므로,
`GroupedFormContainer` 내부 배치 시 별도 `Padding`으로 감싸야 함:
```dart
Padding(
  padding: const EdgeInsetsDirectional.symmetric(horizontal: horizontalPadding),
  child: TitlePopupButton<...>(...),
)
```

### TitleDateTimeButton — dateAndTime 모드
```dart
TitleDateTimeButton(
  title: '입실 일시',
  content: _formatDateTime(_startTime),
  isOpen: _isStartPickerOpen,
  onPressed: () => setState(() => _isStartPickerOpen = !_isStartPickerOpen),
  mode: CupertinoDatePickerMode.dateAndTime,
  initialDateTime: _startTime,
  onDateTimeChanged: (dt) => setState(() => _startTime = dt),
  use24hFormat: true,
)
```

### 하루종일 ON/OFF 동작
```dart
void _onAllDayChanged(bool value) {
  setState(() {
    _isAllDay = value;
    if (value) {
      // 시간을 00:00 / 23:59으로 리셋
      _startTime = DateTime(_startTime.year, _startTime.month, _startTime.day);
      _endTime = DateTime(_endTime.year, _endTime.month, _endTime.day, 23, 59);
    }
    // 피커 닫기
    _isStartPickerOpen = false;
    _isEndPickerOpen = false;
  });
}
```

### SignedInt 입력 포맷터
```dart
// 부호 있는 정수 입력 (음수 허용)
inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?\d*'))],
keyboardType: const TextInputType.numberWithOptions(signed: true),
```

---

## 모달 show 함수 패턴 (reservation_detail_modal.dart 참조)

```dart
Future<void> showReservationEditModal(
  BuildContext context, {
  required Reservation reservation,
  required List<StoreSummary> availableStores,
  required void Function(Reservation) onSaved,
}) {
  if (Platform.isIOS) {
    return showCupertinoSheet<void>(
      context: context,
      builder: (_) => ReservationEditModal(
        reservation: reservation,
        availableStores: availableStores,
        onSaved: onSaved,
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    barrierColor: modalBarrierColor,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(modalTopCornerRadius)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.6,   // TODO: 피그마 기준 적절한 값으로 조정
      minChildSize: 0.3,
      maxChildSize: 1.0,
      expand: false,
      snap: true,
      snapSizes: const [0.6, 1.0],
      builder: (_, controller) => ReservationEditModal(
        reservation: reservation,
        availableStores: availableStores,
        onSaved: onSaved,
        scrollController: controller,
      ),
    ),
  );
}
```

---

## ⚠️ Enum 전환 (2026-04-19)

`reservationPlatforms` / `paymentMethods` const List&lt;String&gt;은 **삭제됨**.
enum으로 대체:

```dart
// lib/domain/enums/reservation_platform.dart
enum ReservationPlatform {
  @JsonValue('NAVER') naver,
  @JsonValue('SPACECLOUD') spaceCloud,
  @JsonValue('YANOLJA') yanolja,
  @JsonValue('OTHER') other;
  String get displayName => ...;
}

// lib/domain/enums/payment_method.dart
enum PaymentMethod {
  @JsonValue('ON_SITE') onSite,
  @JsonValue('BANK_TRANSFER') bankTransfer,
  @JsonValue('OTHER') other;
  String get displayName => ...;
}
```

모달에서 사용:
```dart
TitlePopupButton<ReservationPlatform>(
  items: ReservationPlatform.values,
  itemLabelBuilder: (p) => p.displayName,
  ...
)
```

`Reservation.platform: String` → `ReservationPlatform`,
`Reservation.paymentMethod: String` → `PaymentMethod`

---

## 날짜 포맷 헬퍼 구현 예시

기존 `lib/presentation/commons/extensions/time_formatter.dart`에 추가하거나 모달 파일 내에 private 함수로 정의:

```dart
String _formatDateTime(DateTime dt, {bool dateOnly = false}) {
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final weekday = weekdays[dt.weekday - 1];
  if (dateOnly) {
    return '${dt.year}. ${dt.month.toString().padLeft(2, '0')}. ${dt.day.toString().padLeft(2, '0')}. ($weekday)';
  }
  return '${dt.year}. ${dt.month.toString().padLeft(2, '0')}. ${dt.day.toString().padLeft(2, '0')}. ($weekday) '
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
```

---

## ModalBodyPadding 제거 — 기술 메모

### ModalBodyPadding 구조
```dart
// 현재 (삭제 예정)
class ModalBodyPadding extends StatelessWidget {
  // SafeArea(top: false) + Padding(fromLTRB(16, 16, 16, 8))
}
```

### SafeAreaWithPadding 수정 후 사용법
```dart
// modal_body_padding.dart 삭제 후 교체
SafeAreaWithPadding(
  top: false,   // 모달: AppBar가 상단 담당하므로 top=false
  padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 8),
  child: ...,
)
```

### 기존 SafeAreaWithPadding 사용처 영향 없음
- `StoreFormScreen` 등은 `top: true` 기본값 → 변경 없음
- 신규 `reservation_edit_modal.dart`는 처음부터 `SafeAreaWithPadding(top: false)` 사용

---

## 미결/후속 작업

| 항목 | 내용 |
|------|------|
| `n번째` 계산 | 실제 데이터 연결 전까지 `1` 하드코딩 |
| 입금/확정 안내문 | 별도 안내문 화면 Phase에서 구현 |
| `onSaved` 실제 연결 | 예약 저장 Use Case + Repository 구현 후 연결 |
| `availableStores` 공급 | Home Provider에서 사용자 가입 점포 목록 fetch 후 전달 |
| `totalPrice` 계산 | `calculatedPrice + priceAdjustment` — 완료 시점에 계산 |
| Android `initialChildSize` | 피그마 기준 특정 필드까지 보이는 높이로 조정 (현재 0.6 임시) |
| iOS `topGap` | `showCupertinoSheet`의 `topGap` 미설정 — 추후 조정 |

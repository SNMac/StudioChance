# 입금 안내문 — 핵심 파일 및 의존성

Last Updated: 2026-05-19

## 수정 대상 파일

| 파일 | 변경 내용 |
|------|----------|
| `pubspec.yaml` | `share_plus` 추가 |
| `lib/domain/entities/store.dart` | `bankName`, `bankAccountNumber`, `bankAccountHolder`, `paymentDeadlineHours`, `confirmationNotes` 추가 |
| `lib/data/models/store_model.dart` | 동일 5개 필드 추가, `toEditableJson`, `toEntity`, `fromEntity` 업데이트 |
| `lib/router/router_path.dart` | `paymentInstruction` case 추가 |
| `lib/router/app_router.dart` | home 서브 라우트로 `paymentInstruction` 추가 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart:932` | `_buildSection5`의 `입금 안내문` onPressed 연결 |

## 신규 생성 파일

| 파일 | 역할 |
|------|------|
| `lib/presentation/providers/store_detail_provider.dart` | Store 상세 조회 family provider |
| `lib/presentation/home/screens/payment_instruction_screen.dart` | 입금 안내문 화면 |

## Store 신규 필드 상세

```dart
// domain/entities/store.dart
String? bankName;           // 점포 계좌 은행
String? bankAccountNumber;  // 점포 계좌번호
String? bankAccountHolder;  // 점포 계좌 예금주
int?    paymentDeadlineHours; // 입금 마감 n시간
String? confirmationNotes;  // 확정 안내문 주의사항 (추후 확정 안내문용)

// data/models/store_model.dart
// @Default(null) 모두 nullable, JSON key = camelCase
// toEditableJson() 에 5개 필드 포함 필수
```

## 안내문 텍스트 빌드 로직 (핵심)

```dart
String _buildText(Reservation r, Store? store) {
  final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  final weekday = weekdays[r.startTime.weekday - 1];
  final durationHours = r.endTime.difference(r.startTime).inHours;

  final dateStr = '${r.startTime.year}년 '
      '${r.startTime.month.toString().padLeft(2, '0')}월 '
      '${r.startTime.day.toString().padLeft(2, '0')}일 '
      '($weekday) '
      '${r.startTime.hour.toString().padLeft(2, '0')}시 ~ '
      '${r.endTime.hour.toString().padLeft(2, '0')}시 '
      '(${durationHours}시간)';

  final deadlineStr = store?.paymentDeadlineHours != null
      ? '✔ 입금 마감 시간: 앱에 예약 등록한 시간 기준 ${store!.paymentDeadlineHours}시간 이내\n'
      : '';

  return '''[${r.storeSummary.name} 예약 입금 안내]
안녕하세요, ${r.storeSummary.name}입니다.

아래 내용으로 예약이 진행되었으며, 입금을 완료해 주시면 예약이 확정됩니다.

• 예약자명: ${r.customerName}
• 예약자 전화번호: ${r.customerPhone.formattedPhone}
• 예약 시간: $dateStr
• 예약 인원: ${r.headCount}인
• 요금 안내: ${r.totalPrice}원

✔ 입금 계좌: ${store?.bankName ?? ''} ${store?.bankAccountNumber ?? ''} (${store?.bankAccountHolder ?? ''})
${deadlineStr}
예약자와 실제 이용자의 이름 및 전화번호가 다를 경우 미리 알려주세요.
입금 확인 후 예약 확정 안내를 드리겠습니다. 감사합니다.''';
}
```

## 핵심 의존성

### StoreUseCase
- `getStore(storeId)` — 이미 존재, 신규 provider에서 호출

### 기존 포맷 헬퍼
- `lib/presentation/commons/extensions/price_formatter.dart` — `formattedPrice`
- `lib/presentation/commons/extensions/phone_formatter.dart` — `formattedPhone`

### share_plus
- `Share.share(text)` — iOS: 시스템 공유 시트, Android: Intent chooser

## UI 스펙

| 항목 | 값 |
|------|-----|
| 본문 폰트 | `textTheme.bodyLarge` + `FontWeight.normal` |
| AppBar ↔ 본문 상단 | 32px |
| 본문 하단 ↔ 하단버튼 상단 | 32px |
| 좌우 패딩 | 16px |
| 하단버튼 1 | 복사하기 (OutlinedButton, full width) |
| 하단버튼 2 | 공유하기 (OutlinedButton, full width) |
| AppBar leading | `AppBarNaviBackButton` (기본값) |
| AppBar trailing | 없음 |

## 코드 생성 필요 파일

```
dart run build_runner build --delete-conflicting-outputs
```
재생성 대상:
- `store.freezed.dart`
- `store_model.freezed.dart`, `store_model.g.dart`
- `store_detail_provider.g.dart`

## 관련 문서
- `dev/active/reservation-detail-modal/` — 예약 상세 모달 컨텍스트
- `dev/active/home-screen/` — 홈 화면 컨텍스트

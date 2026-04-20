# 데이터 모델 개선 - 플랜

Last Updated: 2026-04-20

## 개요

Firestore 데이터 모델의 버그 수정 및 유지보수성 개선.  
총 4가지 이슈를 해결한다.

---

## 배경 분석

### 이슈 1: UserModel.fcmTokens 덮어쓰기 버그

`UserModel.fromEntity()`에 `fcmTokens`가 없어서 기본값 `[]`으로 설정됨.
이 상태로 Firestore에 저장하면 기존 FCM 토큰 배열이 소실된다.

**해결 방향**
- `fcmTokens`는 도메인 엔티티(User)에 포함할 필요 없음.
  - 향후 다른 사용자에게 푸시 알림 발송이 필요하면 `NotificationRepository` 인터페이스에
    `sendToUser(userId, message)` 메서드를 정의하고, Data 구현체가 fcmTokens 조회 + FCM 발송을 담당.
  - 이 구조면 UseCase는 토큰 존재를 몰라도 되고, fcmTokens는 완전히 Data 레이어 관심사가 됨.
- **즉시 수정**: `UserModel.fcmTokens`에 `@JsonKey(includeToJson: false)` 추가.
  - 읽기 시에는 Firestore의 fcmTokens 배열이 정상 파싱됨.
  - 쓰기 시에는 해당 필드가 JSON에서 제외되어 덮어쓰기 방지.
  - FCM 토큰 추가/제거는 DataSource에서 `FieldValue.arrayUnion/arrayRemove`로만 수행.

### 이슈 2: DateTime 필드 TimestampConverter 누락

Firestore는 날짜를 `Timestamp` 타입으로 저장/반환하는데,
`json_serializable` 기본 처리는 ISO 8601 문자열을 기대함.
변환기 없이 Firestore 문서를 읽으면 런타임 타입 에러 발생.

영향 필드:
- `ReservationModel.startTime` (DateTime)
- `ReservationModel.endTime` (DateTime)
- `StoreCustomerModel.lastReservationDate` (DateTime)

`TimestampConverter`는 `lib/common/converters/timestamp_converter.dart`에 이미 존재함.

### 이슈 3: StoreCustomerModel 집계 필드 동시성

`visitCount`, `totalSpent`는 예약 생성/취소 시 원자적으로 증가/감소해야 함.
앱단에서 읽고 계산해서 쓰면 동시 접근 시 race condition 발생.

**해결 방향**
- DataSource에서 `FieldValue.increment(n)`을 사용해야 한다는 설계 원칙을 문서화.
- 현재 이 모델을 사용하는 코드가 없으므로, 주석으로 의도를 명시해두는 수준으로 처리.
- 향후 `StoreCustomerDataSource` 구현 시 반드시 atomic 증가 사용.

### 이슈 4: DayGroupModel.days - List<int> 요일 표현 불명확

`1~7`이 어느 요일을 의미하는지 주석에만 의존하고 있어 실수 가능성 있음.
`Weekday` enum을 도입해 타입 안전성을 높인다.

---

## 구현 계획

### Phase 1: 버그 수정 (즉시)

**1-1. UserModel.fcmTokens - includeToJson: false 추가**

`lib/data/models/user_model.dart`

```dart
@JsonKey(includeToJson: false) @Default([]) List<String> fcmTokens,
```

→ `@JsonKey(includeToJson: false)`를 `@Default([])`와 함께 사용.
→ `fromEntity`는 수정 불필요 (fcmTokens 없이도 읽을 때만 파싱됨).

**1-2. TimestampConverter 적용**

`lib/data/models/reservation_model.dart`
```dart
@TimestampConverter() required DateTime startTime,
@TimestampConverter() required DateTime endTime,
```

`lib/data/models/store_customer_model.dart`
```dart
@TimestampConverter() required DateTime lastReservationDate,
```

→ import: `package:studio_chance/common/converters/timestamp_converter.dart`

---

### Phase 2: Weekday enum 도입

**2-1. enum 파일 생성**

`lib/domain/enums/weekday.dart`

```dart
@JsonEnum()
enum Weekday {
  @JsonValue(1) monday,
  @JsonValue(2) tuesday,
  ...
  @JsonValue(7) sunday;

  String get displayName => switch (this) { ... };
}
```

Firestore 저장값은 기존 `1~7` int와 동일하게 유지 (마이그레이션 불필요).

**2-2. DayGroupModel 필드 타입 변경**

`lib/data/models/day_group_model.dart`

```dart
@Default([]) List<Weekday> days,
```

**2-3. DayGroup 엔티티 필드 타입 변경**

`lib/domain/entities/day_group.dart`

```dart
required List<Weekday> days,
```

**2-4. 코드 생성 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### Phase 3: StoreCustomerModel DataSource 설계 원칙 문서화

**3-1. 모델에 주석 추가**

`lib/data/models/store_customer_model.dart`에 집계 필드에 주석 추가:
```dart
// ⚠️ 직접 덮어쓰기 금지. DataSource에서 FieldValue.increment()로만 업데이트.
required int totalSpent,
// ⚠️ 직접 덮어쓰기 금지. DataSource에서 FieldValue.increment()로만 업데이트.
required int visitCount,
```

---

## 코드 생성 의존성

모든 변경 후 반드시 실행:
```bash
dart run build_runner build --delete-conflicting-outputs
```

영향 파일:
- `user_model.g.dart` (fcmTokens includeToJson 변경)
- `reservation_model.g.dart` (TimestampConverter)
- `store_customer_model.g.dart` (TimestampConverter)
- `day_group_model.g.dart` (Weekday enum)
- `day_group_model.freezed.dart` (Weekday enum)
- `weekday.g.dart` (신규)

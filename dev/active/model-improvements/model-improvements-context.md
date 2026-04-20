# 데이터 모델 개선 - 컨텍스트

Last Updated: 2026-04-20

## 핵심 파일

| 파일 | 역할 | 변경 여부 |
|------|------|-----------|
| `lib/data/models/user_model.dart` | UserModel | ✏️ fcmTokens includeToJson 추가 |
| `lib/data/models/reservation_model.dart` | ReservationModel | ✏️ TimestampConverter 추가 |
| `lib/data/models/store_customer_model.dart` | StoreCustomerModel | ✏️ TimestampConverter + 주석 |
| `lib/data/models/day_group_model.dart` | DayGroupModel | ✏️ days 타입 변경 |
| `lib/domain/entities/day_group.dart` | DayGroup 엔티티 | ✏️ days 타입 변경 |
| `lib/domain/enums/weekday.dart` | Weekday enum | 🆕 신규 생성 (part 선언 없음) |
| `lib/presentation/commons/store_input/screens/price_days_input_screen.dart` | 요일 선택 화면 | ✏️ Weekday enum 타입으로 전환 |
| `lib/presentation/commons/store_input/controllers/store_form_controllerable.dart` | 폼 컨트롤러 인터페이스 | ✏️ toggleDayGroupDay 시그니처 변경 |
| `lib/common/converters/timestamp_converter.dart` | TimestampConverter | 읽기 전용 |

## 기존 인프라

- `TimestampConverter` — `lib/common/converters/timestamp_converter.dart` 에 이미 존재
  - `Timestamp → DateTime` (fromJson), `DateTime → Timestamp` (toJson)
  - `JsonConverter<DateTime, Timestamp>` 구현체

- enum 패턴 참조: `lib/domain/enums/store_color.dart`, `reservation_status.dart`
  - `@JsonEnum()` + `@JsonValue('STRING')` 사용
  - `displayName` getter 필수

- `Weekday` enum의 `@JsonValue`는 **문자열이 아닌 int** 사용 (`@JsonValue(1)` 등)
  - 기존 Firestore days 배열이 `[1, 2, 3]` int 형태이므로 호환성 유지
- `@JsonEnum()` enum 파일에는 `part 'xxx.g.dart';` 선언 불필요
  - `json_serializable`은 해당 enum을 사용하는 모델의 `.g.dart`에 enum map 생성
  - 다른 enum들(store_color, reservation_status 등)도 동일하게 part 선언 없음

## 핵심 결정

### fcmTokens - User 엔티티 제외 이유

- fcmTokens는 Firebase Cloud Messaging 인프라 토큰. 도메인 비즈니스 로직과 무관.
- 향후 푸시 알림 발송: `NotificationRepository.sendToUser(userId, message)` 패턴 사용.
  - Data 구현체가 fcmTokens 조회 + FCM 발송 담당 → Domain은 토큰을 몰라도 됨.
- 현재 수정: `@JsonKey(includeToJson: false)` 추가로 쓰기 시 제외.
  - FCM 토큰 등록/제거는 DataSource에서 `FieldValue.arrayUnion/arrayRemove` 사용.

### Weekday enum - int JsonValue 사용 이유

- 기존 Firestore 문서의 days 배열이 `[1, 2, 3]` 정수형으로 저장되어 있을 경우 하위 호환성.
- 신규 저장에도 int로 저장되므로 Firestore 인덱스, 쿼리에 영향 없음.
- `1=월요일, 7=일요일` 기준 (ISO 8601 표준, Dart의 `DateTime.weekday`와 동일).

### StoreCustomerModel 집계 필드

- `totalSpent`, `visitCount` — 예약 생성/취소 시 `FieldValue.increment()` 로만 업데이트.
- `lastReservationDate` — 예약 생성 시 해당 예약의 startTime으로 업데이트.
- 현재 DataSource 코드 없음. 향후 구현 시 원자적 업데이트 사용 필수.

## 변경 후 코드 생성 필수

```bash
dart run build_runner build --delete-conflicting-outputs
```

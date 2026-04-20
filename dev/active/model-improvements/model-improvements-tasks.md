# 데이터 모델 개선 - 작업 체크리스트

Last Updated: 2026-04-20 (완료)

---

## Phase 1: 버그 수정 ✅

### 1-1. UserModel.fcmTokens - 덮어쓰기 방지 ✅

- [x] `lib/data/models/user_model.dart`
  - `@JsonKey(includeToJson: false) @Default([]) List<String> fcmTokens` 적용
- [x] `user_model.g.dart` toJson에서 fcmTokens 제외 확인

### 1-2. TimestampConverter - ReservationModel ✅

- [x] `lib/data/models/reservation_model.dart`
  - `@TimestampConverter()` startTime, endTime 적용

### 1-3. TimestampConverter - StoreCustomerModel ✅

- [x] `lib/data/models/store_customer_model.dart`
  - `@TimestampConverter()` lastReservationDate 적용
  - 집계 필드 주석 추가

### 1-4. 코드 생성 ✅

- [x] `dart run build_runner build --delete-conflicting-outputs` (12s, 61 outputs)

---

## Phase 2: Weekday enum 도입 ✅

### 2-1. Weekday enum 생성 ✅

- [x] `lib/domain/enums/weekday.dart` 신규 생성
  - 1=월, 7=일, 8=공휴일, ISO 8601 기준
  - `displayName`, `shortName` getter 구현

### 2-2. DayGroup 엔티티 타입 변경 ✅

- [x] `lib/domain/entities/day_group.dart` → `List<Weekday> days`

### 2-3. DayGroupModel 타입 변경 ✅

- [x] `lib/data/models/day_group_model.dart` → `List<Weekday> days`

### 2-4. 코드 생성 ✅

- [x] `weekday.g.dart`, `day_group_model.g.dart` 정상 생성 확인

### 2-5. Presentation 레이어 영향 수정 ✅

- [x] `lib/presentation/commons/extensions/day_group_formatter.dart`
  - `int` 기반 비교 → `Weekday` enum 기반으로 변경
  - `contains(8)` → `contains(Weekday.holiday)`
  - `d != 8` → `d != Weekday.holiday`
  - 요일 이름 Map 제거 → `Weekday.displayName`, `Weekday.shortName` getter 사용
  - `dart analyze` 경고 3건 해소

---

## Phase 3: StoreCustomerModel DataSource 원칙 문서화 ✅

### 3-1. 집계 필드 주석 추가 ✅

- [x] `totalSpent`, `visitCount`, `lastReservationDate` 위 주석 추가

---

## 완료 기준

- [x] `UserModel` toJson 결과에 fcmTokens 필드 없음
- [x] `ReservationModel`, `StoreCustomerModel` DateTime 필드가 Timestamp와 정상 변환
- [x] `DayGroupModel.days`가 `List<Weekday>` 타입이며 Firestore int 값(1~8)과 직렬화 호환
- [x] 코드 생성 오류 없음

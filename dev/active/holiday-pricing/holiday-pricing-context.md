# 공휴일 요금 적용 — 컨텍스트

## 현재 상태 (2026-05-19)

`PriceSetting.calculatePrice`에 `isHoliday` 파라미터가 추가되어 있으나,
공휴일 감지 로직은 미구현. 모든 호출부에서 `isHoliday: false` 고정.

### 관련 파일
| 파일 | 상태 |
|------|------|
| `lib/domain/entities/price_setting.dart` | `isHoliday` 파라미터 추가 완료 |
| `lib/domain/enums/weekday.dart` | `Weekday.holiday` 정의됨 (JsonValue=8) |
| `lib/domain/use_cases/reservation_use_case.dart` | `isHoliday: false` TODO 주석 |
| `lib/presentation/.../reservation_create_modal.dart` | `isHoliday: false` TODO 주석 |
| `lib/presentation/.../reservation_detail_modal.dart` | `isHoliday: false` TODO 주석 |

### 배경 — Weekday.holiday 매칭 문제
`DateTime.weekday`는 1(월)~7(일)만 반환. `Weekday.holiday`(index=7, JsonValue=8)는
`w.index + 1 == start.weekday` 조건에서 8 == max7 이므로 절대 매칭되지 않음.
→ PR #9 리뷰에서 지적됨. `isHoliday` 파라미터를 추가해 호출부에서 판단하도록 설계.

---

## 구현 방법

### 데이터 소스 — 공공데이터포털 특일 정보 API

**한국천문연구원 특일 정보 API** (무료, 공공 데이터)
- 엔드포인트: `https://apis.data.go.kr/B090041/openapi/service/SpcdeInfoService/getRestDeInfo`
- 파라미터: `solYear`, `solMonth`, `ServiceKey` (공공데이터포털 발급)
- 응답: 해당 월의 공휴일 목록 (날짜, 공휴일명)

### Clean Architecture 설계

```
domain/repository_interfaces/holiday_repository.dart
  └── abstract interface HolidayRepository
        Future<Either<Exception, bool>> isHoliday(DateTime date)

data/data_sources/holiday_data_source.dart
  └── class HolidayDataSource
        Future<List<DateTime>> getHolidays({int year, int month})
        // 공공데이터포털 API 호출, 월별 캐시 보관

data/repositories/holiday_repository_impl.dart
  └── class HolidayRepositoryImpl implements HolidayRepository
        // DataSource 호출 후 Set<DateTime> 캐시로 O(1) 조회

domain/use_cases/holiday_use_case.dart  (선택)
  └── 복잡한 로직 필요 시 분리, 단순 조회는 Repository 직접 사용 가능
```

### UseCase 연동 (`_applyCalculatedPrice`)

```dart
// reservation_use_case.dart
Future<Reservation> _applyCalculatedPrice(Reservation reservation) async {
  final storeResult = await _storeRepository.getStore(...);
  final store = storeResult.toOption().toNullable();
  if (store == null) return reservation;

  // 공휴일 여부 판단
  final isHolidayResult = await _holidayRepository.isHoliday(reservation.startTime);
  final isHoliday = isHolidayResult.getOrElse((_) => false);

  final calculatedPrice = store.priceSettings.calculatePrice(
    start: reservation.startTime,
    end: reservation.endTime,
    headCount: reservation.headCount,
    isAllDay: reservation.isAllDay,
    isHoliday: isHoliday, // ← 실제 값 전달
  );
  ...
}
```

### UI 모달 연동

모달의 `_recalculatePrice`는 `ConsumerStatefulWidget`이므로 `ref`를 통해 provider 접근 가능.

```dart
// holiday_provider.dart (lib/presentation/providers/ 또는 domain/use_cases/)
@riverpod
Future<bool> isHoliday(Ref ref, DateTime date) async {
  final repo = ref.read(holidayRepositoryProvider);
  final result = await repo.isHoliday(date);
  return result.getOrElse((_) => false);
}

// reservation_create_modal.dart — _recalculatePrice
void _recalculatePrice() async {
  final ps = _priceSetting;
  if (ps == null) return;
  final headCount = int.tryParse(_headCountController.text) ?? 0;
  final isHoliday = await ref.read(isHolidayProvider(_startTime).future);
  final price = ps.calculatePrice(
    start: _startTime,
    end: _endTime,
    headCount: headCount,
    isAllDay: _isAllDay,
    isHoliday: isHoliday,
  );
  if (mounted) setState(() => _calculatedPrice = price);
}
```

### API Key 관리

- 공공데이터포털 API 키는 `.gitignore` 처리된 별도 파일에 분리 (CLAUDE.md 중요 사항 참고)
- 예: `lib/constants/api_keys.dart` (gitignore 처리)

### 캐시 전략

- 공휴일은 연간 거의 변하지 않으므로 월별로 메모리 캐시
- `Map<String, Set<int>>` — key: `"YYYY-MM"`, value: 해당 월의 공휴일 일(day) 집합
- 앱 재시작 시 캐시 초기화 (또는 Firestore에 저장해 오프라인 지원)

---

## 구현 시 수정할 파일 목록

1. `lib/domain/repository_interfaces/holiday_repository.dart` — 신규
2. `lib/data/data_sources/holiday_data_source.dart` — 신규
3. `lib/data/repositories/holiday_repository_impl.dart` — 신규
4. `lib/domain/use_cases/reservation_use_case.dart` — `HolidayRepository` 주입, TODO 제거
5. `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` — async 처리, TODO 제거
6. `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` — async 처리, TODO 제거
7. `lib/constants/api_keys.dart` — API 키 상수 추가 (gitignore)
8. `pubspec.yaml` — HTTP 클라이언트 패키지 추가 (`dio` 또는 `http`)

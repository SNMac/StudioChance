# Domain Layer Critical/Important 이슈 수정 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** GitHub 이슈 [#15](https://github.com/SNMac/StudioChance/issues/15)에서 지적된 Domain Layer의 Critical 3건, Important 4건, Minor 4건(총 11건, M-1은 이미 해결되어 제외)을 각각 독립적으로 테스트 가능한 최소 단위로 수정한다.

**Architecture:** 기존 Clean Architecture(Data/Domain/Presentation) 구조를 그대로 유지한다. `domain/entities`, `domain/use_cases`, `domain/repository_interfaces`, `domain/enums`(→ `common/enums`로 이동) 및 이들을 사용하는 소수의 `presentation` 호출부만 손댄다. 새 계층이나 추상화는 추가하지 않는다.

**Tech Stack:** Flutter/Dart, `freezed`+`json_serializable`, `fpdart`(`Either`/`TaskEither`), `mocktail`(UseCase 단위 테스트), `logger`.

## Global Constraints

- 모든 UseCase/Repository 메서드는 `Either<Exception, T>` 반환, `result.fold(...)` 함수형 패턴 사용 (`isLeft()`/`isRight()` 명령형 스타일은 프로덕션 코드에서 금지)
- 콘솔 출력은 `logger` 패키지만 사용
- 커밋 메시지: `<type>: #15 - <한국어 설명>` 형식, 태스크 단위로 커밋
- 브랜치: `bug/#15-domain-layer-critical-important-fixes` (아직 없다면 `develop`에서 생성)
- Freezed 클래스나 `@riverpod` provider의 시그니처를 바꾸는 태스크(Task 9)만 `dart run build_runner build --delete-conflicting-outputs` 필요. 나머지는 불필요.
- 정식 출시 전(프로덕션 데이터 없음)이므로 Firestore 스키마/문서 변경에 대한 마이그레이션은 고려하지 않는다
- **[M-1] `space_option.dart`의 `empty()` ID는 이미 `const Uuid().v4()`로 수정 완료됨(#10에서 처리)** — 이번 계획에서는 다루지 않는다

---

## File Structure

| 파일 | 역할 |
|---|---|
| `lib/domain/entities/price_setting.dart` | [C-1] `isHoliday`를 콜백으로 변경 |
| `lib/domain/use_cases/reservation_use_case.dart` | [C-2] `_applyCalculatedPrice` 에러 전파 / [C-1] 호출부 갱신 / [I-3] 문서화 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart` | [C-1] `calculatePrice` 호출부 갱신 |
| `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart` | [C-1] `calculatePrice` 호출부 갱신 |
| `lib/domain/repository_interfaces/user_repository.dart` | [I-4] `softDeleteUser` 반환 타입 변경 |
| `lib/data/repositories/user_repository_impl.dart` | [I-4] `softDeleteUser` 구현 변경 |
| `lib/domain/use_cases/store_use_case.dart` | [C-3] `softDeleteStore` 추가 |
| `lib/domain/use_cases/auth_use_case.dart` | [C-3] 계정 삭제 시 관리자 점포 삭제 연동 |
| `lib/domain/use_cases/auth_use_case_provider.dart` | [C-3] `StoreUseCase` 의존성 주입 |
| `lib/domain/use_cases/user_use_case.dart` | [I-2] `fetchOrCreateUser` 제거 |
| `lib/presentation/providers/app_auth_controller.dart` | [I-2] `AuthUseCase.fetchOrCreateUser` 호출로 변경 |
| `lib/domain/enums/*.dart` (6개) → `lib/common/enums/*.dart` | [I-1] Domain 계층에서 이동 |
| `lib/common/enums/store_color.dart` | [M-2] 색상값 getter 제거 |
| `lib/presentation/commons/extensions/store_color_extensions.dart` | [M-2] 색상값 getter 신규 추가 (7개 호출부 import 갱신) |
| `lib/domain/entities/invite_info.dart` | [M-4] 불필요한 private constructor 제거 |
| `test/domain/use_cases/reservation_use_case_test.dart` | [M-5] `isRight()`/`isLeft()` → `fold` 스타일 |
| `CLAUDE.md` | [I-1] 아키텍처 트리 갱신 / [M-3] D10 결정 문서화 |

각 태스크는 파일 하나 또는 강하게 결합된 파일 소수만 건드리며, 태스크 단위로 커밋한다.

---

## Task 1: [C-1] `PriceSetting.calculatePrice` — 다일 예약 `isHoliday` 콜백화

**Files:**
- Modify: `lib/domain/entities/price_setting.dart:19-127`
- Modify: `lib/domain/use_cases/reservation_use_case.dart:216-222`
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart:322-344`
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart:226-231`
- Test: `test/domain/entities/price_setting_test.dart`

**Interfaces:**
- Consumes: `Weekday.holiday`(`lib/domain/enums/weekday.dart`), `DayGroup`/`TimeSlot`/`HeadcountRule` 기존 엔티티
- Produces: `PriceSetting.calculatePrice({..., bool Function(DateTime date)? isHoliday})` — 기존 `bool isHoliday = false` 파라미터를 대체. 생략 시 모든 날짜를 공휴일 아님으로 처리(하위 호환).

- [x] **Step 1: 실패하는(컴파일 안 되는) 테스트 작성**

`test/domain/entities/price_setting_test.dart`의 `void main()` 마지막 `group('calculatePrice — 하루종일 예약', ...)` 블록 바로 뒤(파일 끝나기 전, `main()`이 닫히기 전)에 새 그룹을 추가한다. 먼저 파일 상단 `_makeWeekendSplitSetting` 헬퍼 아래에 헬퍼를 하나 더 추가한다:

```dart
// 평일 DayGroup + Weekday.holiday DayGroup — isHoliday 콜백 테스트용
PriceSetting _makeHolidaySplitSetting({
  required int weekdayPrice,
  required int holidayPrice,
  bool isAllDay = false,
  bool isHourly = false,
  int startTime = 0,
  int endTime = 1440,
}) {
  return PriceSetting(dayGroups: [
    DayGroup(
      days: [
        Weekday.monday,
        Weekday.tuesday,
        Weekday.wednesday,
        Weekday.thursday,
        Weekday.friday,
      ],
      headcountRule: HeadcountRule(
        headcountBase: 999,
        headcountExtraPrice: 0,
        isHeadcountHourly: false,
        isHeadcountPerPerson: false,
      ),
      timeSlots: [
        TimeSlot(
          isAllDay: isAllDay,
          startTime: startTime,
          endTime: endTime,
          price: weekdayPrice,
          isHourly: isHourly,
          isPerPerson: false,
        ),
      ],
    ),
    DayGroup(
      days: [Weekday.holiday],
      headcountRule: HeadcountRule(
        headcountBase: 999,
        headcountExtraPrice: 0,
        isHeadcountHourly: false,
        isHeadcountPerPerson: false,
      ),
      timeSlots: [
        TimeSlot(
          isAllDay: isAllDay,
          startTime: startTime,
          endTime: endTime,
          price: holidayPrice,
          isHourly: isHourly,
          isPerPerson: false,
        ),
      ],
    ),
  ]);
}
```

그리고 `main()` 안, 기존 마지막 그룹(`calculatePrice — 하루종일 예약`) 뒤에 새 그룹을 추가한다:

```dart
  group('calculatePrice — isHoliday 콜백', () {
    test('isHoliday 콜백이 true를 반환하면 Weekday.holiday DayGroup을 사용한다', () {
      final setting = _makeHolidaySplitSetting(
        weekdayPrice: 10000,
        holidayPrice: 30000,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0), // 월요일
        end: DateTime(2026, 5, 18, 12, 0),
        headCount: 1,
        isHoliday: (date) => true,
      );
      expect(result, 30000);
    });

    test('isHoliday를 생략하면 모든 날짜가 공휴일이 아닌 것으로 처리된다', () {
      final setting = _makeHolidaySplitSetting(
        weekdayPrice: 10000,
        holidayPrice: 30000,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18, 10, 0), // 월요일
        end: DateTime(2026, 5, 18, 12, 0),
        headCount: 1,
      );
      expect(result, 10000);
    });

    test('다일 예약에서 isHoliday 콜백이 날짜별로 다르게 적용된다 (C-1 회귀 테스트)', () {
      // 이전 버그: 단일 bool이 모든 날짜에 일괄 적용되어 날짜별로 다른
      // 결과(평일 50,000 + 공휴일 90,000 = 140,000)를 만들 수 없었음
      final setting = _makeHolidaySplitSetting(
        weekdayPrice: 50000,
        holidayPrice: 90000,
        isAllDay: true,
      );
      final result = setting.calculatePrice(
        start: DateTime(2026, 5, 18), // 월요일
        end: DateTime(2026, 5, 20), // 2일: 5/18(월), 5/19(화)
        headCount: 1,
        isAllDay: true,
        isHoliday: (date) => date.day == 19, // 5/19(화)만 공휴일로 지정
      );
      expect(result, 140000); // 월 50,000(평일) + 화 90,000(공휴일)
    });
  });
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/domain/entities/price_setting_test.dart`
Expected: FAIL — 컴파일 에러. `isHoliday` 파라미터가 아직 `bool` 타입이라 `(date) => true`/`(date) => date.day == 19` 같은 함수를 전달할 수 없음.

- [x] **Step 3: `price_setting.dart` 수정**

`lib/domain/entities/price_setting.dart:19-127`(`calculatePrice` 메서드 전체, doc comment 포함)를 다음으로 교체한다:

```dart
  /// 예약 시간 및 인원 기반 기본 요금 계산.
  ///
  /// 예약 구간과 겹치는 모든 TimeSlot을 순회하여 겹치는 시간만큼 각각 계산 후 합산.
  /// DayGroup/TimeSlot이 매칭되지 않으면 0 반환.
  ///
  /// [isHoliday]는 날짜별 공휴일 여부를 판단하는 콜백이다. 다일(allDay) 예약은
  /// 날짜마다 다른 결과를 받을 수 있어야 하므로 단일 `bool`이 아닌 함수로 받는다.
  /// 생략 시 모든 날짜를 공휴일이 아닌 것으로 처리한다.
  int calculatePrice({
    required DateTime start,
    required DateTime end,
    required int headCount,
    bool isAllDay = false,
    bool Function(DateTime date)? isHoliday,
  }) {
    final holidayChecker = isHoliday ?? (_) => false;

    // 1. 하루종일 예약: 날짜별로 DayGroup을 찾아 합산
    //    - isHourly=false 다일 예약 시 일 수 반영
    //    - 날짜 경계를 넘는 다일 예약 시 각 날짜의 DayGroup 적용
    if (isAllDay) {
      final numberOfDays = end.difference(start).inDays;
      int totalPrice = 0;
      bool anyMatched = false;

      for (int dayOffset = 0; dayOffset < numberOfDays; dayOffset++) {
        final dayDate = start.add(Duration(days: dayOffset));
        // holidayChecker(dayDate)가 true이면 해당 날짜만 공휴일로 처리
        final dayWeekday = holidayChecker(dayDate)
            ? Weekday.holiday
            : Weekday.values.firstWhere(
                (w) => w.index + 1 == dayDate.weekday,
                orElse: () => Weekday.monday,
              );

        final dayGroup =
            dayGroups.where((g) => g.days.contains(dayWeekday)).firstOrNull;
        if (dayGroup == null) continue;

        final slot =
            dayGroup.timeSlots.where((s) => s.isAllDay).firstOrNull;
        if (slot == null) continue;

        anyMatched = true;

        // 하루종일 슬롯은 00:00~24:00 기준이므로 24시간 고정
        int dayBase = slot.isHourly ? (slot.price * 24).round() : slot.price;
        if (slot.isPerPerson) dayBase *= headCount;

        final rule = dayGroup.headcountRule;
        final extraPeople = max(0, headCount - rule.headcountBase);
        int dayExtra = 0;
        if (extraPeople > 0) {
          dayExtra = rule.headcountExtraPrice;
          if (rule.isHeadcountPerPerson) dayExtra *= extraPeople;
          if (rule.isHeadcountHourly) dayExtra = (dayExtra * 24).round();
        }

        totalPrice += dayBase + dayExtra;
      }

      return anyMatched ? totalPrice : 0;
    }

    // 2. 시간 지정 예약: 예약 요일의 DayGroup 탐색
    // holidayChecker(start)가 true이면 Weekday.holiday 그룹 우선 적용
    final weekday = holidayChecker(start)
        ? Weekday.holiday
        : Weekday.values.firstWhere(
            (w) => w.index + 1 == start.weekday, // Weekday.monday.index = 0, weekday = 1
            orElse: () => Weekday.monday,
          );

    final group = dayGroups.where((g) => g.days.contains(weekday)).firstOrNull;
    if (group == null) return 0;

    final totalHours = end.difference(start).inMinutes / 60.0;
    final startMinutes = start.hour * 60 + start.minute;
    final rawEndMinutes = end.hour * 60 + end.minute;
    // 끝 시간 00:00은 자정(1440분)으로 처리
    final endMinutes = rawEndMinutes == 0 ? 1440 : rawEndMinutes;

    int totalBase = 0;
    bool anyMatched = false;

    // 3. 겹치는 모든 TimeSlot의 기본 요금 합산
    for (final slot in group.timeSlots) {
      if (slot.isAllDay) continue;
      // 저장된 endTime 0은 하위 호환을 위해 1440으로 처리
      final slotEnd = slot.endTime == 0 ? 1440 : slot.endTime;
      final overlapStart = max(startMinutes, slot.startTime);
      final overlapEnd = min(endMinutes, slotEnd);
      if (overlapStart >= overlapEnd) continue;

      anyMatched = true;
      final overlapHours = (overlapEnd - overlapStart) / 60.0;
      int slotPrice = slot.isHourly ? (slot.price * overlapHours).round() : slot.price;
      if (slot.isPerPerson) slotPrice *= headCount;
      totalBase += slotPrice;
    }

    if (!anyMatched) return 0;

    // 4. 인원 추가 요금 계산 (전체 예약 시간 기준)
    final rule = group.headcountRule;
    final extraPeople = max(0, headCount - rule.headcountBase);
    int extraCharge = 0;
    if (extraPeople > 0) {
      extraCharge = rule.headcountExtraPrice;
      if (rule.isHeadcountPerPerson) extraCharge *= extraPeople;
      if (rule.isHeadcountHourly) extraCharge = (extraCharge * totalHours).round();
    }

    return totalBase + extraCharge;
  }
```

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/domain/entities/price_setting_test.dart`
Expected: PASS (기존 테스트 전부 + 신규 3개)

- [x] **Step 5: 호출부 3곳 갱신**

`lib/domain/use_cases/reservation_use_case.dart:221`:
```dart
      isHoliday: false, // TODO: 공휴일 API 연동 후 실제 값 전달
```
를
```dart
      isHoliday: (date) => false, // TODO: 공휴일 API 연동 후 실제 판단 로직 전달
```
로 교체.

`lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`의 `_recalculatePrice()`(약 322행 부근)와 `_applyInitialPrice()`(약 339행 부근) 두 곳 모두, `isHoliday: false,` (하나는 `// TODO: ...` 주석 포함, 하나는 미포함)를 `isHoliday: (date) => false, // TODO: 공휴일 API 연동 후 실제 값 전달`로 교체.

`lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart:230` 부근의 `isHoliday: false, // TODO: 공휴일 API 연동 후 실제 값 전달`를 `isHoliday: (date) => false, // TODO: 공휴일 API 연동 후 실제 값 전달`로 교체.

- [x] **Step 6: 정적 분석 및 전체 테스트 확인**

Run: `dart analyze`
Expected: 에러 없음

Run: `flutter test`
Expected: 전체 PASS

- [x] **Step 7: 커밋**

```bash
git add lib/domain/entities/price_setting.dart \
  lib/domain/use_cases/reservation_use_case.dart \
  lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart \
  lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart \
  test/domain/entities/price_setting_test.dart
git commit -m "$(cat <<'EOF'
fix: #15 - [C-1] PriceSetting.calculatePrice의 isHoliday를 날짜별 콜백으로 변경

다일 예약에서 단일 bool이 모든 날짜에 일괄 적용되던 문제를 수정.
호출부(_applyCalculatedPrice, 예약 모달 2곳)는 항상 false를 반환하는 콜백으로 갱신.
EOF
)"
```

---

## Task 2: [C-2] `ReservationUseCaseImpl._applyCalculatedPrice` — Store 조회 실패 에러 전파

**Files:**
- Modify: `lib/domain/use_cases/reservation_use_case.dart`
- Test: `test/domain/use_cases/reservation_use_case_test.dart`

**Interfaces:**
- Consumes: `StoreRepository.getStore(String)` (기존), `Logger`(`package:logger/logger.dart`)
- Produces: `_applyCalculatedPrice`가 이제 `Future<Either<Exception, Reservation>>` 반환(기존 `Future<Reservation>`에서 변경, private 메서드이므로 외부 영향 없음)

- [x] **Step 1: 실패하는 테스트 작성**

`test/domain/use_cases/reservation_use_case_test.dart`의 `group('createReservation', ...)` 블록 안, 마지막 test(`'Repository 실패 시 left를 전파한다'`, 124-138행) 뒤에 추가:

```dart
    test('Store 조회 실패 시 left를 반환하고 Repository를 호출하지 않는다', () async {
      when(
        () => mockStoreRepo.getStore(any()),
      ).thenAnswer((_) async => left(Exception('Store 조회 실패')));

      final result = await useCase.createReservation(
        reservation: fakeReservation,
      );

      expect(result.isLeft(), true);
      verifyNever(() => mockUserRepo.getCurrentUser());
      verifyNever(
        () => mockReservationRepo.createReservation(
          reservation: any(named: 'reservation'),
        ),
      );
    });
```

`group('updateReservation', ...)` 블록 안, 마지막 test(`'Repository 실패 시 left를 전파한다'`, 237-249행) 뒤에 추가:

```dart
    test('Store 조회 실패 시 left를 반환하고 Repository를 호출하지 않는다', () async {
      when(
        () => mockStoreRepo.getStore(any()),
      ).thenAnswer((_) async => left(Exception('Store 조회 실패')));

      final result = await useCase.updateReservation(
        reservation: fakeReservation,
      );

      expect(result.isLeft(), true);
      verifyNever(
        () => mockReservationRepo.updateReservation(
          reservation: any(named: 'reservation'),
        ),
      );
    });
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/domain/use_cases/reservation_use_case_test.dart`
Expected: FAIL — 현재 `_applyCalculatedPrice`는 `storeResult.toOption().toNullable()`로 에러를 `null`(=Store 없음)과 동일하게 취급하므로, Store 조회가 실패해도 기존 로직을 타고 `createReservation`/`updateReservation`이 정상 호출되어 `result.isLeft()`가 `false`로 나옴.

- [x] **Step 3: `reservation_use_case.dart` 수정**

파일 상단 import에 추가:

```dart
import 'package:logger/logger.dart';
```

`ReservationUseCaseImpl` 클래스 필드에 추가 (`_storeRepository` 선언 바로 아래):

```dart
  final Logger _logger = Logger();
```

`createReservation`(80-97행)을 다음으로 교체:

```dart
  @override
  Future<Either<Exception, Reservation>> createReservation({
    required Reservation reservation,
  }) async {
    final pricedResult = await _applyCalculatedPrice(reservation);

    return pricedResult.fold(
      (error) => Future.value(left(error)),
      (priced) =>
          getCurrentUserOrThrow(_userRepository).flatMap((currentUser) {
            final reservationWithWriter = priced.copyWith(
              writer: priced.writer.copyWith(user: currentUser),
            );

            return TaskEither(
              () => _reservationRepository.createReservation(
                reservation: reservationWithWriter,
              ),
            );
          }).run(),
    );
  }
```

`updateReservation`(153-159행)을 다음으로 교체:

```dart
  @override
  Future<Either<Exception, void>> updateReservation({
    required Reservation reservation,
  }) async {
    final pricedResult = await _applyCalculatedPrice(reservation);

    return pricedResult.fold(
      (error) => Future.value(left(error)),
      (priced) => _reservationRepository.updateReservation(reservation: priced),
    );
  }
```

`_applyCalculatedPrice`(202-228행, doc comment 포함)를 다음으로 교체:

```dart
  /// Store의 PriceSetting으로 calculatedPrice, totalPrice를 계산하여 반영한 예약 반환.
  ///
  /// Store 조회 자체가 실패(네트워크 등)하면 에러를 그대로 전파한다.
  /// Store가 존재하지 않거나 PriceSetting 매칭에 실패하면 기존 값을 유지한다.
  Future<Either<Exception, Reservation>> _applyCalculatedPrice(
    Reservation reservation,
  ) async {
    final storeResult = await _storeRepository.getStore(
      reservation.storeSummary.id,
    );

    return storeResult.fold(
      (error) {
        _logger.w(
          '가격 계산을 위한 Store 조회 실패 — storeId: ${reservation.storeSummary.id}',
          error: error,
        );
        return left(error);
      },
      (store) {
        if (store == null) return right(reservation);

        final priceSetting = store.priceSettingForSpace(
          reservation.spaceOptionId,
        );
        if (priceSetting == null) return right(reservation);

        final calculatedPrice = priceSetting.calculatePrice(
          start: reservation.startTime,
          end: reservation.endTime,
          headCount: reservation.headCount,
          isAllDay: reservation.isAllDay,
          isHoliday: (date) => false, // TODO: 공휴일 API 연동 후 실제 판단 로직 전달
        );

        return right(
          reservation.copyWith(
            calculatedPrice: calculatedPrice,
            totalPrice: calculatedPrice + reservation.priceAdjustment,
          ),
        );
      },
    );
  }
```

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/domain/use_cases/reservation_use_case_test.dart`
Expected: 전체 PASS (기존 테스트 포함 — `setUp()`의 기본 스텁 `mockStoreRepo.getStore(any()) → right(null)`는 "Store 없음" 경로이므로 영향 없음)

- [x] **Step 5: 정적 분석 확인**

Run: `dart analyze`
Expected: 에러 없음

- [x] **Step 6: 커밋**

```bash
git add lib/domain/use_cases/reservation_use_case.dart \
  test/domain/use_cases/reservation_use_case_test.dart
git commit -m "$(cat <<'EOF'
fix: #15 - [C-2] _applyCalculatedPrice가 Store 조회 실패를 에러로 전파하도록 수정

기존에는 storeResult.toOption().toNullable()로 에러(left)와
"Store 없음"(right(null))이 동일하게 취급되어 조회 실패 시에도
잘못된(미계산) 가격이 조용히 저장될 수 있었음.
EOF
)"
```

---

## Task 3: [I-4] `UserRepository.softDeleteUser` — `Either` 반환으로 전환 (Task 4의 선행 작업)

**Files:**
- Modify: `lib/domain/repository_interfaces/user_repository.dart:38`
- Modify: `lib/data/repositories/user_repository_impl.dart:172-183`
- Test: `test/data/repositories/user_repository_test.dart`

**Interfaces:**
- Consumes: `toException(Object)`(`lib/common/utils/exception_utils.dart`, 이미 파일 내 사용 중)
- Produces: `UserRepository.softDeleteUser(String uid) → Future<Either<Exception, void>>` (기존 `Future<void>`에서 변경 — Task 4에서 `AuthUseCaseImpl.delete()`가 이 시그니처를 사용)

- [x] **Step 1: 실패하는 테스트 작성**

`test/data/repositories/user_repository_test.dart`의 `group('updateStoreInfo', ...)` 뒤(파일의 `main()` 마지막)에 새 그룹 추가:

```dart
  group('softDeleteUser', () {
    test('성공 시 right(null)을 반환한다', () async {
      when(() => mockUserDs.softDeleteUser(any())).thenAnswer((_) async {});

      final result = await repository.softDeleteUser('user-123');

      expect(result.isRight(), true);
      verify(() => mockUserDs.softDeleteUser('user-123')).called(1);
    });

    test('DataSource 실패 시 left를 반환한다', () async {
      when(
        () => mockUserDs.softDeleteUser(any()),
      ).thenThrow(Exception('탈퇴 실패'));

      final result = await repository.softDeleteUser('user-123');

      expect(result.isLeft(), true);
    });
  });
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/data/repositories/user_repository_test.dart`
Expected: FAIL — 컴파일 에러. `repository.softDeleteUser(...)`가 현재 `Future<void>`를 반환하므로 `result.isRight()`/`result.isLeft()` 호출 불가.

- [x] **Step 3: 인터페이스 및 구현체 수정**

`lib/domain/repository_interfaces/user_repository.dart:38`:
```dart
  Future<void> softDeleteUser(String uid);
```
를
```dart
  /// 유저 데이터를 Soft Delete 처리 (탈퇴용)
  Future<Either<Exception, void>> softDeleteUser(String uid);
```
로 교체 (바로 위 37행의 기존 doc comment 한 줄은 제거하고 위 코드로 합침).

`lib/data/repositories/user_repository_impl.dart:172-183`을 다음으로 교체:

```dart
  @override
  Future<Either<Exception, void>> softDeleteUser(String uid) async {
    try {
      await _userDataSource.softDeleteUser(uid);

      _logger.i('사용자 Soft Delete 완료 (회원 탈퇴)\nuid: $uid');
      return right(null);
    } catch (e) {
      _logger.e('사용자 Soft Delete 실패');
      return left(toException(e));
    }
  }
```

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/data/repositories/user_repository_test.dart`
Expected: PASS

- [x] **Step 5: 컴파일 확인 (호출부는 Task 4에서 갱신)**

Run: `dart analyze lib/domain/use_cases/auth_use_case.dart`
Expected: `_userRepository.softDeleteUser(currentUser.id)` 호출부(현재 `try { await ... } catch`)가 반환 타입 변경으로 인해 에러 없이 컴파일되지만(값을 버리는 `await` 표현식 자체는 유효), 실제 동작 수정은 Task 4에서 진행하므로 이 시점에는 경고만 확인하고 넘어간다.

- [x] **Step 6: 커밋**

```bash
git add lib/domain/repository_interfaces/user_repository.dart \
  lib/data/repositories/user_repository_impl.dart \
  test/data/repositories/user_repository_test.dart
git commit -m "$(cat <<'EOF'
fix: #15 - [I-4] UserRepository.softDeleteUser가 Either를 반환하도록 변경

탈퇴 실패라는 중요 실패 경로를 타입 시스템에서 명시적으로 드러내기 위해
FCM 토큰 제거(removeCurrentDeviceFcmToken, 실패 허용)와 동일했던
Future<void> 시그니처를 Either로 분리.
EOF
)"
```

---

## Task 4: [C-3] `StoreUseCase.softDeleteStore` 추가 + 계정 삭제 시 관리자 점포 Soft Delete 연동

**Files:**
- Modify: `lib/domain/use_cases/store_use_case.dart`
- Modify: `lib/domain/use_cases/auth_use_case.dart`
- Modify: `lib/domain/use_cases/auth_use_case_provider.dart`
- Test: `test/domain/use_cases/store_use_case_test.dart`
- Test: `test/domain/use_cases/auth_use_case_test.dart`

**Interfaces:**
- Consumes: `StoreRepository.softDeleteStore(String)`(이미 존재, `lib/domain/repository_interfaces/store_repository.dart:29`), `UserStoreInfo.role`(`UserRole`), `TaskEither.right`/`.left`
- Produces: `StoreUseCase.softDeleteStore(String storeId) → Future<Either<Exception, void>>`, `AuthUseCaseImpl` 생성자에 `required StoreUseCase storeUseCase` 파라미터 추가(Breaking — provider 및 테스트 전부 갱신 필요)

- [x] **Step 1: 실패하는 테스트 작성 — StoreUseCase**

`test/domain/use_cases/store_use_case_test.dart`의 `main()` 마지막(파일 끝, 마지막 `});` 직전)에 그룹 추가:

```dart
  group('softDeleteStore', () {
    test('Repository.softDeleteStore를 그대로 위임한다', () async {
      when(
        () => mockStoreRepo.softDeleteStore(any()),
      ).thenAnswer((_) async => right(null));

      final result = await useCase.softDeleteStore('store-123');

      expect(result.isRight(), true);
      verify(() => mockStoreRepo.softDeleteStore('store-123')).called(1);
    });

    test('Repository 실패 시 left를 전파한다', () async {
      when(
        () => mockStoreRepo.softDeleteStore(any()),
      ).thenAnswer((_) async => left(Exception('삭제 실패')));

      final result = await useCase.softDeleteStore('store-123');

      expect(result.isLeft(), true);
    });
  });
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/domain/use_cases/store_use_case_test.dart`
Expected: FAIL — 컴파일 에러. `useCase.softDeleteStore`가 `StoreUseCase`/`StoreUseCaseImpl`에 존재하지 않음.

- [x] **Step 3: `store_use_case.dart` 수정**

`lib/domain/use_cases/store_use_case.dart`의 `StoreUseCase` 인터페이스(59-62행, `createInviteCode` 선언 뒤)에 추가:

```dart

  /// 점포 삭제 (Soft Delete)
  Future<Either<Exception, void>> softDeleteStore(String storeId);
```

`StoreUseCaseImpl` 클래스 마지막 메서드(`createInviteCode`, 226-235행) 뒤에 추가:

```dart

  @override
  Future<Either<Exception, void>> softDeleteStore(String storeId) {
    return _storeRepository.softDeleteStore(storeId);
  }
```

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/domain/use_cases/store_use_case_test.dart`
Expected: PASS

- [x] **Step 5: 실패하는 테스트 작성 — AuthUseCase.delete()**

`test/domain/use_cases/auth_use_case_test.dart` 상단 import에 추가:

```dart
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
```

`class MockUserRepository extends Mock implements UserRepository {}` 뒤에 추가:

```dart

class MockStoreUseCase extends Mock implements StoreUseCase {}
```

`setUp(() { ... })` 블록을 다음으로 교체:

```dart
  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockUserRepo = MockUserRepository();
    mockStoreUseCase = MockStoreUseCase();
    useCase = AuthUseCaseImpl(
      authRepository: mockAuthRepo,
      userRepository: mockUserRepo,
      storeUseCase: mockStoreUseCase,
    );
  });
```

`late AuthUseCaseImpl useCase;` 아래 변수 선언부에 추가:

```dart
  late MockStoreUseCase mockStoreUseCase;
```

파일 마지막(`group('signOut', ...)` 뒤, `main()`이 닫히기 전)에 새 그룹 추가:

```dart

  // =========================================================================
  // delete
  // =========================================================================

  group('delete', () {
    test('유저 삭제 성공 + 관리자 점포 삭제 성공 시 AuthRepository.delete를 호출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockUserRepo.softDeleteUser(fakeUser.id))
          .thenAnswer((_) async => right(null));
      when(() => mockStoreUseCase.softDeleteStore('store-123'))
          .thenAnswer((_) async => right(null));
      when(() => mockAuthRepo.delete()).thenAnswer((_) async => right(null));

      final result = await useCase.delete();

      expect(result.isRight(), true);
      verify(() => mockStoreUseCase.softDeleteStore('store-123')).called(1);
      verify(() => mockAuthRepo.delete()).called(1);
    });

    test('현재 유저가 null이면 AuthUserNotFoundException을 반환한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(null));

      final result = await useCase.delete();

      expect(result.isLeft(), true);
      verifyNever(() => mockUserRepo.softDeleteUser(any()));
      verifyNever(() => mockStoreUseCase.softDeleteStore(any()));
      verifyNever(() => mockAuthRepo.delete());
    });

    test('getCurrentUser 실패 시 left를 전파한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('조회 실패')));

      final result = await useCase.delete();

      expect(result.isLeft(), true);
    });

    test('softDeleteUser 실패 시 left를 반환하고 점포 삭제/AuthRepository.delete를 호출하지 않는다',
        () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockUserRepo.softDeleteUser(fakeUser.id))
          .thenAnswer((_) async => left(Exception('탈퇴 실패')));

      final result = await useCase.delete();

      expect(result.isLeft(), true);
      verifyNever(() => mockStoreUseCase.softDeleteStore(any()));
      verifyNever(() => mockAuthRepo.delete());
    });

    test('관리자 점포 삭제 실패 시 left를 반환하고 AuthRepository.delete를 호출하지 않는다',
        () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(() => mockUserRepo.softDeleteUser(fakeUser.id))
          .thenAnswer((_) async => right(null));
      when(() => mockStoreUseCase.softDeleteStore('store-123'))
          .thenAnswer((_) async => left(Exception('점포 삭제 실패')));

      final result = await useCase.delete();

      expect(result.isLeft(), true);
      verifyNever(() => mockAuthRepo.delete());
    });

    test('관리자가 아닌 점포는 삭제하지 않는다', () async {
      final staffUser = fakeUser.copyWith(
        storeInfos: [
          fakeUser.storeInfos.first.copyWith(role: UserRole.staff),
        ],
      );
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(staffUser));
      when(() => mockUserRepo.softDeleteUser(staffUser.id))
          .thenAnswer((_) async => right(null));
      when(() => mockAuthRepo.delete()).thenAnswer((_) async => right(null));

      final result = await useCase.delete();

      expect(result.isRight(), true);
      verifyNever(() => mockStoreUseCase.softDeleteStore(any()));
    });
  });
```

- [x] **Step 6: 테스트 실행하여 실패 확인**

Run: `flutter test test/domain/use_cases/auth_use_case_test.dart`
Expected: FAIL — 컴파일 에러(`AuthUseCaseImpl` 생성자에 `storeUseCase` 파라미터 없음) 및 `delete()` 미구현으로 인한 테스트 실패.

- [x] **Step 7: `auth_use_case.dart` 수정**

파일 상단 import를 다음으로 교체 (3행 `user_exceptions.dart` import 제거, 2개 추가):

```dart
import 'package:fpdart/fpdart.dart';
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
import 'package:studio_chance/domain/entities/auth_info.dart';
import 'package:studio_chance/domain/entities/user.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/repository_interfaces/auth_repository.dart';
import 'package:studio_chance/domain/repository_interfaces/user_repository.dart';
import 'package:studio_chance/domain/use_cases/store_use_case.dart';
```

`AuthUseCaseImpl` 클래스(29-37행)를 다음으로 교체:

```dart
class AuthUseCaseImpl implements AuthUseCase {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final StoreUseCase _storeUseCase;

  const AuthUseCaseImpl({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required StoreUseCase storeUseCase,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _storeUseCase = storeUseCase;
```

`delete()` 메서드(82-103행)를 다음으로 교체:

```dart
  @override
  Future<Either<Exception, void>> delete() async {
    final currentUserResult = await _userRepository.getCurrentUser();

    return currentUserResult.fold(
      (error) => Future.value(left(error)),
      (currentUser) {
        if (currentUser == null) {
          return Future.value(
            left(AuthUserNotFoundException(message: '로그인된 사용자가 없습니다.')),
          );
        }

        return TaskEither(() => _userRepository.softDeleteUser(currentUser.id))
            .flatMap((_) => _softDeleteAdminStores(currentUser))
            .flatMap((_) => TaskEither(() => _authRepository.delete()))
            .run();
      },
    );
  }

  /// 사용자가 관리자(admin)로 속한 모든 점포를 Soft Delete 처리한다.
  ///
  /// 계정 삭제 시 관리자 소유 점포 레코드가 Firestore에 잔존하지 않도록
  /// 순회하며 삭제하고, 하나라도 실패하면 그 시점에서 나머지를 진행하지 않고 에러를 반환한다.
  TaskEither<Exception, void> _softDeleteAdminStores(User currentUser) {
    final adminStoreIds = currentUser.storeInfos
        .where((info) => info.role == UserRole.admin)
        .map((info) => info.id);

    return adminStoreIds.fold(
      TaskEither<Exception, void>.right(null),
      (acc, storeId) => acc.flatMap(
        (_) => TaskEither(() => _storeUseCase.softDeleteStore(storeId)),
      ),
    );
  }
```

- [x] **Step 8: 테스트 실행하여 통과 확인**

Run: `flutter test test/domain/use_cases/auth_use_case_test.dart`
Expected: 전체 PASS

- [x] **Step 9: `auth_use_case_provider.dart` 수정**

`lib/domain/use_cases/auth_use_case_provider.dart` 전체를 다음으로 교체:

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:studio_chance/data/repositories/auth_repository_impl.dart';
import 'package:studio_chance/data/repositories/user_repository_impl.dart';
import 'package:studio_chance/domain/use_cases/auth_use_case.dart';
import 'package:studio_chance/domain/use_cases/store_use_case_provider.dart';

part 'auth_use_case_provider.g.dart';

@riverpod
AuthUseCase authUseCase(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  final storeUseCase = ref.watch(storeUseCaseProvider);

  return AuthUseCaseImpl(
    authRepository: authRepository,
    userRepository: userRepository,
    storeUseCase: storeUseCase,
  );
}
```

- [x] **Step 10: 전체 확인**

Run: `dart analyze`
Expected: 에러 없음 (provider 함수 시그니처는 바뀌지 않았으므로 `build_runner` 불필요)

Run: `flutter test`
Expected: 전체 PASS

- [x] **Step 11: 커밋**

```bash
git add lib/domain/use_cases/store_use_case.dart \
  lib/domain/use_cases/auth_use_case.dart \
  lib/domain/use_cases/auth_use_case_provider.dart \
  test/domain/use_cases/store_use_case_test.dart \
  test/domain/use_cases/auth_use_case_test.dart
git commit -m "$(cat <<'EOF'
fix: #15 - [C-3] 계정 삭제 시 관리자 소유 점포를 Soft Delete 처리하도록 연동

StoreUseCase에 softDeleteStore를 추가하고 AuthUseCaseImpl.delete()에
연동하여, 관리자 계정 탈퇴 시 점포 레코드가 좀비 데이터로 남지 않도록 함.
EOF
)"
```

---

## Task 5: [I-2] `UserUseCase.fetchOrCreateUser` 제거 → `AuthUseCase`로 진입점 단일화

**Files:**
- Modify: `lib/domain/use_cases/user_use_case.dart`
- Modify: `lib/domain/use_cases/auth_use_case.dart`
- Modify: `lib/presentation/providers/app_auth_controller.dart`
- Test: `test/domain/use_cases/user_use_case_test.dart`
- Test: `test/domain/use_cases/auth_use_case_test.dart`

**Interfaces:**
- Consumes: `UserRepository.fetchOrCreateUser(AuthInfo)`(기존)
- Produces: `AuthUseCase.fetchOrCreateUser(AuthInfo authInfo) → Future<Either<Exception, User>>` 신규 공개 메서드. `UserUseCase`에서는 동일 메서드 제거.

- [x] **Step 1: 실패하는 테스트 작성 — AuthUseCase**

`test/domain/use_cases/auth_use_case_test.dart`의 `group('signInWithGoogle', ...)` 앞(파일 상단 첫 그룹 이전)에 새 그룹 추가:

```dart
  // =========================================================================
  // fetchOrCreateUser
  // =========================================================================

  group('fetchOrCreateUser', () {
    test('Repository.fetchOrCreateUser를 위임하고 User를 반환한다', () async {
      when(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo))
          .thenAnswer((_) async => right(fakeUser));

      final result = await useCase.fetchOrCreateUser(fakeAuthInfo);

      expect(result.isRight(), true);
      expect(result.getRight().toNullable(), fakeUser);
      verify(() => mockUserRepo.fetchOrCreateUser(fakeAuthInfo)).called(1);
    });

    test('Repository 실패를 그대로 전파한다', () async {
      when(() => mockUserRepo.fetchOrCreateUser(any()))
          .thenAnswer((_) async => left(Exception('유저 조회/생성 실패')));

      final result = await useCase.fetchOrCreateUser(fakeAuthInfo);

      expect(result.isLeft(), true);
    });
  });
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/domain/use_cases/auth_use_case_test.dart`
Expected: FAIL — `AuthUseCase`/`AuthUseCaseImpl`에 `fetchOrCreateUser` 메서드가 없어 컴파일 에러.

- [x] **Step 3: `auth_use_case.dart`에 메서드 추가**

`AuthUseCase` 인터페이스(9-27행)의 `authStateChanges()` 선언 뒤에 추가:

```dart

  /// 인증 정보를 바탕으로 유저 조회/생성
  /// 앱 시작/로그인 상태 변경 시 Firebase Auth 세션과 Firestore User 문서를 연결하는
  /// 유일한 진입점. (AppAuthController에서 사용)
  Future<Either<Exception, User>> fetchOrCreateUser(AuthInfo authInfo);
```

`AuthUseCaseImpl`의 `authStateChanges()` 구현 뒤에 추가:

```dart

  @override
  Future<Either<Exception, User>> fetchOrCreateUser(AuthInfo authInfo) {
    return _userRepository.fetchOrCreateUser(authInfo);
  }
```

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/domain/use_cases/auth_use_case_test.dart`
Expected: 전체 PASS

- [x] **Step 5: `UserUseCase`에서 제거 + 테스트 삭제**

`lib/domain/use_cases/user_use_case.dart`에서 다음을 제거한다:
- 인터페이스의 `Future<Either<Exception, User>> fetchOrCreateUser(AuthInfo authInfo);` 선언(10행)과 그 위 doc comment(8-9행)
- `UserUseCaseImpl`의 `fetchOrCreateUser` 구현(39-42행)
- 더 이상 `AuthInfo`를 참조하지 않으므로 상단 `import 'package:studio_chance/domain/entities/auth_info.dart';`(2행) 제거

`test/domain/use_cases/user_use_case_test.dart`에서 다음을 제거한다:
- `group('fetchOrCreateUser', ...)` 블록 전체(31-51행)
- `import 'package:studio_chance/domain/entities/auth_info.dart';`(4행)
- `class FakeAuthInfo extends Fake implements AuthInfo {}`(12행)
- `setUpAll(() { registerFallbackValue(FakeAuthInfo()); });`(18-20행) — 더 이상 `AuthInfo` fallback이 필요 없으므로 `setUpAll` 블록 자체를 삭제

- [x] **Step 6: 호출부 갱신 — `app_auth_controller.dart`**

`lib/presentation/providers/app_auth_controller.dart`의 import를:
```dart
import 'package:studio_chance/domain/use_cases/user_use_case_provider.dart';
```
에서
```dart
import 'package:studio_chance/domain/use_cases/auth_use_case_provider.dart';
```
로 교체.

`currentUser` provider 본문을:
```dart
  final userUseCase = ref.watch(userUseCaseProvider);
  final result = await userUseCase.fetchOrCreateUser(authInfo);
```
에서
```dart
  final authUseCase = ref.watch(authUseCaseProvider);
  final result = await authUseCase.fetchOrCreateUser(authInfo);
```
로 교체.

- [x] **Step 7: 전체 확인**

Run: `dart analyze`
Expected: 에러 없음 (미사용 import 경고 없음)

Run: `flutter test`
Expected: 전체 PASS

- [x] **Step 8: 커밋**

```bash
git add lib/domain/use_cases/user_use_case.dart \
  lib/domain/use_cases/auth_use_case.dart \
  lib/presentation/providers/app_auth_controller.dart \
  test/domain/use_cases/user_use_case_test.dart \
  test/domain/use_cases/auth_use_case_test.dart
git commit -m "$(cat <<'EOF'
refactor: #15 - [I-2] fetchOrCreateUser를 AuthUseCase로 단일화

UserUseCase에 노출되어 Auth 흐름 없이도 호출 가능했던 fetchOrCreateUser를
제거하고, Auth 세션-User 문서 연결의 유일한 진입점을 AuthUseCase로 통일.
AppAuthController도 AuthUseCase를 사용하도록 갱신.
EOF
)"
```

---

## Task 6: [I-3] `watchReservationsByDateRange` 인증 경쟁 조건 문서화 + 회귀 테스트

**Files:**
- Modify: `lib/domain/use_cases/reservation_use_case.dart:32-39`
- Test: `test/domain/use_cases/reservation_use_case_test.dart`

**Interfaces:**
- Consumes: 없음(신규 인터페이스 변경 없음)
- Produces: 없음(런타임 동작 변경 없음 — 기존 동작을 회귀 테스트로 고정하고 doc comment로 명시)

이슈의 두 제안 중 "프레젠테이션 레이어에서 스트림 종료 시 재구독 처리 확인"을 택한다. `lib/presentation/providers/home_reservations_provider.dart:23`에서 `homeReservations`가 `ref.watch(currentUserProvider.future)`를 먼저 `await`한 뒤에만 `watchReservationsByDateRange`를 호출하므로, 로그인 확정 전 호출로 인한 경쟁 조건은 실무에서 발생하지 않는다. 다만 UseCase 레벨의 공개 API 계약을 명확히 문서화하고 회귀를 막는 테스트를 추가한다.

- [x] **Step 1: 실패하는 테스트 작성**

`test/domain/use_cases/reservation_use_case_test.dart` 상단 import에 추가:

```dart
import 'package:studio_chance/common/exceptions/auth_exceptions.dart';
```

`group('updateReservationStatus', ...)` 뒤(파일 마지막, `main()`이 닫히기 전)에 새 그룹 추가:

```dart

  // =========================================================================
  // watchReservationsByDateRange
  // =========================================================================

  group('watchReservationsByDateRange', () {
    final start = DateTime(2026, 5, 1);
    final end = DateTime(2026, 5, 31);

    test('유저 조회 실패 시 스트림이 에러를 방출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => left(Exception('유저 없음')));

      final stream = useCase.watchReservationsByDateRange(
        storeId: 'store-123',
        start: start,
        end: end,
      );

      await expectLater(stream, emitsError(isA<Exception>()));
    });

    test('유저가 null이면 스트림이 AuthUserNotFoundException을 방출한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(null));

      final stream = useCase.watchReservationsByDateRange(
        storeId: 'store-123',
        start: start,
        end: end,
      );

      await expectLater(stream, emitsError(isA<AuthUserNotFoundException>()));
    });

    test('유저 조회 성공 시 Repository 스트림을 그대로 전달한다', () async {
      when(() => mockUserRepo.getCurrentUser())
          .thenAnswer((_) async => right(fakeUser));
      when(
        () => mockReservationRepo.watchReservationsByDateRange(
          storeId: any(named: 'storeId'),
          currentUid: any(named: 'currentUid'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ),
      ).thenAnswer((_) => Stream.value([fakeReservation]));

      final stream = useCase.watchReservationsByDateRange(
        storeId: 'store-123',
        start: start,
        end: end,
      );

      await expectLater(stream, emits([fakeReservation]));
    });
  });
```

- [x] **Step 2: 테스트 실행하여 통과 확인**

Run: `flutter test test/domain/use_cases/reservation_use_case_test.dart`
Expected: PASS — 기존 구현이 이미 이 계약을 만족하므로 코드 변경 없이 통과해야 한다. (만약 실패한다면 현재 구현이 문서와 다르게 동작하는 것이므로, 그 결과를 보고 Step 3의 doc comment 내용을 실제 동작에 맞게 조정한다.)

- [x] **Step 3: 인터페이스에 doc comment 추가**

`lib/domain/use_cases/reservation_use_case.dart:32-39`:
```dart
  /// 날짜 범위 예약 실시간 구독
  ///
  /// 에러는 스트림 에러로 전파됩니다.
  Stream<List<Reservation>> watchReservationsByDateRange({
    required String storeId,
    required DateTime start,
    required DateTime end,
  });
```
를
```dart
  /// 날짜 범위 예약 실시간 구독
  ///
  /// 내부적으로 최초 구독 시점에 현재 로그인 유저를 1회 조회하여 이후
  /// Repository 스트림에 고정 전달한다. 조회 시점에 로그인 상태가 아직
  /// 확정되지 않았다면([AuthUserNotFoundException]) 스트림은 에러를 1회
  /// 방출한 뒤 영구 종료된다 — 자동 재구독은 하지 않는다.
  ///
  /// 따라서 호출부는 인증 상태가 확정된 이후에만 구독을 시작해야 한다.
  /// (`home_reservations_provider.dart`의 `homeReservations`는
  /// `currentUserProvider.future`를 먼저 await한 뒤 구독을 시작하여
  /// 이 경쟁 조건을 회피한다.)
  ///
  /// 에러는 스트림 에러로 전파된다.
  Stream<List<Reservation>> watchReservationsByDateRange({
    required String storeId,
    required DateTime start,
    required DateTime end,
  });
```
로 교체.

- [x] **Step 4: 전체 확인**

Run: `flutter test test/domain/use_cases/reservation_use_case_test.dart`
Expected: 전체 PASS

- [x] **Step 5: 커밋**

```bash
git add lib/domain/use_cases/reservation_use_case.dart \
  test/domain/use_cases/reservation_use_case_test.dart
git commit -m "$(cat <<'EOF'
docs: #15 - [I-3] watchReservationsByDateRange 인증 경쟁 조건 문서화 및 회귀 테스트 추가

homeReservations Provider가 currentUserProvider.future를 먼저 await하여
이미 경쟁 조건을 회피하고 있음을 확인. UseCase 공개 계약을 doc comment로
명시하고 회귀 테스트로 고정.
EOF
)"
```

---

## Task 7: [I-1] `domain/enums` 6종 → `common/enums`로 이동 (json_annotation 의존성 제거)

**Files:**
- Move: `lib/domain/enums/{payment_method,reservation_platform,reservation_status,user_role,weekday,store_color}.dart` → `lib/common/enums/`
- Modify: 위 6개 파일을 import하는 모든 `lib/`, `test/` 파일(아래 스크립트가 자동 처리)
- Modify: `CLAUDE.md` (아키텍처 트리)

**Interfaces:**
- Consumes: 없음
- Produces: 없음 — 순수 파일 위치 이동 + import 경로 치환. 클래스/enum 자체의 이름, 멤버는 변경 없음.

- [x] **Step 1: 현재 테스트 스위트가 통과하는지 베이스라인 확인**

Run: `flutter test`
Expected: PASS (이후 단계에서 회귀 발생 여부를 비교하기 위한 기준선)

- [x] **Step 2: 디렉터리 생성 및 파일 이동**

```bash
mkdir -p lib/common/enums
git mv lib/domain/enums/payment_method.dart lib/common/enums/payment_method.dart
git mv lib/domain/enums/reservation_platform.dart lib/common/enums/reservation_platform.dart
git mv lib/domain/enums/reservation_status.dart lib/common/enums/reservation_status.dart
git mv lib/domain/enums/user_role.dart lib/common/enums/user_role.dart
git mv lib/domain/enums/weekday.dart lib/common/enums/weekday.dart
git mv lib/domain/enums/store_color.dart lib/common/enums/store_color.dart
```

- [x] **Step 3: import 경로 일괄 치환**

```bash
grep -rl "studio_chance/domain/enums/\(payment_method\|reservation_platform\|reservation_status\|user_role\|weekday\|store_color\)\.dart" \
  lib/ test/ --include="*.dart" | \
  xargs sed -i '' -E "s#studio_chance/domain/enums/(payment_method|reservation_platform|reservation_status|user_role|weekday|store_color)\.dart#studio_chance/common/enums/\1.dart#g"
```

(macOS `sed`는 `-i ''`가 필요하다. Linux 환경이면 `-i` 뒤 빈 문자열 인자를 생략한다.)

- [x] **Step 4: 남은 참조 확인**

```bash
grep -rn "domain/enums/" lib/ test/ --include="*.dart"
```

Expected: 결과 없음(전부 `common/enums/`로 치환됨). 결과가 있다면 해당 파일을 직접 확인하여 수동으로 경로를 고친다.

- [x] **Step 5: `lib/domain/enums/` 빈 디렉터리 제거 확인**

```bash
ls lib/domain/enums/ 2>&1
```

Expected: `No such file or directory` (파일이 모두 이동되어 git이 빈 디렉터리를 추적하지 않음)

- [x] **Step 6: 정적 분석 및 전체 테스트로 회귀 확인**

Run: `dart analyze`
Expected: 에러 없음

Run: `flutter test`
Expected: Step 1과 동일하게 전체 PASS (동작 변경이 없으므로 결과가 달라지면 안 됨)

- [x] **Step 7: `CLAUDE.md` 아키텍처 트리 갱신**

`CLAUDE.md`의 `## 아키텍처` 섹션에서:
```
- `/lib/domain`: Domain(비즈니스 로직) 계층
  - `/entities`: Domain 엔티티
  - `/enums`: Domain 관련 enum
```
를
```
- `/lib/domain`: Domain(비즈니스 로직) 계층
  - `/entities`: Domain 엔티티
```
로 교체(둘째 줄 `/enums` 항목 제거)하고, `/lib/common` 섹션의 `/converters` 항목 뒤에 추가:
```
  - `/enums`: 모든 계층에서 사용되는 enum (`@JsonEnum`/`@JsonValue`로 Firestore 직렬화 값 포함)
```

- [x] **Step 8: 커밋**

```bash
git add -A
git commit -m "$(cat <<'EOF'
refactor: #15 - [I-1] domain/enums를 common/enums로 이동

PaymentMethod, ReservationPlatform, ReservationStatus, UserRole, Weekday,
StoreColor 6개 enum이 json_annotation(Data 직렬화 관심사)에 의존하면서도
Domain 계층에 위치해 있던 아키텍처 부채를 해소. 모든 계층에서 공용으로
쓰이는 실제 성격에 맞게 common/enums로 이동하고 CLAUDE.md 트리를 갱신.
EOF
)"
```

---

## Task 8: [M-2] `StoreColor` 색상값 getter → Presentation Extension 이동

**Files:**
- Modify: `lib/common/enums/store_color.dart`
- Create: `lib/presentation/commons/extensions/store_color_extensions.dart`
- Modify: `lib/presentation/home/widgets/store_filter_modal.dart`
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart`
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart`
- Modify: `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart`
- Modify: `lib/presentation/commons/store_input/screens/store_color_selection_screen.dart`
- Modify: `lib/presentation/commons/store_input/screens/store_form_screen.dart`
- Test: `test/presentation/commons/extensions/store_color_extensions_test.dart`

**Interfaces:**
- Consumes: `StoreColor`(`lib/common/enums/store_color.dart`, Task 7에서 이동됨)
- Produces: `extension StoreColorPalette on StoreColor { int get backgroundColorValue; int get foregroundColorValue; int get labelColorValue; }` — 기존과 동일한 값/이름의 getter를 Presentation extension으로 제공.

- [x] **Step 1: 실패하는 테스트 작성**

`test/presentation/commons/extensions/store_color_extensions_test.dart` 신규 생성:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/common/enums/store_color.dart';
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';

void main() {
  group('StoreColorPalette', () {
    test('red의 배경/전경/라벨 색상값', () {
      expect(StoreColor.red.backgroundColorValue, 0xFFFF9E99);
      expect(StoreColor.red.foregroundColorValue, 0xFFFF3B30);
      expect(StoreColor.red.labelColorValue, 0xFF990800);
    });

    test('blue의 배경/전경/라벨 색상값', () {
      expect(StoreColor.blue.backgroundColorValue, 0xFF99CAFF);
      expect(StoreColor.blue.foregroundColorValue, 0xFF007AFF);
      expect(StoreColor.blue.labelColorValue, 0xFF004999);
    });
  });
}
```

- [x] **Step 2: 테스트 실행하여 실패 확인**

Run: `flutter test test/presentation/commons/extensions/store_color_extensions_test.dart`
Expected: FAIL — `lib/presentation/commons/extensions/store_color_extensions.dart` 파일이 아직 없어 컴파일 에러.

- [x] **Step 3: extension 파일 생성 + enum에서 getter 제거**

`lib/presentation/commons/extensions/store_color_extensions.dart` 신규 생성:

```dart
import 'package:studio_chance/common/enums/store_color.dart';

extension StoreColorPalette on StoreColor {
  int get backgroundColorValue => switch (this) {
    StoreColor.red => 0xFFFF9E99,
    StoreColor.orange => 0xFFFFD599,
    StoreColor.yellow => 0xFFFFEB99,
    StoreColor.green => 0xFFAEEABD,
    StoreColor.blue => 0xFF99CAFF,
    StoreColor.indigo => 0xFFAEADEB,
    StoreColor.purple => 0xFFD7A9EF,
  };

  int get foregroundColorValue => switch (this) {
    StoreColor.red => 0xFFFF3B30,
    StoreColor.orange => 0xFFFF9500,
    StoreColor.yellow => 0xFFFFCC00,
    StoreColor.green => 0xFF34C759,
    StoreColor.blue => 0xFF007AFF,
    StoreColor.indigo => 0xFF5856D6,
    StoreColor.purple => 0xFFAF52DE,
  };

  int get labelColorValue => switch (this) {
    StoreColor.red => 0xFF990800,
    StoreColor.orange => 0xFF995900,
    StoreColor.yellow => 0xFF997A00,
    StoreColor.green => 0xFF207936,
    StoreColor.blue => 0xFF004999,
    StoreColor.indigo => 0xFF1F1E7B,
    StoreColor.purple => 0xFF5E1980,
  };
}
```

`lib/common/enums/store_color.dart`에서 `backgroundColorValue`/`foregroundColorValue`/`labelColorValue` getter 3개(기존 30-58행)를 제거하여 `displayName` getter만 남긴다.

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/presentation/commons/extensions/store_color_extensions_test.dart`
Expected: PASS

- [x] **Step 5: 호출부 7개 파일에 import 추가**

아래 7개 파일 각각의 import 목록에 다음 한 줄을 추가한다(다른 `presentation/commons/extensions/` import와 같은 위치, 알파벳 순 권장):

```dart
import 'package:studio_chance/presentation/commons/extensions/store_color_extensions.dart';
```

- `lib/presentation/home/widgets/store_filter_modal.dart`
- `lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart`
- `lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart`
- `lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart`
- `lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart`
- `lib/presentation/commons/store_input/screens/store_color_selection_screen.dart`
- `lib/presentation/commons/store_input/screens/store_form_screen.dart`

- [x] **Step 6: 전체 확인**

Run: `dart analyze`
Expected: 에러 없음 (extension import 누락 시 `backgroundColorValue` 등에서 "Undefined getter" 에러 발생하므로 빠짐없이 추가되었는지 확인하는 용도)

Run: `flutter test`
Expected: 전체 PASS

- [x] **Step 7: 커밋**

```bash
git add lib/common/enums/store_color.dart \
  lib/presentation/commons/extensions/store_color_extensions.dart \
  lib/presentation/home/widgets/store_filter_modal.dart \
  lib/presentation/home/widgets/three_day_calendar/reservation_list_modal.dart \
  lib/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart \
  lib/presentation/home/widgets/three_day_calendar/reservation_cell.dart \
  lib/presentation/home/widgets/three_day_calendar/reservation_create_modal.dart \
  lib/presentation/commons/store_input/screens/store_color_selection_screen.dart \
  lib/presentation/commons/store_input/screens/store_form_screen.dart \
  test/presentation/commons/extensions/store_color_extensions_test.dart
git commit -m "$(cat <<'EOF'
refactor: #15 - [M-2] StoreColor 색상값 getter를 Presentation extension으로 이동

ARGB int 색상값은 UI 렌더링 관심사이므로 common/enums의 StoreColor에서
제거하고 presentation/commons/extensions/store_color_extensions.dart의
StoreColorPalette extension으로 이동.
EOF
)"
```

---

## Task 9: [M-4] `InviteInfo` 불필요한 private constructor 제거

**Files:**
- Modify: `lib/domain/entities/invite_info.dart`

**Interfaces:**
- Consumes: 없음
- Produces: 없음 (freezed 생성 코드만 재생성, 공개 API 불변)

- [x] **Step 1: private constructor 제거**

`lib/domain/entities/invite_info.dart`를 다음으로 교체:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_info.freezed.dart';

@freezed
abstract class InviteInfo with _$InviteInfo {
  const factory InviteInfo({required String inviteCode}) = _InviteInfo;
}
```

(`const InviteInfo._();` 줄 제거 — `space_option.dart`의 `SpaceOption`도 커스텀 메서드가 없어 동일하게 private constructor 없이 정의되어 있는 기존 패턴과 일치시킴)

- [x] **Step 2: 코드 생성 재실행**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: `lib/domain/entities/invite_info.freezed.dart`가 재생성되고 에러 없이 완료됨

- [x] **Step 3: 정적 분석 및 전체 테스트 확인**

Run: `dart analyze`
Expected: 에러 없음

Run: `flutter test`
Expected: 전체 PASS (기존 `InviteInfo` 사용처는 모두 named constructor `InviteInfo(inviteCode: ...)`만 사용하므로 영향 없음)

- [x] **Step 4: 커밋**

```bash
git add lib/domain/entities/invite_info.dart lib/domain/entities/invite_info.freezed.dart
git commit -m "$(cat <<'EOF'
refactor: #15 - [M-4] InviteInfo의 불필요한 private constructor 제거

커스텀 getter/메서드가 없어 SpaceOption과 동일하게 private constructor
없이도 충분한 상태였음.
EOF
)"
```

---

## Task 10: [M-5] `reservation_use_case_test.dart` — `isRight()`/`isLeft()` → `fold` 스타일 통일

**Files:**
- Modify: `test/domain/use_cases/reservation_use_case_test.dart`

**Interfaces:**
- Consumes: 없음
- Produces: 없음 (테스트 코드 스타일만 변경, 검증 내용은 동일하게 유지)

이 변경은 이슈 [#15]의 M-5에서 `reservation_use_case_test.dart` 한 파일만 명시적으로 지적했으므로 해당 파일만 수정한다(다른 테스트 파일들의 `isRight()`/`isLeft()`는 이번 이슈의 범위 밖이며 프로젝트 전반의 기존 관례이므로 손대지 않는다).

- [x] **Step 1: 현재 테스트가 통과하는지 확인 (베이스라인)**

Run: `flutter test test/domain/use_cases/reservation_use_case_test.dart`
Expected: PASS (Task 1, 2, 6에서 이미 추가한 테스트 포함 전체 통과 상태)

- [x] **Step 2: 스타일 일괄 치환**

```bash
python3 <<'PYEOF'
import pathlib

path = pathlib.Path("test/domain/use_cases/reservation_use_case_test.dart")
text = path.read_text()

text = text.replace(
    "expect(result.isRight(), true);",
    "result.fold((error) => fail(error.toString()), (_) {});",
)
text = text.replace(
    "expect(result.isLeft(), true);",
    "result.fold((_) {}, (_) => fail('실패를 예상했으나 성공했습니다'));",
)

path.write_text(text)
PYEOF
```

- [x] **Step 3: 치환 결과 확인**

```bash
grep -n "isRight()\|isLeft()" test/domain/use_cases/reservation_use_case_test.dart
```

Expected: 결과 없음(전부 `fold` 스타일로 치환됨)

- [x] **Step 4: 테스트 실행하여 통과 확인**

Run: `flutter test test/domain/use_cases/reservation_use_case_test.dart`
Expected: 전체 PASS (검증 내용은 동일 — 성공을 기대하는 곳에서 실패하면 `fail(error)`로, 실패를 기대하는 곳에서 성공하면 `fail('실패를 예상했으나 성공했습니다')`로 즉시 드러남. 성공값을 문자열에 보간하지 않는 이유: `updateReservation`/`deleteReservation`/`updateReservationStatus`처럼 `Either<Exception, void>`를 반환하는 메서드의 경우 성공 콜백 파라미터가 `void` 타입이 되어 `$value` 형태의 문자열 보간이 컴파일 에러(`This expression has type 'void' and can't be used`)를 일으키므로, 모든 반환 타입에 안전하게 동작하도록 고정 문자열을 사용한다)

- [x] **Step 5: 커밋**

```bash
git add test/domain/use_cases/reservation_use_case_test.dart
git commit -m "$(cat <<'EOF'
test: #15 - [M-5] reservation_use_case_test.dart의 isRight()/isLeft()를 fold 스타일로 통일

CLAUDE.md의 Either 처리 컨벤션(명령형 isLeft()/isRight() 대신 fold 사용)에
맞춰 이 파일의 단언 스타일을 통일.
EOF
)"
```

---

## Task 11: [M-3] 단순 위임 UseCase 아키텍처 결정 문서화 (D10)

**Files:**
- Modify: `CLAUDE.md`

**Interfaces:**
- Consumes: 없음
- Produces: 없음 (코드 변경 없음 — `UserUseCaseImpl`이 단순 위임만 수행하는 현재 구조를 팀 결정으로 명시)

- [x] **Step 1: `CLAUDE.md`의 `## 아키텍처 설계 결정` 섹션에 D10 추가**

`### 앱 최초 실행 인증 데이터 삭제 (D9)` 섹션 뒤(파일에서 `## Either / TaskEither 패턴` 섹션 바로 앞)에 추가:

```markdown

### 단순 위임 UseCase 허용 (D10)
`UserUseCaseImpl`처럼 모든 메서드가 Repository에 단일 라인으로 위임하는 UseCase도 의도적으로 허용.
- 목적: Presentation → UseCase → Repository 계층 규칙을 지키기 위함 (Presentation이 Repository를 직접 호출하지 않도록 강제)
- 현재 비즈니스 로직이 없다는 이유로 UseCase 계층 자체를 생략하지 않음 — 향후 검증/가공 로직이 필요해지면 이 계층에 추가
- 관련 이슈: [#15](https://github.com/SNMac/StudioChance/issues/15) [M-3]
```

- [x] **Step 2: 커밋**

```bash
git add CLAUDE.md
git commit -m "$(cat <<'EOF'
docs: #15 - [M-3] 단순 위임 UseCase 설계를 D10으로 문서화

UserUseCaseImpl의 모든 메서드가 Repository 위임만 수행하는 것은
의도된 설계임을 CLAUDE.md 아키텍처 결정 섹션에 명시.
EOF
)"
```

---

## Self-Review 요약

- **Spec coverage**: 이슈의 Critical 3건(C-1~C-3), Important 4건(I-1~I-4), Minor 4건(M-2~M-5) 모두 Task 1~11에 매핑됨. M-1은 이미 해결되어 있음을 확인하고 계획에서 제외(Global Constraints에 명시).
- **Placeholder scan**: 모든 Step에 실제 코드/명령어를 포함시켰으며 "TODO"/"적절히 처리" 같은 모호한 지시는 없음(단, 도메인 자체의 기존 `// TODO: 공휴일 API 연동 후...` 주석은 이슈와 무관한 별도 진행 중 사항이므로 그대로 유지).
- **Type consistency**: `StoreUseCase.softDeleteStore`, `UserRepository.softDeleteUser`, `AuthUseCaseImpl` 생성자 시그니처가 Task 3·4·5에서 일관되게 사용됨을 교차 확인. Task 7(enum 이동)이 Task 8(StoreColor extension) 이전에 실행되어야 import 경로가 맞음 — Task 순서로 이를 강제함.

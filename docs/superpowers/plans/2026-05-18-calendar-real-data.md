# 캘린더 실제 데이터 연결 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 캘린더 화면의 목업 데이터를 제거하고 Firestore 실제 예약 데이터와 연결하며, 예약 수정 저장 로직을 구현한다.

**Architecture:** `homeReservationsProvider(DateTime month)` family provider를 신규 생성하여 현재 사용자의 모든 점포 예약을 월별로 병렬 조회·병합한다. 날짜 필터링 로직을 순수 함수(`calendar_events_utils.dart`)로 분리하여 단위 테스트 가능하게 만든다. `onSaved` 콜백은 fire-and-forget async로 구현하며 성공 시 provider를 invalidate하여 캘린더를 새로고침한다.

**Tech Stack:** Flutter, Riverpod (riverpod_annotation), fpdart (Either), mocktail, logger

---

## 파일 구조

```
lib/presentation/home/utils/calendar_events_utils.dart       [NEW]
lib/presentation/providers/home_reservations_provider.dart   [NEW]
lib/presentation/providers/home_reservations_provider.g.dart [GENERATED]
lib/presentation/home/widgets/three_day_calendar/all_day_row.dart    [MODIFY]
lib/presentation/home/widgets/three_day_calendar/time_grid.dart      [MODIFY]
lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart  [MODIFY]

test/presentation/home/utils/calendar_events_utils_test.dart        [NEW]
test/presentation/providers/home_reservations_provider_test.dart     [NEW]
```

---

### Task 1: calendar_events_utils.dart 스텁 생성

**Files:**
- Create: `lib/presentation/home/utils/calendar_events_utils.dart`

- [ ] **Step 1: utils 디렉토리 및 스텁 파일 생성**

```dart
// lib/presentation/home/utils/calendar_events_utils.dart
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

/// Reservation 목록을 화면 표시용 데이터 구조로 변환한다.
/// 반환: (ReservationDisplayData 목록, id → Reservation 맵)
(List<ReservationDisplayData>, Map<String, Reservation>) buildEventsFromReservations(
    List<Reservation> reservations) {
  throw UnimplementedError();
}

/// 특정 날짜에 표시할 이벤트를 필터링한다.
///
/// - [allDay]=true: 해당 날짜의 종일 이벤트만 반환
/// - [allDay]=false: 해당 날짜에 걸쳐있는 시간대 이벤트 반환 (자정 넘김 분할 포함)
List<ReservationDisplayData> eventsForDate(
    List<ReservationDisplayData> allEvents,
    DateTime date, {
    required bool allDay,
}) {
  throw UnimplementedError();
}
```

---

### Task 2: calendar_events_utils 테스트 작성 및 실패 확인

**Files:**
- Create: `test/presentation/home/utils/calendar_events_utils_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

```dart
// test/presentation/home/utils/calendar_events_utils_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/home/utils/calendar_events_utils.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

import '../../../helpers/fake_entities.dart';

ReservationDisplayData _makeEvent({
  required String id,
  required DateTime start,
  required DateTime end,
  bool isAllDay = false,
}) {
  return ReservationDisplayData(
    summary: ReservationSummary(
      id: id,
      storeSummary: fakeStoreSummary,
      status: fakeReservation.status,
      customerName: '테스트',
      headCount: 1,
      customerPhone: '010-0000-0000',
      isAllDay: isAllDay,
      startTime: start,
      endTime: end,
    ),
  );
}

void main() {
  final today = DateTime(2026, 5, 18);
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));

  // ===========================================================================
  // eventsForDate
  // ===========================================================================

  group('eventsForDate', () {
    test('해당 날짜의 이벤트를 반환한다', () {
      final event = _makeEvent(
        id: 'e1',
        start: today.add(const Duration(hours: 10)),
        end: today.add(const Duration(hours: 12)),
      );

      final result = eventsForDate([event], today, allDay: false);

      expect(result.length, 1);
      expect(result.first.summary.id, 'e1');
    });

    test('다른 날짜의 이벤트는 포함하지 않는다', () {
      final event = _makeEvent(
        id: 'e1',
        start: tomorrow.add(const Duration(hours: 10)),
        end: tomorrow.add(const Duration(hours: 12)),
      );

      final result = eventsForDate([event], today, allDay: false);

      expect(result, isEmpty);
    });

    test('이전 날 시작하여 오늘 이전에 끝난 이벤트는 반환하지 않는다', () {
      final event = _makeEvent(
        id: 'e1',
        start: yesterday.add(const Duration(hours: 10)),
        end: yesterday.add(const Duration(hours: 12)),
      );

      final result = eventsForDate([event], today, allDay: false);

      expect(result, isEmpty);
    });

    test('빈 목록 입력 시 빈 목록을 반환한다', () {
      final result = eventsForDate([], today, allDay: false);
      expect(result, isEmpty);
    });

    group('자정 넘김 이벤트', () {
      test('시작일에 continuesNextDay=true이고 endTime이 자정으로 클립된다', () {
        final midnight = DateTime(today.year, today.month, today.day + 1);
        final event = _makeEvent(
          id: 'e1',
          start: today.add(const Duration(hours: 22)),
          end: tomorrow.add(const Duration(hours: 2)),
        );

        final result = eventsForDate([event], today, allDay: false);

        expect(result.length, 1);
        expect(result.first.continuesNextDay, true);
        expect(result.first.isContinuation, false);
        expect(result.first.summary.endTime, midnight);
      });

      test('익일에 isContinuation=true이고 startTime이 자정으로 설정된다', () {
        final midnight = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
        final event = _makeEvent(
          id: 'e1',
          start: today.add(const Duration(hours: 22)),
          end: tomorrow.add(const Duration(hours: 2)),
        );

        final result = eventsForDate([event], tomorrow, allDay: false);

        expect(result.length, 1);
        expect(result.first.isContinuation, true);
        expect(result.first.continuesNextDay, false);
        expect(result.first.summary.startTime, midnight);
      });

      test('자정에 정확히 끝나는 이벤트는 continuesNextDay=false이다', () {
        final midnight = DateTime(today.year, today.month, today.day + 1);
        final event = _makeEvent(
          id: 'e1',
          start: today.add(const Duration(hours: 22)),
          end: midnight,
        );

        final result = eventsForDate([event], today, allDay: false);

        expect(result.length, 1);
        expect(result.first.continuesNextDay, false);
      });
    });

    group('종일 이벤트', () {
      test('allDay=true 요청 시 종일 이벤트만 반환한다', () {
        final allDayEvent = _makeEvent(
          id: 'allday',
          start: today,
          end: tomorrow,
          isAllDay: true,
        );
        final timedEvent = _makeEvent(
          id: 'timed',
          start: today.add(const Duration(hours: 10)),
          end: today.add(const Duration(hours: 12)),
        );

        final result = eventsForDate([allDayEvent, timedEvent], today, allDay: true);

        expect(result.length, 1);
        expect(result.first.summary.id, 'allday');
      });

      test('allDay=false 요청 시 종일 이벤트는 제외된다', () {
        final allDayEvent = _makeEvent(
          id: 'allday',
          start: today,
          end: tomorrow,
          isAllDay: true,
        );

        final result = eventsForDate([allDayEvent], today, allDay: false);

        expect(result, isEmpty);
      });

      test('다른 날짜의 종일 이벤트는 반환하지 않는다', () {
        final allDayEvent = _makeEvent(
          id: 'allday',
          start: tomorrow,
          end: tomorrow.add(const Duration(days: 1)),
          isAllDay: true,
        );

        final result = eventsForDate([allDayEvent], today, allDay: true);

        expect(result, isEmpty);
      });
    });
  });

  // ===========================================================================
  // buildEventsFromReservations
  // ===========================================================================

  group('buildEventsFromReservations', () {
    test('Reservation을 ReservationDisplayData와 id→Reservation 맵으로 변환한다', () {
      final (events, map) = buildEventsFromReservations([fakeReservation]);

      expect(events.length, 1);
      expect(events.first.summary.id, fakeReservation.id);
      expect(map[fakeReservation.id], fakeReservation);
    });

    test('빈 목록 입력 시 빈 결과를 반환한다', () {
      final (events, map) = buildEventsFromReservations([]);

      expect(events, isEmpty);
      expect(map, isEmpty);
    });

    test('ReservationSummary 필드가 Reservation의 해당 필드와 일치한다', () {
      final (events, _) = buildEventsFromReservations([fakeReservation]);

      final summary = events.first.summary;
      expect(summary.id, fakeReservation.id);
      expect(summary.storeSummary, fakeReservation.storeSummary);
      expect(summary.status, fakeReservation.status);
      expect(summary.customerName, fakeReservation.customerName);
      expect(summary.headCount, fakeReservation.headCount);
      expect(summary.customerPhone, fakeReservation.customerPhone);
      expect(summary.isAllDay, fakeReservation.isAllDay);
      expect(summary.startTime, fakeReservation.startTime);
      expect(summary.endTime, fakeReservation.endTime);
    });

    test('여러 Reservation 입력 시 모두 변환된다', () {
      final r1 = fakeReservation.copyWith(id: 'res-001');
      final r2 = fakeReservation.copyWith(id: 'res-002');

      final (events, map) = buildEventsFromReservations([r1, r2]);

      expect(events.length, 2);
      expect(map.length, 2);
      expect(map.containsKey('res-001'), true);
      expect(map.containsKey('res-002'), true);
    });
  });
}
```

- [ ] **Step 2: 테스트 실행 (실패 확인)**

```bash
flutter test test/presentation/home/utils/calendar_events_utils_test.dart
```

예상: `UnimplementedError` 또는 컴파일 에러로 실패

---

### Task 3: calendar_events_utils 구현 및 테스트 통과

**Files:**
- Modify: `lib/presentation/home/utils/calendar_events_utils.dart`

- [ ] **Step 1: 함수 구현**

```dart
// lib/presentation/home/utils/calendar_events_utils.dart
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

/// Reservation 목록을 화면 표시용 데이터 구조로 변환한다.
/// 반환: (ReservationDisplayData 목록, id → Reservation 맵)
(List<ReservationDisplayData>, Map<String, Reservation>) buildEventsFromReservations(
    List<Reservation> reservations) {
  final summaries = {
    for (final r in reservations)
      r.id: ReservationSummary(
        id: r.id,
        storeSummary: r.storeSummary,
        status: r.status,
        customerName: r.customerName,
        headCount: r.headCount,
        customerPhone: r.customerPhone,
        isAllDay: r.isAllDay,
        startTime: r.startTime,
        endTime: r.endTime,
      ),
  };

  final events = summaries.values
      .map((s) => ReservationDisplayData(summary: s))
      .toList();

  final reservationsMap = {for (final r in reservations) r.id: r};

  return (events, reservationsMap);
}

/// 특정 날짜에 표시할 이벤트를 필터링한다.
///
/// - [allDay]=true: 해당 날짜의 종일 이벤트만 반환
/// - [allDay]=false: 해당 날짜에 걸쳐있는 시간대 이벤트 반환 (자정 넘김 분할 포함)
List<ReservationDisplayData> eventsForDate(
    List<ReservationDisplayData> allEvents,
    DateTime date, {
    required bool allDay,
}) {
  final dateStart = DateTime(date.year, date.month, date.day);
  final dateMidnight = dateStart.add(const Duration(days: 1));
  final result = <ReservationDisplayData>[];

  for (final e in allEvents) {
    if (e.summary.isAllDay != allDay) continue;

    if (allDay) {
      final s = e.summary.startTime;
      if (s.year == date.year && s.month == date.month && s.day == date.day) {
        result.add(e);
      }
      continue;
    }

    final start = e.summary.startTime;
    final end = e.summary.endTime;

    // 이 날짜에 시작하는 이벤트
    if (start.year == date.year &&
        start.month == date.month &&
        start.day == date.day) {
      if (end.isAfter(dateMidnight)) {
        result.add(ReservationDisplayData(
          summary: e.summary.copyWith(endTime: dateMidnight),
          continuesNextDay: true,
        ));
      } else {
        result.add(e);
      }
      continue;
    }

    // 이전 날에 시작해서 이 날짜까지 이어지는 이벤트 → 연속 셀
    if (start.isBefore(dateStart) && end.isAfter(dateStart)) {
      result.add(ReservationDisplayData(
        summary: e.summary.copyWith(startTime: dateStart),
        isContinuation: true,
      ));
    }
  }

  return result;
}
```

- [ ] **Step 2: 테스트 실행 (통과 확인)**

```bash
flutter test test/presentation/home/utils/calendar_events_utils_test.dart
```

예상: All tests PASS

- [ ] **Step 3: 커밋**

```bash
git add lib/presentation/home/utils/calendar_events_utils.dart \
        test/presentation/home/utils/calendar_events_utils_test.dart
git commit -m "feat: #5 - calendar_events_utils 순수 함수 추출 및 단위 테스트 작성"
```

---

### Task 4: homeReservationsProvider 생성 및 build_runner 실행

**Files:**
- Create: `lib/presentation/providers/home_reservations_provider.dart`

- [ ] **Step 1: Provider 파일 생성**

```dart
// lib/presentation/providers/home_reservations_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';

part 'home_reservations_provider.g.dart';

/// 현재 사용자가 접근 가능한 모든 점포의 [month] 기간 예약을 병합하여 반환한다.
///
/// - 조회 범위: [month]의 1일 00:00 ~ 다음달 1일 00:00
/// - 복수 점포 병렬 조회 후 결과 병합
/// - 일부 점포 조회 실패 시 실패 점포는 빈 목록으로 처리 (부분 성공 허용)
@riverpod
Future<List<Reservation>> homeReservations(Ref ref, DateTime month) async {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null || user.storeInfos.isEmpty) return [];

  final start = DateTime(month.year, month.month, 1);
  final end = DateTime(month.year, month.month + 1, 1);

  final useCase = ref.watch(reservationUseCaseProvider);

  final storeIds = user.storeInfos.map((info) => info.id).toList();
  final futures = storeIds
      .map((id) => useCase.getReservationsByDateRange(
            storeId: id,
            start: start,
            end: end,
          ))
      .toList();

  final results = await Future.wait(futures);

  return [
    for (final result in results)
      ...result.fold((_) => <Reservation>[], (r) => r),
  ];
}
```

- [ ] **Step 2: build_runner 실행**

```bash
dart run build_runner build --delete-conflicting-outputs
```

예상: `lib/presentation/providers/home_reservations_provider.g.dart` 생성됨

- [ ] **Step 3: 분석 확인**

```bash
dart analyze lib/presentation/providers/home_reservations_provider.dart
```

예상: No issues

---

### Task 5: homeReservationsProvider 테스트 작성 및 통과

**Files:**
- Create: `test/presentation/providers/home_reservations_provider_test.dart`

- [ ] **Step 1: 테스트 파일 작성**

```dart
// test/presentation/providers/home_reservations_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/user_store_info.dart';
import 'package:studio_chance/domain/enums/store_color.dart';
import 'package:studio_chance/domain/enums/user_role.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_reservations_provider.dart';

import '../../helpers/fake_entities.dart';

class MockReservationUseCase extends Mock implements ReservationUseCase {}

void main() {
  late MockReservationUseCase mockUseCase;
  final month = DateTime(2026, 5, 1);

  setUpAll(() {
    registerFallbackValue(DateTime(2026));
  });

  setUp(() {
    mockUseCase = MockReservationUseCase();
  });

  ProviderContainer _createContainer({required MockReservationUseCase useCase, user}) {
    return ProviderContainer(
      overrides: [
        currentUserProvider.overrideWith((ref) async => user),
        reservationUseCaseProvider.overrideWith((ref) => useCase),
      ],
    );
  }

  test('currentUser가 null이면 빈 목록을 반환하고 UseCase를 호출하지 않는다', () async {
    final container = _createContainer(useCase: mockUseCase, user: null);
    addTearDown(container.dispose);

    final result = await container.read(homeReservationsProvider(month).future);

    expect(result, isEmpty);
    verifyNever(() => mockUseCase.getReservationsByDateRange(
          storeId: any(named: 'storeId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        ));
  });

  test('storeInfos가 비어있으면 빈 목록을 반환한다', () async {
    final userWithNoStores = fakeUser.copyWith(storeInfos: []);
    final container = _createContainer(useCase: mockUseCase, user: userWithNoStores);
    addTearDown(container.dispose);

    final result = await container.read(homeReservationsProvider(month).future);

    expect(result, isEmpty);
  });

  test('단일 점포의 예약을 반환한다', () async {
    when(() => mockUseCase.getReservationsByDateRange(
          storeId: 'store-123',
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => right([fakeReservation]));

    final container = _createContainer(useCase: mockUseCase, user: fakeUser);
    addTearDown(container.dispose);

    final result = await container.read(homeReservationsProvider(month).future);

    expect(result.length, 1);
    expect(result.first.id, fakeReservation.id);
  });

  test('조회 범위가 month의 1일부터 다음달 1일까지이다', () async {
    DateTime? capturedStart;
    DateTime? capturedEnd;

    when(() => mockUseCase.getReservationsByDateRange(
          storeId: any(named: 'storeId'),
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((invocation) async {
      capturedStart = invocation.namedArguments[#start] as DateTime;
      capturedEnd = invocation.namedArguments[#end] as DateTime;
      return right(<Reservation>[]);
    });

    final container = _createContainer(useCase: mockUseCase, user: fakeUser);
    addTearDown(container.dispose);

    await container.read(homeReservationsProvider(month).future);

    expect(capturedStart, DateTime(2026, 5, 1));
    expect(capturedEnd, DateTime(2026, 6, 1));
  });

  test('복수 점포의 예약을 병합하여 반환한다', () async {
    final reservation1 = fakeReservation.copyWith(id: 'res-001');
    final reservation2 = fakeReservation.copyWith(id: 'res-002');

    when(() => mockUseCase.getReservationsByDateRange(
          storeId: 'store-123',
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => right([reservation1]));

    when(() => mockUseCase.getReservationsByDateRange(
          storeId: 'store-456',
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => right([reservation2]));

    final userWith2Stores = fakeUser.copyWith(storeInfos: [
      fakeUser.storeInfos.first,
      UserStoreInfo(
        id: 'store-456',
        name: '두번째점포',
        role: UserRole.admin,
        color: StoreColor.blue,
        memo: '',
      ),
    ]);

    final container = _createContainer(useCase: mockUseCase, user: userWith2Stores);
    addTearDown(container.dispose);

    final result = await container.read(homeReservationsProvider(month).future);

    expect(result.length, 2);
    expect(result.map((r) => r.id), containsAll(['res-001', 'res-002']));
  });

  test('한 점포 조회 실패 시 성공한 점포 결과만 포함한다', () async {
    when(() => mockUseCase.getReservationsByDateRange(
          storeId: 'store-123',
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => right([fakeReservation]));

    when(() => mockUseCase.getReservationsByDateRange(
          storeId: 'store-456',
          start: any(named: 'start'),
          end: any(named: 'end'),
        )).thenAnswer((_) async => left(Exception('네트워크 오류')));

    final userWith2Stores = fakeUser.copyWith(storeInfos: [
      fakeUser.storeInfos.first,
      UserStoreInfo(
        id: 'store-456',
        name: '두번째점포',
        role: UserRole.admin,
        color: StoreColor.blue,
        memo: '',
      ),
    ]);

    final container = _createContainer(useCase: mockUseCase, user: userWith2Stores);
    addTearDown(container.dispose);

    final result = await container.read(homeReservationsProvider(month).future);

    expect(result.length, 1);
    expect(result.first.id, fakeReservation.id);
  });
}
```

- [ ] **Step 2: 테스트 실행 (통과 확인)**

```bash
flutter test test/presentation/providers/home_reservations_provider_test.dart
```

예상: All tests PASS

- [ ] **Step 3: 커밋**

```bash
git add lib/presentation/providers/home_reservations_provider.dart \
        lib/presentation/providers/home_reservations_provider.g.dart \
        test/presentation/providers/home_reservations_provider_test.dart
git commit -m "feat: #5 - homeReservationsProvider 구현 (월별 전체 점포 예약 조회)"
```

---

### Task 6: all_day_row.dart — availableStores 파라미터 추가 및 onSaved 구현

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/all_day_row.dart`

- [ ] **Step 1: 파일 수정**

```dart
// lib/presentation/home/widgets/three_day_calendar/all_day_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';
import 'package:studio_chance/presentation/home/utils/calendar_events_utils.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_detail_modal.dart';
import 'package:studio_chance/presentation/providers/home_reservations_provider.dart';

/// 3일 캘린더 종일 이벤트 셀 (날짜 1열)
class AllDayCell extends ConsumerStatefulWidget {
  const AllDayCell({
    super.key,
    required this.events,
    required this.reservations,
    this.availableStores,
  });

  final List<ReservationDisplayData> events;

  /// 탭 시 상세 모달에 전달할 전체 Reservation 맵 (id → Reservation)
  final Map<String, Reservation> reservations;

  /// 예약 점포 선택 팝업에 표시할 점포 목록.
  final List<StoreSummary>? availableStores;

  @override
  ConsumerState<AllDayCell> createState() => _AllDayCellState();
}

class _AllDayCellState extends ConsumerState<AllDayCell> {
  final Logger _logger = Logger();
  String? _highlightedId;

  Future<void> _onCellTap(ReservationDisplayData event) async {
    final reservation = widget.reservations[event.summary.id];
    if (reservation == null) return;
    setState(() => _highlightedId = event.summary.id);
    if (!mounted) return;
    await showReservationDetailModal(
      context,
      reservation,
      availableStores: widget.availableStores,
      onSaved: (updated) {
        ref
            .read(reservationUseCaseProvider)
            .updateReservation(reservation: updated)
            .then((result) {
          result.fold(
            (e) => _logger.e('예약 수정 실패', error: e),
            (_) => ref.invalidate(homeReservationsProvider),
          );
        });
      },
    );
    if (!mounted) return;
    setState(() => _highlightedId = null);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: allDayRowHeight,
      child: Stack(
        // TODO: 다중 이벤트 겹침 처리 미구현 — 현재는 단순 Stack (겹쳐 보임)
        children: [
          for (final event in widget.events)
            Positioned(
              left: 1,
              right: 8,
              top: 1,
              bottom: 4,
              child: GestureDetector(
                onTap: () => _onCellTap(event),
                child: ReservationCell(
                  data: event,
                  isHighlighted: _highlightedId == event.summary.id,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: 분석 확인**

```bash
dart analyze lib/presentation/home/widgets/three_day_calendar/all_day_row.dart
```

예상: No issues

---

### Task 7: time_grid.dart — availableStores 파라미터 추가 및 onSaved 3곳 구현

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/time_grid.dart`

- [ ] **Step 1: TimeGrid 클래스 파라미터 추가 및 imports 수정**

`time_grid.dart` 상단 임포트에 추가:
```dart
import 'package:logger/logger.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/domain/use_cases/reservation_use_case.dart';
import 'package:studio_chance/presentation/home/utils/calendar_events_utils.dart';
import 'package:studio_chance/presentation/providers/home_reservations_provider.dart';
```

`TimeGrid` 클래스 파라미터에 `availableStores` 추가:
```dart
class TimeGrid extends ConsumerStatefulWidget {
  const TimeGrid({
    super.key,
    required this.scrollController,
    required this.isToday,
    required this.events,
    required this.reservations,
    this.availableStores,
  });

  final ScrollController scrollController;
  final bool isToday;
  final List<ReservationDisplayData> events;
  final Map<String, Reservation> reservations;

  /// 예약 점포 선택 팝업에 표시할 점포 목록.
  final List<StoreSummary>? availableStores;

  @override
  ConsumerState<TimeGrid> createState() => _TimeGridState();
}
```

`_TimeGridState`에 logger 추가:
```dart
class _TimeGridState extends ConsumerState<TimeGrid> {
  final Logger _logger = Logger();
  String? _selectedId;
  String? _highlightedId;
  // ... 나머지 기존 코드 유지
```

- [ ] **Step 2: onSaved 헬퍼 메서드 추가 (상태 클래스 내)**

`_TimeGridState` 내 `_placementFor` 메서드 위에 추가:
```dart
void _onReservationSaved(Reservation updated) {
  ref
      .read(reservationUseCaseProvider)
      .updateReservation(reservation: updated)
      .then((result) {
    result.fold(
      (e) => _logger.e('예약 수정 실패', error: e),
      (_) => ref.invalidate(homeReservationsProvider),
    );
  });
}
```

- [ ] **Step 3: `_onCellTap` 내 3곳의 onSaved를 구현으로 교체**

**① N≥4 그룹 셀 탭 (lines ~265):**
```dart
await showReservationDetailModal(
  context,
  reservation,
  availableStores: widget.availableStores,
  onSaved: _onReservationSaved,
);
```

**② isContinuation 셀 탭 (lines ~293):**
```dart
await showReservationDetailModal(
  context,
  reservation,
  availableStores: widget.availableStores,
  onSaved: _onReservationSaved,
);
```

**③ 일반 셀 탭 (lines ~317):**
```dart
await showReservationDetailModal(
  context,
  reservation,
  availableStores: widget.availableStores,
  onSaved: _onReservationSaved,
);
```

- [ ] **Step 4: 분석 확인**

```bash
dart analyze lib/presentation/home/widgets/three_day_calendar/time_grid.dart
```

예상: No issues

---

### Task 8: three_day_calendar.dart 목업 제거 및 Provider 연결

**Files:**
- Modify: `lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart`

- [ ] **Step 1: 임포트 교체**

파일 상단 임포트 블록 전체 교체:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/store_summary.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/home/utils/calendar_events_utils.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/all_day_row.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/current_time_indicator.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/time_grid.dart';
import 'package:studio_chance/presentation/providers/app_auth_controller.dart';
import 'package:studio_chance/presentation/providers/home_calendar_controller.dart';
import 'package:studio_chance/presentation/providers/home_reservations_provider.dart';
```

- [ ] **Step 2: `_ThreeDayCalendarState` 에서 목업 코드 전체 제거**

`_ThreeDayCalendarState` 내에서 다음 블록 전체 삭제:
- `// ── 목업 데이터 ──` 주석부터 `_buildMockData()` 메서드 끝까지 (lines 38~330)
- `_eventsForDate` static 메서드 전체 (lines 332~381)

- [ ] **Step 3: `build()` 메서드 내 실제 데이터 연결 추가**

`build()` 메서드 상단에 (기존 `final hourHeight = ref.watch(...)` 바로 위에) 추가:

```dart
// 표시 월 기준 예약 데이터 조회
final displayedMonth = ref.watch(
  homeCalendarControllerProvider.select((s) => s.displayedMonth),
);
final reservationsAsync = ref.watch(homeReservationsProvider(displayedMonth));
final reservations = reservationsAsync.when(
  data: (r) => r,
  loading: () => const [],
  error: (_, __) => const [],
);
final (allEvents, reservationsMap) = buildEventsFromReservations(reservations);

// 현재 사용자의 점포 목록 → 모달 availableStores
final currentUser = ref.watch(currentUserProvider).asData?.value;
final availableStores = currentUser?.storeInfos
    .map((info) => StoreSummary(
          id: info.id,
          name: info.name,
          color: info.color,
        ))
    .toList();
```

- [ ] **Step 4: `itemBuilder` 내 AllDayCell / TimeGrid 호출 수정**

기존 mock 데이터 참조를 실제 데이터로 교체:

```dart
// 종일 이벤트 셀
AllDayCell(
  events: eventsForDate(allEvents, date, allDay: true),
  reservations: reservationsMap,
  availableStores: availableStores,
),
// ...
// 이벤트 그리드
Expanded(
  child: TimeGrid(
    scrollController: _controllerForPage(index),
    isToday: _isToday(date),
    events: eventsForDate(allEvents, date, allDay: false),
    reservations: reservationsMap,
    availableStores: availableStores,
  ),
),
```

- [ ] **Step 5: 분석 확인**

```bash
dart analyze lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart
```

예상: No issues

- [ ] **Step 6: 전체 분석 확인**

```bash
dart analyze
```

예상: No issues (또는 기존에 있던 warning만 존재)

---

### Task 9: 최종 테스트 실행 및 커밋

- [ ] **Step 1: 전체 테스트 실행**

```bash
flutter test
```

예상: All tests PASS (기존 테스트 포함)

- [ ] **Step 2: 최종 커밋**

```bash
git add \
  lib/presentation/home/widgets/three_day_calendar/all_day_row.dart \
  lib/presentation/home/widgets/three_day_calendar/time_grid.dart \
  lib/presentation/home/widgets/three_day_calendar/three_day_calendar.dart
git commit -m "feat: #5 - 캘린더 실제 데이터 연결, 목업 제거, onSaved 구현"
```

---

## 자기 검토 (Spec Coverage)

| 스펙 항목 | 대응 Task |
|----------|----------|
| 목업 데이터 제거 | Task 8 |
| homeReservationsProvider 생성 | Task 4 |
| 모든 점포 병렬 조회·병합 | Task 4 |
| onSaved 연결 (all_day_row 1곳) | Task 6 |
| onSaved 연결 (time_grid 3곳) | Task 7 |
| availableStores 전달 | Task 6, 7, 8 |
| calendar_events_utils 추출 | Task 1, 3 |
| 단위 테스트 (유틸) | Task 2 |
| 단위 테스트 (Provider) | Task 5 |
| 저장 실패 시 logger 기록 | Task 6, 7 |
| 저장 성공 시 provider invalidate | Task 6, 7 |

**스코프 외 (이번 PR 미포함):**
- n번째 예약 계산 로직 (modal line 763)
- 입금/확정 안내문 화면 (modal lines 783, 789)
- 종일 이벤트 겹침 처리 (all_day_row line 49)
- 점포 필터 버튼 UI

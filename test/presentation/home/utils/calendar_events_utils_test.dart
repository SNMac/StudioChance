import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/constants/ui_constants.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/home/utils/calendar_events_utils.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

import '../../../helpers/fake_entities.dart';

ReservationDisplayData _makeEvent({
  required String id,
  required DateTime start,
  required DateTime end,
  bool isAllDay = false,
  String customerName = '테스트',
  DateTime? createdAt,
}) {
  return ReservationDisplayData(
    summary: ReservationSummary(
      id: id,
      storeSummary: fakeStoreSummary,
      status: fakeReservation.status,
      customerName: customerName,
      headCount: 1,
      customerPhone: '010-0000-0000',
      isAllDay: isAllDay,
      startTime: start,
      endTime: end,
      createdAt: createdAt,
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

        final result = eventsForDate(
          [allDayEvent, timedEvent],
          today,
          allDay: true,
        );

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
      final (events, map, _) = buildEventsFromReservations([fakeReservation]);

      expect(events.length, 1);
      expect(events.first.summary.id, fakeReservation.id);
      expect(map[fakeReservation.id], fakeReservation);
    });

    test('빈 목록 입력 시 빈 결과를 반환한다', () {
      final (events, map, allDayCounts) = buildEventsFromReservations([]);

      expect(events, isEmpty);
      expect(map, isEmpty);
      expect(allDayCounts, isEmpty);
    });

    test('ReservationSummary 필드가 Reservation의 해당 필드와 일치한다', () {
      final reservation = fakeReservation.copyWith(
        createdAt: DateTime(2026, 4, 30, 9, 0),
      );
      final (events, _, _) = buildEventsFromReservations([reservation]);

      final summary = events.first.summary;
      expect(summary.id, reservation.id);
      expect(summary.storeSummary, reservation.storeSummary);
      expect(summary.status, reservation.status);
      expect(summary.customerName, reservation.customerName);
      expect(summary.headCount, reservation.headCount);
      expect(summary.customerPhone, reservation.customerPhone);
      expect(summary.isAllDay, reservation.isAllDay);
      expect(summary.startTime, reservation.startTime);
      expect(summary.endTime, reservation.endTime);
      expect(summary.createdAt, reservation.createdAt);
    });

    test('종일 예약을 시작일 기준으로 세어 날짜별 건수를 반환한다', () {
      final day = DateTime(2026, 8, 25);
      final other = DateTime(2026, 8, 26);
      final r1 = fakeReservation.copyWith(
        id: 'a',
        isAllDay: true,
        startTime: day,
        endTime: day.add(const Duration(hours: 23)),
      );
      final r2 = fakeReservation.copyWith(
        id: 'b',
        isAllDay: true,
        startTime: day.add(const Duration(hours: 9)),
        endTime: day.add(const Duration(hours: 23)),
      );
      final r3 = fakeReservation.copyWith(
        id: 'c',
        isAllDay: true,
        startTime: other,
        endTime: other.add(const Duration(hours: 23)),
      );

      final (_, _, allDayCounts) = buildEventsFromReservations([r1, r2, r3]);

      expect(allDayCounts[day], 2);
      expect(allDayCounts[other], 1);
    });

    test('시간대 예약은 날짜별 종일 건수에 포함하지 않는다', () {
      final day = DateTime(2026, 8, 25);
      final timed = fakeReservation.copyWith(
        id: 'timed',
        isAllDay: false,
        startTime: day.add(const Duration(hours: 10)),
        endTime: day.add(const Duration(hours: 12)),
      );

      final (_, _, allDayCounts) = buildEventsFromReservations([timed]);

      expect(allDayCounts[day], isNull);
    });

    test('여러 Reservation 입력 시 모두 변환된다', () {
      final r1 = fakeReservation.copyWith(id: 'res-001');
      final r2 = fakeReservation.copyWith(id: 'res-002');

      final (events, map, _) = buildEventsFromReservations([r1, r2]);

      expect(events.length, 2);
      expect(map.length, 2);
      expect(map.containsKey('res-001'), true);
      expect(map.containsKey('res-002'), true);
    });
  });

  // ===========================================================================
  // sortAllDayEventsForDisplay
  // ===========================================================================

  group('sortAllDayEventsForDisplay', () {
    test('시작 시각이 빠른 이벤트가 먼저 온다', () {
      final later = _makeEvent(
        id: 'later',
        start: today.add(const Duration(hours: 2)),
        end: today.add(const Duration(hours: 3)),
        isAllDay: true,
      );
      final earlier = _makeEvent(
        id: 'earlier',
        start: today,
        end: today.add(const Duration(hours: 1)),
        isAllDay: true,
      );

      final result = sortAllDayEventsForDisplay([later, earlier]);

      expect(result.map((e) => e.summary.id).toList(), ['earlier', 'later']);
    });

    test('시작 시각이 같으면 종료 시각이 빠른 이벤트가 먼저 온다', () {
      final long = _makeEvent(
        id: 'long',
        start: today,
        end: today.add(const Duration(days: 2)),
        isAllDay: true,
      );
      final short = _makeEvent(
        id: 'short',
        start: today,
        end: today.add(const Duration(days: 1)),
        isAllDay: true,
      );

      final result = sortAllDayEventsForDisplay([long, short]);

      expect(result.map((e) => e.summary.id).toList(), ['short', 'long']);
    });

    test('시작·종료 시각이 같으면 생성 시각(createdAt) 오름차순으로 정렬한다 (이름보다 우선)', () {
      final later = _makeEvent(
        id: 'later',
        start: today,
        end: today.add(const Duration(days: 1)),
        isAllDay: true,
        customerName: '가가', // 이름만 보면 later가 먼저 와야 하지만 createdAt이 우선한다
        createdAt: today.add(const Duration(hours: 2)),
      );
      final earlier = _makeEvent(
        id: 'earlier',
        start: today,
        end: today.add(const Duration(days: 1)),
        isAllDay: true,
        customerName: '나나',
        createdAt: today.add(const Duration(hours: 1)),
      );

      final result = sortAllDayEventsForDisplay([later, earlier]);

      expect(result.map((e) => e.summary.id).toList(), ['earlier', 'later']);
    });

    test('시작·종료 시각·생성 시각이 같으면 예약자명 오름차순으로 정렬한다', () {
      final bravo = _makeEvent(
        id: 'bravo',
        start: today,
        end: today.add(const Duration(days: 1)),
        isAllDay: true,
        customerName: '나나',
        createdAt: today,
      );
      final alpha = _makeEvent(
        id: 'alpha',
        start: today,
        end: today.add(const Duration(days: 1)),
        isAllDay: true,
        customerName: '가가',
        createdAt: today,
      );

      final result = sortAllDayEventsForDisplay([bravo, alpha]);

      expect(result.map((e) => e.summary.id).toList(), ['alpha', 'bravo']);
    });

    test('createdAt이 null인 이벤트는 뒤로 밀린다 (이름 순서와 무관)', () {
      final withCreatedAt = _makeEvent(
        id: 'withCreatedAt',
        start: today,
        end: today.add(const Duration(days: 1)),
        isAllDay: true,
        customerName: '나나', // 이름만 보면 뒤에 와야 하지만 createdAt 존재 여부가 우선한다
        createdAt: today,
      );
      final withoutCreatedAt = _makeEvent(
        id: 'withoutCreatedAt',
        start: today,
        end: today.add(const Duration(days: 1)),
        isAllDay: true,
        customerName: '가가',
      );

      final result = sortAllDayEventsForDisplay([
        withoutCreatedAt,
        withCreatedAt,
      ]);

      expect(result.map((e) => e.summary.id).toList(), [
        'withCreatedAt',
        'withoutCreatedAt',
      ]);
    });

    test('원본 리스트를 변경하지 않는다', () {
      final a = _makeEvent(
        id: 'a',
        start: today.add(const Duration(hours: 5)),
        end: today.add(const Duration(hours: 6)),
        isAllDay: true,
      );
      final b = _makeEvent(
        id: 'b',
        start: today,
        end: today.add(const Duration(hours: 1)),
        isAllDay: true,
      );
      final original = [a, b];

      sortAllDayEventsForDisplay(original);

      expect(original.map((e) => e.summary.id).toList(), ['a', 'b']);
    });

    test('빈 목록 입력 시 빈 목록을 반환한다', () {
      final result = sortAllDayEventsForDisplay([]);
      expect(result, isEmpty);
    });

    test('시작 시각과 기간이 모두 같으면 id 오름차순으로 정렬한다', () {
      final b = _makeEvent(
        id: 'b',
        start: today,
        end: today.add(const Duration(days: 1)),
        isAllDay: true,
      );
      final a = _makeEvent(
        id: 'a',
        start: today,
        end: today.add(const Duration(days: 1)),
        isAllDay: true,
      );

      final result = sortAllDayEventsForDisplay([b, a]);

      expect(result.map((e) => e.summary.id).toList(), ['a', 'b']);
    });
  });

  // ===========================================================================
  // allDayRowHeightFor
  // ===========================================================================

  group('allDayRowHeightFor', () {
    test('겹침이 없으면 펼침 여부와 무관하게 1칸이다', () {
      expect(
        allDayRowHeightFor(maxCount: 0, isExpanded: true),
        allDayRowHeight,
      );
      expect(
        allDayRowHeightFor(maxCount: 1, isExpanded: true),
        allDayRowHeight,
      );
    });

    test('접힘 상태는 겹침이 많아도 1칸이다', () {
      expect(
        allDayRowHeightFor(maxCount: 5, isExpanded: false),
        allDayRowHeight,
      );
    });

    test('펼침 상태는 겹침 수만큼 칸이 늘어난다', () {
      expect(
        allDayRowHeightFor(maxCount: 2, isExpanded: true),
        allDayRowHeight * 2,
      );
      expect(
        allDayRowHeightFor(maxCount: 3, isExpanded: true),
        allDayRowHeight * 3,
      );
    });

    test('펼침 상태에서 최대 칸 수를 넘어도 높이는 더 늘어나지 않는다', () {
      final capped = allDayRowHeight * allDayMaxStackCount;
      expect(allDayRowHeightFor(maxCount: 4, isExpanded: true), capped);
      expect(allDayRowHeightFor(maxCount: 20, isExpanded: true), capped);
    });
  });
}

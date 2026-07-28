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

    test('시작 시각이 같으면 기간이 짧은 이벤트가 먼저 온다', () {
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
}

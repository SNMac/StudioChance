import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studio_chance/domain/entities/reservation.dart';
import 'package:studio_chance/domain/entities/reservation_summary.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/all_day_row.dart';
import 'package:studio_chance/presentation/home/widgets/three_day_calendar/reservation_cell.dart';

import '../../../helpers/fake_entities.dart';

final _day = DateTime(2026, 8, 25);

ReservationDisplayData _makeAllDayEvent({
  required String id,
  required String customerName,
  required int createdAtMinute,
}) {
  return ReservationDisplayData(
    summary: ReservationSummary(
      id: id,
      storeSummary: fakeStoreSummary,
      status: fakeReservation.status,
      customerName: customerName,
      headCount: 2,
      customerPhone: '010-0000-0000',
      isAllDay: true,
      startTime: _day,
      endTime: _day.add(const Duration(hours: 23, minutes: 59)),
      createdAt: _day.add(Duration(minutes: createdAtMinute)),
    ),
  );
}

Reservation _reservationFor(ReservationDisplayData event) {
  return fakeReservation.copyWith(
    id: event.summary.id,
    customerName: event.summary.customerName,
    isAllDay: true,
    startTime: event.summary.startTime,
    endTime: event.summary.endTime,
  );
}

Future<void> _pumpAllDayCell(
  WidgetTester tester, {
  required List<ReservationDisplayData> events,
  required bool isExpanded,
}) async {
  final reservations = {
    for (final event in events) event.summary.id: _reservationFor(event),
  };

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 120,
          child: AllDayCell(
            events: events,
            reservations: reservations,
            onOpenDetailModal: (_) async {},
            isInteractionBlocked: false,
            isExpanded: isExpanded,
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('AllDayCell 펼침/접힘', () {
    testWidgets('펼침 상태에서 2건이면 두 예약이 모두 표시된다', (tester) async {
      final events = [
        _makeAllDayEvent(id: 'e1', customerName: '가나다', createdAtMinute: 1),
        _makeAllDayEvent(id: 'e2', customerName: '라마바', createdAtMinute: 2),
      ];

      await _pumpAllDayCell(tester, events: events, isExpanded: true);

      expect(find.textContaining('가나다'), findsOneWidget);
      expect(find.textContaining('라마바'), findsOneWidget);
    });

    testWidgets('펼침 상태에서 4건이면 앞 2건과 더보기 행이 표시된다', (tester) async {
      final events = [
        for (int i = 1; i <= 4; i++)
          _makeAllDayEvent(id: 'e$i', customerName: '고객$i', createdAtMinute: i),
      ];

      await _pumpAllDayCell(tester, events: events, isExpanded: true);

      expect(find.textContaining('고객1'), findsOneWidget);
      expect(find.textContaining('고객2'), findsOneWidget);
      expect(find.textContaining('고객3'), findsNothing);
      expect(find.text('+2건 더보기'), findsOneWidget);
    });

    testWidgets('접힘 상태에서는 대표 1건과 초과 배지만 표시된다', (tester) async {
      final events = [
        _makeAllDayEvent(id: 'e1', customerName: '가나다', createdAtMinute: 1),
        _makeAllDayEvent(id: 'e2', customerName: '라마바', createdAtMinute: 2),
      ];

      await _pumpAllDayCell(tester, events: events, isExpanded: false);

      expect(find.textContaining('가나다'), findsOneWidget);
      expect(find.textContaining('라마바'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('펼침 상태여도 1건이면 더보기 행이 없다', (tester) async {
      final events = [
        _makeAllDayEvent(id: 'e1', customerName: '가나다', createdAtMinute: 1),
      ];

      await _pumpAllDayCell(tester, events: events, isExpanded: true);

      expect(find.textContaining('가나다'), findsOneWidget);
      expect(find.textContaining('더보기'), findsNothing);
    });
  });
}

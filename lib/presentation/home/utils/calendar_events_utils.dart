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

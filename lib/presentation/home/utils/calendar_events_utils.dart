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
        createdAt: r.createdAt,
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

/// null을 가장 뒤로 보내는 널러블 DateTime 비교.
/// createdAt은 서버 타임스탬프가 아직 로컬에 반영되지 않으면 일시적으로 null일 수 있어
/// (예: 생성 직후) 방어적으로 처리한다.
int _compareNullableDateTime(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}

/// 종일 이벤트를 배지 대표 이벤트 선정을 위해 정렬한다.
///
/// 정렬 우선순위: 시작 시각 → 종료 시각 → 예약자명 → 생성 시각(createdAt) → id
/// (모두 오름차순). 앞 기준이 동점일 때만 다음 기준으로 넘어가며, id까지 동점인
/// 경우는 사실상 없으므로 항상 결정적인 순서가 보장된다. 원본 리스트는 변경하지 않는다.
List<ReservationDisplayData> sortAllDayEventsForDisplay(
    List<ReservationDisplayData> events) {
  final sorted = [...events];
  sorted.sort((a, b) {
    final startCmp = a.summary.startTime.compareTo(b.summary.startTime);
    if (startCmp != 0) return startCmp;
    final endCmp = a.summary.endTime.compareTo(b.summary.endTime);
    if (endCmp != 0) return endCmp;
    final nameCmp = a.summary.customerName.compareTo(b.summary.customerName);
    if (nameCmp != 0) return nameCmp;
    final createdCmp =
        _compareNullableDateTime(a.summary.createdAt, b.summary.createdAt);
    if (createdCmp != 0) return createdCmp;
    return a.summary.id.compareTo(b.summary.id);
  });
  return sorted;
}

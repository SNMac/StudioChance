import 'package:freezed_annotation/freezed_annotation.dart';

part 'holiday_calendar.freezed.dart';

/// 공휴일 달력에서 날짜를 가리키는 키 (`yyyy-MM-dd`, 기기 로컬 날짜 기준).
///
/// 서버(`holidays/{year}` 문서)와 공휴일 스냅샷(`Reservation.holidayDates`)이 같은 형식을 쓴다.
String holidayDateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// 연도별 공휴일 날짜와 이름.
///
/// 공식 공휴일인지 예측 공휴일인지는 구분하지 않는다 (ADR-0002).
@freezed
abstract class HolidayCalendar with _$HolidayCalendar {
  const HolidayCalendar._();

  /// [daysByYear]: 연도 → {날짜 키: 공휴일 이름 목록}.
  /// 키가 없는 연도는 공휴일 여부를 알 수 없는 연도다 (빈 map은 "공휴일 없음").
  const factory HolidayCalendar({
    @Default({}) Map<int, Map<String, List<String>>> daysByYear,
  }) = _HolidayCalendar;

  /// [date]의 공휴일 여부. 그 연도를 모르면 null.
  bool? isHoliday(DateTime date) {
    final days = daysByYear[date.year];
    if (days == null) return null;
    return days.containsKey(holidayDateKey(date));
  }

  /// 가격 계산용 공휴일 판정 — 모르는 연도는 공휴일이 아닌 것으로 본다.
  ///
  /// 공휴일 달력을 읽지 못해도 예약 저장을 막지 않기 위한 규칙이다. UseCase와 두 예약
  /// 모달이 이 메서드를 공유해야 화면 가격과 저장 가격이 어긋나지 않는다.
  bool isHolidayForPricing(DateTime date) => isHoliday(date) ?? false;

  /// [date]의 공휴일 이름들. 공휴일이 아니거나 그 연도를 모르면 빈 목록.
  List<String> namesOn(DateTime date) =>
      daysByYear[date.year]?[holidayDateKey(date)] ?? const [];
}

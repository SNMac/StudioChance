import 'package:flutter/material.dart';

import 'package:studio_chance/domain/entities/holiday_calendar.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/providers/holiday_calendar_controller.dart';

/// 예약 모달의 결제 정보 아래에 붙이는 공휴일 안내 문구. 표시할 것이 없으면 null.
///
/// 요금표에 공휴일 요일 그룹이 없으면 공휴일 여부가 가격에 영향을 주지 않으므로
/// 아무것도 표시하지 않는다. 예측 공휴일과 공식 공휴일은 구분하지 않는다 (ADR-0002).
///
/// [snapshotKeys]는 공휴일 스냅샷으로 판정하는 날짜들이다. 이 날짜들은 현재 공휴일 달력을
/// 읽지 못해도 스냅샷대로 계산하므로 "확인 불가"로 보지 않는다.
String? holidayPriceNote({
  required PriceSetting? priceSetting,
  required DateTime start,
  required DateTime end,
  required bool isAllDay,
  required bool Function(DateTime date) isHoliday,
  required HolidayCalendarState holidays,
  Set<String> snapshotKeys = const {},
}) {
  if (priceSetting == null || !priceSetting.hasHolidayDayGroup) return null;

  final dates = pricedDatesOf(start: start, end: end, isAllDay: isAllDay);
  final hasUnconfirmed = dates.any(
    (date) =>
        !snapshotKeys.contains(holidayDateKey(date)) &&
        holidays.isUnconfirmed(date),
  );
  if (hasUnconfirmed) return '공휴일 정보를 확인하지 못해 공휴일 요금을 적용하지 않았습니다';

  final holidayDates = dates.where(isHoliday).toList();
  if (holidayDates.isEmpty) return null;
  final names = {
    for (final date in holidayDates) ...holidays.calendar.namesOn(date),
  };
  // 이름은 현재 공휴일 달력에서 찾으므로, 공휴일 스냅샷에만 남은 날짜는 이름이 없을 수 있다
  return names.isEmpty
      ? '공휴일 요금이 적용되었습니다'
      : '공휴일 요금이 적용되었습니다 (${names.join(', ')})';
}

/// [holidayPriceNote]를 결제 정보 footer에 표시하는 위젯.
///
/// 요금 행 안에 두면 금액과 폭을 나눠 공휴일 이름이 잘리므로 footer에 줄바꿈을 허용해 둔다.
class HolidayPriceNoteText extends StatelessWidget {
  const HolidayPriceNoteText(this.note, {super.key});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Text(
      note,
      style: Theme.of(context).textTheme.labelMedium
          ?.copyWith(color: context.secondaryLabel),
    );
  }
}

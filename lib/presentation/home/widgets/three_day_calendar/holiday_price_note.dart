import 'package:flutter/material.dart';

import 'package:studio_chance/domain/entities/holiday_calendar.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';
import 'package:studio_chance/presentation/commons/extensions/context_colors.dart';
import 'package:studio_chance/presentation/providers/holiday_calendar_controller.dart';

/// 예약 모달의 요금 옆에 붙이는 공휴일 안내 문구. 표시할 것이 없으면 null.
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
  if (hasUnconfirmed) return '공휴일 확인 불가';

  final holidayDates = dates.where(isHoliday).toList();
  if (holidayDates.isEmpty) return null;
  final names = {
    for (final date in holidayDates) ...holidays.calendar.namesOn(date),
  };
  // 이름은 현재 공휴일 달력에서 찾으므로, 공휴일 스냅샷에만 남은 날짜는 이름이 없을 수 있다
  return names.isEmpty ? '공휴일 요금' : '공휴일 요금 · ${names.join(', ')}';
}

/// [holidayPriceNote]를 요금 행(`TitleTextLabel.leading`)에 표시하는 위젯.
class HolidayPriceNoteText extends StatelessWidget {
  const HolidayPriceNoteText(this.note, {super.key});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text(
        note,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(color: context.secondaryLabel),
      ),
    );
  }
}

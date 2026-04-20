import 'package:flutter/foundation.dart';

import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/enums/weekday.dart';

extension DayGroupFormatter on DayGroup {
  String get formattedDays {
    final bool hasHoliday = days.contains(Weekday.holiday);

    final logicDays = days
        .where((d) => d != Weekday.holiday)
        .toList()
      ..sort((a, b) => a.index.compareTo(b.index));

    if (logicDays.isEmpty) {
      return hasHoliday ? '공휴일' : '요일 선택';
    }

    final weekdays = [
      Weekday.monday,
      Weekday.tuesday,
      Weekday.wednesday,
      Weekday.thursday,
      Weekday.friday,
    ];
    final weekends = [Weekday.saturday, Weekday.sunday];
    final allDays = [...weekdays, ...weekends];

    String mainText = '';

    if (listEquals(logicDays, allDays)) {
      mainText = '매일';
    } else if (listEquals(logicDays, weekdays)) {
      mainText = '평일';
    } else if (listEquals(logicDays, weekends)) {
      mainText = '주말';
    } else {
      final displayOrder = [
        Weekday.sunday,
        Weekday.monday,
        Weekday.tuesday,
        Weekday.wednesday,
        Weekday.thursday,
        Weekday.friday,
        Weekday.saturday,
      ];

      final sortedForDisplay = displayOrder
          .where((d) => logicDays.contains(d))
          .toList();

      if (sortedForDisplay.length == 1) {
        mainText = sortedForDisplay.first.displayName;
      } else {
        mainText = sortedForDisplay.map((d) => d.shortName).join(', ');
      }
    }

    if (hasHoliday) {
      return mainText.isEmpty ? '공휴일' : '$mainText, 공휴일';
    }

    return mainText;
  }
}

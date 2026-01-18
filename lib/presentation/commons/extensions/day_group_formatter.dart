import 'package:flutter/foundation.dart';

import 'package:studio_chance/domain/entities/day_group.dart';

extension DayGroupFormatter on DayGroup {
  String get formattedDays {
    final bool hasHoliday = days.contains(8);

    final realDays = days.where((d) => d != 8).toList()..sort();

    if (realDays.isEmpty) {
      return hasHoliday ? '공휴일' : '요일 선택';
    }

    final weekdays = [1, 2, 3, 4, 5];
    final weekends = [6, 7];
    final allDays = [1, 2, 3, 4, 5, 6, 7];

    String mainText = '';

    if (listEquals(realDays, allDays)) {
      mainText = '매일';
    } else if (listEquals(realDays, weekdays)) {
      mainText = '평일';
    } else if (listEquals(realDays, weekends)) {
      mainText = '주말';
    } else {
      final dayNames = {1: '월', 2: '화', 3: '수', 4: '목', 5: '금', 6: '토', 7: '일'};

      if (realDays.length == 1) {
        // 하나만 선택된 경우: "월요일"
        mainText = '${dayNames[realDays.first]}요일';
      } else {
        // 여러 개 섞인 경우: "월, 수, 금"
        mainText = realDays.map((d) => dayNames[d]).join(', ');
      }
    }

    if (hasHoliday) {
      return '$mainText + 공휴일';
    }

    return mainText;
  }
}

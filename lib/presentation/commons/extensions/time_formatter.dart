import 'package:flutter/material.dart';

extension IntTimeFormatter on int {
  /// 분(int)을 "HH:mm" 형식의 문자열로 변환
  /// 예: 600 -> "10:00", 1440(자정 끝) -> "00:00"
  String get formattedTime {
    if (this == 1440) return '00:00';
    final int hour = this ~/ 60;
    final int minute = this % 60;
    final String hourStr = hour.toString().padLeft(2, '0');
    final String minuteStr = minute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  /// 분(int)을 Flutter의 TimeOfDay 객체로 변환
  /// ShowTimePicker의 initialTime에 넣을 때 유용함
  TimeOfDay get toTimeOfDay {
    return TimeOfDay(hour: this ~/ 60, minute: this % 60);
  }
}

extension TimeOfDayConverter on TimeOfDay {
  /// TimeOfDay를 분(int)으로 변환
  /// 저장할 때 유용함
  int get toMinutes => hour * 60 + minute;
}

extension DateTimeFormatter on DateTime {
  /// 날짜/시간을 "YYYY. MM. DD. (요일) [HH:mm]" 형식의 문자열로 변환.
  /// [dateOnly]가 true이면 시간 부분(HH:mm)을 생략한다.
  /// 예: 2026-07-27 14:30 -> "2026. 07. 27. (월) 14:30"
  String formattedDateTime({bool dateOnly = false}) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekdayLabel = weekdays[weekday - 1];
    final date =
        '$year. ${month.toString().padLeft(2, '0')}. ${day.toString().padLeft(2, '0')}. ($weekdayLabel)';
    if (dateOnly) return date;
    return '$date ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

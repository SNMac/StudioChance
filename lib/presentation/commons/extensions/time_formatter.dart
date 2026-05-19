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

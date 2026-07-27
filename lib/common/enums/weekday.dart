import 'package:json_annotation/json_annotation.dart';

/// ISO 8601 기준 (1=월요일, 7=일요일, 8=공휴일)
/// Dart DateTime.weekday와 동일한 int 값 사용
@JsonEnum()
enum Weekday {
  @JsonValue(1)
  monday,
  @JsonValue(2)
  tuesday,
  @JsonValue(3)
  wednesday,
  @JsonValue(4)
  thursday,
  @JsonValue(5)
  friday,
  @JsonValue(6)
  saturday,
  @JsonValue(7)
  sunday,
  @JsonValue(8)
  holiday;

  String get displayName => switch (this) {
    Weekday.monday => '월요일',
    Weekday.tuesday => '화요일',
    Weekday.wednesday => '수요일',
    Weekday.thursday => '목요일',
    Weekday.friday => '금요일',
    Weekday.saturday => '토요일',
    Weekday.sunday => '일요일',
    Weekday.holiday => '공휴일',
  };

  String get shortName => switch (this) {
    Weekday.monday => '월',
    Weekday.tuesday => '화',
    Weekday.wednesday => '수',
    Weekday.thursday => '목',
    Weekday.friday => '금',
    Weekday.saturday => '토',
    Weekday.sunday => '일',
    Weekday.holiday => '공',
  };
}

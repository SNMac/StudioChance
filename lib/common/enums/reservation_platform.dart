import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum ReservationPlatform {
  @JsonValue('NAVER')
  naver,
  @JsonValue('SPACECLOUD')
  spaceCloud,
  @JsonValue('YANOLJA')
  yanolja,
  @JsonValue('OTHER')
  other;

  String get displayName => switch (this) {
    ReservationPlatform.naver => '네이버 예약',
    ReservationPlatform.spaceCloud => '스페이스클라우드',
    ReservationPlatform.yanolja => '야놀자',
    ReservationPlatform.other => '기타',
  };

  String get jsonValue => switch (this) {
    ReservationPlatform.naver => 'NAVER',
    ReservationPlatform.spaceCloud => 'SPACECLOUD',
    ReservationPlatform.yanolja => 'YANOLJA',
    ReservationPlatform.other => 'OTHER',
  };
}

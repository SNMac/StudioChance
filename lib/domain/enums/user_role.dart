import 'package:json_annotation/json_annotation.dart';

@JsonEnum()
enum UserRole {
  @JsonValue('ADMIN')
  admin,
  @JsonValue('STAFF')
  staff,
  @JsonValue('VIEWER')
  viewer,
  @JsonValue('NONE')
  none;

  String get displayName => switch (this) {
    UserRole.admin => '관리자',
    UserRole.staff => '스태프',
    UserRole.viewer => '뷰어',
    UserRole.none => '역할 없음',
  };

  String get displayDescription => switch (this) {
    UserRole.admin => '점포 관리 및 초대, 예약 관리',
    UserRole.staff => '초대받은 점포의 예약 관리',
    UserRole.viewer => '초대받은 점포의 예약 확인',
    UserRole.none => '역할 없음',
  };
}

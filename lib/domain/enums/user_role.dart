import 'package:json_annotation/json_annotation.dart';

@JsonEnum(alwaysCreate: true)
enum UserRole {
  admin,
  staff,
  viewer,
  none;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return '관리자';
      case UserRole.staff:
        return '스태프';
      case UserRole.viewer:
        return '뷰어';
      case UserRole.none:
        return '역할 없음';
    }
  }

  String get displayDescription {
    switch (this) {
      case UserRole.admin:
        return '점포 관리 및 초대, 예약 관리';
      case UserRole.staff:
        return '초대받은 점포의 예약 관리';
      case UserRole.viewer:
        return '초대받은 점포의 예약 확인';
      case UserRole.none:
        return '역할 없음';
    }
  }
}

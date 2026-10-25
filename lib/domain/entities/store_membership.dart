import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:studio_chance/common/enums/user_role.dart';

part 'store_membership.freezed.dart';

/// 점포 문서에 기록된 멤버 구성 (사용자 정보 없이 uid와 역할만)
///
/// [Store.memberInfos]는 멤버마다 사용자 문서를 읽어 채우므로 읽지 못한 멤버가 빠진다.
/// 관리자 판정·멤버 수처럼 한 명이라도 빠지면 판단이 틀어지는 곳은 이 값을 쓴다.
/// 승인 대기자는 멤버가 아니므로 포함하지 않는다.
@freezed
abstract class StoreMembership with _$StoreMembership {
  const StoreMembership._();

  const factory StoreMembership({required Map<String, UserRole> roleByUid}) =
      _StoreMembership;

  /// [uid]의 역할. 멤버가 아니면 null
  UserRole? roleOf(String uid) => roleByUid[uid];

  /// [uid] 말고 다른 멤버가 있는지
  bool hasMembersOtherThan(String uid) => roleByUid.keys.any((id) => id != uid);
}

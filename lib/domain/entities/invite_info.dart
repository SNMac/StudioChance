import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_info.freezed.dart';

@freezed
abstract class InviteInfo with _$InviteInfo {
  const InviteInfo._();

  const factory InviteInfo({
    required String inviteCode,
    required DateTime createdAt,
  }) = _InviteInfo;

  DateTime get expiresAt => createdAt.add(const Duration(minutes: 15));

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

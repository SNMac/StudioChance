import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_info.freezed.dart';

@freezed
abstract class InviteInfo with _$InviteInfo {
  const factory InviteInfo({required String inviteCode}) = _InviteInfo;
}

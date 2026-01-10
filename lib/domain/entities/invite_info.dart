import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_info.freezed.dart';
part 'invite_info.g.dart';

@freezed
abstract class InviteInfo with _$InviteInfo {
  const factory InviteInfo({required String inviteCode}) = _InviteInfo;

  factory InviteInfo.fromJson(Map<String, dynamic> json) =>
      _$InviteInfoFromJson(json);
}

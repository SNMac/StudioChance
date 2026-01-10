import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/converters/timestamp_converter.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';

part 'invite_info_model.freezed.dart';
part 'invite_info_model.g.dart';

@freezed
abstract class InviteInfoModel with _$InviteInfoModel {
  const factory InviteInfoModel({
    required String inviteCode,
    @TimestampConverter() required DateTime expiresAt,
  }) = _InviteInfoModel;

  factory InviteInfoModel.fromJson(Map<String, dynamic> json) =>
      _$InviteInfoModelFromJson(json);
}

extension InviteInfoModelExtension on InviteInfoModel {
  InviteInfo toEntity() {
    return InviteInfo(inviteCode: inviteCode);
  }
}

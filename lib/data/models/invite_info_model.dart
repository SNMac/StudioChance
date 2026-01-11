import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/common/converters/timestamp_converter.dart';
import 'package:studio_chance/domain/entities/invite_info.dart';

part 'invite_info_model.freezed.dart';
part 'invite_info_model.g.dart';

@freezed
abstract class InviteInfoModel with _$InviteInfoModel {
  const InviteInfoModel._();

  const factory InviteInfoModel({
    required String inviteCode,
    @TimestampConverter() required DateTime createdAt,
  }) = _InviteInfoModel;

  factory InviteInfoModel.fromJson(Map<String, dynamic> json) =>
      _$InviteInfoModelFromJson(json);

  factory InviteInfoModel.fromEntity(InviteInfo entity) {
    return InviteInfoModel(
      inviteCode: entity.inviteCode,
      createdAt: entity.createdAt,
    );
  }

  InviteInfo toEntity() {
    return InviteInfo(inviteCode: inviteCode, createdAt: createdAt);
  }

  DateTime get expiresAt => createdAt.add(const Duration(minutes: 15));
}

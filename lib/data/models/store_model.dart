import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/invite_info_model.dart';
import 'package:studio_chance/data/models/price_settings_model.dart';
import 'package:studio_chance/domain/entities/store.dart';
import 'package:studio_chance/common/converters/timestamp_converter.dart';

part 'store_model.freezed.dart';
part 'store_model.g.dart';

@freezed
abstract class StoreModel with _$StoreModel {
  const factory StoreModel({
    @JsonKey(includeToJson: false)
    required String id,
    required String ownerId,
    required String name,
    required Map<String, String> memberIds,
    required String address,
    required String memo,
    required String color,

    InviteInfoModel? inviteInfo,
    required PriceSettingsModel priceSettings,

    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,

    @JsonKey(includeIfNull: false)
    @TimestampConverter() DateTime? deletedAt,
    @JsonKey(includeIfNull: false)
    @TimestampConverter() DateTime? expiresAt,
}) = _StoreModel;

  factory StoreModel.fromJson(Map<String, dynamic> json) =>
      _$StoreModelFromJson(json);
}
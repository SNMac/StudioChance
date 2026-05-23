import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/price_settings_model.dart';
import 'package:studio_chance/domain/entities/space_option.dart';

part 'space_option_model.freezed.dart';
part 'space_option_model.g.dart';

@freezed
abstract class SpaceOptionModel with _$SpaceOptionModel {
  const SpaceOptionModel._();

  const factory SpaceOptionModel({
    required String id,
    required String name,
    required PriceSettingsModel priceSettings,
  }) = _SpaceOptionModel;

  factory SpaceOptionModel.fromJson(Map<String, dynamic> json) =>
      _$SpaceOptionModelFromJson(json);

  factory SpaceOptionModel.fromEntity(SpaceOption entity) {
    return SpaceOptionModel(
      id: entity.id,
      name: entity.name,
      priceSettings: PriceSettingsModel.fromEntity(entity.priceSetting),
    );
  }

  SpaceOption toEntity() {
    return SpaceOption(
      id: id,
      name: name,
      priceSetting: priceSettings.toEntity(),
    );
  }
}

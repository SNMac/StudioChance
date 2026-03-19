import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/day_group_model.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';

part 'price_settings_model.freezed.dart';
part 'price_settings_model.g.dart';

@freezed
abstract class PriceSettingsModel with _$PriceSettingsModel {
  const PriceSettingsModel._();

  const factory PriceSettingsModel({
    @Default([]) List<DayGroupModel> dayGroupModels,
  }) = _PriceSettingsModel;

  factory PriceSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$PriceSettingsModelFromJson(json);

  factory PriceSettingsModel.fromEntity(PriceSetting entity) {
    return PriceSettingsModel(
      dayGroupModels: entity.dayGroups
          .map((dayGroup) => DayGroupModel.fromEntity(dayGroup))
          .toList(),
    );
  }

  PriceSetting toEntity() {
    return PriceSetting(
      dayGroups: dayGroupModels
          .map((dayGroupModel) => dayGroupModel.toEntity())
          .toList(),
    );
  }
}

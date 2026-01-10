import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:studio_chance/data/models/day_group_model.dart';
import 'package:studio_chance/domain/entities/day_group.dart';
import 'package:studio_chance/domain/entities/price_setting.dart';

part 'price_settings_model.freezed.dart';
part 'price_settings_model.g.dart';

@freezed
abstract class PriceSettingsModel with _$PriceSettingsModel {
  const factory PriceSettingsModel({
    @Default([]) List<DayGroupModel> dayGroupModels,
  }) = _PriceSettingsModel;

  factory PriceSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$PriceSettingsModelFromJson(json);
}

extension PriceSettingsModelExtension on PriceSettingsModel {
  PriceSetting toEntity() {
    return PriceSetting(
      dayGroups: dayGroupModels
          .map<DayGroup>((dayGroupModel) => dayGroupModel.toEntity())
          .toList(),
    );
  }
}
